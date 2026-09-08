# Implemented game rules

Canonical normal bidding rules are in [game_rules_v1](GAME_RULES_V1.md). They
take precedence over implementation and content. This page describes the
currently implemented follow-suit rule.

## EC-021: following suit

The rule in AGENTS.md and PROJECT_TRACKER.md is implemented by the pure Dart
functions in `lib/core/game_rules/legal_cards.dart`:

- `legalCards(hand, ledSuit: suit)` returns the cards allowed by following suit.
- `isLegalPlay(hand, card, ledSuit: suit)` also checks that the card is held.

Pass the suit of the **first** card in the trick as `ledSuit`. When leading a new
trick, pass null (the default).

| Situation | Allowed cards |
| --- | --- |
| Leading a new trick | Every card in the hand |
| Holding one or more cards of the led suit | Only cards of that suit |
| Void in the led suit | Every card in the hand |
| Empty hand | None |
| Candidate absent from the hand | Never allowed |

Rank does not affect following suit. No obligation to beat a previous card is
introduced. Returned lists preserve hand display order and cannot be modified;
evaluation does not change the hand.

```dart
final hand = Hand(['AS', '2H', 'KD'].map(GameCard.parse));
final allowed = legalCards(hand, ledSuit: Suit.hearts); // [2H]
final canDiscard = isLegalPlay(hand, GameCard.parse('KD'), ledSuit: Suit.hearts);
// false: a Heart is still held.
```

This is a card-selection rule, not a round engine. Callers must manage turn
order, derive the led suit from the current trick, and prevent actions after a
trick is complete. Trump winner resolution and scoring are not implemented
here. Bidding rules are implemented separately under game_rules_v1.
`PlaySituation.legalChoices` (see [EC-045](#ec-045-public-play-situation) below)
wraps this helper for a pending play decision; the Play practice screen commits
one legal card and shows authored coaching from a `PlayScenario`, but does not
resolve a trick winner. The older four-card specimen still uses a demonstration
lock.

Run the rule tests:

```sh
flutter test test/core/game_rules/legal_cards_test.dart
```

Tests cover leading, following with low cards, voids, absent cards, empty and
single-card hands, immutable results, and all suit/rank combinations.

## EC-045: public play situation

`lib/core/game_rules/play_situation.dart` adds an immutable snapshot immediately
before one player chooses a card. It is a domain building block, not a round
engine. EC-046 defines the portable schema/parser (`PlayScenario`); EC-047
connects a reviewed pack of these to the Play practice screen.

- `playerPosition` identifies the pending decision; that seat has not played
  into `currentTrick` yet.
- `hand` holds 1–13 remaining cards. `currentTrick` holds 0–3 ordered `SeatPlay`
  entries, each with a distinct opponent seat and card.
- `leader` must own the first visible card, or be the pending player if the
  trick is empty. The supplied order is preserved without inventing clockwise
  or counterclockwise play.
- `tricksTaken` records completed tricks for all four seats. Counts are
  nonnegative; their sum equals `13 - hand.length` because the pending player
  has not played into the current trick. Current-trick cards cannot also be held.
- `trump` is fixed public context for this normal-round snapshot. Optional
  `auctionBid` is the known winning auction bid, whose trump must match it.
- `trickEstimate` is the pending player's separately assigned target. Its 0–13
  bounds express physical trick counts, not a new rule for assigning estimates.
  Zero does not imply that Dash was declared; the type carries no Dash history.
  Estimates below four and tricks taken above the estimate are representable.
- `legalChoices` reuses the established follow-suit helper. Leading or being
  void allows every held card; Sans does not change follow-suit behavior.
- `observedTricks` (EC-042) is an optional list of `ObservedTrick` — each
  exactly four `SeatPlay`s, one per seat, first is that trick's own leader.
  It is a curated, visible *subset* of prior tricks relevant to the current
  decision, never a claim of recency or completeness; its cards must not
  duplicate the hand, current trick, or each other, and its length cannot
  exceed the total completed tricks implied by `tricksTaken`.

The model checks internal public-snapshot consistency, not whether hidden hands
or a full historical round could produce it. It does not validate opponents'
follow-suit compliance without their hands, resolve a winner, progress turns,
assign estimates, infer the winning bidder's identity, or grade decisions.
Completed tricks/hands beyond what `observedTricks` explicitly shows are
outside this pending-decision model — in particular, one observed trick's
leader is never checked against a previous trick's winner, since that would
require a winner resolver this project does not have.

```sh
flutter test test/core/game_rules/play_situation_test.dart
```

The 28 tests cover boundaries, low estimates, overtricks, all trump
categories, all leading seats, voids, defensive copies, observed-trick
validation, and invalid snapshots.

## EC-042: void tracking

`lib/core/game_rules/void_tracking.dart` derives known-void suits from
visible play — never authored. `knownVoidSuits` scans a seat's cards across
`observedTricks` and the unfinished `currentTrick` uniformly: if a seat plays
off the trick's led suit, the confirmed [follow-suit
rule](#ec-021-following-suit) proves that seat held none of it at that
moment. No new game rule is introduced; this is a direct consequence of the
rule already implemented for EC-021. An empty trick (leading) is skipped
safely and contributes nothing. The function is pure and does not depend on
`PlayScenario`, the parser, or any widget.

```sh
flutter test test/core/game_rules/void_tracking_test.dart
```

The 7 tests cover: following suit inferring no void, an off-suit play
inferring one, repeated evidence deduplicating, one seat becoming void in
multiple suits, an empty trick being ignored, a void revealed within the
current unfinished trick, and backward compatibility with scenarios that
carry no observed history at all.
