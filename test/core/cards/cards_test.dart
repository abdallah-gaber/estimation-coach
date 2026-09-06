import 'package:estimation_coach/core/cards/cards.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameCard', () {
    test('identity is rank plus suit, including set/map lookup', () {
      const ace = GameCard(Rank.ace, Suit.spades);
      final parsed = GameCard.parse('AS');
      expect(ace, parsed);
      expect(ace.hashCode, parsed.hashCode);
      expect({ace, parsed}, hasLength(1));
      expect({ace: 'control'}[parsed], 'control');
      expect(ace, isNot(const GameCard(Rank.king, Suit.spades)));
      expect(ace, isNot(const GameCard(Rank.ace, Suit.hearts)));
      expect(ace, isNot('AS'));
    });

    test('all canonical card codes round-trip', () {
      const ranks = [
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        '10',
        'J',
        'Q',
        'K',
        'A',
      ];
      for (final suit in ['S', 'H', 'D', 'C']) {
        for (final rank in ranks) {
          final notation = '$rank$suit';
          final card = GameCard.parse(notation);
          expect(card.notation, notation);
          expect(card.toString(), notation);
          expect(card.rank.code, rank);
          expect(card.suit.code, suit);
        }
      }
    });

    test('rejects invalid and noncanonical content codes', () {
      for (final input in [
        '',
        'AS ',
        ' AS',
        'as',
        'As',
        '1S',
        '11H',
        'TS',
        'AX',
        'JOKER',
        '♠A',
        'AS\n',
      ]) {
        expect(
          () => GameCard.parse(input),
          throwsFormatException,
          reason: input,
        );
      }
    });
  });

  group('standardDeck', () {
    test('has all 52 unique cards, 13 per suit and four per rank', () {
      final deck = standardDeck();
      expect(deck, hasLength(52));
      expect(deck.toSet(), hasLength(52));
      for (final suit in Suit.values) {
        expect(deck.where((card) => card.suit == suit), hasLength(13));
      }
      for (final rank in Rank.values) {
        expect(deck.where((card) => card.rank == rank), hasLength(4));
      }
    });

    test('is immutable and reproducible', () {
      final deck = standardDeck();
      expect(deck, orderedEquals(standardDeck()));
      expect(() => deck.clear(), throwsUnsupportedError);
      expect(() => deck[0] = deck.last, throwsUnsupportedError);
    });
  });

  group('Hand', () {
    final ace = GameCard.parse('AS');
    final king = GameCard.parse('KH');

    test('membership determines equality while display order is retained', () {
      final first = Hand([ace, king]);
      final reordered = Hand([king, GameCard.parse('AS')]);
      expect(first, reordered);
      expect(first.hashCode, reordered.hashCode);
      expect({first: 'same hand'}[reordered], 'same hand');
      expect(reordered.cards, orderedEquals([king, ace]));
      expect(first, isNot(Hand([ace])));
      expect(first, isNot(Hand([ace, GameCard.parse('KD')])));
      expect(first.contains(GameCard.parse('AS')), isTrue);
    });

    test('copies input and protects the exposed cards', () {
      final source = [ace, king];
      final hand = Hand(source);
      source.clear();
      expect(hand.length, 2);
      expect(hand.isEmpty, isFalse);
      expect(
        () => hand.cards.add(GameCard.parse('2C')),
        throwsUnsupportedError,
      );
      expect(() => hand.cards[0] = king, throwsUnsupportedError);
    });

    test('accepts empty and full hands', () {
      expect(Hand([]).isEmpty, isTrue);
      expect(Hand([]), Hand([]));
      expect(Hand(standardDeck().take(13)).length, 13);
    });

    test('rejects duplicates and hands larger than 13 cards', () {
      expect(() => Hand([ace, GameCard.parse('AS')]), throwsArgumentError);
      expect(() => Hand(standardDeck().take(14)), throwsArgumentError);
    });
  });
}
