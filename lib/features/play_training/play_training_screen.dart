import 'package:flutter/material.dart';

import '../../app/visual_tokens.dart';
import '../../core/cards/cards.dart';
import '../../core/game_rules/play_situation.dart';
import '../../scenarios/bidding_scenario.dart' show PlayerSeat;
import '../../scenarios/load_play_scenarios.dart';
import '../../scenarios/play_scenario.dart';
import '../../shared/widgets/card_labels.dart';
import '../../shared/widgets/playing_card.dart';
import '../bidding_training/bidding_labels.dart';

class PlayTrainingScreen extends StatefulWidget {
  const PlayTrainingScreen({super.key, this.loader});
  final Future<List<PlayScenario>> Function()? loader;

  @override
  State<PlayTrainingScreen> createState() => _PlayTrainingScreenState();
}

class _PlayTrainingScreenState extends State<PlayTrainingScreen> {
  late Future<List<PlayScenario>> _loading;
  final _scroll = ScrollController();
  final _feedbackKey = GlobalKey();
  final _destinationKey = GlobalKey();
  int _index = 0;
  GameCard? _selected;
  GameCard? _played;
  bool _busy = false;
  OverlayEntry? _flight;
  Map<GameCard, GlobalKey> _handKeys = {};

  @override
  void initState() {
    super.initState();
    _loading = _load();
  }

  Future<List<PlayScenario>> _load() async {
    final pack = await (widget.loader?.call() ?? loadPlayScenarios());
    if (pack.isEmpty || pack.any((s) => s.missingEvaluationCount != 0)) {
      throw const FormatException('Training needs complete feedback');
    }
    return pack;
  }

  @override
  void dispose() {
    _scroll.dispose();
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

  Future<void> _commit(PlayScenario scenario) async {
    final card = _selected;
    if (card == null ||
        _busy ||
        _played != null ||
        !scenario.situation.legalChoices.contains(card)) {
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

  void _retry() => setState(() {
    _played = null;
    _selected = null;
  });

  void _advance({bool restart = false}) {
    setState(() {
      _index = restart ? 0 : _index + 1;
      _selected = null;
      _played = null;
      _busy = false;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Play practice')),
      body: SafeArea(
        child: FutureBuilder<List<PlayScenario>>(
          future: _loading,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Training could not load.'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => setState(() {
                          _loading = _load();
                        }),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  semanticsLabel: 'Loading training',
                ),
              );
            }
            final scenarios = snapshot.data!;
            return SingleChildScrollView(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: _index >= scenarios.length
                      ? _completion(scenarios.length)
                      : _exercise(scenarios[_index], scenarios.length),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _completion(int count) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 48),
      Text(
        'Session complete',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      const SizedBox(height: 16),
      Text(
        '$count situations reviewed. Winner resolution and scoring are not calculated yet.',
      ),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: () => _advance(restart: true),
        child: const Text('Practice again'),
      ),
    ],
  );

  Widget _exercise(PlayScenario scenario, int count) {
    final text = Theme.of(context).textTheme;
    final situation = scenario.situation;
    _handKeys = {for (final card in situation.hand.cards) card: GlobalKey()};
    final evaluation = _played == null ? null : scenario.evaluate(_played!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('ESTIMATION COACH', style: text.labelLarge),
            Text(
              'Play practice · Situation ${_index + 1} of $count',
              style: text.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(scenario.title, style: text.headlineMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            Chip(label: Text('Trump: ${situation.trump.label}')),
            Chip(label: Text('Your target: ${situation.trickEstimate.tricks}')),
            Chip(label: Text('Taken: ${situation.playerTricksTaken}')),
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
              _opponentSeat(PlayerSeat.north, situation),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _opponentSeat(PlayerSeat.west, situation),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _opponentSeat(PlayerSeat.east, situation),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Current trick',
                style: text.titleMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final play in situation.currentTrick)
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
                              MediaQuery.textScalerOf(context).scale(26) /
                              26,
                          height:
                              82 *
                              MediaQuery.textScalerOf(context).scale(26) /
                              26,
                          child: _played == null
                              ? const DecoratedBox(
                                  decoration: BoxDecoration(
                                    border: Border.fromBorderSide(
                                      BorderSide(color: VisualTokens.accent),
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
        if (situation.ledSuit case final led?)
          Text('${led.label} were led. Locked cards cannot be selected.')
        else
          const Text('You lead. Any card is legal.'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 16,
          children: [
            for (final card in situation.hand.cards.where((c) => c != _played))
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
                            situation.legalChoices.contains(card)
                        ? () => setState(
                            () => _selected = _selected == card ? null : card,
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
                ? 'Choose a card to play.'
                : 'Selected: ${_selected!.label}',
            style: text.titleMedium,
          ),
        ),
        const SizedBox(height: 12),
        if (evaluation == null) ...[
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _selected == null || _busy || _played != null
                    ? null
                    : () => _commit(scenario),
                child: const Text('Play card'),
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
        ] else
          _feedbackPanel(evaluation, count),
      ],
    );
  }

  Widget _opponentSeat(PlayerSeat seat, PlaySituation situation) => _seat(
    seatLabel(seat),
    seat == situation.leader
        ? 'Led ${situation.ledSuit!.label}'
        : 'Taken: ${situation.tricksTaken[seat]}',
  );

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

  Widget _feedbackPanel(PlayEvaluation result, int count) {
    final text = Theme.of(context).textTheme;
    return Card.filled(
      key: _feedbackKey,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your choice · ${result.card.label}', style: text.labelLarge),
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Text(result.rating.label, style: text.headlineSmall),
            ),
            const SizedBox(height: 8),
            Text(result.feedback.title, style: text.titleMedium),
            const SizedBox(height: 8),
            Text(result.feedback.summary),
            const SizedBox(height: 6),
            const Text('Outcome: not simulated.'),
            ExpansionTile(
              title: const Text('Why?'),
              tilePadding: EdgeInsets.zero,
              children: [
                for (final point in result.feedback.points)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(point),
                    ),
                  ),
              ],
            ),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: _advance,
                  child: Text(
                    _index + 1 == count ? 'Finish session' : 'Next situation',
                  ),
                ),
                TextButton(
                  onPressed: _retry,
                  child: const Text('Try another choice'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
