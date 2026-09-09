import 'dart:convert';
import 'dart:io';

import 'package:estimation_coach/core/cards/cards.dart';
import 'package:estimation_coach/core/game_rules/play_situation.dart'
    show TrickEstimate;
import 'package:estimation_coach/core/game_rules/trick_winner.dart';
import 'package:estimation_coach/core/game_rules/void_tracking.dart';
import 'package:estimation_coach/scenarios/bidding_scenario.dart';
import 'package:estimation_coach/scenarios/play_scenario.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_schema/json_schema.dart';

Map<String, dynamic> playFixture() =>
    jsonDecode(File('test/fixtures/play_contract.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  final schema = JsonSchema.create(
    File('schemas/scenario.v1.schema.json').readAsStringSync(),
  );
  void accepted(Map<String, dynamic> d) {
    final result = schema.validate(d);
    expect(result.isValid, isTrue, reason: result.errors.toString());
    expect(() => PlayScenario.fromJson(d), returnsNormally);
  }

  test(
    'complete fixture passes both contracts and keeps estimates separate',
    () {
      final d = playFixture();
      accepted(d);
      final s = PlayScenario.fromJson(d);
      expect(s.id, 'play_contract_fixture');
      expect(s.situation.trickEstimate.tricks, 1);
      expect(s.situation.auctionBid!.tricks, 4);
      expect(s.situation.playerTricksTaken, 3);
      expect(s.legalChoices.map((c) => c.notation), ['3H', '9H']);
      expect(s.missingEvaluationCount, 0);
    },
  );
  test('zero estimate and Sans without a known auction bid are supported', () {
    final d = playFixture();
    d['situation']['trump'] = 'no_trump';
    d['situation']['trick_estimate'] = 0;
    d['situation'].remove('auction_bid');
    accepted(d);
    expect(PlayScenario.fromJson(d).situation.auctionBid, isNull);
  });
  test('leading and void choices need coverage for every held card', () {
    for (final leading in [true, false]) {
      final d = playFixture();
      d['evaluations'] = [];
      if (leading) {
        d['situation']['current_trick'] = [];
        d['situation']['leader'] = 'south';
      } else {
        d['hand'] = ['3D', '9D', 'AS', '2C'];
      }
      accepted(d);
      expect(PlayScenario.fromJson(d).missingEvaluationCount, 4);
    }
  });
  test(
    'auction bound allows low/equal estimates and absent auction context',
    () {
      for (final estimate in [0, 1, 3, 4]) {
        final data = playFixture();
        data['situation']['trick_estimate'] = estimate;
        accepted(data);
      }
      final data = playFixture();
      data['situation']['trick_estimate'] = 13;
      data['situation'].remove('auction_bid');
      accepted(data);
      data['situation']['auction_bid'] = {'tricks': 13, 'trump': 'spades'};
      accepted(data);
    },
  );
  test('estimate above supplied auction bid reports the snapshot path', () {
    final data = playFixture();
    data['situation']['trick_estimate'] = 5;
    expect(schema.validate(data).isValid, isTrue);
    expect(
      () => PlayScenario.fromJson(data),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          r'$.situation: Trick estimate must not exceed the known winning auction bid',
        ),
      ),
    );
  });
  test('lookup never invents feedback or grades an illegal card', () {
    final d = playFixture();
    d['evaluations'].removeLast();
    final s = PlayScenario.fromJson(d);
    expect(s.evaluate(GameCard.parse('3H')), same(s.evaluations.single));
    expect(s.evaluate(GameCard.parse('9H')), isNull);
    expect(s.missingEvaluationCount, 1);
    expect(() => s.evaluate(GameCard.parse('AS')), throwsArgumentError);
    expect(() => s.evaluate(GameCard.parse('AH')), throwsArgumentError);
  });
  test('observed_tricks is optional and parses into ObservedTrick history', () {
    final d = playFixture();
    expect(PlayScenario.fromJson(d).situation.observedTricks, isEmpty);
    d['situation']['observed_tricks'] = [
      [
        {'player': 'west', 'card': '8D'},
        {'player': 'south', 'card': 'JD'},
        {'player': 'east', 'card': '4D'},
        {'player': 'north', 'card': '9D'},
      ],
    ];
    accepted(d);
    final history = PlayScenario.fromJson(d).situation.observedTricks;
    expect(history, hasLength(1));
    expect(history.single.plays.map((p) => p.card.notation), [
      '8D',
      'JD',
      '4D',
      '9D',
    ]);
  });
  test('opponent_estimates is optional and round-trips a partial or full '
      'seat-keyed map, never duplicating South', () {
    final d = playFixture();
    expect(PlayScenario.fromJson(d).situation.opponentEstimates, isEmpty);
    d['situation']['opponent_estimates'] = {'north': 2};
    accepted(d);
    expect(PlayScenario.fromJson(d).situation.opponentEstimates, {
      PlayerSeat.north: TrickEstimate(2),
    });
    d['situation']['opponent_estimates'] = {'north': 2, 'east': 3, 'west': 3};
    accepted(d);
    final full = PlayScenario.fromJson(d).situation.opponentEstimates;
    expect(full, {
      PlayerSeat.north: TrickEstimate(2),
      PlayerSeat.east: TrickEstimate(3),
      PlayerSeat.west: TrickEstimate(3),
    });
    expect(full.containsKey(PlayerSeat.south), isFalse);
  });
  test('all four ratings use authored feedback', () {
    for (final rating in DecisionRating.values) {
      final d = playFixture();
      d['evaluations'][0]['rating'] = rating.name;
      accepted(d);
      expect(PlayScenario.fromJson(d).evaluations.first.rating, rating);
    }
  });
  test('content and returned collections cannot be mutated', () {
    final d = playFixture();
    final s = PlayScenario.fromJson(d);
    d['hand'].clear();
    d['skills'].clear();
    d['situation']['current_trick'].clear();
    d['evaluations'][0]['feedback']['points'].clear();
    expect(s.situation.hand.length, 4);
    expect(s.skills, hasLength(1));
    expect(s.situation.currentTrick, hasLength(3));
    expect(s.evaluations.first.feedback.points, hasLength(1));
    for (final list in <List>[
      s.skills,
      s.evaluations,
      s.evaluations.first.feedback.points,
    ]) {
      expect(() => list.clear(), throwsUnsupportedError);
    }
  });
  final shapes = <String, void Function(Map<String, dynamic>)>{
    'missing title': (d) => d.remove('title'),
    'blank title': (d) => d['title'] = ' ',
    'version': (d) => d['scenario_version'] = 2,
    'rules': (d) => d['rules_version'] = 'other',
    'bad seat': (d) => d['player_position'] = 'center',
    'empty skills': (d) => d['skills'] = [],
    'duplicate skills': (d) => d['skills'] = ['card_tracking', 'card_tracking'],
    'bad id': (d) => d['id'] = 'BAD ID',
    'bad difficulty': (d) => d['difficulty'] = 'expert',
    'bad hand notation': (d) => d['hand'][0] = '3h',
    'duplicate hand': (d) => d['hand'][1] = '3H',
    'empty hand': (d) => d['hand'] = [],
    'missing situation': (d) => d.remove('situation'),
    'negative estimate': (d) => d['situation']['trick_estimate'] = -1,
    'large estimate': (d) => d['situation']['trick_estimate'] = 14,
    'fractional estimate': (d) => d['situation']['trick_estimate'] = 1.5,
    'unknown trump': (d) => d['situation']['trump'] = 'joker',
    'negative taken': (d) => d['situation']['tricks_taken']['south'] = -1,
    'missing taken seat': (d) => d['situation']['tricks_taken'].remove('north'),
    'unknown situation key': (d) => d['situation']['bid'] = 4,
    'opponent estimate south key': (d) =>
        d['situation']['opponent_estimates'] = {'south': 2},
    'opponent estimate unknown seat': (d) =>
        d['situation']['opponent_estimates'] = {'center': 2},
    'opponent estimate value above 13': (d) =>
        d['situation']['opponent_estimates'] = {'north': 14},
    'opponent estimate fractional value': (d) =>
        d['situation']['opponent_estimates'] = {'north': 1.5},
    'low auction bid': (d) => d['situation']['auction_bid']['tricks'] = 3,
    'null auction bid': (d) => d['situation']['auction_bid'] = null,
    'bad current card': (d) =>
        d['situation']['current_trick'][0]['card'] = '1H',
    'missing current player': (d) =>
        d['situation']['current_trick'][0].remove('player'),
    'short observed trick': (d) => d['situation']['observed_tricks'] = [
      [
        {'player': 'west', 'card': '8D'},
        {'player': 'north', 'card': 'JD'},
        {'player': 'east', 'card': '4D'},
      ],
    ],
    'unknown action': (d) => d['evaluations'][0]['decision']['action'] = 'bid',
    'unknown rating': (d) => d['evaluations'][0]['rating'] = 'correct',
    'missing feedback': (d) => d['evaluations'][0].remove('feedback'),
    'blank evidence': (d) => d['evaluations'][0]['feedback']['points'] = [' '],
    'bid field in decision': (d) =>
        d['evaluations'][0]['decision']['tricks'] = 4,
    'authored allowed decisions': (d) => d['allowed_decisions'] = {},
    'bidding history': (d) => d['previous_actions'] = [],
    'bidding phase': (d) => d['bidding_phase'] = 'normal',
    'Dash metadata': (d) => d['dash_players'] = [],
  };
  for (final entry in shapes.entries) {
    test('schema and parser reject ${entry.key}', () {
      final d = playFixture();
      entry.value(d);
      expect(schema.validate(d).isValid, isFalse);
      expect(
        () => PlayScenario.fromJson(d),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'path',
            startsWith(r'$.'),
          ),
        ),
      );
    });
  }
  final relations = <String, void Function(Map<String, dynamic>)>{
    'primary missing from skills': (d) => d['primary_skill'] = 'other',
    'duplicate current seat': (d) =>
        d['situation']['current_trick'][1]['player'] = 'west',
    'duplicate visible card': (d) =>
        d['situation']['current_trick'][1]['card'] = '7H',
    'public card in hand': (d) =>
        d['situation']['current_trick'][0]['card'] = '3H',
    'wrong leader': (d) => d['situation']['leader'] = 'north',
    'already played': (d) =>
        d['situation']['current_trick'][1]['player'] = 'south',
    'count total': (d) => d['situation']['tricks_taken']['north'] = 1,
    'trump mismatch': (d) => d['situation']['auction_bid']['trump'] = 'hearts',
    'complete opponent estimates total 13 with South': (d) =>
        d['situation']['opponent_estimates'] = {
          'north': 4,
          'east': 4,
          'west': 4,
        },
    'illegal evaluation': (d) => d['evaluations'][0]['decision']['card'] = 'AS',
    'duplicate evaluation': (d) => d['evaluations'].add(d['evaluations'][0]),
    'observed trick duplicate seat': (d) =>
        d['situation']['observed_tricks'] = [
          [
            {'player': 'west', 'card': '8D'},
            {'player': 'west', 'card': 'JD'},
            {'player': 'east', 'card': '4D'},
            {'player': 'south', 'card': '9D'},
          ],
        ],
    'observed card shared with hand': (d) =>
        d['situation']['observed_tricks'] = [
          [
            {'player': 'west', 'card': '8D'},
            {'player': 'south', 'card': 'JD'},
            {'player': 'east', 'card': '4D'},
            {'player': 'north', 'card': '3H'},
          ],
        ],
    'more observed tricks than completed': (d) {
      d['situation']['tricks_taken'] = {
        'north': 0,
        'east': 0,
        'south': 0,
        'west': 0,
      };
      d['hand'] = [
        '3H',
        '9H',
        'AS',
        '2C',
        '4H',
        '5H',
        '6H',
        '8H',
        '10H',
        'JH',
        'QH',
        'KH',
        'AH',
      ];
      d['situation']['leader'] = 'south';
      d['situation']['current_trick'] = [];
      d['situation']['observed_tricks'] = [
        [
          {'player': 'west', 'card': '8D'},
          {'player': 'south', 'card': 'JD'},
          {'player': 'east', 'card': '4D'},
          {'player': 'north', 'card': '9D'},
        ],
      ];
    },
  };
  for (final entry in relations.entries) {
    test('domain rejects ${entry.key} after valid shape', () {
      final d = playFixture();
      entry.value(d);
      expect(schema.validate(d).isValid, isTrue);
      expect(() => PlayScenario.fromJson(d), throwsFormatException);
    });
  }

  test(
    'bundled void-tracking scenarios derive the seat/suit their coaching relies on',
    () {
      final expectedVoids = {
        'play_void_tracking_001': (PlayerSeat.east, Suit.diamonds),
        'play_void_tracking_002': (PlayerSeat.east, Suit.hearts),
        'play_void_tracking_003': (PlayerSeat.east, Suit.clubs),
      };
      for (final entry in expectedVoids.entries) {
        final data = jsonDecode(
          File(
            'content/scenarios/v1/play/${entry.key}.json',
          ).readAsStringSync(),
        );
        final scenario = PlayScenario.fromJson(data);
        final (seat, suit) = entry.value;
        expect(
          knownVoidSuits(
            seat: seat,
            observedTricks: scenario.situation.observedTricks,
            currentTrick: scenario.situation.currentTrick,
          ),
          {suit},
          reason: '${entry.key} coaching depends on this derived void',
        );
      }
    },
  );

  test(
    'play_void_tracking_001 requires the observed void to justify its rating',
    () {
      final data = jsonDecode(
        File(
          'content/scenarios/v1/play/play_void_tracking_001.json',
        ).readAsStringSync(),
      );
      final scenario = PlayScenario.fromJson(data);
      final withoutHistory = PlayScenario.fromJson(
        (jsonDecode(jsonEncode(data)) as Map<String, dynamic>)
          ..['situation'].remove('observed_tricks'),
      );
      expect(
        knownVoidSuits(
          seat: PlayerSeat.east,
          observedTricks: scenario.situation.observedTricks,
          currentTrick: scenario.situation.currentTrick,
        ),
        {Suit.diamonds},
      );
      expect(
        knownVoidSuits(
          seat: PlayerSeat.east,
          observedTricks: withoutHistory.situation.observedTricks,
          currentTrick: withoutHistory.situation.currentTrick,
        ),
        isEmpty,
        reason:
            'without the observed trick, nothing in this situation reveals '
            "East's void — the rating genuinely depends on the shown history, "
            'not on decorative evidence',
      );
      expect(
        scenario.evaluate(GameCard.parse('3D'))!.rating,
        DecisionRating.strong,
      );
      expect(
        scenario.evaluate(GameCard.parse('KD'))!.rating,
        DecisionRating.risky,
      );
    },
  );

  test('play_void_tracking_005 authors South as its empty-trick leader '
      'consistently with who actually wins its shown prior trick', () {
    // This scenario intends its one observed trick as the immediately
    // previous one — the whole point is "you just won this, now lead" —
    // so, unlike PlaySituation's general contract (which does not assume
    // observedTricks is contiguous; see docs/DECISIONS.md D-025), this
    // specific file's own authored intent lets trickWinner double-check
    // it directly.
    final scenario = PlayScenario.fromJson(
      jsonDecode(
        File(
          'content/scenarios/v1/play/play_void_tracking_005.json',
        ).readAsStringSync(),
      ),
    );
    final situation = scenario.situation;
    expect(situation.currentTrick, isEmpty, reason: 'South is leading');
    expect(situation.observedTricks, hasLength(1));
    expect(
      trickWinner(situation.observedTricks.single, situation.trump),
      PlayerSeat.south,
      reason:
          'the observed trick must be legitimately won by South for '
          'South to be a consistent leader of the next, empty trick',
    );
    expect(situation.leader, PlayerSeat.south);
  });
}
