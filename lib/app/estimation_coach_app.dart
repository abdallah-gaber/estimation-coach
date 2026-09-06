import 'package:flutter/material.dart';

/// The application shell. Training features arrive in subsequent milestones.
class EstimationCoachApp extends StatelessWidget {
  const EstimationCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estimation Coach',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF246650)),
        scaffoldBackgroundColor: const Color(0xFFF6F7F2),
      ),
      home: const _FoundationScreen(),
    );
  }
}

class _FoundationScreen extends StatelessWidget {
  const _FoundationScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.style_outlined,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Estimation Coach',
                    style: theme.textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Better decisions. One hand at a time.',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 32),
                  Card.filled(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Foundation preview',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'The app is ready to grow. Training scenarios '
                            'will arrive in the next milestones.',
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Next up: a visual hand and bid practice.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
