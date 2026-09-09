import 'dart:math';

import '../core/session/session_selector.dart';

/// Composes a scenario catalog loader with [selectSession] so trainer
/// screens depend on one call that returns an already-ordered session.
/// Screens hold no randomization logic themselves: this class owns the
/// random source, the cached catalog and the previous session's last
/// scenario, so repeated calls (including "Practice again") produce fresh
/// orders without reloading or mutating the underlying catalog.
///
/// Architecture: `Scenario Catalog -> Session Selector -> trainer UI`.
class ScenarioSession<T> {
  ScenarioSession({
    required this.loadCatalog,
    required this.idOf,
    Random? random,
  }) : _random = random ?? Random();

  /// Loads the eligible scenario catalog. Called at most once; the result is
  /// cached and reused by every session.
  final Future<List<T>> Function() loadCatalog;

  /// Stable identity for [T], used for repeat/duplicate checks instead of
  /// object identity (a reloaded catalog is a fresh list of instances).
  final String Function(T item) idOf;

  final Random _random;

  List<T>? _catalog;
  T? _previousSessionLast;

  /// Loads the catalog once (cached across calls; retried automatically if
  /// a prior load failed) and returns a freshly ordered session every call.
  Future<List<T>> nextSession() async {
    final catalog = _catalog ??= await loadCatalog();
    final session = selectSession<T>(
      catalog,
      random: _random,
      idOf: idOf,
      previousSessionLast: _previousSessionLast,
    );
    _previousSessionLast = session.isEmpty ? null : session.last;
    return session;
  }
}
