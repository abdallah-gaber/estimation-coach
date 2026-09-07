import '../../scenarios/bidding_scenario.dart';

/// Exact authored evaluation. Missing feedback is deliberately not a rating.
AuthoredEvaluation? evaluateBid(
  BiddingScenario scenario,
  BiddingDecision choice,
) {
  if (!scenario.allowedDecisions.contains(choice)) {
    throw ArgumentError.value(choice, 'choice', 'Not a legal scenario choice');
  }
  for (final evaluation in scenario.evaluations) {
    if (evaluation.decision == choice) return evaluation;
  }
  return null;
}
