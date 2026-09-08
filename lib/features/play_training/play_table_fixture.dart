import '../../core/cards/cards.dart';
import '../../core/game_rules/bidding.dart';

/// UI fixture only, like preview_cards.dart. No authored coaching or outcome.
/// Replace with validated portable play scenarios during EC-047 coached integration.
abstract final class PlayTableFixture {
  static final hand = Hand(['3H', '9H', 'AS', '2C'].map(GameCard.parse));
  static const trump = Trump.spades;
  static const target = 4;
  static const taken = 3;
  static const leader = PlayerSeat.west;
  static const trick = [
    (seat: PlayerSeat.west, card: GameCard(Rank.seven, Suit.hearts)),
    (seat: PlayerSeat.north, card: GameCard(Rank.queen, Suit.hearts)),
    (seat: PlayerSeat.east, card: GameCard(Rank.two, Suit.hearts)),
  ];
  static const opponentTaken = 2;
}
