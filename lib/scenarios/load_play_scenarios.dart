import 'dart:convert';

import 'package:flutter/services.dart';

import 'play_scenario.dart';

/// Flutter asset I/O stays outside the pure Dart scenario model and evaluator.
Future<List<PlayScenario>> loadPlayScenarios({AssetBundle? bundle}) async {
  final assets = bundle ?? rootBundle;
  final manifest = await AssetManifest.loadFromAssetBundle(assets);
  final paths =
      manifest
          .listAssets()
          .where(
            (path) =>
                path.startsWith('content/scenarios/v1/play/') &&
                path.endsWith('.json'),
          )
          .toList()
        ..sort();
  if (paths.isEmpty) {
    throw const FormatException('No play scenarios bundled');
  }
  final scenarios = <PlayScenario>[];
  final ids = <String>{};
  for (final path in paths) {
    final scenario = PlayScenario.fromJson(
      jsonDecode(await assets.loadString(path)),
    );
    if (!ids.add(scenario.id)) {
      throw FormatException('Duplicate scenario: ${scenario.id}');
    }
    if (scenario.missingEvaluationCount != 0) {
      throw FormatException('Incomplete feedback: ${scenario.id}');
    }
    scenarios.add(scenario);
  }
  return List.unmodifiable(scenarios);
}
