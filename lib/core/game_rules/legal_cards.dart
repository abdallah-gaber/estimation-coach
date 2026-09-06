import '../cards/cards.dart';

/// Cards permitted by the follow-suit rule, in the hand's display order.
///
/// [ledSuit] is the suit of the first card in the current trick, or null when
/// leading. Follow that suit if held; otherwise any card in the hand is allowed.
/// The returned list is immutable. An empty hand has no legal cards.
///
/// This evaluates card membership and following suit only. The caller owns
/// turn order and trick lifecycle; this function does not resolve a winner.
List<GameCard> legalCards(Hand hand, {Suit? ledSuit}) {
  if (ledSuit == null) return hand.cards;
  final matching = hand.cards.where((card) => card.suit == ledSuit).toList();
  return matching.isEmpty ? hand.cards : List.unmodifiable(matching);
}

/// Whether [card] is in the hand and permitted by the follow-suit rule.
bool isLegalPlay(Hand hand, GameCard card, {Suit? ledSuit}) =>
    legalCards(hand, ledSuit: ledSuit).contains(card);
