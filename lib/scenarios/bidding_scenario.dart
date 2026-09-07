import '../core/cards/cards.dart';
import '../core/game_rules/bidding.dart';
export '../core/game_rules/bidding.dart' show PlayerSeat, BiddingPhase, Trump;

enum Difficulty { beginner, intermediate, advanced }

enum DecisionRating { strong, reasonable, risky, weak }

enum BiddingAction { dash, enter, bid }

enum PreviousActionKind { pass, dash, enter, bid }

/// Typed, immutable authored content. Parsing does not endorse coaching quality.
final class BiddingScenario {
  BiddingScenario._({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.primarySkill,
    required this.skills,
    required this.playerPosition,
    required this.hand,
    required this.previousActions,
    required this.allowedDecisions,
    required this.evaluations,
    required this.authorNotes,
    required this.biddingState,
  });

  final String id;
  final String title;
  final Difficulty difficulty;
  final String primarySkill;
  final List<String> skills;
  final PlayerSeat playerPosition;
  final Hand hand;
  final List<PreviousAction> previousActions;
  final AllowedDecisions allowedDecisions;
  final List<AuthoredEvaluation> evaluations;
  final String? authorNotes;
  final BiddingState biddingState;
  String get rulesVersion => 'game_rules_v1';

  factory BiddingScenario.fromJson(Object? value) {
    final data = _object(value, r'$');
    if (data['scenario_version'] != 1 || data['scenario_version'] is! int) {
      _fail(r'$.scenario_version', 'expected supported integer version 1');
    }
    if (data['type'] != 'bidding') {
      _fail(r'$.type', 'only bidding scenarios are supported');
    }
    final id = _text(data['id'], r'$.id');
    if (!RegExp(r'^[a-z0-9_-]+$').hasMatch(id)) {
      _fail(r'$.id', 'use lowercase letters, digits, underscore or hyphen');
    }
    final skills = _texts(data['skills'], r'$.skills');
    if (skills.isEmpty || skills.toSet().length != skills.length) {
      _fail(r'$.skills', 'expected distinct nonempty skill tags');
    }
    final primary = _text(data['primary_skill'], r'$.primary_skill');
    if (!skills.contains(primary)) {
      _fail(r'$.primary_skill', 'must also appear in skills');
    }
    final rawHand = _array(data['hand'], r'$.hand');
    if (rawHand.length != 13) _fail(r'$.hand', 'bidding requires 13 cards');
    final cards = <GameCard>[];
    for (var i = 0; i < rawHand.length; i++) {
      try {
        cards.add(GameCard.parse(_text(rawHand[i], '\$.hand[$i]')));
      } on FormatException {
        _fail('\$.hand[$i]', 'invalid canonical card notation');
      }
    }
    if (cards.toSet().length != cards.length) {
      _fail(r'$.hand', 'duplicate card');
    }
    if (data['rules_version'] != 'game_rules_v1') {
      _fail(
        r'$.rules_version',
        'expected game_rules_v1; migrate legacy content',
      );
    }
    final phase = switch (data['bidding_phase']) {
      'pre_bidding' => BiddingPhase.preBidding,
      'normal' => BiddingPhase.normal,
      _ => _fail(r'$.bidding_phase', 'expected pre_bidding or normal'),
    };
    final player = _enum(
      data['player_position'],
      PlayerSeat.values,
      r'$.player_position',
    );
    var state = BiddingState.start();
    for (final value in _array(data['dash_players'], r'$.dash_players')) {
      final seat = _enum(value, PlayerSeat.values, r'$.dash_players');
      if (state.dashPlayers.contains(seat)) {
        _fail(r'$.dash_players', 'duplicate Dash player');
      }
      state = state.declareDash(seat);
    }
    if (phase == BiddingPhase.normal) state = state.startNormalBidding();
    final rawPrevious = _array(data['previous_actions'], r'$.previous_actions');
    final previous = <PreviousAction>[];
    final preDecisions = <PlayerSeat>{...state.dashPlayers};
    for (var i = 0; i < rawPrevious.length; i++) {
      final path = '\$.previous_actions[$i]';
      final action = PreviousAction._parse(rawPrevious[i], path);
      if (phase == BiddingPhase.preBidding) {
        if (action.action != PreviousActionKind.dash &&
            action.action != PreviousActionKind.enter) {
          _fail(path, 'only Dash/enter decisions belong before normal bidding');
        }
        if (!preDecisions.add(action.player)) {
          _fail(path, 'player already made a pre-bidding decision');
        }
        if (action.action == PreviousActionKind.dash) {
          state = state.declareDash(action.player);
        }
      } else {
        if (state.dashPlayers.contains(action.player)) {
          _fail(path, 'Dash players cannot participate in normal bidding');
        }
        if (action.action == PreviousActionKind.bid) {
          final bid = Bid(action.tricks!, action.trump!);
          if (!state.canBid(action.player, bid)) {
            _fail(path, 'bid must outrank the previous bid');
          }
          state = state.placeBid(action.player, bid);
        } else if (action.action != PreviousActionKind.pass) {
          _fail(path, 'Dash/enter decisions must occur before normal bidding');
        }
      }
      previous.add(action);
    }
    if (state.dashPlayers.contains(player) ||
        (phase == BiddingPhase.preBidding && preDecisions.contains(player))) {
      _fail(
        r'$.player_position',
        'player cannot make another decision in this phase',
      );
    }
    final allowed = AllowedDecisions._parse(
      data['allowed_decisions'],
      state,
      player,
    );
    final rawEvaluations = _array(data['evaluations'], r'$.evaluations');
    final evaluations = <AuthoredEvaluation>[];
    final seen = <BiddingDecision>{};
    for (var i = 0; i < rawEvaluations.length; i++) {
      final path = '\$.evaluations[$i]';
      final evaluation = AuthoredEvaluation._parse(rawEvaluations[i], path);
      if (!allowed.contains(evaluation.decision)) {
        _fail('$path.decision', 'decision is outside allowed_decisions');
      }
      if (!seen.add(evaluation.decision)) {
        _fail('$path.decision', 'duplicate evaluation for this decision');
      }
      evaluations.add(evaluation);
    }
    return BiddingScenario._(
      id: id,
      title: _text(data['title'], r'$.title'),
      difficulty: _enum(data['difficulty'], Difficulty.values, r'$.difficulty'),
      primarySkill: primary,
      skills: skills,
      playerPosition: _enum(
        data['player_position'],
        PlayerSeat.values,
        r'$.player_position',
      ),
      hand: Hand(cards),
      previousActions: List.unmodifiable(previous),
      biddingState: state,
      allowedDecisions: allowed,
      evaluations: List.unmodifiable(evaluations),
      authorNotes: data.containsKey('author_notes')
          ? _text(data['author_notes'], r'$.author_notes')
          : null,
    );
  }

  /// Missing authored feedback is coverage information, never an inferred rating.
  int get missingEvaluationCount => allowedDecisions.count - evaluations.length;
}

final class BiddingDecision {
  const BiddingDecision._(this.action, this.tricks, this.trump);
  final BiddingAction action;
  final int? tricks;
  final Trump? trump;

  factory BiddingDecision._parse(Object? value, String path) {
    final data = _object(value, path);
    final action = _enum(data['action'], BiddingAction.values, '$path.action');
    if (action != BiddingAction.bid) {
      _noBidFields(data, path);
      return BiddingDecision._(action, null, null);
    }
    return BiddingDecision._(
      action,
      _tricks(data['tricks'], '$path.tricks'),
      _trump(data['trump'], '$path.trump'),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BiddingDecision &&
      action == other.action &&
      tricks == other.tricks &&
      trump == other.trump;
  @override
  int get hashCode => Object.hash(action, tricks, trump);
}

final class AllowedDecisions {
  const AllowedDecisions._(
    this.dash,
    this.enter,
    this.minBid,
    this.maxBid,
    this.trumps,
    this.choices,
  );
  final bool dash;
  final bool enter;
  final int? minBid;
  final int? maxBid;
  final List<Trump> trumps;
  final List<BiddingDecision> choices;

  factory AllowedDecisions._parse(
    Object? value,
    BiddingState state,
    PlayerSeat player,
  ) {
    const path = r'$.allowed_decisions';
    final data = _object(value, path);
    if (data['dash'] is! bool) _fail('$path.dash', 'expected boolean');
    if (state.phase == BiddingPhase.preBidding) {
      if (data['enter'] is! bool) _fail('$path.enter', 'expected boolean');
      if (data.containsKey('bids') || data.containsKey('trumps')) {
        _fail(path, 'pre-bidding has no trick or trump choices');
      }
      final choices = [
        if (data['dash'] == true)
          const BiddingDecision._(BiddingAction.dash, null, null),
        if (data['enter'] == true)
          const BiddingDecision._(BiddingAction.enter, null, null),
      ];
      if (choices.isEmpty) {
        _fail(path, 'at least one participation choice is required');
      }
      return AllowedDecisions._(
        data['dash'] as bool,
        data['enter'] as bool,
        null,
        null,
        const [],
        List.unmodifiable(choices),
      );
    }
    if (data['dash'] != false ||
        (data.containsKey('enter') && data['enter'] != false)) {
      _fail(path, 'Dash/enter are unavailable during normal bidding');
    }
    final bids = _object(data['bids'], '$path.bids');
    final min = _tricks(bids['min'], '$path.bids.min');
    final max = _tricks(bids['max'], '$path.bids.max');
    if (min > max) _fail('$path.bids', 'min must not exceed max');
    final rawTrumps = _array(data['trumps'], '$path.trumps');
    final trumps = [
      for (var i = 0; i < rawTrumps.length; i++)
        _trump(rawTrumps[i], '$path.trumps[$i]'),
    ];
    if (trumps.isEmpty || trumps.toSet().length != trumps.length) {
      _fail('$path.trumps', 'expected distinct supported trump categories');
    }
    final choices = [
      for (var count = min; count <= max; count++)
        for (final trump in trumps)
          if (state.canBid(player, Bid(count, trump)))
            BiddingDecision._(BiddingAction.bid, count, trump),
    ];
    if (choices.isEmpty) _fail(path, 'bounds contain no legal raises');
    return AllowedDecisions._(
      false,
      false,
      min,
      max,
      List.unmodifiable(trumps),
      List.unmodifiable(choices),
    );
  }

  int get count => choices.length;
  bool contains(BiddingDecision decision) => choices.contains(decision);
}

final class PreviousAction {
  const PreviousAction._(this.player, this.action, this.tricks, this.trump);
  final PlayerSeat player;
  final PreviousActionKind action;
  final int? tricks;
  final Trump? trump;

  factory PreviousAction._parse(Object? value, String path) {
    final data = _object(value, path);
    final player = _enum(data['player'], PlayerSeat.values, '$path.player');
    final action = _enum(
      data['action'],
      PreviousActionKind.values,
      '$path.action',
    );
    if (action != PreviousActionKind.bid) {
      _noBidFields(data, path);
      return PreviousAction._(player, action, null, null);
    }
    return PreviousAction._(
      player,
      action,
      _tricks(data['tricks'], '$path.tricks'),
      _trump(data['trump'], '$path.trump'),
    );
  }
}

final class AuthoredEvaluation {
  const AuthoredEvaluation._(this.decision, this.rating, this.feedback);
  final BiddingDecision decision;
  final DecisionRating rating;
  final ScenarioFeedback feedback;

  factory AuthoredEvaluation._parse(Object? value, String path) {
    final data = _object(value, path);
    return AuthoredEvaluation._(
      BiddingDecision._parse(data['decision'], '$path.decision'),
      _enum(data['rating'], DecisionRating.values, '$path.rating'),
      ScenarioFeedback._parse(data['feedback'], '$path.feedback'),
    );
  }
}

final class ScenarioFeedback {
  const ScenarioFeedback._(this.title, this.summary, this.points);
  final String title;
  final String summary;
  final List<String> points;

  factory ScenarioFeedback._parse(Object? value, String path) {
    final data = _object(value, path);
    return ScenarioFeedback._(
      _text(data['title'], '$path.title'),
      _text(data['summary'], '$path.summary'),
      _texts(data['points'], '$path.points'),
    );
  }
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

List<String> _texts(Object? value, String path) {
  final values = _array(value, path);
  return List.unmodifiable([
    for (var i = 0; i < values.length; i++) _text(values[i], '$path[$i]'),
  ]);
}

T _enum<T extends Enum>(Object? value, List<T> values, String path) {
  for (final option in values) {
    if (option.name == value) return option;
  }
  _fail(
    path,
    'expected one of ${values.map((value) => value.name).join(', ')}',
  );
}

int _tricks(Object? value, String path) {
  if (value is! int || value < 4 || value > 13) {
    _fail(path, 'expected integer from 4 to 13');
  }
  return value;
}

void _noBidFields(Map<String, dynamic> data, String path) {
  if (data.containsKey('tricks') || data.containsKey('trump')) {
    _fail(path, 'non-bid action must not carry tricks or trump');
  }
}

Trump _trump(Object? value, String path) {
  for (final trump in Trump.values) {
    if (trump.code == value) return trump;
  }
  _fail(path, 'expected clubs, diamonds, hearts, spades or no_trump');
}
