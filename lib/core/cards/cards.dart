/// Standard suit identities. Enumeration order does not define bid precedence.
enum Suit {
  spades('S'),
  hearts('H'),
  diamonds('D'),
  clubs('C');

  const Suit(this.code);
  final String code;
}

/// Rank identities and portable content notation, independent of Flutter.
enum Rank {
  two('2'),
  three('3'),
  four('4'),
  five('5'),
  six('6'),
  seven('7'),
  eight('8'),
  nine('9'),
  ten('10'),
  jack('J'),
  queen('Q'),
  king('K'),
  ace('A');

  const Rank(this.code);
  final String code;
}

/// A value object. Equal rank and suit mean the same physical card.
final class GameCard {
  const GameCard(this.rank, this.suit);

  final Rank rank;
  final Suit suit;

  /// Parses the exact uppercase v1 content notation (e.g. AS, 10H, QD).
  /// Invalid or noncanonical input is rejected instead of silently normalized.
  factory GameCard.parse(String notation) {
    for (final suit in Suit.values) {
      for (final rank in Rank.values) {
        if (notation == '${rank.code}${suit.code}') {
          return GameCard(rank, suit);
        }
      }
    }
    throw FormatException('Invalid card notation', notation);
  }

  String get notation => '${rank.code}${suit.code}';

  @override
  bool operator ==(Object other) =>
      other is GameCard && rank == other.rank && suit == other.suit;

  @override
  int get hashCode => Object.hash(rank, suit);

  @override
  String toString() => notation;
}

/// Returns a deterministic, immutable 52-card deck without jokers.
/// It is ordered by Suit.values then Rank.values, not shuffled or dealt.
List<GameCard> standardDeck() => List.unmodifiable([
  for (final suit in Suit.values)
    for (final rank in Rank.values) GameCard(rank, suit),
]);

/// An immutable remaining hand (0–13 distinct cards).
/// Display order is preserved; equality compares membership, not display order.
final class Hand {
  factory Hand(Iterable<GameCard> cards) {
    final snapshot = List<GameCard>.unmodifiable(cards);
    if (snapshot.length > 13) {
      throw ArgumentError.value(snapshot.length, 'cards', 'At most 13 cards');
    }
    if (snapshot.toSet().length != snapshot.length) {
      throw ArgumentError.value(snapshot, 'cards', 'Duplicate card in hand');
    }
    return Hand._(snapshot);
  }

  const Hand._(this.cards);

  final List<GameCard> cards;
  int get length => cards.length;
  bool get isEmpty => cards.isEmpty;
  bool contains(GameCard card) => cards.contains(card);

  @override
  bool operator ==(Object other) =>
      other is Hand && length == other.length && cards.every(other.contains);

  @override
  int get hashCode => Object.hashAllUnordered(cards);
}
