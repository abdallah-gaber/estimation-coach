import 'dart:convert';
import 'dart:io';

import 'package:estimation_coach/scenarios/load_bidding_scenarios.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class CatalogBundle extends CachingAssetBundle {
  CatalogBundle(this.files);
  final Map<String, String> files;

  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin') {
      return const StandardMessageCodec().encodeMessage({
        for (final path in files.keys)
          path: [
            {'asset': path},
          ],
      })!;
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(files[key]!)));
  }
}

void main() {
  const path = 'content/scenarios/v1/bidding/bid_enter_controls_001.json';
  final valid = File(path).readAsStringSync();
  test('empty catalogs fail before training', () async {
    await expectLater(
      loadBiddingScenarios(bundle: CatalogBundle({})),
      throwsFormatException,
    );
  });
  test('duplicate IDs fail even under different filenames', () async {
    await expectLater(
      loadBiddingScenarios(
        bundle: CatalogBundle({
          path: valid,
          'content/scenarios/v1/bidding/duplicate.json': valid,
        }),
      ),
      throwsFormatException,
    );
  });
  test('incomplete feedback is rejected before training', () async {
    final incomplete = jsonDecode(valid) as Map<String, dynamic>;
    incomplete['evaluations'] = [];
    await expectLater(
      loadBiddingScenarios(
        bundle: CatalogBundle({path: jsonEncode(incomplete)}),
      ),
      throwsFormatException,
    );
  });
  test('malformed JSON fails before training', () async {
    await expectLater(
      loadBiddingScenarios(bundle: CatalogBundle({path: '{'})),
      throwsFormatException,
    );
  });
}
