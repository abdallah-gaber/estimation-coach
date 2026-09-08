import 'dart:convert';
import 'dart:io';

import 'package:estimation_coach/core/cards/cards.dart';
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
    'low auction bid': (d) => d['situation']['auction_bid']['tricks'] = 3,
    'null auction bid': (d) => d['situation']['auction_bid'] = null,
    'bad current card': (d) =>
        d['situation']['current_trick'][0]['card'] = '1H',
    'missing current player': (d) =>
        d['situation']['current_trick'][0].remove('player'),
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
    'wrong leader': (d) => d['situation']['leader'] = 'east',
    'already played': (d) =>
        d['situation']['current_trick'][1]['player'] = 'south',
    'count total': (d) => d['situation']['tricks_taken']['north'] = 1,
    'trump mismatch': (d) => d['situation']['auction_bid']['trump'] = 'hearts',
    'illegal evaluation': (d) => d['evaluations'][0]['decision']['card'] = 'AS',
    'duplicate evaluation': (d) => d['evaluations'].add(d['evaluations'][0]),
  };
  for (final entry in relations.entries) {
    test('domain rejects ${entry.key} after valid shape', () {
      final d = playFixture();
      entry.value(d);
      expect(schema.validate(d).isValid, isTrue);
      expect(() => PlayScenario.fromJson(d), throwsFormatException);
    });
  }
}
