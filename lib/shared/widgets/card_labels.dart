import '../../core/cards/cards.dart';

/// UI text and symbols stay out of the game domain.
extension SuitLabels on Suit {
  String get symbol => switch (this) {
    Suit.spades => '♠',
    Suit.hearts => '♥',
    Suit.diamonds => '♦',
    Suit.clubs => '♣',
  };

  String get label => switch (this) {
    Suit.spades => 'Spades',
    Suit.hearts => 'Hearts',
    Suit.diamonds => 'Diamonds',
    Suit.clubs => 'Clubs',
  };

  bool get isRed => this == Suit.hearts || this == Suit.diamonds;
}

extension RankLabels on Rank {
  String get label => switch (this) {
    Rank.two => 'Two',
    Rank.three => 'Three',
    Rank.four => 'Four',
    Rank.five => 'Five',
    Rank.six => 'Six',
    Rank.seven => 'Seven',
    Rank.eight => 'Eight',
    Rank.nine => 'Nine',
    Rank.ten => 'Ten',
    Rank.jack => 'Jack',
    Rank.queen => 'Queen',
    Rank.king => 'King',
    Rank.ace => 'Ace',
  };
}

extension CardLabels on GameCard {
  String get label => '${rank.label} of ${suit.label}';
}
