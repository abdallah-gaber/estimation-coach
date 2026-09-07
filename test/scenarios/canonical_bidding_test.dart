import 'dart:io';

import 'package:estimation_coach/scenarios/bidding_scenario.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_schema/json_schema.dart';

import 'bidding_scenario_test.dart' show fixture, preFixture;

void main() {
  final schema = JsonSchema.create(
    File('schemas/scenario.v1.schema.json').readAsStringSync(),
  );

  test('normal fixture filters non-raises and counts only legal choices', () {
    final data = fixture();
    expect(schema.validate(data).isValid, isTrue);
    final scenario = BiddingScenario.fromJson(data);
    expect(scenario.rulesVersion, 'game_rules_v1');
    expect(scenario.biddingState.phase, BiddingPhase.normal);
    final four = scenario.allowedDecisions.choices.where((c) => c.tricks == 4);
    expect(four.map((c) => c.trump), [Trump.spades, Trump.noTrump]);
    expect(scenario.allowedDecisions.count, 17);
    expect(scenario.missingEvaluationCount, 16);
    expect(
      scenario.allowedDecisions.choices.every(
        (c) => c.action == BiddingAction.bid,
      ),
      isTrue,
    );
    expect(
      () => scenario.allowedDecisions.choices.clear(),
      throwsUnsupportedError,
    );
  });

  test('pre-bidding offers Dash/enter, with no normal bids', () {
    final data = preFixture();
    data['previous_actions'] = [
      {'player': 'west', 'action': 'dash'},
    ];
    expect(schema.validate(data).isValid, isTrue);
    final scenario = BiddingScenario.fromJson(data);
    expect(scenario.biddingState.fixedEstimate(PlayerSeat.west), 0);
    expect(scenario.allowedDecisions.choices.map((c) => c.action), [
      BiddingAction.dash,
      BiddingAction.enter,
    ]);
    expect(scenario.allowedDecisions.minBid, isNull);
    expect(scenario.allowedDecisions.trumps, isEmpty);
    expect(scenario.missingEvaluationCount, 2);
  });

  test('pre-bidding can carry authored Dash and enter feedback', () {
    final data = preFixture();
    data['evaluations'] = [
      for (final action in ['dash', 'enter'])
        {
          'decision': {'action': action},
          'rating': 'reasonable',
          'feedback': fixture()['evaluations'][0]['feedback'],
        },
    ];
    expect(schema.validate(data).isValid, isTrue);
    expect(BiddingScenario.fromJson(data).missingEvaluationCount, 0);
  });

  test('Sans is accepted in previous bids and evaluations', () {
    final data = fixture();
    data['previous_actions'][1]['trump'] = 'spades';
    data['evaluations'][0]['decision']['trump'] = 'no_trump';
    expect(schema.validate(data).isValid, isTrue);
    expect(
      BiddingScenario.fromJson(data).evaluations.single.decision.trump,
      Trump.noTrump,
    );
    data['previous_actions'][1]['trump'] = 'no_trump';
    data['evaluations'][0]['decision']['tricks'] = 5;
    expect(
      BiddingScenario.fromJson(data).biddingState.currentBid!.trump,
      Trump.noTrump,
    );
  });

  final invalidNormal = <String, void Function(Map<String, dynamic>)>{
    'legacy rules missing': (d) => d.remove('rules_version'),
    'unsupported rule version': (d) => d['rules_version'] = 'special_rounds',
    'phase missing': (d) => d.remove('bidding_phase'),
    'fixed-trump phase': (d) => d['bidding_phase'] = 'fixed_trump',
    'minimum below four': (d) => d['allowed_decisions']['bids']['min'] = 3,
    'old three-trick prior bid': (d) => d['previous_actions'][1]['tricks'] = 3,
    'late Dash choice': (d) => d['allowed_decisions']['dash'] = true,
    'late Dash action': (d) => d['previous_actions'] = [
      {'player': 'west', 'action': 'dash'},
    ],
    'late enter action': (d) => d['previous_actions'] = [
      {'player': 'west', 'action': 'enter'},
    ],
    'Dash player is current bidder': (d) => d['dash_players'] = ['south'],
    'Dash player bid in history': (d) => d['dash_players'] = ['north'],
    'Dash player passed in history': (d) => d['dash_players'] = ['west'],
    'duplicate Dash player': (d) => d['dash_players'] = ['east', 'east'],
    'equal bid in history': (d) => d['previous_actions'].add({
      'player': 'east',
      'action': 'bid',
      'tricks': 4,
      'trump': 'hearts',
    }),
    'lower bid in history': (d) => d['previous_actions'].add({
      'player': 'east',
      'action': 'bid',
      'tricks': 4,
      'trump': 'clubs',
    }),
    'evaluation of filtered-out bid': (d) =>
        d['evaluations'][0]['decision']['trump'] = 'hearts',
    'no legal raises in bounds': (d) {
      d['previous_actions'][1]['tricks'] = 13;
      d['previous_actions'][1]['trump'] = 'no_trump';
    },
  };
  for (final entry in invalidNormal.entries) {
    test('canonical normal bidding rejects ${entry.key}', () {
      final data = fixture();
      entry.value(data);
      expect(() => BiddingScenario.fromJson(data), throwsFormatException);
    });
  }

  final invalidPre = <String, void Function(Map<String, dynamic>)>{
    'trump selection before bidding': (d) =>
        d['allowed_decisions']['trumps'] = ['spades'],
    'normal bid in history': (d) => d['previous_actions'] = [
      {'player': 'west', 'action': 'bid', 'tricks': 4, 'trump': 'spades'},
    ],
    'pass used in place of enter': (d) => d['previous_actions'] = [
      {'player': 'west', 'action': 'pass'},
    ],
    'repeated participation': (d) => d['previous_actions'] = [
      {'player': 'west', 'action': 'enter'},
      {'player': 'west', 'action': 'dash'},
    ],
    'player already entered': (d) => d['previous_actions'] = [
      {'player': 'south', 'action': 'enter'},
    ],
    'player already dashed': (d) => d['dash_players'] = ['south'],
    'no choices': (d) =>
        d['allowed_decisions'] = {'dash': false, 'enter': false},
  };
  for (final entry in invalidPre.entries) {
    test('pre-bidding rejects ${entry.key}', () {
      final data = preFixture();
      entry.value(data);
      expect(() => BiddingScenario.fromJson(data), throwsFormatException);
    });
  }
}
