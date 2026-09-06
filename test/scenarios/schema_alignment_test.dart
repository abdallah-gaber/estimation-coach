import 'dart:convert';
import 'dart:io';

import 'package:estimation_coach/scenarios/bidding_scenario.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_schema/json_schema.dart';

import 'bidding_scenario_test.dart' show fixture;

void main() {
  final schema = JsonSchema.create(
    File('schemas/scenario.v1.schema.json').readAsStringSync(),
  );

  void expectAccepted(Map<String, dynamic> data) {
    final result = schema.validate(data);
    expect(result.isValid, isTrue, reason: result.errors.toString());
    expect(() => BiddingScenario.fromJson(data), returnsNormally);
  }

  test('canonical draft still passes schema and parser', () {
    expectAccepted(fixture());
  });

  test('Dash decisions and previous Dash/pass actions omit bid fields', () {
    final data = fixture();
    data['previous_actions'] = [
      {'player': 'north', 'action': 'dash'},
      {'player': 'west', 'action': 'pass'},
    ];
    data['evaluations'][0]['decision'] = {'action': 'dash'};
    data['evaluations'][0]['rating'] = 'reasonable';
    data['evaluations'][0]['feedback']['points'] = [];
    expectAccepted(data);
  });

  test(
    'additional properties remain permitted without defining new behavior',
    () {
      final data = fixture()..['external_author_id'] = 'local-test';
      data['evaluations'][0]['external_note'] = 'ignored';
      expectAccepted(data);
    },
  );

  test(
    'empty draft evaluations remain valid, with coverage reported separately',
    () {
      final data = fixture()..['evaluations'] = [];
      expectAccepted(data);
      expect(BiddingScenario.fromJson(data).missingEvaluationCount, 21);
    },
  );

  final malformed = <String, void Function(Map<String, dynamic>)>{
    'missing bidding title': (d) => d.remove('title'),
    'missing bidding seat': (d) => d.remove('player_position'),
    'missing bidding hand': (d) => d.remove('hand'),
    'short hand': (d) => d['hand'].removeLast(),
    'long hand': (d) => d['hand'].add('2H'),
    'missing previous actions': (d) => d.remove('previous_actions'),
    'missing allowed choices': (d) => d.remove('allowed_decisions'),
    'missing evaluations': (d) => d.remove('evaluations'),
    'blank title': (d) => d['title'] = ' \n\t',
    'blank skill': (d) => d['skills'][0] = ' ',
    'blank author notes': (d) => d['author_notes'] = '',
    'invalid id characters': (d) => d['id'] = r'bad\id',
    'non-object prior action': (d) => d['previous_actions'][0] = 'pass',
    'unknown prior action': (d) => d['previous_actions'][0]['action'] = 'play',
    'missing prior seat': (d) => d['previous_actions'][0].remove('player'),
    'bid missing trump': (d) => d['previous_actions'][1].remove('trump'),
    'pass carrying tricks': (d) => d['previous_actions'][0]['tricks'] = 3,
    'pass carrying null trump': (d) => d['previous_actions'][0]['trump'] = null,
    'invalid Dash flag': (d) => d['allowed_decisions']['dash'] = 1,
    'missing bid range': (d) => d['allowed_decisions'].remove('bids'),
    'missing range endpoint': (d) =>
        d['allowed_decisions']['bids'].remove('max'),
    'fractional tricks': (d) => d['allowed_decisions']['bids']['min'] = 3.5,
    'too many tricks': (d) => d['allowed_decisions']['bids']['max'] = 14,
    'empty trumps': (d) => d['allowed_decisions']['trumps'] = [],
    'duplicate trumps': (d) => d['allowed_decisions']['trumps'].add('spades'),
    'unsupported trump': (d) => d['allowed_decisions']['trumps'] = ['no_trump'],
    'unknown evaluation action': (d) =>
        d['evaluations'][0]['decision']['action'] = 'pass',
    'Dash carrying bid fields': (d) =>
        d['evaluations'][0]['decision']['action'] = 'dash',
    'unsupported rating': (d) => d['evaluations'][0]['rating'] = 'correct',
    'missing feedback': (d) => d['evaluations'][0].remove('feedback'),
    'blank feedback': (d) => d['evaluations'][0]['feedback']['summary'] = ' ',
    'missing evidence array': (d) =>
        d['evaluations'][0]['feedback'].remove('points'),
    'invalid evidence type': (d) =>
        d['evaluations'][0]['feedback']['points'] = [1],
  };
  for (final entry in malformed.entries) {
    test('schema and parser both reject ${entry.key}', () {
      final data = fixture();
      entry.value(data);
      expect(schema.validate(data).isValid, isFalse);
      expect(() => BiddingScenario.fromJson(data), throwsFormatException);
    });
  }

  final crossField = <String, void Function(Map<String, dynamic>)>{
    'inverted range': (d) => d['allowed_decisions']['bids']['min'] = 8,
    'primary skill membership': (d) => d['primary_skill'] = 'another_skill',
    'decision outside allowed trumps': (d) =>
        d['allowed_decisions']['trumps'] = ['clubs'],
    'duplicate decision with different feedback': (d) {
      final duplicate = jsonDecode(jsonEncode(d['evaluations'][0]));
      duplicate['feedback']['summary'] = 'Another explanation';
      d['evaluations'].add(duplicate);
    },
  };
  for (final entry in crossField.entries) {
    test('parser retains cross-field check: ${entry.key}', () {
      final data = fixture();
      entry.value(data);
      // Shape is valid, but relational constraints still require the parser.
      expect(schema.validate(data).isValid, isTrue);
      expect(() => BiddingScenario.fromJson(data), throwsFormatException);
    });
  }

  test(
    'reserved play shape is preserved but remains unsupported by parser',
    () {
      final data = {
        'scenario_version': 1,
        'type': 'play',
        'id': 'play_reserved',
        'difficulty': 'beginner',
        'primary_skill': 'tracking',
        'skills': ['tracking'],
      };
      expect(schema.validate(data).isValid, isTrue);
      expect(() => BiddingScenario.fromJson(data), throwsFormatException);
    },
  );
}
