import '../../core/cards/cards.dart';

/// UI specimens, not an authored hand, legal-play exercise or scored scenario.
const previewCards = [
  (card: GameCard(Rank.ace, Suit.spades), enabled: true),
  (card: GameCard(Rank.king, Suit.hearts), enabled: true),
  (card: GameCard(Rank.ten, Suit.diamonds), enabled: false),
  (card: GameCard(Rank.jack, Suit.clubs), enabled: true),
];
