import 'dart:math';

import 'package:estimation_coach/scenarios/scenario_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScenarioSession', () {
    test('loads the catalog once and caches it across sessions', () async {
      var loadCalls = 0;
      final session = ScenarioSession<String>(
        loadCatalog: () async {
          loadCalls++;
          return ['a', 'b', 'c'];
        },
        idOf: (item) => item,
        random: Random(1),
      );
      await session.nextSession();
      await session.nextSession();
      await session.nextSession();
      expect(loadCalls, 1);
    });

    test('every session is a permutation of the loaded catalog', () async {
      final session = ScenarioSession<String>(
        loadCatalog: () async => ['a', 'b', 'c', 'd', 'e'],
        idOf: (item) => item,
        random: Random(11),
      );
      for (var i = 0; i < 5; i++) {
        final ordered = await session.nextSession();
        expect(ordered.toSet(), {'a', 'b', 'c', 'd', 'e'});
        expect(ordered, hasLength(5));
      }
    });

    test('a new session does not start with the previous session\'s last '
        'scenario when an alternative exists', () async {
      final session = ScenarioSession<String>(
        loadCatalog: () async => ['a', 'b', 'c', 'd'],
        idOf: (item) => item,
        random: Random(5),
      );
      var previous = await session.nextSession();
      for (var i = 0; i < 10; i++) {
        final next = await session.nextSession();
        expect(next.first, isNot(previous.last));
        previous = next;
      }
    });

    test('a failed load is retried on the next call', () async {
      var attempt = 0;
      final session = ScenarioSession<String>(
        loadCatalog: () async {
          attempt++;
          if (attempt == 1) throw const FormatException('unavailable');
          return ['a', 'b'];
        },
        idOf: (item) => item,
        random: Random(2),
      );
      await expectLater(session.nextSession(), throwsFormatException);
      final ordered = await session.nextSession();
      expect(ordered.toSet(), {'a', 'b'});
      expect(attempt, 2);
    });

    test('the same seed reproduces the same first session', () async {
      List<String> catalog() => ['a', 'b', 'c', 'd', 'e', 'f'];
      final first = await ScenarioSession<String>(
        loadCatalog: () async => catalog(),
        idOf: (item) => item,
        random: Random(123),
      ).nextSession();
      final second = await ScenarioSession<String>(
        loadCatalog: () async => catalog(),
        idOf: (item) => item,
        random: Random(123),
      ).nextSession();
      expect(first, second);
    });

    test('an empty catalog produces an empty session, not an error', () async {
      final session = ScenarioSession<String>(
        loadCatalog: () async => const [],
        idOf: (item) => item,
        random: Random(1),
      );
      expect(await session.nextSession(), isEmpty);
      expect(await session.nextSession(), isEmpty);
    });
  });
}
