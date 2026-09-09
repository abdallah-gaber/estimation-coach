# game_rules_v1 — Canonical trainer rules

**Status:** Accepted. Confirmed by the project owner on 2026-09-06.

This document is the source of truth for the trainer's normal bidding rounds.
If code, schema, draft content or an older design note conflicts with these rules,
these documented rules take precedence. Implementation gaps are not rule variants.

## Normal bidding

The minimum opening bid is **4 tricks**. A bid consists of a trick count and a
trump category. Compare trick counts first; for equal counts, compare trump rank.
An equal-count bid is allowed only with a higher-ranked trump category.

Trump categories, highest to lowest:

1. No Trump / Sans
2. Spades
3. Hearts
4. Diamonds
5. Clubs

No Trump / Sans is allowed. It is a trump category, not a fifth card suit: the
standard deck still has four suits.

Examples:

| Current bid | New bid | Result |
| --- | --- | --- |
| No bid | 3 Spades | Below minimum; not allowed |
| No bid | 4 Clubs | Meets the opening minimum |
| 4 Diamonds | 4 Hearts | Higher trump rank; allowed |
| 4 Hearts | 4 Diamonds | Lower trump rank; not allowed |
| 4 Hearts | 4 Hearts | Same bid; not allowed |
| 4 Spades | 4 Sans | Higher trump rank; allowed |
| Any 4-trick bid, including Sans | 5 Clubs | Higher trick count; allowed |

## Dash phase

Dash is an estimate of **exactly 0 tricks**. It is declared **before normal
bidding starts**, while the round's trump is still unknown.

A player who declares Dash keeps an estimate of 0 for that hand and does not
participate in normal bidding for tricks/trump. Dash must not be presented as an
alternative to raising an existing normal bid. Normal bids and a pre-bidding Dash
decision belong to distinct phases of the training flow.

## Post-auction trick estimates

Owner-confirmed on 2026-09-08:

1. After the Caller wins the auction and sets trump, the other players enter
   their exact trick estimates. The Caller's own estimate is their winning
   auction bid's trick count — a separate value is not entered for the Caller.
2. A non-Caller may not estimate more tricks than the Caller.
3. A player may estimate the same number as the Caller; this is **With**.
4. The total of all four trick estimates must never equal 13. The last
   player in the estimate phase must choose a value that makes the total
   less than 13 or greater than 13.
5. A total of 14 or more is **Over**; a total of 12 or fewer is **Under**.
6. A player's target is exact: success means taking exactly the number of
   tricks estimated, not at least that number.
7. **Risk** is associated with the last estimator when that estimate pushes
   the total farther from 13; multiple risk levels exist. Risk *scoring* is
   not confirmed and is deliberately not implemented yet — see the
   [audit](#rule-domain-status-audit-2026-09-08) below.

This confirms constraints on individual estimates and on the completed set
of four; it does **not** confirm which seat estimates in which order, or
whose turn is "last" (see [Scope](#scope)). Full scoring, Risk's point
levels, Double/Quadruple round multipliers, Mini/Micro round structures, and
fixed-color/Super Call orchestration remain unconfirmed.

Implemented in `lib/core/game_rules/estimate_totals.dart` (rules 2–5) and
`lib/core/game_rules/exact_bid_outcome.dart` (rule 6). Both are pure
functions over an already-known set of estimates or a known trick count —
neither models the estimate phase's seat order, tracks a round in progress,
or computes a score.

## Trick winners

Owner-confirmed on 2026-09-08:

- Highest card of the led suit wins unless at least one trump is played.
- If trump is played, the highest trump wins.
- Rank order is A > K > Q > J > 10 > 9 > 8 > 7 > 6 > 5 > 4 > 3 > 2.
- In Sans (صنز), only cards of the led suit can win.

These rules are used as authored reasoning in Play practice's coaching (EC-047).
The trainer UI still does not compute a trick winner or update taken counts
from a play — no runtime resolver exists. A small, pure implementation of this
rule for exactly *one already-complete trick* does exist
(`lib/core/game_rules/trick_winner.dart`, `trickWinner`, added EC-055/D-025)
and is used by exactly one content-validation check — see
[Play direction / seat rotation](#play-direction--seat-rotation) below. It is
not a resolver in the sense above: it never runs during play, chains across
tricks, or updates any count.

## Play direction / seat rotation

Owner-confirmed on 2026-09-08: play is **counter-clockwise**. With the table
laid out North top, West left, East right, South bottom, the fixed rotation is:

```text
North → West → South → East → North
```

Equivalent rotations by leader:

| Leader | Play order |
| --- | --- |
| North | North → West → South → East |
| West | West → South → East → North |
| South | South → East → North → West |
| East | East → North → West → South |

This defines **seat succession within one trick only** — who plays next after
whom, starting from that trick's leader. It does not define:

- who wins a trick in general ([Trick winners](#trick-winners) above is the
  confirmed rule; `trickWinner` computes it for one already-complete trick,
  but nothing chains that across a sequence of tricks);
- which seat leads a trick *after the very next one* — that still depends on
  winning tricks not yet shown, which remains unresolved;
- a full round/deal turn order, scoring, or auction termination — those remain
  undefined (see [Scope](#scope)).

Implemented in `lib/core/game_rules/seat_rotation.dart` (`rotationFrom`) and
enforced by `PlaySituation`'s `currentTrick`/`observedTricks` validation (see
[GAME_RULES.md](GAME_RULES.md#ec-045-public-play-situation)): every authored
`current_trick` must be an ordered prefix of this rotation from its leader,
the pending player must be exactly the next seat to act, and every
`observed_tricks` entry must show all four seats in this exact order from its
own leader. This is validated content/domain structure, not general
trick-winner resolution or next-leader computation — those remain out of
scope, **except** one narrow case added after a real authored-content bug
(EC-055/D-025): when the pending player is leading (`currentTrick` is empty)
and at least one trick has been observed, the authored `leader` must equal
`trickWinner` of the *last* observed trick — the only situation where "who
leads" is asserted by the `leader` field alone, with no other visible
evidence (an already-shown first play in a non-empty current trick) to check
it against. This does not chain multiple observed tricks against each other,
and does not compute who leads beyond that one immediate next trick.

## Scope

Only normal bidding rounds are in the first MVP. Special late-game rounds and
fixed-trump rounds remain outside scope until explicitly added.

This confirmation does not define scoring formulas, a full deal/round turn
order beyond one trick's seat succession (see
[Play direction](#play-direction--seat-rotation) above) or the post-auction
estimate phase's own seat order (see [Post-auction trick
estimates](#post-auction-trick-estimates) above), auction termination, or the
treatment of a player who passes rather than declares Dash. Those details
must be documented before an implementation depends on them.
Following-suit behavior already implemented is documented in [GAME_RULES.md](GAME_RULES.md).

## Implementation status (EC-026)

`lib/core/game_rules/bidding.dart` implements `Bid`, `Trump` and immutable
`BiddingState`. Bids enforce 4–13 tricks. Trump rank is explicit and independent
from card-suit enumeration order. Dash declarations fix a player's estimate at
zero, survive the transition to normal bidding, and exclude that player from bids.
Late or repeated Dash declarations fail. Bid state rejects equal/lower raises.

Scenario files explicitly declare `rules_version: game_rules_v1`,
`bidding_phase: pre_bidding|normal` and `dash_players`. The parser checks history
against these rules and filters authored bid bounds to legal raises. The caller
still owns turn order and auction termination; passing does not imply an
undocumented permanent withdrawal rule.

The canonical draft was migrated from an illegal prior 3 Hearts bid to 4 Hearts,
with a minimum choice bound of 4, Dash disabled and Sans supported. Its 4 Spades
choice is a legal raise. Bounds 4–7 over the five trump categories produce 17
legal choices (4 Spades, 4 Sans, and all five trumps for 5–7), now all evaluated.
The [coaching review](COACHING_REVIEW.md) rates 4 Spades reasonable and records
its conditional assumptions. Rule-valid data is not proof of a strong decision.

## Rule domain status audit (2026-09-08)

A repository-wide review requested ahead of EC-043 (exact-bid protection).
Purpose: give a future contributor — human or AI — a single place to see
what's actually confirmed and implemented, what's confirmed but waiting on
implementation, and what remains genuinely open, organized by independent
rule domain rather than as one undifferentiated list. This audit does not
implement round orchestration, scoring, or fixed-color rounds; it only
classifies statements made elsewhere in this document,
[GAME_RULES.md](GAME_RULES.md), [docs/DECISIONS.md](DECISIONS.md) and
[docs/EGYPTIAN_ARABIC.md](EGYPTIAN_ARABIC.md).

**Source-gap disclosure (updated):** this audit was originally requested
against "confirmed owner rules and the documented Jawaker/Pocket rules," but
no file, comment, or prior decision record in this repository mentioned
"Jawaker" or "Pocket," and an agent session has no access to a prior
conversation where such rules might have been described —
[AGENTS.md](../AGENTS.md) §10 requires that essential rule knowledge live in
this repository, not in chat history. The owner has since confirmed the
post-auction estimate rules below in writing (see [Post-auction trick
estimates](#post-auction-trick-estimates)), resolving most of what was
previously listed as unresolved. What remains unresolved is listed
explicitly, not guessed at.

### Confirmed and currently implemented

| Rule domain | Confirmed in | Implemented in |
| --- | --- | --- |
| Normal-bid minimum, trump ranking, raise comparison | [Normal bidding](#normal-bidding) | `lib/core/game_rules/bidding.dart` (`Bid`, `Trump`) |
| Dash: exactly 0, pre-bidding only, excludes normal bidding | [Dash phase](#dash-phase) | `bidding.dart` (`BiddingState.declareDash`) |
| Follow-suit legality | [GAME_RULES.md](GAME_RULES.md#ec-021-following-suit) | `lib/core/game_rules/legal_cards.dart` |
| Seat succession within one trick (counter-clockwise rotation) | [Play direction](#play-direction--seat-rotation) | `lib/core/game_rules/seat_rotation.dart` |
| `auctionBid` distinct from each player's `trickEstimate` | [EGYPTIAN_ARABIC.md](EGYPTIAN_ARABIC.md#auction-bid-and-trick-estimate-are-distinct), D-013 | `Bid` vs `TrickEstimate` in `play_situation.dart` |
| `TrickEstimate`'s 0–13 physical bound | [GAME_RULES.md](GAME_RULES.md#ec-045-public-play-situation) | `TrickEstimate` in `play_situation.dart` — the bound only, not how a real estimate gets assigned |
| Void suits derived from observed follow-suit violations | D-018 | `lib/core/game_rules/void_tracking.dart` (a consequence of follow-suit, not a new rule) |
| A non-Caller's estimate must not exceed the Caller's | [Post-auction trick estimates](#post-auction-trick-estimates) rule 2 | `lib/core/game_rules/estimate_totals.dart` (`isValidNonCallerEstimate`) |
| "With": an estimate equal to the Caller's | rule 3 | `estimate_totals.dart` (`isWithCaller`) — derived from equality, never an authored flag |
| Total of four estimates must never equal 13 | rule 4 | `estimate_totals.dart` (`isValidEstimateTotal`, `estimateTotal`) |
| "Over"/"Under": total ≥ 14 is Over, ≤ 12 is Under | rule 5 | `estimate_totals.dart` (`classifyEstimateTotal`) |
| Exact-bid target: success is exact tricks taken, not "at least" | rule 6 | `lib/core/game_rules/exact_bid_outcome.dart` (`classifyExactBid`) |

### Confirmed but not implemented

| Rule domain | Confirmed in | What's missing |
| --- | --- | --- |
| Trick winners (highest of led suit; highest trump if any played; A high…2 low; Sans only led suit can win) | [Trick winners](#trick-winners) | No resolver anywhere in the app; used only as authored reasoning in EC-047/EC-042 coaching text |
| Risk: associated with the last estimator when their estimate pushes the total farther from 13; multiple risk levels exist | [Post-auction trick estimates](#post-auction-trick-estimates) rule 7 | No module computes or classifies Risk; its point levels/scoring are unconfirmed and deliberately not implemented yet |

Everything else already implemented (normal bidding, Dash, follow-suit, seat
rotation, the estimate/bid distinction, non-Caller/With/total/exact-bid
estimate rules) has no confirmed-but-unimplemented gap — implementation
matches confirmation.

### Unresolved / variant-specific (not confirmed anywhere in this repository)

These need owner confirmation, recorded here, before any implementation —
including full EC-043 scoring — depends on them:

| Rule domain | What's being asked | Where the gap is stated |
| --- | --- | --- |
| Exact seat/order for the post-auction estimate phase (who estimates in what order; whose turn is "last") | Explicitly kept unresolved when the estimate rules were confirmed | [Post-auction trick estimates](#post-auction-trick-estimates), [Scope](#scope) |
| Risk's point levels / scoring values | Rule 7 confirms Risk's *association*, not its scoring | [Post-auction trick estimates](#post-auction-trick-estimates) rule 7 |
| Full scoring formula (points for onTarget/tookMore/tookFewer, With, Over/Under, Risk) | — | Explicitly out of scope per [Scope](#scope): "This confirmation does not define scoring formulas" |
| Double/Quadruple round multipliers | Named when the estimate rules were confirmed, not defined | — |
| Mini/Micro round structures | Named when the estimate rules were confirmed, not defined | — |
| Fixed-color/Super Call orchestration | Named when the estimate rules were confirmed, not defined; may overlap with the already-excluded "fixed-trump rounds" below | [Scope](#scope) |
| Full deal/round turn order, auction termination, pass-vs-Dash treatment | — | Explicitly out of scope per [Scope](#scope) |
| Special late-game / fixed-trump rounds | — | Explicitly excluded from MVP per [Scope](#scope), not merely unimplemented |

### Implementation guidance for whoever picks up EC-043

Keep confirmed rules in independent, small, pure modules — mirroring how
`bidding.dart` (auction rules), `seat_rotation.dart` (seat succession),
`void_tracking.dart` (derived void facts), `estimate_totals.dart`
(estimate-set rules) and `exact_bid_outcome.dart` (exact-target outcome)
already stay separate and independently testable. Do not fold these into one
large combined rules type — each confirmed rule domain should stay its own
file, testable on its own, so a future rule change invalidates dependent
content through validation rather than requiring scattered manual updates
(see AGENTS.md's content-only invariant).

When authoring EC-043 scenario content, author the *observable*
inputs (each seat's estimate, the trump, the trick count taken so far) — not
derived labels. Whether an estimate is "With", whether the room's total is
Over/Under, and whether a player is currently onTarget/tookMore/tookFewer are
all computable from those inputs by `estimate_totals.dart`/
`exact_bid_outcome.dart`; a scenario file should never carry a redundant
`"with": true` or `"over": true` field that could silently drift from what
the inputs actually compute.
