import 'package:flutter/material.dart';

/// Post-decision coaching, shown compactly by default with the full reviewed
/// explanation one action away (EC-055/D-028).
///
/// The default view carries only the rating, one short [headline] line and
/// the already-short [facts] — never [summary] or [points], which are
/// authored evidence prose and belong behind [onToggleDetail]. Nothing here
/// shortens, splits or truncates authored text: the split is which authored
/// field is shown when, so no coaching content is weakened or hidden from a
/// player who asks for it.
///
/// Deliberately knows nothing about scenarios, evaluations or ratings as
/// domain types — callers pass already-resolved strings, so both trainers
/// share one presentation and coaching content stays in the content layer.
class CoachingResultCard extends StatelessWidget {
  const CoachingResultCard({
    super.key,
    required this.choiceLabel,
    required this.ratingLabel,
    required this.headline,
    required this.summary,
    required this.points,
    required this.facts,
    required this.detailOpen,
    required this.onToggleDetail,
    required this.actions,
  });

  /// e.g. "Your choice · Ace of Clubs".
  final String choiceLabel;

  /// e.g. "Strong decision" — the reviewed rating, never recomputed here.
  final String ratingLabel;

  /// The one concise line shown by default: the authored feedback title.
  final String headline;

  /// Authored explanation. Detail only — never part of the default view.
  final String summary;

  /// Authored evidence. Detail only — every point is shown when expanded.
  final List<String> points;

  /// Short, non-prose statements of what the decision committed to (for
  /// example "Outcome: not simulated."). Part of the compact default because
  /// they state the decision's outcome rather than explain reasoning.
  final List<String> facts;

  final bool detailOpen;
  final VoidCallback onToggleDetail;

  /// Continue / retry controls, owned by the calling trainer.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card.filled(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(choiceLabel, style: text.labelLarge),
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Text(ratingLabel, style: text.headlineSmall),
            ),
            const SizedBox(height: 8),
            Text(headline, style: text.titleMedium),
            const SizedBox(height: 8),
            for (final fact in facts)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(fact),
              ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onToggleDetail,
                icon: Icon(detailOpen ? Icons.expand_less : Icons.expand_more),
                label: Text(detailOpen ? 'Hide detail' : detailActionLabel),
              ),
            ),
            if (detailOpen) ...[
              const SizedBox(height: 4),
              Text(summary),
              const SizedBox(height: 12),
              for (final point in points)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(point),
                  ),
                ),
            ],
            const SizedBox(height: 4),
            Wrap(spacing: 12, runSpacing: 8, children: actions),
          ],
        ),
      ),
    );
  }

  /// Names how much evidence is waiting, so the action is explicit about
  /// what expanding reveals rather than hinting at unspecified "more".
  String get detailActionLabel => points.length == 1
      ? 'More detail · 1 point'
      : 'More detail · ${points.length} points';
}
