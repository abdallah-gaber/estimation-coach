import 'package:estimation_coach/core/cards/cards.dart';
import 'package:estimation_coach/core/game_rules/bidding.dart';
import 'package:estimation_coach/core/game_rules/play_situation.dart';
import 'package:estimation_coach/core/game_rules/seat_rotation.dart';
import 'package:estimation_coach/core/game_rules/trick_winner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Builds a complete four-play trick in canonical rotation order from
  // [leader], one card per seat in that order.
  ObservedTrick trick(PlayerSeat leader, List<String> cardsInOrder) {
    final order = rotationFrom(leader);
    return ObservedTrick([
      for (final (i, seat) in order.indexed)
        SeatPlay(seat, GameCard.parse(cardsInOrder[i])),
    ]);
  }

  test('highest card of the led suit wins when no trump is played', () {
    // East leads Hearts; North and West follow, South discards a Club.
    final t = trick(PlayerSeat.east, ['7H', 'QH', '2H', '3C']);
    final winner = trickWinner(t, Trump.spades);
    expect(winner, PlayerSeat.north); // QH is the highest Heart shown.
  });

  test('rank order is A > K > ... > 2 among the contesting suit', () {
    final t = trick(PlayerSeat.east, ['AH', '2H', 'KH', 'QH']);
    expect(trickWinner(t, Trump.clubs), PlayerSeat.east); // AH highest.
  });

  test('a single trump beats every non-trump card regardless of rank', () {
    // East leads Hearts (AH, the highest Heart); West trumps with a low Club.
    final t = trick(PlayerSeat.east, ['AH', 'KH', '2C', 'QH']);
    expect(trickWinner(t, Trump.clubs), PlayerSeat.west);
  });

  test('the highest trump wins when more than one trump is played', () {
    final t = trick(PlayerSeat.east, ['AH', '5C', 'KH', '9C']);
    // North (5C) and South (9C) both trump; 9 beats 5.
    expect(trickWinner(t, Trump.clubs), PlayerSeat.south);
  });

  test('leading trump itself is just the highest card of that suit', () {
    final t = trick(PlayerSeat.east, ['7S', 'KS', '2S', 'AS']);
    expect(trickWinner(t, Trump.spades), PlayerSeat.south); // AS.
  });

  test('in Sans only the led suit can ever win, trump is meaningless', () {
    final t = trick(PlayerSeat.east, ['7H', '2H', 'AC', 'QH']);
    // East's off-suit Ace of Clubs cannot win in Sans no matter its rank.
    expect(
      trickWinner(t, Trump.noTrump),
      PlayerSeat.south,
    ); // QH highest Heart.
  });

  test('an off-suit, non-trump card never wins even with the highest rank', () {
    final t = trick(PlayerSeat.east, ['2H', 'AC', '3H', '4H']);
    expect(trickWinner(t, Trump.spades), PlayerSeat.south); // 4H, not AC.
  });

  test('every seat can be the leader and every seat can win', () {
    for (final leader in PlayerSeat.values) {
      final order = rotationFrom(leader);
      for (var winnerIndex = 0; winnerIndex < 4; winnerIndex++) {
        final cards = ['2H', '3H', '4H', '5H'];
        cards[winnerIndex] = 'AH';
        final t = trick(leader, cards);
        expect(trickWinner(t, Trump.clubs), order[winnerIndex]);
      }
    }
  });

  test('the same cards can resolve differently depending on trump alone', () {
    // North leads Diamonds; rotation from North is North-West-South-East,
    // so North=9D, West=2S, South=KD, East=AD.
    final t = trick(PlayerSeat.north, ['9D', '2S', 'KD', 'AD']);
    expect(
      trickWinner(t, Trump.diamonds),
      PlayerSeat.east,
    ); // AD, highest Diamond.
    expect(
      trickWinner(t, Trump.spades),
      PlayerSeat.west,
    ); // 2S is the only trump.
  });
}
