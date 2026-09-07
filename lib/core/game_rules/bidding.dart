enum PlayerSeat { north, east, south, west }

enum BiddingPhase { preBidding, normal }

/// Trump categories are not card suits. Sans does not add cards to the deck.
enum Trump {
  clubs('clubs', 0),
  diamonds('diamonds', 1),
  hearts('hearts', 2),
  spades('spades', 3),
  noTrump('no_trump', 4);

  const Trump(this.code, this.strength);
  final String code;
  final int strength;
}

final class Bid implements Comparable<Bid> {
  Bid(this.tricks, this.trump) {
    if (tricks < 4 || tricks > 13) {
      throw RangeError.range(tricks, 4, 13, 'tricks');
    }
  }

  final int tricks;
  final Trump trump;

  @override
  int compareTo(Bid other) {
    final count = tricks.compareTo(other.tricks);
    return count != 0 ? count : trump.strength.compareTo(other.trump.strength);
  }

  @override
  bool operator ==(Object other) =>
      other is Bid && tricks == other.tricks && trump == other.trump;
  @override
  int get hashCode => Object.hash(tricks, trump);
}

/// Scope: participation, phase, and bid ranking. Does not infer turns or passes.
final class BiddingState {
  BiddingState._(this.phase, Iterable<PlayerSeat> dashPlayers, this.currentBid)
    : dashPlayers = Set.unmodifiable(dashPlayers);

  factory BiddingState.start() =>
      BiddingState._(BiddingPhase.preBidding, {}, null);
  final BiddingPhase phase;
  final Set<PlayerSeat> dashPlayers;
  final Bid? currentBid;

  /// Null means no fixed estimate is known here; Dash stays exactly zero.
  int? fixedEstimate(PlayerSeat player) =>
      dashPlayers.contains(player) ? 0 : null;

  BiddingState declareDash(PlayerSeat player) {
    if (phase != BiddingPhase.preBidding || dashPlayers.contains(player)) {
      throw StateError('Dash must be declared once before normal bidding');
    }
    return BiddingState._(phase, {...dashPlayers, player}, currentBid);
  }

  BiddingState startNormalBidding() {
    if (phase != BiddingPhase.preBidding) {
      throw StateError('Normal bidding already started');
    }
    return BiddingState._(BiddingPhase.normal, dashPlayers, null);
  }

  bool canBid(PlayerSeat player, Bid bid) =>
      phase == BiddingPhase.normal &&
      !dashPlayers.contains(player) &&
      (currentBid == null || bid.compareTo(currentBid!) > 0);

  BiddingState placeBid(PlayerSeat player, Bid bid) {
    if (!canBid(player, bid)) throw StateError('Player cannot make this bid');
    return BiddingState._(phase, dashPlayers, bid);
  }
}
