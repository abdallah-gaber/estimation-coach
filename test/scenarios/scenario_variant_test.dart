import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:estimation_coach/core/game_rules/bidding.dart' show PlayerSeat;
import 'package:estimation_coach/scenarios/play_scenario.dart';
import 'package:estimation_coach/scenarios/scenario_variant.dart';
import 'package:flutter_test/flutter_test.dart';

PlayScenario _load(String id) => PlayScenario.fromJson(
  jsonDecode(File('content/scenarios/v1/play/$id.json').readAsStringSync()),
);

void main() {
  group('generateTricksTakenVariant', () {
    test('same base + same variant seed produces the same output', () {
      final base = _load('play_target_protection_004');
      final first = generateTricksTakenVariant(base, random: Random(7));
      final second = generateTricksTakenVariant(base, random: Random(7));
      expect(first.situation.tricksTaken, second.situation.tricksTaken);
    });

    test('different seeds can produce different valid distributions', () {
      final base = _load('play_target_protection_004');
      final bySeed = <int, Map<PlayerSeat, int>>{
        for (final seed in [1, 2, 3, 4, 5])
          seed: generateTricksTakenVariant(
            base,
            random: Random(seed),
          ).situation.tricksTaken,
      };
      final distinct = bySeed.values.map((m) => m.toString()).toSet();
      expect(
        distinct.length,
        greaterThan(1),
        reason: 'at least two of these seeds should disagree',
      );
    });

    test('the source scenario is never mutated', () {
      final base = _load('play_target_protection_004');
      final beforeTaken = Map.of(base.situation.tricksTaken);
      generateTricksTakenVariant(base, random: Random(3));
      expect(base.situation.tricksTaken, beforeTaken);
    });

    test('the variant is a valid PlayScenario: same total, same player count, '
        'others sum unchanged', () {
      final base = _load('play_target_protection_004');
      for (final seed in [1, 2, 3, 4, 5, 6, 7, 8]) {
        final variant = generateTricksTakenVariant(base, random: Random(seed));
        final taken = variant.situation.tricksTaken;
        expect(
          taken.values.fold(0, (a, b) => a + b),
          base.situation.tricksTaken.values.fold(0, (a, b) => a + b),
        );
        expect(
          taken[base.situation.playerPosition],
          base.situation.tricksTaken[base.situation.playerPosition],
        );
        for (final count in taken.values) {
          expect(count, inInclusiveRange(0, 13));
        }
      }
    });

    test('rating/evaluation mapping is unchanged for every legal choice', () {
      final base = _load('play_target_protection_004');
      final variant = generateTricksTakenVariant(base, random: Random(9));
      for (final card in base.legalChoices) {
        expect(variant.evaluate(card), same(base.evaluate(card)));
      }
      expect(variant.legalChoices, base.legalChoices);
    });

    test('transformed public evidence still supports the authored coaching '
        'rationale: hand, trump, current trick, estimate and history are '
        'byte-identical', () {
      final base = _load('play_target_protection_004');
      final variant = generateTricksTakenVariant(base, random: Random(11));
      expect(variant.situation.hand.cards, base.situation.hand.cards);
      expect(variant.situation.trump, base.situation.trump);
      expect(variant.situation.leader, base.situation.leader);
      expect(
        variant.situation.currentTrick.map((p) => (p.seat, p.card)),
        base.situation.currentTrick.map((p) => (p.seat, p.card)),
      );
      expect(variant.situation.trickEstimate, base.situation.trickEstimate);
      expect(variant.situation.observedTricks, base.situation.observedTricks);
      expect(variant.id, base.id);
      expect(variant.title, base.title);
      expect(variant.evaluations, same(base.evaluations));
    });

    test('every production play scenario accepts this transformation', () {
      final files = Directory(
        'content/scenarios/v1/play',
      ).listSync().whereType<File>().where((f) => f.path.endsWith('.json'));
      for (final file in files) {
        final base = PlayScenario.fromJson(jsonDecode(file.readAsStringSync()));
        final variant = generateTricksTakenVariant(base, random: Random(42));
        expect(variant.legalChoices, base.legalChoices, reason: base.id);
      }
    });
  });

  group('PlayScenario.withTricksTaken (fail-closed apply step)', () {
    test('a map whose sum disagrees with the remaining hand is rejected', () {
      final base = _load('play_target_protection_004');
      final invalid = Map.of(base.situation.tricksTaken);
      final seat = PlayerSeat.values.firstWhere(
        (s) => s != base.situation.playerPosition,
      );
      invalid[seat] = invalid[seat]! + 1;
      expect(() => base.withTricksTaken(invalid), throwsArgumentError);
    });

    test('a map missing a seat is rejected', () {
      final base = _load('play_target_protection_004');
      final invalid = Map.of(base.situation.tricksTaken)
        ..remove(PlayerSeat.north);
      expect(() => base.withTricksTaken(invalid), throwsArgumentError);
    });

    test('an out-of-range count is rejected', () {
      final base = _load('play_target_protection_004');
      final invalid = Map.of(base.situation.tricksTaken);
      invalid[PlayerSeat.north] = 99;
      expect(() => base.withTricksTaken(invalid), throwsArgumentError);
    });
  });
}
