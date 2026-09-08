import 'bidding.dart';

/// Canonical counter-clockwise play rotation, owner-confirmed 2026-09-08:
/// North → West → South → East → North (see game_rules_v1). This defines
/// seat succession within one trick only. It does not resolve a trick
/// winner, compute the next trick's leader, or model a full round.
PlayerSeat nextSeat(PlayerSeat seat) => switch (seat) {
  PlayerSeat.north => PlayerSeat.west,
  PlayerSeat.west => PlayerSeat.south,
  PlayerSeat.south => PlayerSeat.east,
  PlayerSeat.east => PlayerSeat.north,
};

/// The four seats in play order for one trick, starting with [leader].
List<PlayerSeat> rotationFrom(PlayerSeat leader) {
  final order = <PlayerSeat>[];
  var seat = leader;
  for (var i = 0; i < PlayerSeat.values.length; i++) {
    order.add(seat);
    seat = nextSeat(seat);
  }
  return List.unmodifiable(order);
}
