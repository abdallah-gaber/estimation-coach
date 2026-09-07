import 'dart:convert';
import 'dart:io';

import 'package:estimation_coach/core/cards/cards.dart';
import 'package:estimation_coach/scenarios/bidding_scenario.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> fixture() =>
    jsonDecode(
          File(
            'content/scenarios/v1/bidding/bid_safe_probable_001.json',
          ).readAsStringSync(),
        )
        as Map<String, dynamic>;

Map<String, dynamic> preFixture() {
  final data = fixture();
  data['bidding_phase'] = 'pre_bidding';
  data['previous_actions'] = [];
  data['allowed_decisions'] = <String, dynamic>{'dash': true, 'enter': true};
  data['evaluations'] = [];
  return data;
}

void main() {
  test(
    'parses the canonical fixture into typed content without inventing feedback',
    () {
      final scenario = BiddingScenario.fromJson(fixture());
      expect(scenario.id, 'bid_safe_probable_001');
      expect(scenario.title, 'Strong Spades, uncertain side winners');
      expect(scenario.difficulty, Difficulty.beginner);
      expect(scenario.playerPosition, PlayerSeat.south);
      expect(scenario.primarySkill, 'bid_sizing');
      expect(scenario.skills, contains('safe_vs_probable'));
      expect(scenario.hand.length, 13);
      expect(scenario.hand.contains(GameCard.parse('AS')), isTrue);
      expect(scenario.previousActions.first.action, PreviousActionKind.pass);
      expect(scenario.previousActions.last.trump, Trump.hearts);
      expect(scenario.previousActions.last.tricks, 4);
      expect(scenario.allowedDecisions.minBid, 4);
      expect(scenario.allowedDecisions.maxBid, 7);
      expect(scenario.allowedDecisions.count, 17);
      expect(scenario.evaluations, hasLength(1));
      expect(scenario.evaluations.single.rating, DecisionRating.strong);
      expect(scenario.evaluations.single.decision.tricks, 4);
      expect(scenario.evaluations.single.feedback.points, hasLength(3));
      expect(scenario.missingEvaluationCount, 16);
      expect(scenario.authorNotes, contains('Migrated to game_rules_v1'));
    },
  );

  test('copies collections and cannot be changed through decoded JSON', () {
    final data = fixture();
    final scenario = BiddingScenario.fromJson(data);
    (data['hand'] as List).clear();
    (data['skills'] as List).clear();
    (data['evaluations'][0]['feedback']['points'] as List).clear();
    expect(scenario.hand.length, 13);
    expect(scenario.skills, hasLength(3));
    expect(scenario.evaluations.single.feedback.points, hasLength(3));
    for (final list in <List>[
      scenario.skills,
      scenario.previousActions,
      scenario.allowedDecisions.trumps,
      scenario.evaluations,
      scenario.evaluations.single.feedback.points,
    ]) {
      expect(() => list.clear(), throwsUnsupportedError);
    }
  });

  test('can represent all ratings and complete legal bid coverage', () {
    final data = fixture();
    data['allowed_decisions']['trumps'] = ['spades'];
    final feedback = data['evaluations'][0]['feedback'];
    data['evaluations'] = [
      for (final (tricks, rating) in [
        (4, 'strong'),
        (5, 'reasonable'),
        (6, 'risky'),
        (7, 'weak'),
      ])
        {
          'decision': {'action': 'bid', 'tricks': tricks, 'trump': 'spades'},
          'rating': rating,
          'feedback': feedback,
        },
    ];
    final scenario = BiddingScenario.fromJson(data);
    expect(scenario.missingEvaluationCount, 0);
    expect(
      scenario.evaluations.map((e) => e.rating).toSet(),
      DecisionRating.values.toSet(),
    );
  });

  final invalid = <String, void Function(Map<String, dynamic>)>{
    'unsupported version': (d) => d['scenario_version'] = 2,
    'unsupported play scenario': (d) => d['type'] = 'play',
    'invalid difficulty': (d) => d['difficulty'] = 'expert',
    'invalid seat': (d) => d['player_position'] = 'middle',
    'missing title': (d) => d.remove('title'),
    'primary skill absent from tags': (d) => d['primary_skill'] = 'unknown',
    'duplicate skill': (d) => d['skills'].add('bid_sizing'),
    'short bidding hand': (d) => d['hand'].removeLast(),
    'duplicate card': (d) => d['hand'][1] = 'AS',
    'invalid card': (d) => d['hand'][0] = '1S',
    'malformed previous action': (d) => d['previous_actions'][0] = 'pass',
    'unsupported previous action': (d) =>
        d['previous_actions'][0]['action'] = 'play',
    'pass with bid fields': (d) => d['previous_actions'][0]['tricks'] = 3,
    'bid without trump': (d) => d['previous_actions'][1].remove('trump'),
    'inverted range': (d) => d['allowed_decisions']['bids']['min'] = 8,
    'out-of-range trick count': (d) =>
        d['allowed_decisions']['bids']['max'] = 14,
    'non-integer trick count': (d) =>
        d['allowed_decisions']['bids']['min'] = 3.5,
    'non-boolean Dash': (d) => d['allowed_decisions']['dash'] = 'true',
    'unsupported trump category': (d) =>
        d['allowed_decisions']['trumps'] = ['joker'],
    'duplicate trump': (d) => d['allowed_decisions']['trumps'].add('spades'),
    'empty trump list': (d) => d['allowed_decisions']['trumps'] = [],
    'duplicate evaluation': (d) => d['evaluations'].add(d['evaluations'][0]),
    'evaluation outside range': (d) =>
        d['evaluations'][0]['decision']['tricks'] = 8,
    'evaluation outside trumps': (d) =>
        d['allowed_decisions']['trumps'] = ['clubs'],
    'unsupported rating': (d) => d['evaluations'][0]['rating'] = 'correct',
    'missing feedback': (d) => d['evaluations'][0].remove('feedback'),
    'empty feedback text': (d) =>
        d['evaluations'][0]['feedback']['summary'] = ' ',
    'invalid evidence point': (d) =>
        d['evaluations'][0]['feedback']['points'] = [2],
    'Dash outside allowed choices': (d) {
      d['allowed_decisions']['dash'] = false;
      d['evaluations'][0]['decision'] = {'action': 'dash'};
    },
    'Dash with a trump': (d) =>
        d['evaluations'][0]['decision'] = {'action': 'dash', 'trump': 'spades'},
  };
  for (final entry in invalid.entries) {
    test('rejects ${entry.key} with a field-path error', () {
      final data = fixture();
      entry.value(data);
      expect(
        () => BiddingScenario.fromJson(data),
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

  test('rejects non-object input', () {
    for (final value in [null, 1, 'bidding', <Object>[]]) {
      expect(() => BiddingScenario.fromJson(value), throwsFormatException);
    }
  });
}
