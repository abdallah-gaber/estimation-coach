import 'package:flutter/material.dart';

import '../../app/visual_tokens.dart';
import '../../core/cards/cards.dart';
import 'card_labels.dart';
import 'suit_symbol.dart';

class PlayingCard extends StatelessWidget {
  const PlayingCard({
    super.key,
    required this.card,
    this.selected = false,
    this.onTap,
    this.readOnly = false,
    this.compact = false,
  });

  final GameCard card;
  final bool selected;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final suit = card.suit;
    final enabled = readOnly || onTap != null;
    final active = !readOnly && enabled && selected;
    final color = enabled
        ? (suit.isRed ? const Color(0xFFAD343B) : VisualTokens.ink)
        : const Color(0xFF646B66);
    // Let card text grow along with system text instead of clipping its corners.
    final scale = MediaQuery.textScalerOf(context).scale(26) / 26;
    return Semantics(
      label: card.label,
      button: !readOnly,
      enabled: readOnly ? null : enabled,
      selected: readOnly ? null : active,
      child: AnimatedSlide(
        offset: active ? const Offset(0, -0.04) : Offset.zero,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 140),
        child: SizedBox(
          width: (compact ? 56 : 96) * (scale < 1 ? 1 : scale),
          height: (compact ? 82 : 144) * (scale < 1 ? 1 : scale),
          child: Material(
            color: enabled ? Colors.white : const Color(0xFFCED5CF),
            elevation: active ? 6 : 1,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: readOnly ? null : onTap,
              canRequestFocus: !readOnly && enabled,
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
                padding: EdgeInsets.all(compact ? 4 : VisualTokens.small),
                child: ExcludeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            card.rank.code,
                            style: VisualTokens.rank.copyWith(
                              color: color,
                              fontSize: compact ? 18 : 26,
                            ),
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
                          child: SuitSymbol(
                            suit: suit,
                            color: color,
                            size: (compact ? 24 : 38) * scale,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SuitSymbol(
                          suit: suit,
                          color: color,
                          size: (compact ? 12 : 18) * scale,
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
