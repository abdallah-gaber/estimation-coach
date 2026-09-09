import 'dart:convert';
import 'dart:io';

import 'package:estimation_coach/core/cards/cards.dart';
import 'package:estimation_coach/core/game_rules/bidding.dart' show PlayerSeat;
import 'package:estimation_coach/core/game_rules/play_situation.dart';
import 'package:estimation_coach/core/game_rules/target_feasibility.dart';
import 'package:estimation_coach/core/game_rules/trick_winner.dart';
import 'package:estimation_coach/scenarios/bidding_scenario.dart'
    show DecisionRating;
import 'package:estimation_coach/scenarios/play_scenario.dart';
import 'package:flutter_test/flutter_test.dart';

List<PlayScenario> _productionPlayScenarios() {
  final files =
      Directory('content/scenarios/v1/play')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  return [
    for (final file in files)
      PlayScenario.fromJson(jsonDecode(file.readAsStringSync())),
  ];
}

/// Whether South is the last seat to act in the current trick — the one
/// case where a candidate card's win/loss for *this specific trick* is
/// mechanically provable from already-visible cards alone, via
/// [trickWinner] applied to the hypothetical completed trick. When South
/// is leading or another seat still has to respond, nothing here can prove
/// whether a candidate wins without knowing unseen hands (or, for
/// void-tracking scenarios, without re-deriving the same void reasoning the
/// coaching itself uses) — see the "not mechanically checkable" group below.
bool _actsLast(PlaySituation situation) => situation.currentTrick.length == 3;

/// True if [candidate] would win the current trick, assuming it is played
/// next — only meaningful when [_actsLast] is true, since only then does
/// adding [candidate] complete the trick.
bool _wins(PlaySituation situation, GameCard candidate) {
  final completedTrick = ObservedTrick([
    ...situation.currentTrick,
    SeatPlay(situation.playerPosition, candidate),
  ]);
  return trickWinner(completedTrick, situation.trump) ==
      situation.playerPosition;
}

void main() {
  // Audited 2026-09-09 (owner review): every production play scenario's
  // target-feasibility state, from South's own taken/target/remaining hand.
  // A new or edited scenario must update this map deliberately — that is
  // the point: feasibility must be reviewed, not just computed in passing.
  const expected = <String, TargetFeasibility>{
    'play_mixed_tactical_001': TargetFeasibility.mustWinAll,
    'play_mixed_tactical_002': TargetFeasibility.slack,
    'play_safe_probable_001': TargetFeasibility.slack,
    'play_safe_probable_002': TargetFeasibility.slack,
    'play_safe_probable_003': TargetFeasibility.mustWinAll,
    'play_safe_probable_004': TargetFeasibility.mustWinAll,
    'play_target_protection_001': TargetFeasibility.slack,
    'play_target_protection_002': TargetFeasibility.onTarget,
    'play_target_protection_003': TargetFeasibility.alreadyOver,
    'play_target_protection_004': TargetFeasibility.onTarget,
    'play_target_protection_005': TargetFeasibility.slack,
    'play_target_protection_006': TargetFeasibility.mustWinAll,
    'play_void_tracking_001': TargetFeasibility.slack,
    'play_void_tracking_002': TargetFeasibility.mustWinAll,
    'play_void_tracking_003': TargetFeasibility.slack,
    'play_void_tracking_004': TargetFeasibility.slack,
    'play_void_tracking_005': TargetFeasibility.slack,
  };

  test('every production play scenario has a reviewed, matching feasibility '
      'classification', () {
    final scenarios = _productionPlayScenarios();
    expect(
      scenarios.map((s) => s.id).toSet(),
      expected.keys.toSet(),
      reason:
          'a scenario was added or removed without updating the reviewed '
          'feasibility table above',
    );
    for (final scenario in scenarios) {
      final situation = scenario.situation;
      final actual = classifyTargetFeasibility(
        taken: situation.playerTricksTaken,
        target: situation.trickEstimate,
        remainingTricks: situation.hand.length,
      );
      expect(
        actual,
        expected[scenario.id],
        reason: '${scenario.id} (${scenario.title})',
      );
    }
  });

  test(
    'play_void_tracking_005 has slack, not mustWinAll — the fixed state',
    () {
      // Regression for the owner-review finding: with the original
      // tricks_taken (South 2 of 4, two cards remaining), South needed
      // both remaining tricks, yet the recommended card (4D) had no case
      // for winning at all. Rebalanced to South 3 of 4 / North 2 of 4
      // (same 11-completed-trick total) so needing only one more of the
      // two remaining tricks is genuinely true, and the "avoid the known
      // risk" recommendation becomes a real safe-vs-probable trade-off
      // rather than a contradiction of the exact-target objective.
      final scenario = PlayScenario.fromJson(
        jsonDecode(
          File(
            'content/scenarios/v1/play/play_void_tracking_005.json',
          ).readAsStringSync(),
        ),
      );
      final situation = scenario.situation;
      expect(
        classifyTargetFeasibility(
          taken: situation.playerTricksTaken,
          target: situation.trickEstimate,
          remainingTricks: situation.hand.length,
        ),
        TargetFeasibility.slack,
      );
      expect(situation.tricksTaken[PlayerSeat.south], 3);
      expect(situation.tricksTaken[PlayerSeat.north], 2);
      expect(
        situation.tricksTaken.values.fold(0, (a, b) => a + b),
        13 - situation.hand.length,
        reason: 'tricksTaken must still sum to the completed-trick total',
      );
    },
  );

  group('mustWinAll scenarios never recommend giving up the current trick '
      '(mechanically checkable subset only)', () {
    // Mechanical proof is only possible when South acts last: only then
    // does trickWinner (applied to the hypothetical completed trick) tell
    // us, from public information alone, whether a specific candidate
    // card actually wins. Of the five mustWinAll scenarios
    // (play_mixed_tactical_001, play_safe_probable_003,
    // play_safe_probable_004, play_target_protection_006,
    // play_void_tracking_002), only play_target_protection_006 has South
    // acting last; the check below runs generically so it also covers any
    // future mustWinAll scenario that acts last, not just this one file.
    test('every Strong-rated choice in a mechanically-checkable mustWinAll '
        'scenario actually wins the current trick', () {
      final scenarios = _productionPlayScenarios();
      var checked = 0;
      for (final scenario in scenarios) {
        final situation = scenario.situation;
        final feasibility = classifyTargetFeasibility(
          taken: situation.playerTricksTaken,
          target: situation.trickEstimate,
          remainingTricks: situation.hand.length,
        );
        if (feasibility != TargetFeasibility.mustWinAll ||
            !_actsLast(situation)) {
          continue;
        }
        checked++;
        for (final evaluation in scenario.evaluations) {
          if (evaluation.rating != DecisionRating.strong) continue;
          expect(
            _wins(situation, evaluation.card),
            isTrue,
            reason:
                '${scenario.id}: Strong-rated ${evaluation.card.notation} '
                'must actually win this must-win-all trick',
          );
        }
      }
      expect(
        checked,
        1,
        reason:
            'exactly one production scenario (play_target_protection_006) '
            'is currently both mustWinAll and acts-last; update this '
            'count deliberately if that changes',
      );
    });
  });

  test('the other four mustWinAll scenarios are not mechanically checkable — '
      'documented, not silently assumed correct', () {
    // None of these four has South acting last (at least one other
    // seat's still-pending card could beat the candidate).
    // play_void_tracking_002 specifically resolves this in *its own*
    // coaching only by combining a derived void (East confirmed void in
    // Hearts) with the Sans rule — a form of reasoning this test would
    // have to reimplement to check mechanically, which would just be a
    // second, parallel coaching engine liable to drift from the first
    // rather than an independent check of it. Per the task's own
    // instruction, this is documented instead of invented: these four
    // scenarios' Strong ratings remain reviewed content (see
    // docs/COACHING_REVIEW.md), not something this test suite proves.
    // (play_void_tracking_005 is not in this list: the owner-review fix
    // moved it out of mustWinAll entirely — see the dedicated regression
    // test above.)
    final notMechanicallyCheckable = [
      'play_mixed_tactical_001',
      'play_safe_probable_003',
      'play_safe_probable_004',
      'play_void_tracking_002',
    ];
    final scenarios = _productionPlayScenarios();
    for (final id in notMechanicallyCheckable) {
      final scenario = scenarios.firstWhere((s) => s.id == id);
      final situation = scenario.situation;
      expect(
        classifyTargetFeasibility(
          taken: situation.playerTricksTaken,
          target: situation.trickEstimate,
          remainingTricks: situation.hand.length,
        ),
        TargetFeasibility.mustWinAll,
      );
      expect(
        _actsLast(situation),
        isFalse,
        reason:
            '$id is in the non-mechanically-checkable group because South '
            'does not act last here; if that ever changes, move it into '
            'the mechanically-checked group above instead',
      );
    }
  });
}
