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
