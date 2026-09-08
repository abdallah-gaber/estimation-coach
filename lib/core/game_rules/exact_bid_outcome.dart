import 'play_situation.dart';

/// Whether a player's realized trick count matches their exact estimate.
/// Owner-confirmed 2026-09-08 (see game_rules_v1): success means taking
/// EXACTLY the estimated number of tricks, not at least that many.
///
/// This classifies one already-known trick count against one estimate; it
/// does not track a round in progress, resolve trick winners, or compute any
/// score. Named distinctly from [EstimateTotalBalance] in `estimate_totals.dart`
/// on purpose — that enum classifies the *room's* total of four estimates
/// against 13 (the confirmed "Over"/"Under" terms); this classifies *one
/// player's* realized tricks against their own estimate, an unrelated
/// comparison that happens to also have a higher/lower/equal shape.
enum ExactBidOutcome { onTarget, tookMore, tookFewer }

/// Classifies [tricksTaken] against [estimate] per the exact-target rule.
ExactBidOutcome classifyExactBid({
  required int tricksTaken,
  required TrickEstimate estimate,
}) {
  if (tricksTaken < 0 || tricksTaken > 13) {
    throw RangeError.range(tricksTaken, 0, 13, 'tricksTaken');
  }
  if (tricksTaken == estimate.tricks) return ExactBidOutcome.onTarget;
  return tricksTaken > estimate.tricks
      ? ExactBidOutcome.tookMore
      : ExactBidOutcome.tookFewer;
}
