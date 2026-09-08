import 'package:estimation_coach/core/cards/cards.dart';
import 'package:estimation_coach/features/bidding_training/bidding_training_screen.dart';
import 'package:estimation_coach/features/play_training/play_table_fixture.dart';
import 'package:estimation_coach/features/play_training/play_table_preview_screen.dart';
import 'package:estimation_coach/shared/widgets/playing_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'bidding_training_test.dart' show pack, tap;

void main() {
  Finder card(String code) => find.byWidgetPredicate(
    (w) => w is PlayingCard && w.card == GameCard.parse(code),
  );
  test('preview public cards are distinct and match nine completed tricks', () {
    final cards = [
      ...PlayTableFixture.hand.cards,
      ...PlayTableFixture.trick.map((p) => p.card),
    ];
    expect(cards.toSet(), hasLength(cards.length));
    expect(PlayTableFixture.trick.first.seat, PlayTableFixture.leader);
    expect(
      PlayTableFixture.taken + 3 * PlayTableFixture.opponentTaken,
      13 - PlayTableFixture.hand.length,
    );
  });

  testWidgets('four seats, public context and follow-suit selection', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PlayTablePreviewScreen()));
    expect(find.text('You · South'), findsOneWidget);
    for (final seat in ['North', 'West', 'East']) {
      expect(find.text(seat), findsNWidgets(2));
    }
    expect(find.text('Your target: 4'), findsOneWidget);
    expect(find.text('Trump: Spades'), findsOneWidget);
    expect(find.text('Current trick'), findsOneWidget);
    expect(tester.widget<PlayingCard>(card('AS')).onTap, isNull);
    expect(tester.widget<PlayingCard>(card('2C')).onTap, isNull);
    await tester.ensureVisible(card('3H'));
    await tester.tap(card('3H'));
    await tester.pumpAndSettle();
    expect(tester.widget<PlayingCard>(card('3H')).selected, isTrue);
    await tester.ensureVisible(card('9H'));
    await tester.tap(card('9H'));
    await tester.pumpAndSettle();
    expect(tester.widget<PlayingCard>(card('3H')).selected, isFalse);
    expect(find.text('Selected: Nine of Hearts'), findsOneWidget);
    await tap(tester, 'Clear selection');
    expect(tester.widget<PlayingCard>(card('9H')).selected, isFalse);
    expect(find.byType(PlayingCard), findsNWidgets(7));
  });

  testWidgets('opening the preview and returning preserves bidding feedback', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: BiddingTrainingScreen(loader: () async => pack())),
    );
    await tester.pumpAndSettle();
    await tap(tester, 'Enter bidding');
    await tester.tap(find.byTooltip('Play table preview'));
    await tester.pumpAndSettle();
    expect(
      find.text('Layout and card selection demo · No coaching yet'),
      findsOneWidget,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Strong decision'), findsOneWidget);
    expect(find.text('Your choice · Enter bidding'), findsOneWidget);
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets('phone layout and selection at ${scale}x text', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: const PlayTablePreviewScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(card('9H'));
      await tester.tap(card('9H'));
      await tester.pumpAndSettle();
      await tap(tester, 'Clear selection');
      expect(tester.takeException(), isNull);
    });
  }
}
