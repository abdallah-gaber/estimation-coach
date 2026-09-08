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
  GameCard? _played;
  bool _busy = false;
  OverlayEntry? _flight;
  final _destinationKey = GlobalKey();
  final _handKeys = {
    for (final card in PlayTableFixture.hand.cards) card: GlobalKey(),
  };

  @override
  void dispose() {
    _flight?.remove();
    _flight?.dispose();
    _flight = null;
    super.dispose();
  }

  void _finishPlay(GameCard card) {
    _flight?.remove();
    _flight?.dispose();
    _flight = null;
    if (!mounted) return;
    setState(() {
      _played = card;
      _selected = null;
      _busy = false;
    });
  }

  Future<void> _commit() async {
    final card = _selected;
    if (card == null ||
        _busy ||
        _played != null ||
        !isLegalPlay(
          PlayTableFixture.hand,
          card,
          ledSuit: PlayTableFixture.trick.first.card.suit,
        )) {
      return;
    }
    final reduced = MediaQuery.disableAnimationsOf(context);
    setState(() => _busy = true);
    // Bring the destination into view before animating from the hand's actual
    // position. On a small screen the card travels into view from below.
    await Scrollable.ensureVisible(
      _destinationKey.currentContext!,
      duration: reduced ? Duration.zero : const Duration(milliseconds: 160),
    );
    if (!mounted) return;
    if (reduced) {
      _finishPlay(card);
      return;
    }
    final overlay = Overlay.of(context);
    final overlayBox = overlay.context.findRenderObject()! as RenderBox;
    Rect bounds(GlobalKey key) {
      final box = key.currentContext!.findRenderObject()! as RenderBox;
      return box.localToGlobal(Offset.zero, ancestor: overlayBox) & box.size;
    }

    final from = bounds(_handKeys[card]!);
    final to = bounds(_destinationKey);
    _flight = OverlayEntry(
      builder: (_) => IgnorePointer(
        child: ExcludeSemantics(
          child: TweenAnimationBuilder<Rect?>(
            tween: RectTween(begin: from, end: to),
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            onEnd: () => _finishPlay(card),
            builder: (_, rect, child) => Stack(
              children: [Positioned.fromRect(rect: rect!, child: child!)],
            ),
            child: FittedBox(child: PlayingCard(card: card, readOnly: true)),
          ),
        ),
      ),
    );
    overlay.insert(_flight!);
  }

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
                  const Text('Card play demo · No coaching yet'),
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
                            if (_selected != null || _played != null)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    key: _destinationKey,
                                    width:
                                        56 *
                                        MediaQuery.textScalerOf(
                                          context,
                                        ).scale(26) /
                                        26,
                                    height:
                                        82 *
                                        MediaQuery.textScalerOf(
                                          context,
                                        ).scale(26) /
                                        26,
                                    child: _played == null
                                        ? const DecoratedBox(
                                            decoration: BoxDecoration(
                                              border: Border.fromBorderSide(
                                                BorderSide(
                                                  color: VisualTokens.accent,
                                                ),
                                              ),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(12),
                                              ),
                                            ),
                                          )
                                        : PlayingCard(
                                            card: _played!,
                                            compact: true,
                                            readOnly: true,
                                          ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'You',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _seat(
                          'You · South',
                          _played != null
                              ? 'Card played'
                              : _busy
                              ? 'Playing…'
                              : 'Your turn',
                          active: true,
                        ),
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
                      for (final card in PlayTableFixture.hand.cards.where(
                        (card) => card != _played,
                      ))
                        SizedBox(
                          key: _handKeys[card],
                          child: Opacity(
                            opacity: _busy && _selected == card ? 0 : 1,
                            child: PlayingCard(
                              card: card,
                              selected: card == _selected,
                              onTap:
                                  !_busy &&
                                      _played == null &&
                                      allowed.contains(card)
                                  ? () => setState(
                                      () => _selected = _selected == card
                                          ? null
                                          : card,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _played != null
                          ? 'Played: ${_played!.label}'
                          : _selected == null
                          ? 'Choose a card to preview selection.'
                          : 'Selected: ${_selected!.label}',
                      style: text.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'One card play only. Winner, score and coaching are not calculated.',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      FilledButton(
                        onPressed: _selected == null || _busy || _played != null
                            ? null
                            : _commit,
                        child: const Text('Play card'),
                      ),
                      if (_played != null)
                        OutlinedButton(
                          onPressed: () => setState(() {
                            _played = null;
                            _selected = null;
                          }),
                          child: const Text('Reset hand'),
                        ),
                      OutlinedButton(
                        onPressed: _selected == null || _busy
                            ? null
                            : () => setState(() => _selected = null),
                        child: const Text('Clear selection'),
                      ),
                    ],
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
