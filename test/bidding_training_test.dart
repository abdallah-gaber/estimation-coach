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

List<BiddingScenario> catalog() {
  final files =
      Directory('content/scenarios/v1/bidding')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  return [
    for (final file in files)
      BiddingScenario.fromJson(jsonDecode(file.readAsStringSync())),
  ];
}

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
    'all 73 legal choices return exact authored feedback across four ratings',
    () {
      final ratings = <DecisionRating>{};
      var count = 0;
      for (final scenario in catalog()) {
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
      expect(count, 73);
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
    expect(scenarios, hasLength(16));
    expect(scenarios.map((s) => s.id), catalog().map((s) => s.id));
    expect(() => scenarios.clear(), throwsUnsupportedError);
  });

  testWidgets(
    'all sixteen independent hands can be reviewed and session completed',
    (tester) async {
      final scenarios = catalog();
      await tester.pumpWidget(
        MaterialApp(home: BiddingTrainingScreen(loader: () async => scenarios)),
      );
      await tester.pumpAndSettle();
      for (var index = 0; index < scenarios.length; index++) {
        final scenario = scenarios[index];
        expect(find.text(scenario.title), findsOneWidget);
        final choice = scenario.allowedDecisions.choices.first;
        if (choice.action == BiddingAction.bid) {
          await tap(tester, '${choice.tricks}');
          final label = switch (choice.trump!) {
            Trump.spades => 'Spades',
            Trump.hearts => 'Hearts',
            Trump.diamonds => 'Diamonds',
            Trump.clubs => 'Clubs',
            Trump.noTrump => 'Sans',
          };
          await tap(tester, label);
          await tap(tester, 'Review bid');
        } else {
          await tap(
            tester,
            choice.action == BiddingAction.dash
                ? 'Dash · 0 tricks'
                : 'Enter bidding',
          );
        }
        expect(
          find.text(evaluateBid(scenario, choice)!.feedback.summary),
          findsOneWidget,
        );
        await tap(
          tester,
          index == scenarios.length - 1 ? 'Finish session' : 'Next hand',
        );
      }
      expect(find.text('Session complete'), findsOneWidget);
    },
  );

  testWidgets('default app loads the first training hand', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const EstimationCoachApp());
      await loadBiddingScenarios();
    });
    await tester.pumpAndSettle();
    // The default session is shuffled (EC-049): the first hand may be a
    // Dash/enter or a normal-bidding decision, so accept either heading.
    expect(find.textContaining('Hand 1 of 16'), findsOneWidget);
    expect(
      find.text('Dash or enter?').evaluate().isNotEmpty ||
          find.text('Your bid').evaluate().isNotEmpty,
      isTrue,
    );
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

  Future<void> completeHand(
    WidgetTester tester,
    BiddingScenario scenario,
  ) async {
    final choice = scenario.allowedDecisions.choices.first;
    if (choice.action == BiddingAction.bid) {
      await tap(tester, '${choice.tricks}');
      final label = switch (choice.trump!) {
        Trump.spades => 'Spades',
        Trump.hearts => 'Hearts',
        Trump.diamonds => 'Diamonds',
        Trump.clubs => 'Clubs',
        Trump.noTrump => 'Sans',
      };
      await tap(tester, label);
      await tap(tester, 'Review bid');
    } else {
      await tap(
        tester,
        choice.action == BiddingAction.dash
            ? 'Dash · 0 tricks'
            : 'Enter bidding',
      );
    }
  }

  testWidgets(
    'Practice again requests a new session order instead of resetting to '
    'the first loaded scenario',
    (tester) async {
      var calls = 0;
      final orderA = pack();
      final orderB = pack().reversed.toList();
      await tester.pumpWidget(
        MaterialApp(
          home: BiddingTrainingScreen(
            loader: () async => (++calls == 1) ? orderA : orderB,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(orderA[0].title), findsOneWidget);

      await completeHand(tester, orderA[0]);
      await tap(tester, 'Next hand');
      expect(find.text(orderA[1].title), findsOneWidget);
      await completeHand(tester, orderA[1]);
      await tap(tester, 'Finish session');
      expect(find.text('Session complete'), findsOneWidget);

      await tap(tester, 'Practice again');
      expect(calls, 2);
      expect(find.text(orderB[0].title), findsOneWidget);
    },
  );

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
