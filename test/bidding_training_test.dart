import 'dart:convert';
import 'dart:io';

import 'package:estimation_coach/app/estimation_coach_app.dart';
import 'package:estimation_coach/core/coaching/evaluate_bid.dart';
import 'package:estimation_coach/features/bidding_training/bidding_training_screen.dart';
import 'package:estimation_coach/scenarios/bidding_scenario.dart';
import 'package:estimation_coach/scenarios/load_bidding_scenarios.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

List<BiddingScenario> pack() => [
  for (final id in ['bid_enter_controls_001', 'bid_safe_probable_001'])
    BiddingScenario.fromJson(
      jsonDecode(
        File('content/scenarios/v1/bidding/$id.json').readAsStringSync(),
      ),
    ),
];

Future<void> tap(WidgetTester tester, String label) async {
  final target = RegExp(r'^[4-7]$').hasMatch(label)
      ? find.widgetWithText(ChoiceChip, label)
      : find.text(label);
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'all 19 legal choices return exact authored feedback across four ratings',
    () {
      final ratings = <DecisionRating>{};
      var count = 0;
      for (final scenario in pack()) {
        expect(scenario.missingEvaluationCount, 0);
        for (final choice in scenario.allowedDecisions.choices) {
          final result = evaluateBid(scenario, choice)!;
          expect(
            result,
            same(scenario.evaluations.singleWhere((e) => e.decision == choice)),
          );
          ratings.add(result.rating);
          count++;
        }
      }
      expect(count, 19);
      expect(ratings, DecisionRating.values.toSet());
    },
  );

  test(
    'illegal choices throw and missing legal feedback is never invented',
    () {
      final scenarios = pack();
      expect(
        () => evaluateBid(
          scenarios.last,
          scenarios.first.allowedDecisions.choices.first,
        ),
        throwsArgumentError,
      );
      final data =
          jsonDecode(
                File(
                  'content/scenarios/v1/bidding/bid_safe_probable_001.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      data['evaluations'] = [];
      final incomplete = BiddingScenario.fromJson(data);
      expect(
        evaluateBid(incomplete, incomplete.allowedDecisions.choices.first),
        isNull,
      );
    },
  );

  test('bundled catalog is complete and immutable', () async {
    final scenarios = await loadBiddingScenarios();
    expect(scenarios.map((s) => s.id), pack().map((s) => s.id));
    expect(() => scenarios.clear(), throwsUnsupportedError);
  });

  testWidgets('default app loads the first training hand', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const EstimationCoachApp());
      await loadBiddingScenarios();
    });
    await tester.pumpAndSettle();
    expect(find.text('Dash or enter?'), findsOneWidget);
  });

  testWidgets('Dash fixes zero; next hand is independent; session restarts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: BiddingTrainingScreen(loader: () async => pack())),
    );
    await tester.pumpAndSettle();
    await tap(tester, 'Dash · 0 tricks');
    expect(find.text('Weak decision'), findsOneWidget);
    expect(
      find.text('Estimate fixed at 0; no normal bidding for this hand.'),
      findsOneWidget,
    );
    await tap(tester, 'Next hand');
    expect(find.text(pack().last.title), findsOneWidget);
    expect(find.text('Dash · 0 tricks'), findsNothing);
    await tap(tester, '4');
    await tap(tester, 'Spades');
    await tap(tester, 'Review bid');
    expect(find.text('Reasonable'), findsOneWidget);
    expect(find.text('Outcome: not simulated.'), findsOneWidget);
    await tap(tester, 'Why?');
    expect(
      find.text(pack().last.evaluations.first.feedback.points.first),
      findsOneWidget,
    );
    await tap(tester, 'Finish session');
    expect(find.text('Session complete'), findsOneWidget);
    await tap(tester, 'Practice again');
    expect(find.text('Dash or enter?'), findsOneWidget);
  });

  testWidgets(
    'legal raises disable lower suits and clear an invalid selection',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BiddingTrainingScreen(loader: () async => [pack().last]),
        ),
      );
      await tester.pumpAndSettle();
      await tap(tester, '4');
      ChoiceChip chip(String label) =>
          tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, label));
      expect(chip('Hearts').onSelected, isNull);
      expect(chip('Diamonds').onSelected, isNull);
      expect(chip('Clubs').onSelected, isNull);
      expect(chip('Sans').onSelected, isNotNull);
      await tap(tester, '5');
      await tap(tester, 'Hearts');
      await tap(tester, '4');
      expect(chip('Hearts').selected, isFalse);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Review bid'),
            )
            .onPressed,
        isNull,
      );
      await tap(tester, 'Sans');
      await tap(tester, 'Review bid');
      expect(find.text('Risky'), findsOneWidget);
      await tap(tester, 'Try another choice');
      expect(find.text('Your bid'), findsOneWidget);
    },
  );

  testWidgets('load failure can be retried', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: BiddingTrainingScreen(
          loader: () async {
            if (++calls == 1) throw const FormatException('Unavailable');
            return pack();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Training could not load.'), findsOneWidget);
    await tap(tester, 'Retry');
    expect(find.text('Dash or enter?'), findsOneWidget);
  });

  testWidgets('320px with double text scale can reach choices and feedback', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: BiddingTrainingScreen(loader: () async => pack()),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tap(tester, 'Enter bidding');
    expect(find.text('Strong decision'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tap(tester, 'Next hand');
    await tap(tester, '4');
    await tap(tester, 'Spades');
    await tap(tester, 'Review bid');
    expect(find.text('Reasonable'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
