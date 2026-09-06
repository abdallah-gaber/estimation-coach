import 'package:estimation_coach/app/estimation_coach_app.dart';
import 'package:estimation_coach/shared/widgets/playing_card.dart';
import 'package:flutter/material.dart';
import 'dart:ui' show Tristate;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Finder card(int index) => find.byKey(ValueKey('card-$index'));

  testWidgets(
    'selection switches, toggles off, clears and ignores locked card',
    (tester) async {
      await tester.pumpWidget(const EstimationCoachApp());
      expect(find.byType(PlayingCard), findsNWidgets(4));
      expect(find.text('No card selected'), findsOneWidget);
      await tester.tap(card(0));
      await tester.pumpAndSettle();
      expect(find.text('Ace of Spades selected'), findsOneWidget);
      await tester.tap(card(2));
      await tester.pumpAndSettle();
      expect(find.text('Ace of Spades selected'), findsOneWidget);
      await tester.tap(card(1));
      await tester.pumpAndSettle();
      expect(find.text('King of Hearts selected'), findsOneWidget);
      expect(tester.widget<PlayingCard>(card(0)).selected, isFalse);
      await tester.tap(card(1));
      await tester.pumpAndSettle();
      expect(find.text('No card selected'), findsOneWidget);
      await tester.tap(card(3));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Clear selection'));
      await tester.tap(find.text('Clear selection'));
      await tester.pumpAndSettle();
      expect(find.text('No card selected'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'cards expose identity and enabled/selected state to accessibility',
    (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(const EstimationCoachApp());
      var ace = tester.getSemantics(find.bySemanticsLabel('Ace of Spades'));
      expect(ace.flagsCollection.isButton, isTrue);
      expect(ace.flagsCollection.isEnabled, Tristate.isTrue);
      final locked = tester.getSemantics(
        find.bySemanticsLabel('Ten of Diamonds'),
      );
      expect(locked.flagsCollection.isEnabled, isNot(Tristate.none));
      expect(locked.flagsCollection.isEnabled, Tristate.isFalse);
      await tester.tap(card(0));
      await tester.pumpAndSettle();
      ace = tester.getSemantics(find.bySemanticsLabel('Ace of Spades'));
      expect(ace.flagsCollection.isSelected, Tristate.isTrue);
      handle.dispose();
    },
  );

  testWidgets('keyboard activates cards and skips the disabled specimen', (
    tester,
  ) async {
    await tester.pumpWidget(const EstimationCoachApp());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Ace of Spades selected'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Jack of Clubs selected'), findsOneWidget);
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets('320px phone layout works at ${scale}x text size', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(const EstimationCoachApp());
      expect(
        MediaQuery.textScalerOf(tester.element(card(0))).scale(26),
        26 * scale,
      );
      for (final index in [0, 1, 3]) {
        await tester.ensureVisible(card(index));
        await tester.tap(card(index));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(tester.getRect(card(index)).left, greaterThanOrEqualTo(0));
        expect(tester.getRect(card(index)).right, lessThanOrEqualTo(320));
      }
      await tester.ensureVisible(find.text('Clear selection'));
      await tester.tap(find.text('Clear selection'));
      await tester.pumpAndSettle();
      expect(find.text('No card selected'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
