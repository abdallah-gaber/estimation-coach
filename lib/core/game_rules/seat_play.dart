import '../cards/cards.dart';
import 'bidding.dart';
import 'seat_rotation.dart';

/// One visible card belonging to a seat in a trick.
final class SeatPlay {
  const SeatPlay(this.seat, this.card);
  final PlayerSeat seat;
  final GameCard card;
}

/// One prior trick the player can see, offered as visible evidence for this
/// decision — not a claim that it is the most recent trick, or that it is
/// the complete history of the round. An author may show only the tricks
/// relevant to the lesson; nothing infers who is void from an *absence* of
/// shown history, only from an actual observed off-suit play.
final class ObservedTrick {
  factory ObservedTrick(Iterable<SeatPlay> plays) {
    final list = List<SeatPlay>.unmodifiable(plays);
    if (list.length != PlayerSeat.values.length) {
      throw ArgumentError('An observed trick has all four seats, once each');
    }
    final order = rotationFrom(list.first.seat);
    for (var i = 0; i < list.length; i++) {
      if (list[i].seat != order[i]) {
        throw ArgumentError(
          'An observed trick must follow the canonical seat rotation from '
          'its leader (see game_rules_v1)',
        );
      }
    }
    return ObservedTrick._(list);
  }

  const ObservedTrick._(this.plays);

  /// Supplied order, beginning with that trick's own leader.
  final List<SeatPlay> plays;
}
