import 'package:estimation_coach/core/game_rules/bidding.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'normal bids accept 4–13 tricks and reject smaller or larger counts',
    () {
      for (final trump in Trump.values) {
        for (final count in [-1, 0, 1, 2, 3, 14]) {
          expect(() => Bid(count, trump), throwsRangeError);
        }
        expect(Bid(4, trump).tricks, 4);
        expect(Bid(13, trump).tricks, 13);
      }
    },
  );

  test(
    'canonical equal-count ordering and count priority for all trump pairs',
    () {
      const order = [
        Trump.clubs,
        Trump.diamonds,
        Trump.hearts,
        Trump.spades,
        Trump.noTrump,
      ];
      for (var i = 0; i < order.length; i++) {
        for (var j = 0; j < order.length; j++) {
          expect(
            Bid(4, order[i]).compareTo(Bid(4, order[j])).sign,
            (i - j).sign,
          );
          expect(Bid(5, order[i]).compareTo(Bid(4, order[j])), greaterThan(0));
        }
      }
    },
  );

  test('bid equality and hash use count and trump', () {
    final first = Bid(4, Trump.noTrump);
    final second = Bid(4, Trump.noTrump);
    expect(first, second);
    expect(first.hashCode, second.hashCode);
    expect({first, second}, hasLength(1));
    expect(first, isNot(Bid(4, Trump.spades)));
  });

  test('Dash is pre-bidding only and its zero estimate persists', () {
    final start = BiddingState.start();
    expect(start.canBid(PlayerSeat.south, Bid(4, Trump.clubs)), isFalse);
    final dash = start.declareDash(PlayerSeat.south);
    expect(start.dashPlayers, isEmpty);
    expect(dash.fixedEstimate(PlayerSeat.south), 0);
    expect(dash.fixedEstimate(PlayerSeat.north), isNull);
    expect(() => dash.declareDash(PlayerSeat.south), throwsStateError);
    final normal = dash.startNormalBidding();
    expect(normal.fixedEstimate(PlayerSeat.south), 0);
    expect(normal.canBid(PlayerSeat.south, Bid(13, Trump.noTrump)), isFalse);
    expect(
      () => normal.placeBid(PlayerSeat.south, Bid(4, Trump.spades)),
      throwsStateError,
    );
    expect(() => normal.declareDash(PlayerSeat.north), throwsStateError);
    expect(() => normal.startNormalBidding(), throwsStateError);
    expect(() => normal.dashPlayers.clear(), throwsUnsupportedError);
  });

  test(
    'normal bids must strictly outrank current bid and state is immutable',
    () {
      final normal = BiddingState.start().startNormalBidding();
      final hearts = normal.placeBid(PlayerSeat.north, Bid(4, Trump.hearts));
      expect(normal.currentBid, isNull);
      expect(hearts.canBid(PlayerSeat.south, Bid(4, Trump.hearts)), isFalse);
      expect(hearts.canBid(PlayerSeat.south, Bid(4, Trump.diamonds)), isFalse);
      expect(hearts.canBid(PlayerSeat.south, Bid(4, Trump.spades)), isTrue);
      final sans = hearts.placeBid(PlayerSeat.south, Bid(4, Trump.noTrump));
      expect(sans.canBid(PlayerSeat.west, Bid(5, Trump.clubs)), isTrue);
      expect(
        () => sans.placeBid(PlayerSeat.west, Bid(4, Trump.spades)),
        throwsStateError,
      );
    },
  );
}
