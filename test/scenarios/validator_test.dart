import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/validate_scenarios.dart';
import 'bidding_scenario_test.dart' show fixture;

void main() {
  late Directory root;
  late StringBuffer output;
  late StringBuffer errors;
  setUp(() {
    root = Directory.systemTemp.createTempSync('estimation-validator-');
    Directory('${root.path}/schemas').createSync();
    File(
      'schemas/scenario.v1.schema.json',
    ).copySync('${root.path}/schemas/scenario.v1.schema.json');
    Directory(
      '${root.path}/content/scenarios/v1/bidding',
    ).createSync(recursive: true);
    output = StringBuffer();
    errors = StringBuffer();
  });
  tearDown(() => root.deleteSync(recursive: true));

  void write(String name, Object? data) => File(
    '${root.path}/content/scenarios/v1/bidding/$name.json',
  ).writeAsStringSync(jsonEncode(data));
  int run([List<String> args = const []]) =>
      validateScenarios(args, repository: root, output: output, errors: errors);

  test(
    'default command checks nested content and reports incomplete coverage',
    () {
      write('draft', fixture());
      expect(run(), 0);
      expect(output.toString(), contains('16 of 17'));
      expect(output.toString(), contains('structure + game_rules_v1'));
      expect(errors.toString(), isEmpty);
    },
  );

  test('strict coverage returns a failure for the draft', () {
    write('draft', fixture());
    expect(run(['--require-complete']), 1);
    expect(errors.toString(), contains('no authored evaluation'));
  });

  test('strict coverage accepts a complete structural fixture', () {
    final data = fixture();
    data['allowed_decisions'] = {
      'dash': false,
      'bids': {'min': 4, 'max': 4},
      'trumps': ['spades'],
    };
    write('complete', data);
    expect(run(['--require-complete']), 0);
    expect(
      output.toString(),
      contains('manual coaching review remains required'),
    );
  });

  test('duplicate ids fail even in separate files', () {
    write('first', fixture());
    write('second', fixture());
    expect(run(), 1);
    expect(errors.toString(), contains('duplicate scenario id'));
  });

  test(
    'malformed JSON and domain errors are reported while scanning continues',
    () {
      File(
        '${root.path}/content/scenarios/v1/bidding/broken.json',
      ).writeAsStringSync('{');
      final bad = fixture()..['id'] = 'invalid_hand';
      bad['hand'].removeLast();
      write('bad_hand', bad);
      write('valid', fixture());
      expect(run(), 1);
      expect(errors.toString(), contains('broken.json'));
      expect(errors.toString(), contains('hand'));
      expect(output.toString(), contains('Checked 3 file(s); 2 failure(s)'));
      expect(output.toString(), contains('VALID'));
    },
  );

  test('uses the canonical schema rather than only the parser', () {
    final schemaFile = File('${root.path}/schemas/scenario.v1.schema.json');
    final schema = jsonDecode(schemaFile.readAsStringSync());
    schema['required'].add('schema_only_requirement');
    schemaFile.writeAsStringSync(jsonEncode(schema));
    write('draft', fixture());
    expect(run(), 1);
    expect(errors.toString(), contains('schema_only_requirement'));
  });

  test(
    'schema catches duplicates and domain catches cross-field inconsistencies',
    () {
      final duplicate = fixture()..['id'] = 'duplicate_card';
      duplicate['hand'][1] = 'AS';
      write('duplicate', duplicate);
      final rating = fixture()..['id'] = 'bad_range';
      rating['allowed_decisions']['bids']['min'] = 8;
      write('rating', rating);
      expect(run(), 1);
      expect(errors.toString(), contains('schema'));
      expect(errors.toString(), contains(r'$.allowed_decisions.bids'));
    },
  );

  test('missing, empty and unsupported paths fail', () {
    expect(run(), 1);
    expect(run(['missing.json']), 1);
    File('${root.path}/notes.txt').writeAsStringSync('notes');
    expect(run(['notes.txt']), 1);
  });

  test(
    'explicit paths work and overlapping input does not double-count files',
    () {
      write('draft', fixture());
      expect(
        run([
          'content/scenarios/v1',
          'content/scenarios/v1/bidding/draft.json',
        ]),
        0,
      );
      expect(output.toString(), contains('Checked 1 file(s)'));
    },
  );

  test('bad schema or options produce configuration exit code', () {
    expect(run(['--unknown']), 2);
    File('${root.path}/schemas/scenario.v1.schema.json').writeAsStringSync('{');
    expect(run(), 2);
    expect(errors.toString(), contains('ERROR schema'));
  });
}
