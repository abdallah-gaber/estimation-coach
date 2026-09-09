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
    await tester.ensureVisible(card('AH'));
    await tester.tap(card('AH'));
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
}
