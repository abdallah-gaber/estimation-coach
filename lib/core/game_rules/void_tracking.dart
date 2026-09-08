import '../cards/cards.dart';
import 'bidding.dart';
import 'play_situation.dart';

/// Suits [seat] is known void in, derived only from observed suit mismatches
/// — never authored, and never a guess. Uses the confirmed follow-suit rule
/// (see `legal_cards.dart`): a seat that could follow the led suit must, so
/// an observed off-suit play proves that seat held none of that suit at the
/// time. The absence of shown history proves nothing; only an actual
/// off-suit play does.
///
/// Scans both [observedTricks] (already-finished tricks) and the unfinished
/// [currentTrick] uniformly — a void can be revealed within the trick in
/// progress just as validly as in an earlier one. An empty trick (no cards
/// played yet, e.g. the player is leading) contributes no information and is
/// skipped safely.
Set<Suit> knownVoidSuits({
  required PlayerSeat seat,
  required List<ObservedTrick> observedTricks,
  required List<SeatPlay> currentTrick,
}) {
  final voids = <Suit>{};

  void scan(List<SeatPlay> plays) {
    if (plays.isEmpty) return;
    final ledSuit = plays.first.card.suit;
    for (final play in plays) {
      if (play.seat == seat && play.card.suit != ledSuit) {
        voids.add(ledSuit);
      }
    }
  }

  for (final trick in observedTricks) {
    scan(trick.plays);
  }
  scan(currentTrick);
  return voids;
}
