import 'package:estimation_coach/core/game_rules/bidding.dart';
import 'package:estimation_coach/core/game_rules/estimate_totals.dart';
import 'package:estimation_coach/core/game_rules/play_situation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<PlayerSeat, TrickEstimate> estimates(
    int north,
    int east,
    int south,
    int west,
  ) => {
    PlayerSeat.north: TrickEstimate(north),
    PlayerSeat.east: TrickEstimate(east),
    PlayerSeat.south: TrickEstimate(south),
    PlayerSeat.west: TrickEstimate(west),
  };

  test('estimateTotal sums all four seats', () {
    expect(estimateTotal(estimates(4, 3, 2, 1)), 10);
    expect(estimateTotal(estimates(0, 0, 0, 0)), 0);
  });

  test('estimateTotal rejects a set missing a seat', () {
    expect(
      () => estimateTotal({
        PlayerSeat.north: TrickEstimate(4),
        PlayerSeat.east: TrickEstimate(3),
        PlayerSeat.south: TrickEstimate(2),
      }),
      throwsArgumentError,
    );
  });

  test('a total of exactly 13 is invalid', () {
    expect(isValidEstimateTotal(estimates(4, 4, 4, 1)), isFalse);
    expect(isValidEstimateTotal(estimates(5, 4, 2, 1)), isTrue);
  });

  test('classifyEstimateTotal: 14+ is Over, 12 or fewer is Under', () {
    expect(
      classifyEstimateTotal(estimates(4, 4, 4, 2)),
      EstimateTotalBalance.over,
    );
    expect(
      classifyEstimateTotal(estimates(4, 4, 3, 1)),
      EstimateTotalBalance.under,
    );
    // Boundaries either side of the forbidden 13.
    expect(
      classifyEstimateTotal(estimates(4, 4, 4, 0)),
      EstimateTotalBalance.under,
    );
    expect(
      classifyEstimateTotal(estimates(4, 4, 4, 2)),
      EstimateTotalBalance.over,
    );
  });

  test('classifyEstimateTotal throws for exactly 13', () {
    expect(
      () => classifyEstimateTotal(estimates(4, 4, 4, 1)),
      throwsArgumentError,
    );
  });

  test('a non-Caller estimate must not exceed the Caller\'s', () {
    final caller = TrickEstimate(5);
    expect(
      isValidNonCallerEstimate(
        estimate: TrickEstimate(5),
        callerEstimate: caller,
      ),
      isTrue,
    );
    expect(
      isValidNonCallerEstimate(
        estimate: TrickEstimate(3),
        callerEstimate: caller,
      ),
      isTrue,
    );
    expect(
      isValidNonCallerEstimate(
        estimate: TrickEstimate(6),
        callerEstimate: caller,
      ),
      isFalse,
    );
  });

  test('a complete set must contain some seat at the Caller\'s estimate', () {
    final caller = TrickEstimate(4);
    // Any seat can be the one at the winning bid; several may be ("With").
    for (final set in [
      estimates(4, 3, 2, 1),
      estimates(1, 4, 2, 3),
      estimates(1, 3, 4, 2),
      estimates(2, 1, 3, 4),
      estimates(4, 4, 4, 2),
    ]) {
      expect(includesCallerEstimate(set, callerEstimate: caller), isTrue);
    }
    // Nobody at 4 means no seat could be the Caller of a 4-trick bid.
    expect(
      includesCallerEstimate(estimates(3, 3, 2, 1), callerEstimate: caller),
      isFalse,
    );
    // Exceeding the bid is a separate rule; this one only asks for equality.
    expect(
      includesCallerEstimate(estimates(5, 3, 2, 1), callerEstimate: caller),
      isFalse,
    );
  });

  test('includesCallerEstimate rejects an incomplete set', () {
    expect(
      () => includesCallerEstimate({
        PlayerSeat.north: TrickEstimate(4),
        PlayerSeat.east: TrickEstimate(3),
        PlayerSeat.west: TrickEstimate(2),
      }, callerEstimate: TrickEstimate(4)),
      throwsArgumentError,
    );
  });

  test('"With" is exact equality with the Caller\'s estimate', () {
    final caller = TrickEstimate(5);
    expect(
      isWithCaller(estimate: TrickEstimate(5), callerEstimate: caller),
      isTrue,
    );
    expect(
      isWithCaller(estimate: TrickEstimate(4), callerEstimate: caller),
      isFalse,
    );
  });
}
