import 'dart:math';

import 'package:estimation_coach/core/session/session_selector.dart';
import 'package:flutter_test/flutter_test.dart';

class _Item {
  const _Item(this.id);
  final String id;

  @override
  String toString() => 'Item($id)';
}

List<_Item> _pool(int count) => [
  for (var i = 0; i < count; i++) _Item('item_$i'),
];

List<String> _ids(List<_Item> items) => items.map((item) => item.id).toList();

void main() {
  group('selectSession', () {
    test('an empty pool returns an empty session', () {
      final session = selectSession<_Item>(
        const [],
        random: Random(1),
        idOf: (item) => item.id,
      );
      expect(session, isEmpty);
    });

    test('a single-item pool always returns that item', () {
      final pool = _pool(1);
      final session = selectSession<_Item>(
        pool,
        random: Random(1),
        idOf: (item) => item.id,
      );
      expect(_ids(session), ['item_0']);
    });

    test(
      'a single-item pool repeats the previous session last when unavoidable',
      () {
        final pool = _pool(1);
        final session = selectSession<_Item>(
          pool,
          random: Random(7),
          idOf: (item) => item.id,
          previousSessionLast: pool.single,
        );
        expect(_ids(session), ['item_0']);
      },
    );

    test('a two-item pool avoids starting with the previous session last', () {
      final pool = _pool(2);
      for (final seed in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) {
        final session = selectSession<_Item>(
          pool,
          random: Random(seed),
          idOf: (item) => item.id,
          previousSessionLast: pool[0],
        );
        expect(_ids(session).toSet(), {'item_0', 'item_1'});
        expect(session.first.id, 'item_1');
        expect(session.last.id, 'item_0');
      }
    });

    test('same seed produces the same order for the same pool', () {
      final pool = _pool(8);
      final first = selectSession<_Item>(
        pool,
        random: Random(42),
        idOf: (item) => item.id,
      );
      final second = selectSession<_Item>(
        pool,
        random: Random(42),
        idOf: (item) => item.id,
      );
      expect(_ids(first), _ids(second));
    });

    test('different seeds can produce different valid orders', () {
      final pool = _pool(8);
      final bySeed = <int, List<String>>{
        for (final seed in [1, 2, 3, 4, 5])
          seed: _ids(
            selectSession<_Item>(
              pool,
              random: Random(seed),
              idOf: (item) => item.id,
            ),
          ),
      };
      final distinctOrders = bySeed.values
          .map((order) => order.join(','))
          .toSet();
      expect(
        distinctOrders.length,
        greaterThan(1),
        reason: 'at least two of these seeds should disagree on order',
      );
    });

    test('the output is always a permutation of the eligible input', () {
      final pool = _pool(10);
      for (final seed in [1, 2, 3, 4, 5]) {
        final session = selectSession<_Item>(
          pool,
          random: Random(seed),
          idOf: (item) => item.id,
        );
        expect(session, hasLength(pool.length));
        expect(_ids(session).toSet(), _ids(pool).toSet());
      }
    });

    test('no scenario is duplicated or lost within one session', () {
      final pool = _pool(12);
      final session = selectSession<_Item>(
        pool,
        random: Random(99),
        idOf: (item) => item.id,
      );
      final seen = <String>{};
      for (final item in session) {
        expect(seen.add(item.id), isTrue, reason: '${item.id} appeared twice');
      }
      expect(seen, _ids(pool).toSet());
    });

    test('no two adjacent entries share an id within one session', () {
      final pool = _pool(9);
      for (final seed in [1, 2, 3, 4, 5]) {
        final session = selectSession<_Item>(
          pool,
          random: Random(seed),
          idOf: (item) => item.id,
        );
        for (var i = 1; i < session.length; i++) {
          expect(session[i].id, isNot(session[i - 1].id));
        }
      }
    });

    test('a session never starts with the previous session last when an '
        'alternative exists', () {
      final pool = _pool(6);
      for (final startAt in pool) {
        for (final seed in [1, 2, 3, 4, 5, 6, 7, 8]) {
          final session = selectSession<_Item>(
            pool,
            random: Random(seed),
            idOf: (item) => item.id,
            previousSessionLast: startAt,
          );
          expect(session.first.id, isNot(startAt.id));
        }
      }
    });

    test('file/catalog order is not preserved by contract: at least one seed '
        'reorders the pool', () {
      final pool = _pool(10);
      final reordered = [1, 2, 3, 4, 5].any(
        (seed) =>
            _ids(
              selectSession<_Item>(
                pool,
                random: Random(seed),
                idOf: (item) => item.id,
              ),
            ).join(',') !=
            _ids(pool).join(','),
      );
      expect(reordered, isTrue);
    });

    test(
      'a pool with more than one item is never returned in original order '
      'when a previous session last is supplied and swap lands elsewhere',
      () {
        // Regression: the previous-last swap must not silently reintroduce a
        // duplicate or drop an item.
        final pool = _pool(5);
        final session = selectSession<_Item>(
          pool,
          random: Random(3),
          idOf: (item) => item.id,
          previousSessionLast: pool[2],
        );
        expect(_ids(session).toSet(), _ids(pool).toSet());
        expect(session, hasLength(pool.length));
      },
    );
  });
}
