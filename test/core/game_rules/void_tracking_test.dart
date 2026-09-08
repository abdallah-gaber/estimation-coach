import 'package:estimation_coach/core/cards/cards.dart';
import 'package:estimation_coach/core/game_rules/bidding.dart';
import 'package:estimation_coach/core/game_rules/play_situation.dart';
import 'package:estimation_coach/core/game_rules/void_tracking.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ObservedTrick trick(List<(PlayerSeat, String)> plays) =>
      ObservedTrick(plays.map((p) => SeatPlay(p.$1, GameCard.parse(p.$2))));

  test('following suit does not infer a void', () {
    final history = [
      trick([
        (PlayerSeat.west, '8D'),
        (PlayerSeat.north, 'JD'),
        (PlayerSeat.east, '4D'),
        (PlayerSeat.south, '9D'),
      ]),
    ];
    expect(
      knownVoidSuits(
        seat: PlayerSeat.east,
        observedTricks: history,
        currentTrick: const [],
      ),
      isEmpty,
    );
  });

  test('off-suit play infers the led suit as void', () {
    final history = [
      trick([
        (PlayerSeat.west, '8D'),
        (PlayerSeat.north, 'JD'),
        (PlayerSeat.east, '4C'),
        (PlayerSeat.south, '9D'),
      ]),
    ];
    expect(
      knownVoidSuits(
        seat: PlayerSeat.east,
        observedTricks: history,
        currentTrick: const [],
      ),
      {Suit.diamonds},
    );
  });

  test('repeated evidence deduplicates the suit', () {
    final history = [
      trick([
        (PlayerSeat.west, '8D'),
        (PlayerSeat.north, 'JD'),
        (PlayerSeat.east, '4C'),
        (PlayerSeat.south, '9D'),
      ]),
      trick([
        (PlayerSeat.north, '7D'),
        (PlayerSeat.east, '5C'),
        (PlayerSeat.south, 'QD'),
        (PlayerSeat.west, '2D'),
      ]),
    ];
    final voids = knownVoidSuits(
      seat: PlayerSeat.east,
      observedTricks: history,
      currentTrick: const [],
    );
    expect(voids, {Suit.diamonds});
    expect(voids, hasLength(1));
  });

  test('one player can become known void in multiple suits', () {
    final history = [
      trick([
        (PlayerSeat.west, '8D'),
        (PlayerSeat.north, 'JD'),
        (PlayerSeat.east, '4C'),
        (PlayerSeat.south, '9D'),
      ]),
      trick([
        (PlayerSeat.north, '8H'),
        (PlayerSeat.east, '3S'),
        (PlayerSeat.south, 'QH'),
        (PlayerSeat.west, '2H'),
      ]),
    ];
    expect(
      knownVoidSuits(
        seat: PlayerSeat.east,
        observedTricks: history,
        currentTrick: const [],
      ),
      {Suit.diamonds, Suit.hearts},
    );
  });

  test('an empty trick is ignored safely', () {
    expect(
      knownVoidSuits(
        seat: PlayerSeat.east,
        observedTricks: const [],
        currentTrick: const [],
      ),
      isEmpty,
    );
  });

  test('the current unfinished trick can reveal a void', () {
    final currentTrick = [
      SeatPlay(PlayerSeat.north, GameCard.parse('6H')),
      SeatPlay(PlayerSeat.east, GameCard.parse('3C')),
    ];
    expect(
      knownVoidSuits(
        seat: PlayerSeat.east,
        observedTricks: const [],
        currentTrick: currentTrick,
      ),
      {Suit.hearts},
    );
  });

  test(
    'existing play scenarios remain backward-compatible with no observed history',
    () {
      final situation = PlaySituation(
        playerPosition: PlayerSeat.south,
        hand: Hand(['AH', '3H', '2C', '5D'].map(GameCard.parse)),
        leader: PlayerSeat.west,
        currentTrick: [
          SeatPlay(PlayerSeat.west, GameCard.parse('8H')),
          SeatPlay(PlayerSeat.north, GameCard.parse('4H')),
          SeatPlay(PlayerSeat.east, GameCard.parse('6H')),
        ],
        trump: Trump.clubs,
        trickEstimate: TrickEstimate(5),
        tricksTaken: {
          PlayerSeat.north: 2,
          PlayerSeat.east: 2,
          PlayerSeat.south: 2,
          PlayerSeat.west: 3,
        },
      );
      expect(situation.observedTricks, isEmpty);
      for (final seat in PlayerSeat.values) {
        expect(
          knownVoidSuits(
            seat: seat,
            observedTricks: situation.observedTricks,
            currentTrick: situation.currentTrick,
          ),
          isEmpty,
        );
      }
    },
  );
}
