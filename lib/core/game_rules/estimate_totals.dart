import 'bidding.dart';
import 'play_situation.dart';

/// Whether the four trick estimates' total is Over or Under 13 tricks.
/// Owner-confirmed 2026-09-08 (see game_rules_v1): the total must never
/// equal 13. This module only classifies an already-complete set of four
/// estimates — it does not model the post-auction estimate phase's seat
/// order, whose seat estimates last, or how a player is expected to satisfy
/// the constraint. Those remain undocumented.
enum EstimateTotalBalance { over, under }

/// Sum of all four seats' trick estimates. Throws unless every seat is
/// present exactly once.
int estimateTotal(Map<PlayerSeat, TrickEstimate> estimates) {
  _requireAllSeats(estimates);
  return estimates.values.fold(0, (sum, estimate) => sum + estimate.tricks);
}

/// The total must never equal 13 (game_rules_v1). This says nothing about
/// which seat is responsible for avoiding it, only whether a complete set
/// already violates it.
bool isValidEstimateTotal(Map<PlayerSeat, TrickEstimate> estimates) =>
    estimateTotal(estimates) != 13;

/// Classifies a complete, valid set of four estimates as Over (total >= 14)
/// or Under (total <= 12). Throws if the total is exactly 13 — check
/// [isValidEstimateTotal] first if the set is not already known to be valid.
EstimateTotalBalance classifyEstimateTotal(
  Map<PlayerSeat, TrickEstimate> estimates,
) {
  final total = estimateTotal(estimates);
  if (total == 13) {
    throw ArgumentError('Total estimates must never equal 13');
  }
  return total >= 14 ? EstimateTotalBalance.over : EstimateTotalBalance.under;
}

/// A non-Caller's estimate must not exceed the Caller's (game_rules_v1).
bool isValidNonCallerEstimate({
  required TrickEstimate estimate,
  required TrickEstimate callerEstimate,
}) => estimate.tricks <= callerEstimate.tricks;

/// "With": [estimate] equals the Caller's estimate exactly. Always derive
/// this from equality rather than an authored flag, so content never
/// duplicates what this already computes.
bool isWithCaller({
  required TrickEstimate estimate,
  required TrickEstimate callerEstimate,
}) => estimate.tricks == callerEstimate.tricks;

void _requireAllSeats(Map<PlayerSeat, TrickEstimate> estimates) {
  if (estimates.length != PlayerSeat.values.length ||
      !PlayerSeat.values.every(estimates.containsKey)) {
    throw ArgumentError('estimates must contain all four seats');
  }
}
