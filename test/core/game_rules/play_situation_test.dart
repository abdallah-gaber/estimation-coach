import 'package:estimation_coach/core/cards/cards.dart';
import 'package:estimation_coach/core/game_rules/bidding.dart';
import 'package:estimation_coach/core/game_rules/play_situation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  PlaySituation situation({
    List<String> hand = const ['3H', '9H', 'AS', '2C'],
    PlayerSeat player = PlayerSeat.south,
    PlayerSeat leader = PlayerSeat.west,
    List<SeatPlay>? plays,
    Map<PlayerSeat, int>? taken,
    int estimate = 4,
    Trump trump = Trump.spades,
    Bid? bid,
  }) => PlaySituation(
    playerPosition: player,
    hand: Hand(hand.map(GameCard.parse)),
    leader: leader,
    currentTrick:
        plays ??
        [
          SeatPlay(PlayerSeat.west, GameCard.parse('7H')),
          SeatPlay(PlayerSeat.north, GameCard.parse('QH')),
          SeatPlay(PlayerSeat.east, GameCard.parse('2H')),
        ],
    trump: trump,
    trickEstimate: TrickEstimate(estimate),
    tricksTaken:
        taken ??
        {
          PlayerSeat.north: 2,
          PlayerSeat.east: 2,
          PlayerSeat.south: 3,
          PlayerSeat.west: 2,
        },
    auctionBid: bid,
  );

  test(
    'low estimates and overtricks stay distinct from the winning auction bid',
    () {
      for (final estimate in [0, 1, 2, 3, 4, 13]) {
        final state = situation(estimate: estimate, bid: Bid(5, Trump.spades));
        expect(state.trickEstimate.tricks, estimate);
        expect(state.auctionBid!.tricks, 5);
        expect(state.playerTricksTaken, 3);
      }
      expect(situation().auctionBid, isNull);
      expect(() => Bid(3, Trump.spades), throwsRangeError);
      expect(TrickEstimate(2), TrickEstimate(2));
      expect(TrickEstimate(2).hashCode, TrickEstimate(2).hashCode);
      for (final value in [-1, 14]) {
        expect(() => TrickEstimate(value), throwsRangeError);
      }
    },
  );
  test('following suit uses the first card for every trump including Sans', () {
    for (final trump in Trump.values) {
      final state = situation(trump: trump);
      expect(state.ledSuit, Suit.hearts);
      expect(state.legalChoices.map((c) => c.notation), ['3H', '9H']);
    }
  });
  test('a void allows every held card', () {
    final state = situation(hand: ['3D', '9D', 'AS', '2C']);
    expect(state.legalChoices, state.hand.cards);
  });
  test('leading works for every seat without inferring play direction', () {
    for (final seat in PlayerSeat.values) {
      final state = situation(player: seat, leader: seat, plays: []);
      expect(state.ledSuit, isNull);
      expect(state.legalChoices, state.hand.cards);
    }
  });
  test('first and last trick decision boundaries', () {
    final first = PlaySituation(
      playerPosition: PlayerSeat.south,
      hand: Hand(standardDeck().take(13)),
      leader: PlayerSeat.south,
      currentTrick: [],
      trump: Trump.noTrump,
      trickEstimate: TrickEstimate(1),
      tricksTaken: {for (final seat in PlayerSeat.values) seat: 0},
    );
    expect(first.legalChoices, hasLength(13));
    final last = situation(
      hand: ['9H'],
      taken: {for (final seat in PlayerSeat.values) seat: 3},
    );
    expect(last.legalChoices, hasLength(1));
  });
  test('one/two visible plays are accepted without requiring a full trick', () {
    for (final n in [1, 2]) {
      final plays = situation().currentTrick.take(n).toList();
      expect(situation(plays: plays).currentTrick, hasLength(n));
    }
  });
  test('defensive copies and exposed collections are immutable', () {
    final plays = situation().currentTrick.toList();
    final taken = Map<PlayerSeat, int>.of(situation().tricksTaken);
    final state = situation(plays: plays, taken: taken);
    plays.clear();
    taken.clear();
    expect(state.currentTrick, hasLength(3));
    expect(state.tricksTaken, hasLength(4));
    expect(() => state.currentTrick.clear(), throwsUnsupportedError);
    expect(() => state.tricksTaken.clear(), throwsUnsupportedError);
    expect(() => state.legalChoices.clear(), throwsUnsupportedError);
  });
  final invalid = <String, void Function()>{
    'empty hand': () => situation(hand: []),
    'missing seat count': () => situation(taken: {PlayerSeat.south: 9}),
    'negative count': () => situation(
      taken: {
        PlayerSeat.north: -1,
        PlayerSeat.east: 4,
        PlayerSeat.south: 4,
        PlayerSeat.west: 2,
      },
    ),
    'count above 13': () => situation(
      taken: {
        PlayerSeat.north: 14,
        PlayerSeat.east: 0,
        PlayerSeat.south: 0,
        PlayerSeat.west: 0,
      },
    ),
    'inconsistent hand/counts': () => situation(hand: ['3H']),
    'mismatched leader': () => situation(leader: PlayerSeat.north),
    'empty trick with another leader': () => situation(plays: []),
    'player already played': () => situation(
      plays: [
        SeatPlay(PlayerSeat.west, GameCard.parse('7H')),
        SeatPlay(PlayerSeat.south, GameCard.parse('QH')),
      ],
    ),
    'duplicate seat': () => situation(
      plays: [
        SeatPlay(PlayerSeat.west, GameCard.parse('7H')),
        SeatPlay(PlayerSeat.west, GameCard.parse('QH')),
      ],
    ),
    'card shared with hand': () =>
        situation(plays: [SeatPlay(PlayerSeat.west, GameCard.parse('3H'))]),
    'duplicate public card': () => situation(
      plays: [
        SeatPlay(PlayerSeat.west, GameCard.parse('7H')),
        SeatPlay(PlayerSeat.north, GameCard.parse('7H')),
      ],
    ),
    'completed trick': () => situation(
      plays: [
        ...situation().currentTrick,
        SeatPlay(PlayerSeat.south, GameCard.parse('4H')),
      ],
    ),
    'winning bid/trump mismatch': () => situation(bid: Bid(5, Trump.hearts)),
  };
  for (final entry in invalid.entries) {
    test(
      'rejects ${entry.key}',
      () => expect(entry.value, throwsArgumentError),
    );
  }
}
