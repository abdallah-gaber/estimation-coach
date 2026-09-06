import 'package:estimation_coach/app/estimation_coach_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('launches the foundation preview', (tester) async {
    await tester.pumpWidget(const EstimationCoachApp());

    expect(find.text('Estimation Coach'), findsOneWidget);
    expect(find.text('Foundation preview'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('preview fits a small phone with large text', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(2)),
        child: EstimationCoachApp(),
      ),
    );

    await tester.ensureVisible(
      find.text('Next up: a visual hand and bid practice.'),
    );
    expect(tester.takeException(), isNull);
  });
}
