import 'package:flutter/material.dart';

import '../../app/visual_tokens.dart';
import '../../shared/widgets/playing_card.dart';
import 'preview_cards.dart';

class VisualPreviewScreen extends StatefulWidget {
  const VisualPreviewScreen({super.key});

  @override
  State<VisualPreviewScreen> createState() => _VisualPreviewScreenState();
}

class _VisualPreviewScreenState extends State<VisualPreviewScreen> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final selection = _selected == null ? null : previewCards[_selected!];
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(VisualTokens.large),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: VisualTokens.large),
                  Text('ESTIMATION COACH', style: text.labelLarge),
                  const SizedBox(height: VisualTokens.large),
                  Text('Get a feel for the cards.', style: text.headlineLarge),
                  const SizedBox(height: VisualTokens.small),
                  Text(
                    'Tap a card to select it. Tap again to release.',
                    style: text.bodyLarge,
                  ),
                  const SizedBox(height: VisualTokens.large),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(VisualTokens.large),
                    decoration: BoxDecoration(
                      color: VisualTokens.table,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CARD PREVIEW',
                          style: text.labelLarge?.copyWith(
                            color: VisualTokens.accent,
                          ),
                        ),
                        const SizedBox(height: VisualTokens.large),
                        Center(
                          child: Wrap(
                            spacing: VisualTokens.medium,
                            runSpacing: VisualTokens.large,
                            alignment: WrapAlignment.center,
                            children: [
                              for (var i = 0; i < previewCards.length; i++)
                                PlayingCard(
                                  key: ValueKey('card-$i'),
                                  rank: previewCards[i].rank,
                                  rankLabel: previewCards[i].label,
                                  suit: previewCards[i].suit,
                                  selected: _selected == i,
                                  onTap: previewCards[i].enabled
                                      ? () => setState(
                                          () => _selected = _selected == i
                                              ? null
                                              : i,
                                        )
                                      : null,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: VisualTokens.large),
                        const Text(
                          'The locked 10 ♦ shows an unavailable card.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: VisualTokens.large),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      selection == null
                          ? 'No card selected'
                          : '${selection.label} of ${selection.suit.label} selected',
                      style: text.titleMedium,
                    ),
                  ),
                  const SizedBox(height: VisualTokens.small),
                  OutlinedButton.icon(
                    onPressed: _selected == null
                        ? null
                        : () => setState(() => _selected = null),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Clear selection'),
                  ),
                  const SizedBox(height: VisualTokens.large),
                  Text(
                    'Visual foundations • Preview only',
                    style: text.labelLarge,
                  ),
                  const SizedBox(height: VisualTokens.small),
                  const Text(
                    'These four sample cards let you try the controls. Bidding and coaching come next.',
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
