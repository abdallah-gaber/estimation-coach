import 'package:flutter/material.dart';

import '../features/visual_preview/visual_preview_screen.dart';
import 'visual_tokens.dart';

class EstimationCoachApp extends StatelessWidget {
  const EstimationCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estimation Coach',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: VisualTokens.table),
        scaffoldBackgroundColor: VisualTokens.paper,
      ),
      home: const VisualPreviewScreen(),
    );
  }
}
