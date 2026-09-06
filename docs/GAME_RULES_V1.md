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

## Scope

Only normal bidding rounds are in the first MVP. Special late-game rounds and
fixed-trump rounds remain outside scope until explicitly added.

This confirmation does not define scoring formulas, deal/turn order, auction
termination, or the treatment of a player who passes rather than declares Dash.
Those details must be documented before an implementation depends on them.
Following-suit behavior already implemented is documented in [GAME_RULES.md](GAME_RULES.md).

## Implementation and draft-content audit

The existing parser and schema validate a provisional content shape; they do not
yet enforce these bidding rules. EC-026 tracks the required implementation:

- Normal opening/raising bids must respect the 4-trick minimum and bid ranking.
- Add a trump-category type including Sans, separate from the card-suit type.
- Model the pre-bidding Dash phase and exclude Dash players from normal bidding.
- Update schema, parser, tests and affected content together to express the rules.

`content/scenarios/v1/bidding/bid_safe_probable_001.json` is a structural draft,
not approved training content. It currently conflicts with these rules:

- A prior bid of 3 Hearts is below the opening minimum.
- Its selectable range starts at 3 tricks.
- It offers Dash after a normal bid, when Dash must already have been declared.
- Its trump options omit Sans. An authored exercise may eventually offer a subset
  of choices, but the engine must support Sans as a valid category.

Its one rating has not been certified against a corrected scenario. Do not use
the draft to teach a game decision until the situation is migrated and its
coaching reviewed. A successful structural validator result is not approval of
these conflicting rules or the authored rating.
