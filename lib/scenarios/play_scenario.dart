import '../core/cards/cards.dart';
import '../core/game_rules/bidding.dart';
import '../core/game_rules/play_situation.dart';
import 'bidding_scenario.dart'
    show Difficulty, DecisionRating, ScenarioFeedback;

/// Portable authored content for one pending card decision. No outcome engine.
final class PlayScenario {
  const PlayScenario._(
    this.id,
    this.title,
    this.difficulty,
    this.primarySkill,
    this.skills,
    this.situation,
    this.evaluations,
    this.authorNotes,
  );

  final String id;
  final String title;
  final Difficulty difficulty;
  final String primarySkill;
  final List<String> skills;
  final PlaySituation situation;
  final List<PlayEvaluation> evaluations;
  final String? authorNotes;
  String get rulesVersion => 'game_rules_v1';
  List<GameCard> get legalChoices => situation.legalChoices;
  int get missingEvaluationCount => legalChoices.length - evaluations.length;

  factory PlayScenario.fromJson(Object? value) {
    final data = _object(value, r'$');
    if (data['scenario_version'] is! int || data['scenario_version'] != 1) {
      _fail(r'$.scenario_version', 'expected integer version 1');
    }
    if (data['type'] != 'play') _fail(r'$.type', 'expected play');
    if (data['rules_version'] != 'game_rules_v1') {
      _fail(r'$.rules_version', 'expected game_rules_v1');
    }
    for (final field in [
      'allowed_decisions',
      'previous_actions',
      'bidding_phase',
      'dash_players',
    ]) {
      if (data.containsKey(field)) {
        _fail('\$.$field', 'not a play-scenario field');
      }
    }
    final id = _text(data['id'], r'$.id');
    if (!RegExp(r'^[a-z0-9_-]+$').hasMatch(id)) {
      _fail(r'$.id', 'invalid scenario id');
    }
    final skills = _array(data['skills'], r'$.skills').indexed
        .map((entry) => _text(entry.$2, '\$.skills[${entry.$1}]'))
        .toList();
    if (skills.isEmpty || skills.toSet().length != skills.length) {
      _fail(r'$.skills', 'expected distinct nonempty skill tags');
    }
    final primary = _text(data['primary_skill'], r'$.primary_skill');
    if (!skills.contains(primary)) {
      _fail(r'$.primary_skill', 'must appear in skills');
    }
    final cards = _array(
      data['hand'],
      r'$.hand',
    ).indexed.map((entry) => _card(entry.$2, '\$.hand[${entry.$1}]')).toList();
    late final Hand hand;
    try {
      hand = Hand(cards);
    } on ArgumentError catch (error) {
      _fail(r'$.hand', '${error.message}');
    }
    final raw = _object(data['situation'], r'$.situation');
    _keys(raw, [
      'leader',
      'current_trick',
      'trump',
      'trick_estimate',
      'tricks_taken',
      'auction_bid',
      'observed_tricks',
    ], r'$.situation');
    final plays = _seatPlays(
      raw['current_trick'],
      r'$.situation.current_trick',
    );
    final history = <ObservedTrick>[];
    if (raw.containsKey('observed_tricks')) {
      final rawHistory = _array(
        raw['observed_tricks'],
        r'$.situation.observed_tricks',
      );
      for (var i = 0; i < rawHistory.length; i++) {
        final path = '\$.situation.observed_tricks[$i]';
        final trickPlays = _seatPlays(rawHistory[i], path);
        try {
          history.add(ObservedTrick(trickPlays));
        } on ArgumentError catch (error) {
          _fail(path, '${error.message}');
        }
      }
    }
    final rawTaken = _object(raw['tricks_taken'], r'$.situation.tricks_taken');
    _keys(
      rawTaken,
      PlayerSeat.values.map((s) => s.name).toList(),
      r'$.situation.tricks_taken',
    );
    final taken = {
      for (final seat in PlayerSeat.values)
        seat: _count(
          rawTaken[seat.name],
          '\$.situation.tricks_taken.${seat.name}',
        ),
    };
    Bid? bid;
    if (raw.containsKey('auction_bid')) {
      final path = r'$.situation.auction_bid';
      final b = _object(raw['auction_bid'], path);
      _keys(b, ['tricks', 'trump'], path);
      bid = Bid(
        _count(b['tricks'], '$path.tricks', min: 4),
        _trump(b['trump'], '$path.trump'),
      );
    }
    late final PlaySituation situation;
    try {
      situation = PlaySituation(
        playerPosition: _enum(
          data['player_position'],
          PlayerSeat.values,
          r'$.player_position',
        ),
        hand: hand,
        leader: _enum(raw['leader'], PlayerSeat.values, r'$.situation.leader'),
        currentTrick: plays,
        trump: _trump(raw['trump'], r'$.situation.trump'),
        trickEstimate: TrickEstimate(
          _count(raw['trick_estimate'], r'$.situation.trick_estimate'),
        ),
        tricksTaken: taken,
        auctionBid: bid,
        observedTricks: history,
      );
    } on ArgumentError catch (error) {
      _fail(r'$.situation', '${error.message}');
    }
    final evaluations = <PlayEvaluation>[];
    final seen = <GameCard>{};
    final rawEvaluations = _array(data['evaluations'], r'$.evaluations');
    for (var i = 0; i < rawEvaluations.length; i++) {
      final path = '\$.evaluations[$i]';
      final entry = _object(rawEvaluations[i], path);
      final decision = _object(entry['decision'], '$path.decision');
      _keys(decision, ['action', 'card'], '$path.decision');
      if (decision['action'] != 'play') {
        _fail('$path.decision.action', 'expected play');
      }
      final card = _card(decision['card'], '$path.decision.card');
      if (!situation.legalChoices.contains(card)) {
        _fail('$path.decision.card', 'card is not a legal choice');
      }
      if (!seen.add(card)) _fail('$path.decision.card', 'duplicate evaluation');
      evaluations.add(
        PlayEvaluation._(
          card,
          _enum(entry['rating'], DecisionRating.values, '$path.rating'),
          ScenarioFeedback.fromJson(entry['feedback'], path: '$path.feedback'),
        ),
      );
    }
    return PlayScenario._(
      id,
      _text(data['title'], r'$.title'),
      _enum(data['difficulty'], Difficulty.values, r'$.difficulty'),
      primary,
      List.unmodifiable(skills),
      situation,
      List.unmodifiable(evaluations),
      data.containsKey('author_notes')
          ? _text(data['author_notes'], r'$.author_notes')
          : null,
    );
  }

  /// Illegal choices throw; missing authored feedback remains explicitly unknown.
  PlayEvaluation? evaluate(GameCard card) {
    if (!legalChoices.contains(card)) {
      throw ArgumentError.value(card, 'card', 'Not a legal choice');
    }
    for (final evaluation in evaluations) {
      if (evaluation.card == card) return evaluation;
    }
    return null;
  }

  /// Returns a copy of this scenario with [tricksTaken] replacing the
  /// situation's taken counts, re-running the exact [PlaySituation]
  /// validation any authored scenario goes through — the fail-closed path
  /// for an invalid or unsupported map (throws [ArgumentError], same as
  /// [PlaySituation] itself). Every other field — hand, current trick,
  /// trump, estimate, auction bound, observed history, id, title,
  /// evaluations and feedback — is carried over unchanged, so callers that
  /// only vary taken counts cannot alter anything a rating or feedback
  /// string depends on. Never mutates this instance.
  ///
  /// Used by the scenario variant generator (EC-055); see
  /// `lib/scenarios/scenario_variant.dart`.
  PlayScenario withTricksTaken(Map<PlayerSeat, int> tricksTaken) {
    final rebuilt = PlaySituation(
      playerPosition: situation.playerPosition,
      hand: situation.hand,
      leader: situation.leader,
      currentTrick: situation.currentTrick,
      trump: situation.trump,
      trickEstimate: situation.trickEstimate,
      tricksTaken: tricksTaken,
      auctionBid: situation.auctionBid,
      observedTricks: situation.observedTricks,
    );
    return PlayScenario._(
      id,
      title,
      difficulty,
      primarySkill,
      skills,
      rebuilt,
      evaluations,
      authorNotes,
    );
  }
}

final class PlayEvaluation {
  const PlayEvaluation._(this.card, this.rating, this.feedback);
  final GameCard card;
  final DecisionRating rating;
  final ScenarioFeedback feedback;
}

List<SeatPlay> _seatPlays(Object? value, String path) {
  final raw = _array(value, path);
  final plays = <SeatPlay>[];
  for (var i = 0; i < raw.length; i++) {
    final entryPath = '$path[$i]';
    final play = _object(raw[i], entryPath);
    _keys(play, ['player', 'card'], entryPath);
    plays.add(
      SeatPlay(
        _enum(play['player'], PlayerSeat.values, '$entryPath.player'),
        _card(play['card'], '$entryPath.card'),
      ),
    );
  }
  return plays;
}

Never _fail(String path, String message) =>
    throw FormatException('$path: $message');
Map<String, dynamic> _object(Object? value, String path) {
  if (value is! Map<String, dynamic>) _fail(path, 'expected object');
  return value;
}

List<dynamic> _array(Object? value, String path) {
  if (value is! List) _fail(path, 'expected array');
  return value;
}

String _text(Object? value, String path) {
  if (value is! String || value.trim().isEmpty) {
    _fail(path, 'expected nonempty string');
  }
  return value;
}

void _keys(Map<String, dynamic> value, List<String> allowed, String path) {
  for (final key in value.keys) {
    if (!allowed.contains(key)) _fail('$path.$key', 'unsupported field');
  }
}

int _count(Object? value, String path, {int min = 0}) {
  if (value is! int || value < min || value > 13) {
    _fail(path, 'expected integer from $min to 13');
  }
  return value;
}

T _enum<T extends Enum>(Object? value, List<T> values, String path) {
  for (final entry in values) {
    if (entry.name == value) return entry;
  }
  _fail(path, 'unsupported value');
}

Trump _trump(Object? value, String path) {
  for (final trump in Trump.values) {
    if (trump.code == value) return trump;
  }
  _fail(path, 'unsupported trump');
}

GameCard _card(Object? value, String path) {
  try {
    return GameCard.parse(_text(value, path));
  } on FormatException {
    _fail(path, 'invalid canonical card');
  }
}
