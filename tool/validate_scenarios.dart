import 'dart:convert';
import 'dart:io';

import 'package:json_schema/json_schema.dart';

import 'package:estimation_coach/scenarios/bidding_scenario.dart';

void main(List<String> arguments) {
  exitCode = validateScenarios(arguments);
}

/// Validates local files only. No Flutter engine or network service is required.
int validateScenarios(
  List<String> arguments, {
  Directory? repository,
  StringSink? output,
  StringSink? errors,
}) {
  final out = output ?? stdout;
  final err = errors ?? stderr;
  final root = repository ?? Directory.current;
  const usage =
      'Usage: dart run tool/validate_scenarios.dart '
      '[--require-complete] [file-or-directory ...]\nRun from the repository root.';
  if (arguments.contains('--help')) {
    out.writeln(usage);
    return 0;
  }
  if (arguments.any(
    (arg) => arg.startsWith('-') && arg != '--require-complete',
  )) {
    err.writeln(usage);
    return 2;
  }
  final requireComplete = arguments.contains('--require-complete');
  final paths = arguments.where((arg) => arg != '--require-complete').toList();
  if (paths.isEmpty) paths.add('content/scenarios/v1');
  late final JsonSchema schema;
  try {
    // Synchronous creation resolves bundled/local references only.
    schema = JsonSchema.create(
      File('${root.path}/schemas/scenario.v1.schema.json').readAsStringSync(),
    );
  } catch (error) {
    err.writeln('ERROR schema: $error');
    return 2;
  }
  final files = <String>{};
  var failureCount = 0;
  for (final path in paths) {
    final target = File.fromUri(root.uri.resolve(path)).path;
    try {
      switch (FileSystemEntity.typeSync(target, followLinks: false)) {
        case FileSystemEntityType.file:
          if (!target.endsWith('.json')) {
            err.writeln('ERROR $path: expected a .json file');
            failureCount++;
          } else {
            files.add(target);
          }
        case FileSystemEntityType.directory:
          final found = Directory(target)
              .listSync(recursive: true, followLinks: false)
              .whereType<File>()
              .where((file) => file.path.endsWith('.json'));
          if (found.isEmpty) {
            err.writeln('ERROR $path: no scenario JSON files found');
            failureCount++;
          }
          files.addAll(found.map((file) => file.path));
        default:
          err.writeln(
            'ERROR $path: expected an existing file or directory (no symlinks)',
          );
          failureCount++;
      }
    } on FileSystemException catch (error) {
      err.writeln('ERROR $path: ${error.message}');
      failureCount++;
    }
  }
  final sorted = files.toList()..sort();
  final ids = <String, String>{};
  for (final path in sorted) {
    try {
      final data = jsonDecode(File(path).readAsStringSync());
      final result = schema.validate(data);
      if (!result.isValid) {
        for (final error in result.errors) {
          err.writeln('ERROR $path: schema $error');
        }
        failureCount++;
        continue;
      }
      final scenario = BiddingScenario.fromJson(data);
      final existing = ids[scenario.id];
      if (existing != null) {
        err.writeln(
          'ERROR $path: duplicate scenario id ${scenario.id} (also in $existing)',
        );
        failureCount++;
        continue;
      }
      ids[scenario.id] = path;
      final missing = scenario.missingEvaluationCount;
      if (missing > 0) {
        final message =
            '$path: $missing of ${scenario.allowedDecisions.count} '
            'allowed decisions have no authored evaluation';
        if (requireComplete) {
          err.writeln('ERROR $message');
          failureCount++;
          continue;
        }
        out.writeln('WARNING $message');
      }
      out.writeln('VALID $path (${scenario.id}; structure only)');
    } on FormatException catch (error) {
      err.writeln('ERROR $path: ${error.message}');
      failureCount++;
    } on FileSystemException catch (error) {
      err.writeln('ERROR $path: ${error.message}');
      failureCount++;
    }
  }
  out.writeln('Checked ${files.length} file(s); $failureCount failure(s).');
  out.writeln(
    'Structural validation does not certify bidding legality or coaching quality; '
    'manual rules review remains required (EC-024).',
  );
  return failureCount == 0 ? 0 : 1;
}
