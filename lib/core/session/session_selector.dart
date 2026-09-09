import 'dart:math';

/// Orders an eligible scenario pool into one practice session, independent
/// of catalog/filename order (EC-049). This module only reorders; it never
/// mutates scenario content and never picks cards.
///
/// Contract:
/// - Empty [pool] returns an empty list.
/// - A single-item pool returns that item; it necessarily repeats
///   [previousSessionLast] when there is no alternative.
/// - Otherwise the result is a shuffled permutation of [pool] that, when
///   [previousSessionLast] is one of the eligible items, does not start with
///   it (an alternative always exists once the pool has more than one item).
/// - [random] is the only source of randomness; the same seed always
///   produces the same order for the same [pool].
///
/// [T] items are compared by [idOf] rather than object identity, since a
/// reloaded catalog is a fresh list of equivalent instances.
List<T> selectSession<T>(
  List<T> pool, {
  required Random random,
  required String Function(T item) idOf,
  T? previousSessionLast,
}) {
  if (pool.isEmpty) return const [];
  if (pool.length == 1) return List.unmodifiable(pool);

  final shuffled = List<T>.of(pool)..shuffle(random);

  if (previousSessionLast != null &&
      idOf(shuffled.first) == idOf(previousSessionLast)) {
    final swapIndex = 1 + random.nextInt(shuffled.length - 1);
    final first = shuffled[0];
    shuffled[0] = shuffled[swapIndex];
    shuffled[swapIndex] = first;
  }

  return List.unmodifiable(shuffled);
}
