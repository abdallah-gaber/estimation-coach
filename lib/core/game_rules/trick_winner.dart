import '../cards/cards.dart';
import 'bidding.dart';
import 'seat_play.dart';

/// Confirmed game_rules_v1 "Trick winners" rule, applied to one already
/// complete trick: the highest card of the led suit wins unless at least
/// one trump is played, in which case the highest trump wins; in Sans
/// (`Trump.noTrump`) only the led suit can ever win. Rank order is
/// A > K > Q > J > 10 > 9 > 8 > 7 > 6 > 5 > 4 > 3 > 2.
///
/// This resolves exactly one fully-shown trick — the seats and cards
/// already visible in [trick]. It does not chain across tricks, track a
/// full round, or resolve scoring; those remain explicitly out of scope
/// (see game_rules_v1's Scope section).
///
/// Deliberately *not* wired into [PlaySituation]'s validation: `observedTricks`
/// is curated, visible evidence, not guaranteed to be a contiguous sequence
/// ending at the immediately previous trick, so nothing can assume this
/// function's answer for `observedTricks.last` is who leads next (see
/// docs/DECISIONS.md D-025). Use it directly — in content-authoring tooling
/// or a targeted test for one specific scenario — only where that scenario's
/// own authored intent already establishes the observed trick as immediately
/// previous.
PlayerSeat trickWinner(ObservedTrick trick, Trump trump) {
  final ledSuit = trick.plays.first.card.suit;
  Suit? trumpSuit;
  if (trump != Trump.noTrump) {
    final matchingSuit = Suit.values.firstWhere(
      (suit) => suit.name == trump.name,
    );
    if (trick.plays.any((play) => play.card.suit == matchingSuit)) {
      trumpSuit = matchingSuit;
    }
  }
  final contestingSuit = trumpSuit ?? ledSuit;
  return trick.plays
      .where((play) => play.card.suit == contestingSuit)
      .reduce(
        (best, play) =>
            play.card.rank.index > best.card.rank.index ? play : best,
      )
      .seat;
}
