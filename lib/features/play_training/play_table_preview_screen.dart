import 'package:flutter/material.dart';

import '../../app/visual_tokens.dart';
import '../../core/cards/cards.dart';
import '../../core/game_rules/legal_cards.dart';
import '../../shared/widgets/card_labels.dart';
import '../../shared/widgets/playing_card.dart';
import '../bidding_training/bidding_labels.dart';
import 'play_table_fixture.dart';

class PlayTablePreviewScreen extends StatefulWidget {
  const PlayTablePreviewScreen({super.key});

  @override
  State<PlayTablePreviewScreen> createState() => _PlayTablePreviewScreenState();
}

class _PlayTablePreviewScreenState extends State<PlayTablePreviewScreen> {
  GameCard? _selected;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final allowed = legalCards(
      PlayTableFixture.hand,
      ledSuit: PlayTableFixture.trick.first.card.suit,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Play table preview')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Layout and card selection demo · No coaching yet',
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text('Trump: ${PlayTableFixture.trump.label}'),
                      ),
                      const Chip(
                        label: Text('Your target: ${PlayTableFixture.target}'),
                      ),
                      const Chip(
                        label: Text('Taken: ${PlayTableFixture.taken}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: VisualTokens.table,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        _seat(
                          'North',
                          'Taken: ${PlayTableFixture.opponentTaken}',
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _seat('West', 'Led Hearts'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: _seat(
                                  'East',
                                  'Taken: ${PlayTableFixture.opponentTaken}',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Current trick',
                          style: text.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            for (final play in PlayTableFixture.trick)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PlayingCard(
                                    card: play.card,
                                    compact: true,
                                    readOnly: true,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    seatLabel(play.seat),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _seat('You · South', 'Your turn', active: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Your remaining hand', style: text.titleLarge),
                  const SizedBox(height: 8),
                  const Text(
                    'Hearts were led. Choose a Heart; locked cards cannot be selected.',
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 16,
                    children: [
                      for (final card in PlayTableFixture.hand.cards)
                        PlayingCard(
                          card: card,
                          selected: card == _selected,
                          onTap: allowed.contains(card)
                              ? () => setState(
                                  () => _selected = _selected == card
                                      ? null
                                      : card,
                                )
                              : null,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _selected == null
                          ? 'Choose a card to preview selection.'
                          : 'Selected: ${_selected!.label}',
                      style: text.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Selection only. No card is played and no winner or rating is calculated.',
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _selected == null
                        ? null
                        : () => setState(() => _selected = null),
                    child: const Text('Clear selection'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _seat(String name, String detail, {bool active = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: active
          ? VisualTokens.accent
          : Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: active ? VisualTokens.ink : Colors.white,
          ),
        ),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: TextStyle(color: active ? VisualTokens.ink : Colors.white),
        ),
      ],
    ),
  );
}
