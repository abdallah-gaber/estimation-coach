import 'package:estimation_coach/shared/widgets/coaching_result_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _headline = 'Save the king; the ace is already gone';
const _summary =
    'East has already shown void in Diamonds and is free to trump this '
    'trick no matter which Diamond you play.';
const _points = [
  'The earlier trick shows East playing a club when Diamonds were led.',
  'The ace of Diamonds is already out, so the king is the highest left.',
  'The target still needs one more trick from the two remaining.',
];

void main() {
  /// Holds the disclosure state the way each trainer screen does, so the
  /// test exercises the same collapsed/expanded contract they rely on.
  Widget harness() {
    var open = false;
    return MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: CoachingResultCard(
              choiceLabel: 'Your choice · King of Diamonds',
              ratingLabel: 'Strong decision',
              headline: _headline,
              summary: _summary,
              points: _points,
              facts: const ['Outcome: not simulated.'],
              detailOpen: open,
              onToggleDetail: () => setState(() => open = !open),
              actions: const [Text('Next situation')],
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('the default view is compact: rating, one headline, no prose', (
    tester,
  ) async {
    await tester.pumpWidget(harness());
    expect(find.text('Strong decision'), findsOneWidget);
    expect(find.text(_headline), findsOneWidget);
    expect(find.text('Outcome: not simulated.'), findsOneWidget);
    expect(find.text('Your choice · King of Diamonds'), findsOneWidget);
    // Neither the explanation nor any evidence point is visible by default.
    expect(find.text(_summary), findsNothing);
    for (final point in _points) {
      expect(find.text(point), findsNothing);
    }
  });

  testWidgets('the detail action names how much evidence is waiting', (
    tester,
  ) async {
    await tester.pumpWidget(harness());
    expect(find.text('More detail · 3 points'), findsOneWidget);
    expect(find.text('Hide detail'), findsNothing);
  });

  testWidgets('expanding reveals the complete authored coaching, unaltered', (
    tester,
  ) async {
    await tester.pumpWidget(harness());
    await tester.tap(find.textContaining('More detail'));
    await tester.pumpAndSettle();
    expect(find.text(_summary), findsOneWidget);
    for (final point in _points) {
      expect(find.text(point), findsOneWidget);
    }
    // The headline is not repeated inside the detail.
    expect(find.text(_headline), findsOneWidget);
  });

  testWidgets('the action collapses the detail again', (tester) async {
    await tester.pumpWidget(harness());
    await tester.tap(find.textContaining('More detail'));
    await tester.pumpAndSettle();
    expect(find.text('Hide detail'), findsOneWidget);
    await tester.tap(find.text('Hide detail'));
    await tester.pumpAndSettle();
    expect(find.text(_summary), findsNothing);
    expect(find.text(_points.first), findsNothing);
    expect(find.text('More detail · 3 points'), findsOneWidget);
  });

  testWidgets('a single point is named in the singular', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoachingResultCard(
            choiceLabel: 'Your choice · Dash',
            ratingLabel: 'Weak',
            headline: _headline,
            summary: _summary,
            points: const ['The only point.'],
            facts: const [],
            detailOpen: false,
            onToggleDetail: () {},
            actions: const [],
          ),
        ),
      ),
    );
    expect(find.text('More detail · 1 point'), findsOneWidget);
  });
}
