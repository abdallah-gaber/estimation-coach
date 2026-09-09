import 'package:flutter/material.dart';

import '../../app/visual_tokens.dart';
import '../../core/coaching/evaluate_bid.dart';
import '../../scenarios/bidding_scenario.dart';
import '../../scenarios/load_bidding_scenarios.dart';
import '../../scenarios/scenario_session.dart';
import '../../shared/widgets/coaching_result_card.dart';
import '../../shared/widgets/playing_card.dart';
import 'bidding_labels.dart';
import '../play_training/play_training_screen.dart';

class BiddingTrainingScreen extends StatefulWidget {
  const BiddingTrainingScreen({super.key, this.loader});
  final Future<List<BiddingScenario>> Function()? loader;

  @override
  State<BiddingTrainingScreen> createState() => _BiddingTrainingScreenState();
}

class _BiddingTrainingScreenState extends State<BiddingTrainingScreen> {
  late final Future<List<BiddingScenario>> Function() _nextSession;
  late Future<List<BiddingScenario>> _loading;
  final _scroll = ScrollController();
  final _feedbackKey = GlobalKey();
  int _index = 0;
  int? _tricks;
  Trump? _trump;
  AuthoredEvaluation? _feedback;

  /// Coaching detail is collapsed for each new decision; the player opts in
  /// per result rather than carrying an earlier choice's expansion forward.
  bool _detailOpen = false;

  @override
  void initState() {
    super.initState();
    _nextSession =
        widget.loader ??
        ScenarioSession<BiddingScenario>(
          loadCatalog: loadBiddingScenarios,
          idOf: (scenario) => scenario.id,
        ).nextSession;
    _loading = _load();
  }

  Future<List<BiddingScenario>> _load() async {
    final pack = await _nextSession();
    if (pack.isEmpty || pack.any((s) => s.missingEvaluationCount != 0)) {
      throw const FormatException('Training needs complete feedback');
    }
    return pack;
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _review(BiddingScenario scenario, BiddingDecision choice) {
    final result = evaluateBid(scenario, choice);
    if (result == null) return; // The loader rejects incomplete packs.
    setState(() => _feedback = result);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _feedbackKey.currentContext;
      if (context != null) Scrollable.ensureVisible(context);
    });
  }

  void _advance({bool restart = false}) {
    setState(() {
      if (restart) {
        // A new session order, not a reset to the first loaded scenario.
        _loading = _load();
        _index = 0;
      } else {
        _index += 1;
      }
      _tricks = null;
      _trump = null;
      _feedback = null;
      _detailOpen = false;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Play practice',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PlayTrainingScreen(),
              ),
            ),
            icon: const Icon(Icons.table_restaurant_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<BiddingScenario>>(
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
                  constraints: const BoxConstraints(maxWidth: 940),
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
        '$count hands reviewed. Keep separating controls from conditional winners.',
      ),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: () => _advance(restart: true),
        child: const Text('Practice again'),
      ),
    ],
  );

  Widget _exercise(BiddingScenario scenario, int count) {
    final text = Theme.of(context).textTheme;
    final pre = scenario.biddingState.phase == BiddingPhase.preBidding;
    final choices = scenario.allowedDecisions.choices;
    BiddingDecision? selected;
    for (final choice in choices) {
      if (choice.action == BiddingAction.bid &&
          choice.tricks == _tricks &&
          choice.trump == _trump) {
        selected = choice;
      }
    }
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
              'Bid practice · Hand ${_index + 1} of $count',
              style: text.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(scenario.title, style: text.headlineMedium),
        const SizedBox(height: 8),
        Text(
          pre
              ? 'Before bidding · Trump unknown'
              : 'Normal bidding · Choose a legal raise',
          style: text.bodyLarge,
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: VisualTokens.table,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (scenario.previousActions.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final action in scenario.previousActions)
                      Chip(
                        label: Text(
                          '${seatLabel(action.player)} · ${action.action == PreviousActionKind.bid ? '${action.tricks} ${action.trump!.label}' : action.action.name}',
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              if (scenario.biddingState.dashPlayers.isNotEmpty) ...[
                Text(
                  'Dash · ${scenario.biddingState.dashPlayers.map(seatLabel).join(', ')} · 0 tricks',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                'YOUR HAND · ${seatLabel(scenario.playerPosition)}',
                style: text.labelLarge?.copyWith(color: VisualTokens.accent),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 8,
                children: [
                  for (final card in scenario.hand.cards)
                    PlayingCard(card: card, compact: true, readOnly: true),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_feedback == null) ...[
          Text(pre ? 'Dash or enter?' : 'Your bid', style: text.titleLarge),
          const SizedBox(height: 12),
          if (pre)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final choice in choices)
                  FilledButton.tonal(
                    onPressed: () => _review(scenario, choice),
                    child: Text(choice.label),
                  ),
              ],
            )
          else ...[
            Text('Tricks', style: text.labelLarge),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final count in choices.map((c) => c.tricks!).toSet())
                  ChoiceChip(
                    label: Text('$count'),
                    selected: _tricks == count,
                    onSelected: (_) => setState(() {
                      _tricks = count;
                      if (!choices.any(
                        (c) => c.tricks == count && c.trump == _trump,
                      )) {
                        _trump = null;
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Trump / qatou‘', style: text.labelLarge),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final trump in scenario.allowedDecisions.trumps)
                  ChoiceChip(
                    label: Text(trump.label),
                    selected: _trump == trump,
                    onSelected:
                        choices.any(
                          (c) => c.tricks == _tricks && c.trump == trump,
                        )
                        ? (_) => setState(() => _trump = trump)
                        : null,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: selected == null
                  ? null
                  : () => _review(scenario, selected!),
              child: const Text('Review bid'),
            ),
          ],
        ] else
          _feedbackPanel(_feedback!, count),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _feedbackPanel(AuthoredEvaluation result, int count) {
    final commitment = switch (result.decision.action) {
      BiddingAction.dash =>
        'Estimate fixed at 0; no normal bidding for this hand.',
      BiddingAction.enter =>
        'You stay in normal bidding; no trick target chosen yet.',
      BiddingAction.bid =>
        'Proposed target: ${result.decision.tricks} tricks with ${result.decision.trump!.label}.',
    };
    return KeyedSubtree(
      key: _feedbackKey,
      child: CoachingResultCard(
        choiceLabel: 'Your choice · ${result.decision.label}',
        ratingLabel: result.rating.label,
        headline: result.feedback.title,
        summary: result.feedback.summary,
        points: result.feedback.points,
        facts: [commitment, 'Outcome: not simulated.'],
        detailOpen: _detailOpen,
        onToggleDetail: () => setState(() => _detailOpen = !_detailOpen),
        actions: [
          FilledButton(
            onPressed: _advance,
            child: Text(_index + 1 == count ? 'Finish session' : 'Next hand'),
          ),
          TextButton(
            onPressed: () => setState(() {
              _feedback = null;
              _detailOpen = false;
            }),
            child: const Text('Try another choice'),
          ),
        ],
      ),
    );
  }
}
