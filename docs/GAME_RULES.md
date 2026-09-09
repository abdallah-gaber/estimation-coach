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
  trick is empty. `currentTrick` must be an ordered prefix of the
  owner-confirmed counter-clockwise rotation from `leader` (see
  [game_rules_v1](GAME_RULES_V1.md#play-direction--seat-rotation) and
  `lib/core/game_rules/seat_rotation.dart`), and `playerPosition` must be
  exactly the next seat to act — this is seat succession within one trick
  only, not a trick-winner resolver or a computed next-trick leader.
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
  exactly four `SeatPlay`s, one per seat, in the same owner-confirmed
  rotation order starting from that trick's own leader (enforced by
  `ObservedTrick`'s own constructor). It is a curated, visible *subset* of
  prior tricks relevant to the current decision, never a claim of recency or
  completeness; its cards must not duplicate the hand, current trick, or each
  other, and its length cannot exceed the total completed tricks implied by
  `tricksTaken`.

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

The 32 tests cover boundaries, low estimates, overtricks, all trump
categories, all leading seats, voids, defensive copies, rotation validation
for every leader and rejected seat sequences, observed-trick validation, and
invalid snapshots.

## EC-042: void tracking

`lib/core/game_rules/void_tracking.dart` derives known-void suits from
visible play — never authored. `knownVoidSuits` scans a seat's cards across
`observedTricks` and the unfinished `currentTrick` uniformly: if a seat plays
off the trick's led suit, the confirmed [follow-suit
rule](#ec-021-following-suit) proves that seat held none of it at that
moment. No new game rule is introduced; this is a direct consequence of the
rule already implemented for EC-021. An empty trick (leading) is skipped
safely and contributes nothing. The function is pure and does not depend on
`PlayScenario`, the parser, or any widget — it does not itself enforce seat
rotation (that is `PlaySituation`/`ObservedTrick`'s job), so it stays testable
against arbitrary seat lists.

Seat succession itself is `lib/core/game_rules/seat_rotation.dart`
(`rotationFrom`), the owner-confirmed counter-clockwise rotation from
[game_rules_v1](GAME_RULES_V1.md#play-direction--seat-rotation). It is a
single pure lookup, used by both `PlaySituation` (for `currentTrick`) and
`ObservedTrick` (for its own four seats), so no parser or widget duplicates
seat-ordering logic.

```sh
flutter test test/core/game_rules/void_tracking_test.dart
```

The 8 tests cover: following suit inferring no void, an off-suit play
inferring one, repeated evidence deduplicating, one seat becoming void in
multiple suits, an empty trick being ignored, a void revealed within the
current unfinished trick, and backward compatibility with scenarios that
carry no observed history at all.

## Post-auction trick estimates (EC-043 preparation)

Two small pure modules implement the owner-confirmed estimate rules from
[game_rules_v1](GAME_RULES_V1.md#post-auction-trick-estimates). Neither
models the estimate phase's seat order, tracks a round, resolves a trick
winner, or computes a score — both classify already-known values.

`lib/core/game_rules/estimate_totals.dart` covers the estimate-*set* rules:

- `estimateTotal`/`isValidEstimateTotal` sum a complete `Map<PlayerSeat,
  TrickEstimate>` and check it does not equal 13.
- `classifyEstimateTotal` returns `EstimateTotalBalance.over` (total ≥ 14) or
  `.under` (≤ 12); it throws if the total is exactly 13 rather than silently
  picking a side.
- `isValidNonCallerEstimate` checks a non-Caller's estimate does not exceed
  the Caller's.
- `isWithCaller` derives "With" from equality with the Caller's estimate —
  scenario content should never carry a redundant authored `with` flag.

```sh
flutter test test/core/game_rules/estimate_totals_test.dart
```

`lib/core/game_rules/exact_bid_outcome.dart` covers the exact-target rule:
`classifyExactBid` compares a known trick count against a `TrickEstimate` and
returns `ExactBidOutcome.onTarget` / `.tookMore` / `.tookFewer` — deliberately
named apart from `EstimateTotalBalance` to keep "the room's total vs 13" and
"one player's tricks vs their own estimate" from being confused as the same
comparison; they are unrelated except for both having a higher/lower/equal
shape.

Play Practice uses this function for its **Before this play** status from the
existing `PlaySituation.trickEstimate` and `playerTricksTaken`. EC-043's three
authored scenarios require no contract extension. The count and classification
remain the original snapshot after submission; no winner or round is advanced.

```sh
flutter test test/core/game_rules/exact_bid_outcome_test.dart
```

7 and 5 tests respectively cover the boundaries above, including that the
total-13 case throws rather than resolving to an arbitrary side, and that an
out-of-range trick count is rejected.
