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
    if (list.length != PlayerSeat.values.length ||
        list.map((play) => play.seat).toSet().length !=
            PlayerSeat.values.length) {
      throw ArgumentError('An observed trick has all four seats, once each');
    }
    return ObservedTrick._(list);
  }

  const ObservedTrick._(this.plays);

  /// Supplied order, beginning with that trick's own leader.
  final List<SeatPlay> plays;
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
    Iterable<ObservedTrick> observedTricks = const [],
  }) {
    final plays = List<SeatPlay>.unmodifiable(currentTrick);
    final taken = Map<PlayerSeat, int>.unmodifiable(tricksTaken);
    final history = List<ObservedTrick>.unmodifiable(observedTricks);
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
    final totalCompleted = taken.values.fold(0, (sum, count) => sum + count);
    if (totalCompleted != 13 - hand.length) {
      throw ArgumentError('Taken counts disagree with the remaining hand');
    }
    if (history.length > totalCompleted) {
      throw ArgumentError(
        'Cannot observe more completed tricks than tricksTaken records',
      );
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
    for (final trick in history) {
      for (final play in trick.plays) {
        if (!cards.add(play.card)) {
          throw ArgumentError('Duplicate card in hand/current/observed play');
        }
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
      history,
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
    this.observedTricks,
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

  /// Prior tricks visible to the player for this decision. See [ObservedTrick]
  /// for what this does and does not claim about the round's full history.
  final List<ObservedTrick> observedTricks;

  Suit? get ledSuit =>
      currentTrick.isEmpty ? null : currentTrick.first.card.suit;
  int get playerTricksTaken => tricksTaken[playerPosition]!;
  List<GameCard> get legalChoices => rules.legalCards(hand, ledSuit: ledSuit);
}
