import '../cards/cards.dart';
import 'bidding.dart';
import 'play_situation.dart';

/// Confirmed game_rules_v1 "Trick winners" rule, applied to one already
/// complete trick: the highest card of the led suit wins unless at least
/// one trump is played, in which case the highest trump wins; in Sans
/// (`Trump.noTrump`) only the led suit can ever win. Rank order is
/// A > K > Q > J > 10 > 9 > 8 > 7 > 6 > 5 > 4 > 3 > 2.
///
/// This resolves exactly one fully-shown trick — the seats and cards
/// already visible in [trick]. It does not chain across tricks, compute a
/// future trick's leader beyond the immediate next one, track a full round,
/// or resolve scoring; those remain explicitly out of scope (see
/// game_rules_v1's Scope section).
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
