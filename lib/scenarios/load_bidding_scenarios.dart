import 'dart:convert';

import 'package:flutter/services.dart';

import 'bidding_scenario.dart';

/// Flutter asset I/O stays outside the pure Dart scenario model and evaluator.
Future<List<BiddingScenario>> loadBiddingScenarios({
  AssetBundle? bundle,
}) async {
  final assets = bundle ?? rootBundle;
  final manifest = await AssetManifest.loadFromAssetBundle(assets);
  final paths =
      manifest
          .listAssets()
          .where(
            (path) =>
                path.startsWith('content/scenarios/v1/bidding/') &&
                path.endsWith('.json'),
          )
          .toList()
        ..sort();
  if (paths.isEmpty) {
    throw const FormatException('No bidding scenarios bundled');
  }
  final scenarios = <BiddingScenario>[];
  final ids = <String>{};
  for (final path in paths) {
    final scenario = BiddingScenario.fromJson(
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
