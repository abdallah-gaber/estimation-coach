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

## Trick winners

Owner-confirmed on 2026-09-08:

- Highest card of the led suit wins unless at least one trump is played.
- If trump is played, the highest trump wins.
- Rank order is A > K > Q > J > 10 > 9 > 8 > 7 > 6 > 5 > 4 > 3 > 2.
- In Sans (صنز), only cards of the led suit can win.

These rules are used as authored reasoning in Play practice's coaching (EC-047),
but no resolver implements them: the app does not compute a trick winner or
update taken counts from a play.

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

- who wins a trick (see [Trick winners](#trick-winners) above, still
  unimplemented by any resolver);
- which seat leads the *next* trick (that depends on who wins this one, which
  is not resolved);
- a full round/deal turn order, scoring, or auction termination — those remain
  undefined (see [Scope](#scope)).

Implemented in `lib/core/game_rules/seat_rotation.dart` (`rotationFrom`) and
enforced by `PlaySituation`'s `currentTrick`/`observedTricks` validation (see
[GAME_RULES.md](GAME_RULES.md#ec-045-public-play-situation)): every authored
`current_trick` must be an ordered prefix of this rotation from its leader,
the pending player must be exactly the next seat to act, and every
`observed_tricks` entry must show all four seats in this exact order from its
own leader. This is validated content/domain structure, not trick-winner
resolution or next-leader computation — those remain explicitly out of scope.

## Scope

Only normal bidding rounds are in the first MVP. Special late-game rounds and
fixed-trump rounds remain outside scope until explicitly added.

This confirmation does not define scoring formulas, a full deal/round turn
order beyond one trick's seat succession (see
[Play direction](#play-direction--seat-rotation) above), auction termination,
or the treatment of a player who passes rather than declares Dash. Those
details must be documented before an implementation depends on them.
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
implement anything; it only classifies existing statements already made
elsewhere in this document, [GAME_RULES.md](GAME_RULES.md),
[docs/DECISIONS.md](DECISIONS.md) and
[docs/EGYPTIAN_ARABIC.md](EGYPTIAN_ARABIC.md).

**Source-gap disclosure:** this audit was requested against "confirmed owner
rules and the documented Jawaker/Pocket rules." No file, comment, or prior
decision record in this repository mentions "Jawaker" or "Pocket," and an
agent session has no access to a prior conversation where such rules might
have been described — [AGENTS.md](../AGENTS.md) §10 requires that essential
rule knowledge live in this repository, not in chat history. Terms named
below that map to no confirmed rule (estimate ordering/constraints across
players, total-estimate rules, "With", "Over/Under", exact-bid scoring
semantics) are marked **unresolved** rather than guessed at. Before EC-043
implementation depends on any of them, the owner must confirm them in
writing in this document, the same way every other section here was
confirmed.

### Confirmed and currently implemented

| Rule domain | Confirmed in | Implemented in |
| --- | --- | --- |
| Normal-bid minimum, trump ranking, raise comparison | [Normal bidding](#normal-bidding) | `lib/core/game_rules/bidding.dart` (`Bid`, `Trump`) |
| Dash: exactly 0, pre-bidding only, excludes normal bidding | [Dash phase](#dash-phase) | `bidding.dart` (`BiddingState.declareDash`) |
| Follow-suit legality | [GAME_RULES.md](GAME_RULES.md#ec-021-following-suit) | `lib/core/game_rules/legal_cards.dart` |
| Seat succession within one trick (counter-clockwise rotation) | [Play direction](#play-direction--seat-rotation) | `lib/core/game_rules/seat_rotation.dart` |
| `auctionBid` distinct from each player's `trickEstimate` | [EGYPTIAN_ARABIC.md](EGYPTIAN_ARABIC.md#auction-bid-and-trick-estimate-are-distinct), D-013 | `Bid` vs `TrickEstimate` in `play_situation.dart` |
| `TrickEstimate`'s 0–13 physical bound | [GAME_RULES.md](GAME_RULES.md#ec-045-public-play-situation) | `TrickEstimate` in `play_situation.dart` — the bound only, explicitly **not** a claim about how a real estimate gets assigned |
| Void suits derived from observed follow-suit violations | D-018 | `lib/core/game_rules/void_tracking.dart` (a consequence of follow-suit, not a new rule) |

### Confirmed but not implemented

| Rule domain | Confirmed in | What's missing |
| --- | --- | --- |
| Trick winners (highest of led suit; highest trump if any played; A high…2 low; Sans only led suit can win) | [Trick winners](#trick-winners) | No resolver anywhere in the app; used only as authored reasoning in EC-047/EC-042 coaching text |

Everything else already implemented (normal bidding, Dash, follow-suit, seat
rotation, the estimate/bid distinction) has no confirmed-but-unimplemented
gap — implementation matches confirmation.

### Unresolved / variant-specific (not confirmed anywhere in this repository)

These need owner confirmation, recorded here, before any implementation —
including EC-043 — depends on them:

| Rule domain | What's being asked | Where the gap is stated |
| --- | --- | --- |
| Estimate ordering/constraints across players (e.g. can two players share an estimate; must the auction winner's estimate equal their bid; is any player's choice restricted by others' already-declared estimates) | Referenced by this audit's request | Not addressed anywhere; `TrickEstimate` only bounds one player's value, in isolation |
| Total-estimate rules (whether the sum of all four estimates is constrained relative to 13 — e.g. a "cannot total 13" rule) | Referenced by this audit's request | Not addressed anywhere |
| "With" | Referenced by this audit's request as a Jawaker/Pocket term | Term does not appear anywhere in this repository |
| "Over/Under" | Referenced by this audit's request as a Jawaker/Pocket term | The *coaching theme* "avoiding unwanted overtricks" is named in [AGENTS.md](../AGENTS.md) §3.1(D) as an MVP concept, but no formal rule defines what counts as over/under or any scoring consequence; the specific "Over/Under" mechanic is undocumented |
| Exact-bid scoring semantics / formulas | Referenced by this audit's request | Explicitly out of scope per [Scope](#scope): "This confirmation does not define scoring formulas" |
| Full deal/round turn order, auction termination, pass-vs-Dash treatment | — | Explicitly out of scope per [Scope](#scope) |
| Special late-game / fixed-trump rounds | — | Explicitly excluded from MVP per [Scope](#scope), not merely unimplemented |

### Implementation guidance for whoever picks up EC-043

Once the rules above are confirmed, keep them in independent, small, pure
modules — mirroring how `bidding.dart` (auction rules), `seat_rotation.dart`
(seat succession) and `void_tracking.dart` (derived void facts) already stay
separate and independently testable. For example: an estimate-totals check
belongs in its own module, distinct from any future trick-winner resolver or
scoring module. Do not fold these into one large combined rules type — each
confirmed rule domain should stay its own file, testable on its own, so a
future rule change invalidates dependent content through validation rather
than requiring scattered manual updates (see AGENTS.md's content-only
invariant).
