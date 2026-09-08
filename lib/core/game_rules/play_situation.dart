import '../cards/cards.dart';
import 'bidding.dart';
import 'legal_cards.dart' as rules;

/// An already assigned exact-trick target, not an auction bid or Dash declaration.
/// 0–13 is a physical bound; this does not define how estimates are assigned.
final class TrickEstimate {
  TrickEstimate(this.tricks) {
    if (tricks < 0 || tricks > 13) {
      throw RangeError.range(tricks, 0, 13, 'tricks');
    }
  }

  final int tricks;

  @override
  bool operator ==(Object other) =>
      other is TrickEstimate && tricks == other.tricks;
  @override
  int get hashCode => tricks.hashCode;
}

/// One visible card belonging to a seat in the unfinished current trick.
final class SeatPlay {
  const SeatPlay(this.seat, this.card);
  final PlayerSeat seat;
  final GameCard card;
}

/// Public information immediately before [playerPosition] chooses a card.
/// No hidden hands, auction progression, winner resolution or coaching.
final class PlaySituation {
  factory PlaySituation({
    required PlayerSeat playerPosition,
    required Hand hand,
    required PlayerSeat leader,
    required Iterable<SeatPlay> currentTrick,
    required Trump trump,
    required TrickEstimate trickEstimate,
    required Map<PlayerSeat, int> tricksTaken,
    Bid? auctionBid,
  }) {
    final plays = List<SeatPlay>.unmodifiable(currentTrick);
    final taken = Map<PlayerSeat, int>.unmodifiable(tricksTaken);
    if (hand.isEmpty) {
      throw ArgumentError('A pending card decision requires a nonempty hand');
    }
    if (plays.length > 3) {
      throw ArgumentError('The current trick must be unfinished');
    }
    if (taken.length != PlayerSeat.values.length ||
        !PlayerSeat.values.every(taken.containsKey)) {
      throw ArgumentError('tricksTaken must contain all four seats');
    }
    for (final count in taken.values) {
      if (count < 0 || count > 13) {
        throw RangeError.range(count, 0, 13, 'tricksTaken');
      }
    }
    // This player has not played into the current trick, so its remaining hand
    // contains exactly one card per unfinished trick in the 13-trick hand.
    if (taken.values.fold(0, (sum, count) => sum + count) != 13 - hand.length) {
      throw ArgumentError('Taken counts disagree with the remaining hand');
    }
    if (plays.isEmpty ? leader != playerPosition : plays.first.seat != leader) {
      throw ArgumentError(
        'Leader must lead this decision or own the first card',
      );
    }
    final seats = <PlayerSeat>{};
    final cards = hand.cards.toSet();
    for (final play in plays) {
      if (play.seat == playerPosition || !seats.add(play.seat)) {
        throw ArgumentError(
          'A seat cannot play twice or before its own pending decision',
        );
      }
      if (!cards.add(play.card)) {
        throw ArgumentError('Duplicate card in hand/current trick');
      }
    }
    if (auctionBid != null && auctionBid.trump != trump) {
      throw ArgumentError(
        'Known winning auction bid must match normal-round trump',
      );
    }
    return PlaySituation._(
      playerPosition,
      hand,
      leader,
      plays,
      trump,
      trickEstimate,
      taken,
      auctionBid,
    );
  }

  const PlaySituation._(
    this.playerPosition,
    this.hand,
    this.leader,
    this.currentTrick,
    this.trump,
    this.trickEstimate,
    this.tricksTaken,
    this.auctionBid,
  );

  final PlayerSeat playerPosition;
  final Hand hand;
  final PlayerSeat leader;

  /// Supplied order, beginning with the lead. Play direction is not inferred.
  final List<SeatPlay> currentTrick;
  final Trump trump;
  final TrickEstimate trickEstimate;
  final Map<PlayerSeat, int> tricksTaken;

  /// Optional known winning auction bid; never used as this player's estimate.
  final Bid? auctionBid;

  Suit? get ledSuit =>
      currentTrick.isEmpty ? null : currentTrick.first.card.suit;
  int get playerTricksTaken => tricksTaken[playerPosition]!;
  List<GameCard> get legalChoices => rules.legalCards(hand, ledSuit: ledSuit);
}
