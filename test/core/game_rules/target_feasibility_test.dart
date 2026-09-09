import 'package:estimation_coach/core/game_rules/play_situation.dart';
import 'package:estimation_coach/core/game_rules/target_feasibility.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('taken exceeding target is alreadyOver, regardless of what remains', () {
    for (final remaining in [0, 1, 5, 13]) {
      expect(
        classifyTargetFeasibility(
          taken: 5,
          target: TrickEstimate(4),
          remainingTricks: remaining,
        ),
        TargetFeasibility.alreadyOver,
      );
    }
  });

  test('taken equal to target with tricks still remaining is onTarget', () {
    expect(
      classifyTargetFeasibility(
        taken: 4,
        target: TrickEstimate(4),
        remainingTricks: 3,
      ),
      TargetFeasibility.onTarget,
    );
  });

  test('taken equal to target with nothing remaining is still onTarget', () {
    // No further trick can happen either way; the target was met exactly.
    expect(
      classifyTargetFeasibility(
        taken: 4,
        target: TrickEstimate(4),
        remainingTricks: 0,
      ),
      TargetFeasibility.onTarget,
    );
  });

  test('needing exactly as many tricks as remain is mustWinAll, not slack', () {
    expect(
      classifyTargetFeasibility(
        taken: 2,
        target: TrickEstimate(4),
        remainingTricks: 2,
      ),
      TargetFeasibility.mustWinAll,
    );
    // The boundary case: one trick left, one trick needed.
    expect(
      classifyTargetFeasibility(
        taken: 3,
        target: TrickEstimate(4),
        remainingTricks: 1,
      ),
      TargetFeasibility.mustWinAll,
    );
  });

  test('needing fewer tricks than remain is slack', () {
    expect(
      classifyTargetFeasibility(
        taken: 3,
        target: TrickEstimate(4),
        remainingTricks: 2,
      ),
      TargetFeasibility.slack,
    );
    expect(
      classifyTargetFeasibility(
        taken: 2,
        target: TrickEstimate(5),
        remainingTricks: 4,
      ),
      TargetFeasibility.slack,
    );
  });

  test(
    'needing more tricks than remain is unreachable, never silently slack',
    () {
      expect(
        classifyTargetFeasibility(
          taken: 0,
          target: TrickEstimate(13),
          remainingTricks: 2,
        ),
        TargetFeasibility.unreachable,
      );
      // The boundary case: one more trick needed than remains.
      expect(
        classifyTargetFeasibility(
          taken: 2,
          target: TrickEstimate(4),
          remainingTricks: 1,
        ),
        TargetFeasibility.unreachable,
      );
    },
  );

  test('unreachable and alreadyOver are distinct kinds of impossible', () {
    // Too few tricks left (unreachable) vs. too many already taken
    // (alreadyOver) are different situations and must not collapse into
    // the same classification.
    final unreachable = classifyTargetFeasibility(
      taken: 0,
      target: TrickEstimate(3),
      remainingTricks: 1,
    );
    final alreadyOver = classifyTargetFeasibility(
      taken: 3,
      target: TrickEstimate(0),
      remainingTricks: 1,
    );
    expect(unreachable, TargetFeasibility.unreachable);
    expect(alreadyOver, TargetFeasibility.alreadyOver);
    expect(unreachable, isNot(alreadyOver));
  });

  test('boundaries: zero and thirteen classify correctly', () {
    expect(
      classifyTargetFeasibility(
        taken: 0,
        target: TrickEstimate(0),
        remainingTricks: 0,
      ),
      TargetFeasibility.onTarget,
    );
    expect(
      classifyTargetFeasibility(
        taken: 0,
        target: TrickEstimate(13),
        remainingTricks: 13,
      ),
      TargetFeasibility.mustWinAll,
    );
    expect(
      classifyTargetFeasibility(
        taken: 13,
        target: TrickEstimate(13),
        remainingTricks: 0,
      ),
      TargetFeasibility.onTarget,
    );
  });

  test('rejects an out-of-range taken count', () {
    expect(
      () => classifyTargetFeasibility(
        taken: -1,
        target: TrickEstimate(4),
        remainingTricks: 2,
      ),
      throwsRangeError,
    );
    expect(
      () => classifyTargetFeasibility(
        taken: 14,
        target: TrickEstimate(4),
        remainingTricks: 2,
      ),
      throwsRangeError,
    );
  });

  test('rejects an out-of-range remaining-tricks count', () {
    expect(
      () => classifyTargetFeasibility(
        taken: 4,
        target: TrickEstimate(4),
        remainingTricks: -1,
      ),
      throwsRangeError,
    );
    expect(
      () => classifyTargetFeasibility(
        taken: 0,
        target: TrickEstimate(4),
        remainingTricks: 14,
      ),
      throwsRangeError,
    );
  });
}
