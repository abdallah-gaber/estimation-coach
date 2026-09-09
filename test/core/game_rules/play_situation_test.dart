import 'package:estimation_coach/core/cards/cards.dart';
import 'package:estimation_coach/core/game_rules/bidding.dart';
import 'package:estimation_coach/core/game_rules/play_situation.dart';
import 'package:estimation_coach/core/game_rules/seat_rotation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Default current trick follows the owner-confirmed rotation from East:
  // East -> North -> West -> South, so South (the default pending player)
  // is genuinely the last of the four seats to act.
  PlaySituation situation({
    List<String> hand = const ['3H', '9H', 'AS', '2C'],
    PlayerSeat player = PlayerSeat.south,
    PlayerSeat leader = PlayerSeat.east,
    List<SeatPlay>? plays,
    Map<PlayerSeat, int>? taken,
    int estimate = 4,
    Trump trump = Trump.spades,
    Bid? bid,
    List<ObservedTrick> observed = const [],
    Map<PlayerSeat, TrickEstimate> opponentEstimates = const {},
  }) => PlaySituation(
    playerPosition: player,
    hand: Hand(hand.map(GameCard.parse)),
    leader: leader,
    currentTrick:
        plays ??
        [
          SeatPlay(PlayerSeat.east, GameCard.parse('7H')),
          SeatPlay(PlayerSeat.north, GameCard.parse('QH')),
          SeatPlay(PlayerSeat.west, GameCard.parse('2H')),
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
    observedTricks: observed,
    opponentEstimates: opponentEstimates,
  );

  test(
    'low estimates and overtricks stay distinct from the winning auction bid',
    () {
      for (final estimate in [0, 1, 2, 3, 4, 5]) {
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
  test('known auction bounds estimates for every seat and trump', () {
    for (final trump in Trump.values) {
      for (final seat in PlayerSeat.values) {
        for (final bidCount in [4, 5, 13]) {
          for (final estimate in [0, bidCount - 1, bidCount]) {
            final state = situation(
              player: seat,
              leader: seat,
              plays: [],
              trump: trump,
              bid: Bid(bidCount, trump),
              estimate: estimate,
            );
            expect(state.trickEstimate.tricks, estimate);
          }
        }
        expect(
          () => situation(
            player: seat,
            leader: seat,
            plays: [],
            trump: trump,
            bid: Bid(4, trump),
            estimate: 5,
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('must not exceed the known winning auction bid'),
            ),
          ),
        );
      }
    }
  });
  test('without auction context the full estimate range remains supported', () {
    for (var estimate = 0; estimate <= 13; estimate++) {
      final state = situation(estimate: estimate);
      expect(state.trickEstimate.tricks, estimate);
      expect(state.auctionBid, isNull);
    }
  });
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
  test('every rotation prefix is accepted with the matching next player', () {
    final order = rotationFrom(PlayerSeat.east);
    final fullPlays = situation().currentTrick;
    for (var n = 0; n <= 3; n++) {
      final state = situation(
        plays: fullPlays.take(n).toList(),
        player: order[n],
      );
      expect(state.currentTrick, hasLength(n));
      expect(state.currentTrick.map((p) => p.seat), order.take(n));
    }
  });
  test('every one of the four leaders produces a valid rotation', () {
    for (final leader in PlayerSeat.values) {
      final order = rotationFrom(leader);
      expect(order.toSet(), PlayerSeat.values.toSet());
      final threePlays = [
        SeatPlay(order[0], GameCard.parse('7H')),
        SeatPlay(order[1], GameCard.parse('QH')),
        SeatPlay(order[2], GameCard.parse('2H')),
      ];
      final state = situation(
        leader: leader,
        plays: threePlays,
        player: order[3],
      );
      expect(state.currentTrick.map((p) => p.seat), order.take(3));
      expect(state.leader, leader);
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
  // West leads; canonical rotation from West is West -> South -> East -> North.
  ObservedTrick observedTrick({String east = '4C', String north = '9D'}) =>
      ObservedTrick([
        SeatPlay(PlayerSeat.west, GameCard.parse('8D')),
        SeatPlay(PlayerSeat.south, GameCard.parse('JD')),
        SeatPlay(PlayerSeat.east, GameCard.parse(east)),
        SeatPlay(PlayerSeat.north, GameCard.parse(north)),
      ]);
  test('observed tricks default to empty and stay backward compatible', () {
    expect(situation().observedTricks, isEmpty);
  });
  test('observed tricks are accepted, exposed in order and immutable', () {
    final history = [observedTrick()];
    final state = situation(observed: history);
    expect(state.observedTricks, hasLength(1));
    expect(state.observedTricks.single.plays.first.seat, PlayerSeat.west);
    expect(() => state.observedTricks.clear(), throwsUnsupportedError);
    expect(
      () => state.observedTricks.single.plays.clear(),
      throwsUnsupportedError,
    );
    history.clear();
    expect(state.observedTricks, hasLength(1));
  });
  test('ObservedTrick accepts every leader in canonical rotation order', () {
    for (final leader in PlayerSeat.values) {
      final order = rotationFrom(leader);
      final cards = ['8D', 'JD', '4C', '9D'];
      final trick = ObservedTrick([
        for (final (i, seat) in order.indexed)
          SeatPlay(seat, GameCard.parse(cards[i])),
      ]);
      expect(trick.plays.map((p) => p.seat), order);
    }
  });
  test('leading with observed history shown does not require the leader to '
      'be that history\'s winner — observedTricks is not guaranteed '
      'contiguous with the current trick', () {
    // observedTrick() is West-led Diamonds (8D, JD, 4C, 9D); under Spades
    // no one trumps, so South's JD is the highest Diamond and South wins
    // it — yet North, not South, is accepted as leader here, standing in
    // for a scenario where one or more unshown tricks happened between
    // the observed trick and this one. See docs/DECISIONS.md D-025.
    final state = situation(
      leader: PlayerSeat.north,
      plays: [],
      player: PlayerSeat.north,
      observed: [observedTrick()],
    );
    expect(state.leader, PlayerSeat.north);
    expect(state.currentTrick, isEmpty);
  });
  test('ObservedTrick rejects too few seats', () {
    expect(
      () => ObservedTrick([
        SeatPlay(PlayerSeat.west, GameCard.parse('8D')),
        SeatPlay(PlayerSeat.south, GameCard.parse('JD')),
        SeatPlay(PlayerSeat.east, GameCard.parse('4C')),
      ]),
      throwsArgumentError,
    );
  });
  test('ObservedTrick rejects a seat sequence that violates the rotation', () {
    expect(
      () => ObservedTrick([
        SeatPlay(PlayerSeat.west, GameCard.parse('8D')),
        SeatPlay(PlayerSeat.north, GameCard.parse('JD')), // should be south
        SeatPlay(PlayerSeat.east, GameCard.parse('4C')),
        SeatPlay(PlayerSeat.south, GameCard.parse('9D')),
      ]),
      throwsArgumentError,
    );
    expect(
      () => ObservedTrick([
        SeatPlay(PlayerSeat.west, GameCard.parse('8D')),
        SeatPlay(PlayerSeat.west, GameCard.parse('JD')), // duplicate seat
        SeatPlay(PlayerSeat.east, GameCard.parse('4C')),
        SeatPlay(PlayerSeat.south, GameCard.parse('9D')),
      ]),
      throwsArgumentError,
    );
  });
  test('opponent estimates default to empty and stay backward compatible', () {
    expect(situation().opponentEstimates, isEmpty);
  });
  test('opponent estimates are accepted absent, partial and full', () {
    expect(
      situation(
        opponentEstimates: {PlayerSeat.north: TrickEstimate(2)},
      ).opponentEstimates,
      {PlayerSeat.north: TrickEstimate(2)},
    );
    expect(
      situation(
        opponentEstimates: {
          PlayerSeat.north: TrickEstimate(2),
          PlayerSeat.east: TrickEstimate(3),
        },
      ).opponentEstimates,
      hasLength(2),
    );
    final full = situation(
      opponentEstimates: {
        PlayerSeat.north: TrickEstimate(2),
        PlayerSeat.east: TrickEstimate(3),
        PlayerSeat.west: TrickEstimate(3),
      },
    );
    expect(full.opponentEstimates, hasLength(3));
    // South's own trickEstimate (4, the default) combines with the three
    // opponents to a total of 12 — under 13, so this full set is valid.
  });
  test('opponent estimates are exposed as an immutable defensive copy', () {
    final estimates = {PlayerSeat.north: TrickEstimate(2)};
    final state = situation(opponentEstimates: estimates);
    estimates.clear();
    expect(state.opponentEstimates, hasLength(1));
    expect(() => state.opponentEstimates.clear(), throwsUnsupportedError);
  });
  test('a complete four-seat estimate set combining South is validated '
      'against the total-13 rule', () {
    expect(
      () => situation(
        estimate: 4,
        opponentEstimates: {
          PlayerSeat.north: TrickEstimate(3),
          PlayerSeat.east: TrickEstimate(3),
          PlayerSeat.west: TrickEstimate(3),
        },
      ),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('must not total 13'),
        ),
      ),
    );
  });
  test(
    'opponent estimates must not include the pending player\'s own seat',
    () {
      expect(
        () => situation(
          player: PlayerSeat.south,
          opponentEstimates: {PlayerSeat.south: TrickEstimate(2)},
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('must not include the pending player'),
          ),
        ),
      );
    },
  );
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
    'seat sequence skips a seat in the rotation': () => situation(
      plays: [
        SeatPlay(PlayerSeat.east, GameCard.parse('7H')),
        SeatPlay(PlayerSeat.west, GameCard.parse('QH')), // should be north
      ],
    ),
    'player already played': () => situation(
      plays: [
        SeatPlay(PlayerSeat.east, GameCard.parse('7H')),
        SeatPlay(PlayerSeat.north, GameCard.parse('QH')),
      ],
      player: PlayerSeat.north,
    ),
    'duplicate seat': () => situation(
      plays: [
        SeatPlay(PlayerSeat.east, GameCard.parse('7H')),
        SeatPlay(PlayerSeat.east, GameCard.parse('QH')),
      ],
    ),
    'card shared with hand': () =>
        situation(plays: [SeatPlay(PlayerSeat.east, GameCard.parse('3H'))]),
    'duplicate public card': () => situation(
      plays: [
        SeatPlay(PlayerSeat.east, GameCard.parse('7H')),
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
    'observed card shared with hand': () =>
        situation(observed: [observedTrick(east: '3H')]),
    'observed card shared with current trick': () =>
        situation(observed: [observedTrick(east: '7H')]),
    'observed card repeated across observed tricks': () => situation(
      observed: [
        observedTrick(),
        observedTrick(east: '6C', north: 'KD'),
      ],
    ),
    'more observed tricks than completed': () => situation(
      leader: PlayerSeat.south,
      plays: [],
      taken: {
        PlayerSeat.north: 0,
        PlayerSeat.east: 0,
        PlayerSeat.south: 0,
        PlayerSeat.west: 0,
      },
      hand: const [
        '2H',
        '3H',
        '4H',
        '5H',
        '6H',
        '7H',
        '8H',
        '9H',
        '10H',
        'JH',
        'QH',
        'KH',
        'AH',
      ],
      observed: [observedTrick()],
    ),
  };
  for (final entry in invalid.entries) {
    test(
      'rejects ${entry.key}',
      () => expect(entry.value, throwsArgumentError),
    );
  }
}
