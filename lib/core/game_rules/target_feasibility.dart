import 'play_situation.dart';

/// Whether a player's exact-target estimate is still reachable given how
/// many tricks remain, and if so how much room the remaining tricks give.
/// Owner-confirmed 2026-09-08 (see game_rules_v1): success means taking
/// EXACTLY the estimated number of tricks; a target does not stay reachable
/// just because it has not been exceeded yet — it also needs enough
/// remaining tricks left to physically reach it.
///
/// Named and scoped distinctly from [ExactBidOutcome] in
/// `exact_bid_outcome.dart` on purpose: that classifies one already-known,
/// *completed* trick count against an estimate, with no notion of what is
/// still to come. This classifies the *in-progress* situation — taken,
/// target and how many tricks remain — which `ExactBidOutcome` alone cannot
/// express and which authored coaching needs to reason about a specific
/// card decision, not just a finished count.
enum TargetFeasibility {
  /// `taken > target`: the target can no longer be hit exactly no matter
  /// what happens in the remaining tricks — this player has already taken
  /// too many. Every remaining trick should still be avoided, but exact
  /// success is already out of reach either way.
  alreadyOver,

  /// `taken == target`: every remaining trick must be avoided to stay
  /// exact. Winning any one of them would push this player into
  /// [alreadyOver].
  onTarget,

  /// `target - taken == remainingTricks`: every single remaining trick,
  /// including the one being decided right now, must be won. Losing any of
  /// them makes the target [unreachable] from that point on.
  mustWinAll,

  /// `0 < target - taken < remainingTricks`: some remaining tricks can be
  /// lost without missing the target. Not every remaining trick is forced
  /// either way — there is room to choose.
  slack,

  /// `target - taken > remainingTricks`: even winning every single
  /// remaining trick cannot reach the target — there simply are not enough
  /// tricks left. Distinct from [alreadyOver], which is too many tricks
  /// already taken rather than too few left to take.
  unreachable,
}

/// Classifies target feasibility from [taken] (this player's completed
/// tricks), [target] (their exact-trick estimate) and [remainingTricks]
/// (tricks left to play, inclusive of the one currently being decided —
/// ordinarily a hand's remaining card count). Resolves nothing beyond this
/// one classification: it does not resolve trick winners, track a full
/// round, or compute a score.
TargetFeasibility classifyTargetFeasibility({
  required int taken,
  required TrickEstimate target,
  required int remainingTricks,
}) {
  if (taken < 0 || taken > 13) {
    throw RangeError.range(taken, 0, 13, 'taken');
  }
  if (remainingTricks < 0 || remainingTricks > 13) {
    throw RangeError.range(remainingTricks, 0, 13, 'remainingTricks');
  }
  final remainingNeeded = target.tricks - taken;
  if (remainingNeeded < 0) return TargetFeasibility.alreadyOver;
  if (remainingNeeded > remainingTricks) return TargetFeasibility.unreachable;
  if (remainingNeeded == 0) return TargetFeasibility.onTarget;
  if (remainingNeeded == remainingTricks) return TargetFeasibility.mustWinAll;
  return TargetFeasibility.slack;
}
