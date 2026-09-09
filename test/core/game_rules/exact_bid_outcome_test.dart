import 'package:estimation_coach/core/game_rules/exact_bid_outcome.dart';
import 'package:estimation_coach/core/game_rules/play_situation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exact match is onTarget, not merely "at least"', () {
    expect(
      classifyExactBid(tricksTaken: 4, estimate: TrickEstimate(4)),
      ExactBidOutcome.onTarget,
    );
  });

  test('taking more than estimated is tookMore, even though it exceeds it', () {
    expect(
      classifyExactBid(tricksTaken: 5, estimate: TrickEstimate(4)),
      ExactBidOutcome.tookMore,
    );
  });

  test('taking fewer than estimated is tookFewer', () {
    expect(
      classifyExactBid(tricksTaken: 3, estimate: TrickEstimate(4)),
      ExactBidOutcome.tookFewer,
    );
  });

  test('boundaries: zero and thirteen tricks classify correctly', () {
    expect(
      classifyExactBid(tricksTaken: 0, estimate: TrickEstimate(0)),
      ExactBidOutcome.onTarget,
    );
    expect(
      classifyExactBid(tricksTaken: 13, estimate: TrickEstimate(13)),
      ExactBidOutcome.onTarget,
    );
    expect(
      classifyExactBid(tricksTaken: 13, estimate: TrickEstimate(0)),
      ExactBidOutcome.tookMore,
    );
  });

  test('rejects an out-of-range trick count', () {
    expect(
      () => classifyExactBid(tricksTaken: -1, estimate: TrickEstimate(4)),
      throwsRangeError,
    );
    expect(
      () => classifyExactBid(tricksTaken: 14, estimate: TrickEstimate(4)),
      throwsRangeError,
    );
  });
}
