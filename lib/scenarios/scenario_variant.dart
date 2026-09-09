import 'dart:math';

import '../core/game_rules/bidding.dart' show PlayerSeat;
import 'play_scenario.dart';

/// Variant mechanism v1 (EC-055): the only transformation currently proven
/// safe against the free-text feedback contract. See docs/DECISIONS.md for
/// why every other transformation considered (suit/rank substitution, seat
/// relabeling) was rejected as unsafe for this checkpoint.
///
/// Redistributes how many of the completed tricks belong to the three seats
/// other than [PlayScenario.situation]'s player, keeping the player's own
/// taken count, and every card, trump, estimate, auction bound and observed
/// trick, byte-identical. No scenario's authored feedback names an
/// opponent's exact taken-trick count, so every rating and feedback string
/// stays authored-and-reviewed content, unchanged and untouched.
///
/// Deterministic from [base] plus [random]: call with a freshly seeded
/// `Random(seed)` to reproduce the same result for the same base and seed.
/// [base] is never mutated — a new [PlayScenario] is returned, sharing
/// [base]'s id (so the base remains traceable), title, evaluations and
/// feedback by reference.
///
/// Fails closed: this function only ever constructs valid redistributions,
/// but the [PlayScenario.withTricksTaken] it calls performs the same
/// [PlaySituation](../core/game_rules/play_situation.dart) validation any
/// authored scenario goes through, so a future change to this generator
/// that produced an invalid map would throw rather than present something
/// unvalidated.
PlayScenario generateTricksTakenVariant(
  PlayScenario base, {
  required Random random,
}) {
  final situation = base.situation;
  final player = situation.playerPosition;
  final others = PlayerSeat.values.where((seat) => seat != player).toList();
  final total = situation.tricksTaken.values.fold(0, (a, b) => a + b);
  final playerCount = situation.tricksTaken[player]!;
  final shares = _distribute(total - playerCount, others.length, random);
  return base.withTricksTaken({
    player: playerCount,
    for (var i = 0; i < others.length; i++) others[i]: shares[i],
  });
}

/// Splits [total] into [parts] non-negative integers that sum to [total],
/// deterministic from [random] (stars-and-bars: pick `parts - 1` cut points
/// in `[0, total]`, sort them, and take the gaps between them).
List<int> _distribute(int total, int parts, Random random) {
  if (parts <= 1) return [total];
  final cuts = List<int>.generate(parts - 1, (_) => random.nextInt(total + 1))
    ..sort();
  final shares = <int>[];
  var previous = 0;
  for (final cut in cuts) {
    shares.add(cut - previous);
    previous = cut;
  }
  shares.add(total - previous);
  return shares;
}
