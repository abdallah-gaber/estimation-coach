import 'dart:convert';
import 'dart:io';

import 'package:estimation_coach/core/cards/cards.dart';
import 'package:estimation_coach/features/bidding_training/bidding_labels.dart';
import 'package:estimation_coach/features/bidding_training/bidding_training_screen.dart';
import 'package:estimation_coach/features/play_training/play_training_screen.dart';
import 'package:estimation_coach/scenarios/bidding_scenario.dart'
    show DecisionRating;
import 'package:estimation_coach/scenarios/load_play_scenarios.dart';
import 'package:estimation_coach/scenarios/play_scenario.dart';
import 'package:estimation_coach/shared/widgets/card_labels.dart';
import 'package:estimation_coach/shared/widgets/playing_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'bidding_training_test.dart' show pack, tap;

List<PlayScenario> playPack() {
  final files =
      Directory('content/scenarios/v1/play')
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  return [
    for (final file in files)
      PlayScenario.fromJson(jsonDecode(file.readAsStringSync())),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Finder card(String code) => find.byWidgetPredicate(
    (w) => w is PlayingCard && w.card == GameCard.parse(code),
  );

  test('bundled play catalog is complete and immutable', () async {
    final scenarios = await loadPlayScenarios();
    expect(scenarios, isNotEmpty);
    expect(scenarios.map((s) => s.id), playPack().map((s) => s.id));
    expect(() => scenarios.clear(), throwsUnsupportedError);
  });

  test('all legal choices return exact authored feedback across ratings', () {
    final ratings = <DecisionRating>{};
    for (final scenario in playPack()) {
      expect(scenario.missingEvaluationCount, 0);
      for (final choice in scenario.situation.legalChoices) {
        final result = scenario.evaluate(choice)!;
        ratings.add(result.rating);
        expect(result.card, choice);
      }
    }
    expect(ratings, {
      DecisionRating.strong,
      DecisionRating.weak,
      DecisionRating.risky,
      DecisionRating.reasonable,
    });
  });

  test(
    'illegal choices throw and missing legal feedback is never invented',
    () {
      final scenarios = playPack();
      expect(
        () => scenarios.first.evaluate(
          scenarios.last.situation.legalChoices.first,
        ),
        throwsArgumentError,
      );
      final data =
          jsonDecode(
                File(
                  'content/scenarios/v1/play/play_safe_probable_001.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      data['evaluations'] = [data['evaluations'][0]];
      final incomplete = PlayScenario.fromJson(data);
      expect(incomplete.missingEvaluationCount, 1);
      expect(incomplete.evaluate(GameCard.parse('3H')), isNull);
    },
  );

  testWidgets('all situations can be reviewed and session completed', (
    tester,
  ) async {
    final scenarios = playPack();
    await tester.pumpWidget(
      MaterialApp(home: PlayTrainingScreen(loader: () async => scenarios)),
    );
    await tester.pumpAndSettle();
    for (var index = 0; index < scenarios.length; index++) {
      final scenario = scenarios[index];
      expect(find.text(scenario.title), findsOneWidget);
      final choice = scenario.situation.legalChoices.first;
      await tester.ensureVisible(card(choice.notation));
      await tester.tap(card(choice.notation));
      await tester.pumpAndSettle();
      await tap(tester, 'Play card');
      final result = scenario.evaluate(choice)!;
      expect(find.text(result.rating.label), findsOneWidget);
      expect(find.text(result.feedback.summary), findsOneWidget);
      await tap(
        tester,
        index == scenarios.length - 1 ? 'Finish session' : 'Next situation',
      );
    }
    expect(find.text('Session complete'), findsOneWidget);
  });

  testWidgets(
    'Practice again requests a new session order instead of resetting to '
    'the first loaded scenario',
    (tester) async {
      var calls = 0;
      final orderA = [
        playPack().firstWhere((s) => s.id == 'play_safe_probable_001'),
        playPack().firstWhere((s) => s.id == 'play_safe_probable_002'),
      ];
      final orderB = orderA.reversed.toList();
      await tester.pumpWidget(
        MaterialApp(
          home: PlayTrainingScreen(
            loader: () async => (++calls == 1) ? orderA : orderB,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(orderA[0].title), findsOneWidget);

      Future<void> completeSituation(PlayScenario scenario) async {
        final choice = scenario.situation.legalChoices.first;
        await tester.ensureVisible(card(choice.notation));
        await tester.tap(card(choice.notation));
        await tester.pumpAndSettle();
        await tap(tester, 'Play card');
      }

      await completeSituation(orderA[0]);
      await tap(tester, 'Next situation');
      expect(find.text(orderA[1].title), findsOneWidget);
      await completeSituation(orderA[1]);
      await tap(tester, 'Finish session');
      expect(find.text('Session complete'), findsOneWidget);

      await tap(tester, 'Practice again');
      expect(calls, 2);
      expect(find.text(orderB[0].title), findsOneWidget);
    },
  );

  testWidgets(
    'locked cards cannot be selected; Try another choice resets without advancing',
    (tester) async {
      final scenario = playPack().firstWhere(
        (s) => s.id == 'play_safe_probable_001',
      );
      await tester.pumpWidget(
        MaterialApp(home: PlayTrainingScreen(loader: () async => [scenario])),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<PlayingCard>(card('2C')).onTap, isNull);
      expect(tester.widget<PlayingCard>(card('5D')).onTap, isNull);
      await tester.ensureVisible(card('3H'));
      await tester.tap(card('3H'));
      await tester.pumpAndSettle();
      await tap(tester, 'Play card');
      expect(find.text('Weak decision'), findsOneWidget);
      expect(find.text('Giving away a guaranteed trick'), findsOneWidget);
      expect(find.text('Outcome: not simulated.'), findsOneWidget);
      await tap(tester, 'Why?');
      expect(
        find.text(
          scenario.evaluate(GameCard.parse('3H'))!.feedback.points.first,
        ),
        findsOneWidget,
      );
      await tap(tester, 'Try another choice');
      expect(find.text(scenario.title), findsOneWidget);
      expect(find.text('Choose a card to play.'), findsOneWidget);
      await tester.ensureVisible(card('AH'));
      await tester.tap(card('AH'));
      await tester.pumpAndSettle();
      await tap(tester, 'Play card');
      expect(find.text('Strong decision'), findsOneWidget);
    },
  );

  testWidgets(
    'opening play practice and returning preserves bidding feedback',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: BiddingTrainingScreen(loader: () async => pack())),
      );
      await tester.pumpAndSettle();
      await tap(tester, 'Enter bidding');
      await tester.runAsync(() async {
        await tester.tap(find.byTooltip('Play practice'));
        await tester.pump();
        await loadPlayScenarios();
      });
      await tester.pumpAndSettle();
      expect(find.text('Play practice'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Strong decision'), findsOneWidget);
      expect(find.text('Your choice · Enter bidding'), findsOneWidget);
    },
  );

  testWidgets('reduced motion commits without an animation overlay', (
    tester,
  ) async {
    final trumpScenario = playPack().firstWhere(
      (s) => s.id == 'play_safe_probable_002',
    );
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: PlayTrainingScreen(loader: () async => [trumpScenario]),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(card('2S'));
    await tester.tap(card('2S'));
    await tester.pump();
    await tap(tester, 'Play card');
    expect(find.text('Played: Two of Spades'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaving during a card flight cleans up the overlay', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: BiddingTrainingScreen(loader: () async => pack())),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.byTooltip('Play practice'));
      await tester.pump();
      await loadPlayScenarios();
    });
    await tester.pumpAndSettle();
    // The default session is shuffled (EC-049): pick whichever card is
    // actually legal in the situation shown rather than a fixed notation.
    final legalCard = tester
        .widgetList<PlayingCard>(find.byType(PlayingCard))
        .firstWhere((widget) => widget.onTap != null)
        .card;
    await tester.ensureVisible(card(legalCard.notation));
    await tester.tap(card(legalCard.notation));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Play card'));
    await tester.tap(find.text('Play card'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Dash or enter?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets('phone layout and selection at ${scale}x text', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final trumpScenario = playPack().firstWhere(
        (s) => s.id == 'play_safe_probable_002',
      );
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: PlayTrainingScreen(loader: () async => [trumpScenario]),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(card('2S'));
      await tester.tap(card('2S'));
      await tester.pumpAndSettle();
      await tap(tester, 'Play card');
      expect(find.text('Played: Two of Spades'), findsOneWidget);
      await tap(tester, 'Try another choice');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'observed play is shown and void-derived coaching drives the decision',
    (tester) async {
      final scenario = playPack().firstWhere(
        (s) => s.id == 'play_void_tracking_001',
      );
      await tester.pumpWidget(
        MaterialApp(home: PlayTrainingScreen(loader: () async => [scenario])),
      );
      await tester.pumpAndSettle();
      expect(find.text('Observed play'), findsOneWidget);
      for (final code in ['7D', '10D', 'AD', '6C']) {
        expect(card(code), findsOneWidget);
      }
      await tester.ensureVisible(card('KD'));
      await tester.tap(card('KD'));
      await tester.pumpAndSettle();
      await tap(tester, 'Play card');
      expect(find.text('Risky'), findsOneWidget);
      expect(
        find.text('Risking your best card on a trick you don\'t control'),
        findsOneWidget,
      );
      await tap(tester, 'Try another choice');
      await tester.ensureVisible(card('3D'));
      await tester.tap(card('3D'));
      await tester.pumpAndSettle();
      await tap(tester, 'Play card');
      expect(find.text('Strong decision'), findsOneWidget);
      expect(
        find.text('Save the king; the ace is already gone'),
        findsOneWidget,
      );
    },
  );

  testWidgets('observed play does not appear for scenarios without history', (
    tester,
  ) async {
    final scenario = playPack().firstWhere(
      (s) => s.id == 'play_safe_probable_001',
    );
    await tester.pumpWidget(
      MaterialApp(home: PlayTrainingScreen(loader: () async => [scenario])),
    );
    await tester.pumpAndSettle();
    expect(find.text('Observed play'), findsNothing);
  });

  testWidgets(
    'every bundled scenario shows a real target and taken count for all '
    'three opponents, including the seat that led',
    (tester) async {
      for (final scenario in playPack()) {
        final situation = scenario.situation;
        expect(
          situation.opponentEstimates,
          hasLength(3),
          reason: '${scenario.id} should author a complete opponent set',
        );
        await tester.pumpWidget(
          MaterialApp(
            // A distinct key forces a fresh State per scenario; without it
            // the screen keeps showing the first one it loaded.
            home: PlayTrainingScreen(
              key: ValueKey(scenario.id),
              loader: () async => [scenario],
            ),
          ),
        );
        await tester.pumpAndSettle();
        // Seats can legitimately share a label (same target, same taken), so
        // count expected occurrences rather than assuming each is unique.
        final expected = <String, int>{};
        for (final entry in situation.opponentEstimates.entries) {
          final label =
              'Target ${entry.value.tricks} · '
              'Taken ${situation.tricksTaken[entry.key]}';
          // The leading seat keeps its led-suit line above the same
          // target/taken line instead of replacing it.
          final chip = entry.key == situation.leader
              ? 'Led ${situation.ledSuit!.label}\n$label'
              : label;
          expected.update(chip, (count) => count + 1, ifAbsent: () => 1);
        }
        for (final entry in expected.entries) {
          expect(
            find.text(entry.key),
            findsNWidgets(entry.value),
            reason: '${scenario.id} should show "${entry.key}"',
          );
        }
        expect(find.textContaining('Target unknown'), findsNothing);
      }
    },
  );

  testWidgets(
    'an opponent left without an authored estimate falls back to an honest '
    'unknown target rather than an invented one',
    (tester) async {
      final data =
          jsonDecode(
                File(
                  'content/scenarios/v1/play/play_safe_probable_001.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      // Drop North's authored estimate only. North (taken 2) is a
      // non-leading opponent here; East leads and West keeps its estimate.
      (data['situation']['opponent_estimates'] as Map).remove('north');
      final scenario = PlayScenario.fromJson(data);
      expect(scenario.situation.opponentEstimates, hasLength(2));
      await tester.pumpWidget(
        MaterialApp(home: PlayTrainingScreen(loader: () async => [scenario])),
      );
      await tester.pumpAndSettle();
      expect(find.text('Target unknown · Taken 2'), findsOneWidget);
      expect(find.text('Target 4 · Taken 3'), findsOneWidget);
    },
  );
}
