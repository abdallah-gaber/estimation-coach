import 'package:estimation_coach/core/cards/cards.dart';
import 'package:estimation_coach/core/game_rules/exact_bid_outcome.dart';
import 'package:estimation_coach/features/play_training/play_training_screen.dart';
import 'package:estimation_coach/scenarios/bidding_scenario.dart';
import 'package:estimation_coach/scenarios/play_scenario.dart';
import 'package:estimation_coach/shared/widgets/playing_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'bidding_training_test.dart' show tap;
import 'play_training_test.dart' show playPack;

PlayScenario situation(int number) =>
    playPack().firstWhere((s) => s.id == 'play_target_protection_00$number');

void main() {
  test('same cards reverse the preferred decision at the exact target', () {
    final below = situation(1);
    final exact = situation(2);
    expect(below.situation.hand.cards, exact.situation.hand.cards);
    expect(
      below.situation.currentTrick.map((p) => p.card),
      exact.situation.currentTrick.map((p) => p.card),
    );
    expect(below.situation.trump, exact.situation.trump);
    expect(below.evaluate(GameCard.parse('KH'))!.rating, DecisionRating.strong);
    expect(below.evaluate(GameCard.parse('3H'))!.rating, DecisionRating.risky);
    expect(exact.evaluate(GameCard.parse('3H'))!.rating, DecisionRating.strong);
    expect(exact.evaluate(GameCard.parse('KH'))!.rating, DecisionRating.weak);
  });

  final cases = [
    (1, ExactBidOutcome.tookFewer, 'Below target', 'KH', '3H'),
    (2, ExactBidOutcome.onTarget, 'Exactly on target', '3H', 'KH'),
    (3, ExactBidOutcome.tookMore, 'Already above target', '7C', '2S'),
  ];
  for (final (number, outcome, label, first, second) in cases) {
    testWidgets('$label renders and both choices keep pre-play facts intact', (
      tester,
    ) async {
      final scenario = situation(number);
      final facts = scenario.situation;
      expect(
        classifyExactBid(
          tricksTaken: facts.playerTricksTaken,
          estimate: facts.trickEstimate,
        ),
        outcome,
      );
      await tester.pumpWidget(
        MaterialApp(home: PlayTrainingScreen(loader: () async => [scenario])),
      );
      await tester.pumpAndSettle();
      for (final code in [first, second]) {
        expect(find.text('Before this play: $label'), findsOneWidget);
        final card = find.byWidgetPredicate(
          (w) => w is PlayingCard && w.card == GameCard.parse(code),
        );
        await tester.ensureVisible(card);
        await tester.tap(card);
        await tester.pumpAndSettle();
        await tap(tester, 'Play card');
        final feedback = scenario.evaluate(GameCard.parse(code))!.feedback;
        // The concise headline is the default; the explanation stays behind
        // the detail action.
        expect(find.text(feedback.title), findsOneWidget);
        expect(find.text(feedback.summary), findsNothing);
        expect(find.text('Before this play: $label'), findsOneWidget);
        expect(find.text('Taken: ${facts.playerTricksTaken}'), findsOneWidget);
        expect(find.text('Outcome: not simulated.'), findsOneWidget);
        await tap(tester, 'Try another choice');
      }
    });
  }
}
