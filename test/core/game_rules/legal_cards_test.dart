import 'package:estimation_coach/core/cards/cards.dart';
import 'package:estimation_coach/core/game_rules/legal_cards.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Hand handOf(List<String> codes) => Hand(codes.map(GameCard.parse));

  test('leading permits every card, preserving display order', () {
    final hand = handOf(['KH', '2C', 'AS', '10H']);
    expect(legalCards(hand), orderedEquals(hand.cards));
    for (final card in hand.cards) {
      expect(isLegalPlay(hand, card), isTrue);
    }
  });

  test('must follow suit even with a low card', () {
    final hand = handOf(['AS', '2H', 'KD', '10H']);
    expect(
      legalCards(hand, ledSuit: Suit.hearts),
      orderedEquals([GameCard.parse('2H'), GameCard.parse('10H')]),
    );
    expect(
      isLegalPlay(hand, GameCard.parse('AS'), ledSuit: Suit.hearts),
      isFalse,
    );
    expect(
      isLegalPlay(hand, GameCard.parse('2H'), ledSuit: Suit.hearts),
      isTrue,
    );
  });

  test('a void permits every off-suit card', () {
    final hand = handOf(['AS', 'KD', '2C']);
    expect(legalCards(hand, ledSuit: Suit.hearts), orderedEquals(hand.cards));
    for (final card in hand.cards) {
      expect(isLegalPlay(hand, card, ledSuit: Suit.hearts), isTrue);
    }
  });

  test('cards outside the hand are rejected in every follow-suit state', () {
    final hand = handOf(['AS', '2H']);
    for (final ledSuit in [null, ...Suit.values]) {
      expect(
        isLegalPlay(hand, GameCard.parse('KH'), ledSuit: ledSuit),
        isFalse,
      );
      expect(
        isLegalPlay(hand, GameCard.parse('AC'), ledSuit: ledSuit),
        isFalse,
      );
    }
  });

  test('empty and single-card hands are handled', () {
    for (final ledSuit in [null, ...Suit.values]) {
      expect(legalCards(Hand([]), ledSuit: ledSuit), isEmpty);
      expect(
        isLegalPlay(Hand([]), GameCard.parse('AS'), ledSuit: ledSuit),
        isFalse,
      );
      final single = handOf(['2H']);
      expect(legalCards(single, ledSuit: ledSuit), orderedEquals(single.cards));
    }
  });

  test('results are immutable and evaluation leaves the hand unchanged', () {
    final hand = handOf(['KH', 'AS', '2H']);
    final original = hand.cards.toList();
    for (final ledSuit in [null, Suit.hearts, Suit.clubs]) {
      final result = legalCards(hand, ledSuit: ledSuit);
      expect(() => result.clear(), throwsUnsupportedError);
      expect(() => result[0] = GameCard.parse('2C'), throwsUnsupportedError);
      expect(hand.cards, orderedEquals(original));
    }
  });

  test('all four suits follow the same rule across every rank', () {
    // Rotate the led suit and vary the only held card in it through all ranks.
    for (final ledSuit in Suit.values) {
      for (final rank in Rank.values) {
        final follower = GameCard(rank, ledSuit);
        final offSuit = [
          for (final suit in Suit.values)
            if (suit != ledSuit) GameCard(Rank.ace, suit),
        ];
        final hand = Hand([...offSuit, follower]);
        expect(legalCards(hand, ledSuit: ledSuit), [follower]);
        for (final candidate in standardDeck()) {
          expect(
            isLegalPlay(hand, candidate, ledSuit: ledSuit),
            candidate == follower,
            reason: 'Led $ledSuit, held $follower, candidate $candidate',
          );
        }
      }
    }
  });
}
