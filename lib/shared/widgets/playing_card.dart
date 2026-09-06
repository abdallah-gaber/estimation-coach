import 'package:flutter/material.dart';

import '../../app/visual_tokens.dart';

/// Presentation metadata only; game models and legality live in the domain core.
enum SuitVisual {
  spades('♠', 'Spades', false),
  hearts('♥', 'Hearts', true),
  diamonds('♦', 'Diamonds', true),
  clubs('♣', 'Clubs', false);

  const SuitVisual(this.symbol, this.label, this.isRed);
  final String symbol;
  final String label;
  final bool isRed;
}

class PlayingCard extends StatelessWidget {
  const PlayingCard({
    super.key,
    required this.rank,
    required this.rankLabel,
    required this.suit,
    this.selected = false,
    this.onTap,
  });

  final String rank;
  final String rankLabel;
  final SuitVisual suit;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final active = enabled && selected;
    final color = enabled
        ? (suit.isRed ? const Color(0xFFAD343B) : VisualTokens.ink)
        : const Color(0xFF646B66);
    // Let card text grow along with system text instead of clipping its corners.
    final scale = MediaQuery.textScalerOf(context).scale(26) / 26;
    return Semantics(
      label: '$rankLabel of ${suit.label}',
      button: true,
      enabled: enabled,
      selected: active,
      child: AnimatedSlide(
        offset: active ? const Offset(0, -0.04) : Offset.zero,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 140),
        child: SizedBox(
          width: 96 * (scale < 1 ? 1 : scale),
          height: 144 * (scale < 1 ? 1 : scale),
          child: Material(
            color: enabled ? Colors.white : const Color(0xFFCED5CF),
            elevation: active ? 6 : 1,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onTap,
              canRequestFocus: enabled,
              borderRadius: BorderRadius.circular(12),
              focusColor: const Color(0xFFB9DCCF),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: active ? VisualTokens.accent : Colors.transparent,
                    width: 3,
                  ),
                ),
                padding: const EdgeInsets.all(VisualTokens.small),
                child: ExcludeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            rank,
                            style: VisualTokens.rank.copyWith(color: color),
                          ),
                          if (!enabled || active)
                            Icon(
                              enabled ? Icons.check_circle : Icons.lock_outline,
                              color: color,
                              size: 18,
                            ),
                        ],
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            suit.symbol,
                            style: VisualTokens.suit.copyWith(color: color),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          suit.symbol,
                          style: TextStyle(color: color, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
