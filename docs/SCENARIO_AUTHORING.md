# Scenario Authoring Guide

This document defines how humans and AI agents add training content without changing application code.

[game_rules_v1](GAME_RULES_V1.md) is authoritative for normal bidding. The first two training hands have complete feedback; see the [coaching review](COACHING_REVIEW.md).

## Goal

Scenario content must be independently maintainable from the Flutter UI and domain implementation.

A contributor should be able to:

1. open this repository;
2. read this guide;
3. add or modify scenario files;
4. validate them;
5. open a content-only Pull Request;

without editing Flutter widgets, navigation, or unrelated application code.

---

## Source of truth

All authored scenarios live under:

```text
content/
  scenarios/
    v1/
      bidding/
      play/
```

Scenario structure is versioned.

The current format is:

```text
scenario_version: 1
```

The schema lives at:

```text
schemas/scenario.v1.schema.json
```

Do not invent new fields silently.

If a scenario needs information the current schema cannot express:

1. do not work around it with arbitrary metadata;
2. document the need in `docs/DECISIONS.md`;
3. propose a schema change separately;
4. keep backward compatibility where practical.

---

## Content-only workflow

Adding scenarios should normally require only:

```text
content/scenarios/...
```

and, when appropriate:

```text
PROJECT_TRACKER.md
```

Do not modify Flutter implementation just to add another scenario of an already-supported type.

Suggested branch naming:

```text
content/bidding-dash-pack-01
content/void-tracking-pack-01
content/exact-bid-pack-01
```

---

## Scenario authoring rules

### Visual interaction first

A scenario should ask the player to respond using an interaction the app can render visually:

- Dash / Enter
- trick count
- trump suit
- card selection
- compact tactical choice

Do not create scenarios whose required answer is free-text.

### One main lesson

Each scenario should have one main teaching objective.

Examples:

- Do not count a conditional King as guaranteed.
- Dash when the hand has no credible path to the minimum bid.
- A player who failed to follow Clubs is now known void in Clubs.
- After reaching the exact bid, stop maximizing trick count.

Secondary concepts may be tagged, but the coaching should not become unfocused.

### Decision quality is graded

Choices may use:

- `strong`
- `reasonable`
- `risky`
- `weak`

Avoid binary correct/incorrect unless the choice is illegal by game rules.

### Coaching text is concise

Default coaching should normally fit in:

- one title;
- one short explanation;
- up to three compact evidence points.

Long explanations should be optional expansion content later.

### No hidden assumptions

Everything needed to evaluate the authored scenario must exist in the scenario file or deterministic game rules.

Do not rely on:
- chat history;
- the author's memory;
- undocumented conventions.

---

## Bidding scenario example

The complete examples are maintained directly in portable content:

- [Pre-bidding: Dash or enter](../content/scenarios/v1/bidding/bid_enter_controls_001.json)
- [Normal bidding: 17 legal raises](../content/scenarios/v1/bidding/bid_safe_probable_001.json)

Read those files for the exact schema, decisions, and authored feedback used by
the app. Avoid maintaining a second, divergent copy in this guide.

---

## Card notation

Use:

```text
A K Q J 10 9 8 7 6 5 4 3 2
```

Suit suffixes:

```text
S = Spades
H = Hearts
D = Diamonds
C = Clubs
```

Examples:

```text
AS
10H
QD
2C
```

---

## Required review for authored scenarios

Before a scenario is accepted:

- cards are valid;
- no duplicate card exists where duplication is impossible;
- hand size is valid for the scenario;
- previous actions are legal;
- available choices are legal;
- evaluation ratings are internally consistent;
- coaching does not contradict the game state;
- the main lesson is clear;
- the scenario is visually answerable;
- scenario passes schema validation;
- scenario passes domain validation once the validator exists.

AI-generated scenarios require exactly the same review.

---

## Instructions for AI agents

When asked to add scenarios:

1. Read:
   - `AGENTS.md`
   - this file
   - `docs/DECISIONS.md`
2. Inspect several existing scenarios of the same type.
3. Do not modify application code unless the requested scenario cannot be represented by the current supported schema.
4. Create scenarios only under `content/scenarios/v1/...`.
5. Keep each scenario focused on one primary learning objective.
6. Never invent or reinterpret game rules.
7. If the requested game rule is undocumented or ambiguous, mark the task blocked and identify the exact missing rule.
8. Validate all scenario files.
9. Provide a content-only PR whenever possible.

---

## Future authoring tool

A future editor may provide a visual UI for creating scenarios, but it must produce the same versioned scenario files.

The files remain the portable source of truth.

## Standalone validation

From the repository root after `flutter pub get`:

```sh
dart run tool/validate_scenarios.dart
flutter test test/scenarios
```

The command recursively scans `content/scenarios/v1/`, checks the canonical JSON
schema, then parses and checks `game_rules_v1` bidding constraints using the same
pure Dart model available to the app. No Flutter engine or network service is
required; `json_schema` is a development-only dependency using local validation.
Explicit file/directory paths are supported. Files are sorted and deduplicated;
missing paths, empty directories, invalid JSON and duplicate IDs fail. Symlinks
are not followed. Errors identify the file and field; scanning continues.

## Required bidding context

Only scenario v1 bidding with `rules_version: game_rules_v1` is implemented.
`play` remains reserved by the schema and unsupported by the parser. Every
bidding file now requires:

- `rules_version`: exactly `game_rules_v1`.
- `bidding_phase`: `pre_bidding` or `normal`.
- `dash_players`: distinct seats that declared Dash before the listed history.
  Do not repeat these declarations in `previous_actions`.

This intentionally rejects legacy files lacking phase/rules metadata. There is
no silent inference from old mixed Dash/bid data. Scenario version 1 is still a
pre-release content contract; these required fields migrate that contract.

### Pre-bidding phase

Trump is not known and no normal bids have occurred. The player chooses Dash
(exactly zero tricks) or enter (continue into normal bidding). Choices contain no
trick or trump fields:

```json
"allowed_decisions": {"dash": true, "enter": true}
```

At least one of the two flags must be true. `bids` and `trumps` are forbidden.
Evaluation decisions use `{"action":"dash"}` or `{"action":"enter"}`.
Previous actions may only be Dash/enter with a player seat. Each player may have
only one recorded pre-bidding decision, and the current player must not already
have decided. Recorded Dash declarations update the parsed bidding state and
fix that player's estimate at zero.

### Normal bidding phase

Dash players are excluded. Previous actions may be pass or bid; bids require
4–13 integer tricks and a trump category and must strictly outrank the preceding
bid. Pass/enter/Dash are not interchangeable: no new Dash/enter declaration is
allowed once normal bidding starts. Turn order and pass re-entry are outside
this model's scope.

```json
"allowed_decisions": {
  "dash": false,
  "bids": {"min": 4, "max": 7},
  "trumps": ["clubs", "diamonds", "hearts", "spades", "no_trump"]
}
```

Normal choices are bids only (`enter` must be absent or false). `min <= max`,
trumps must be nonempty and distinct. Trump codes map to the canonical ranking;
`no_trump` means Sans, not a fifth card suit.

These are authored bounds, not a claim that every count/trump combination is
legal. `allowedDecisions.choices` filters them through the bid engine; use that
list in UI and evaluation. At least one legal choice must remain. Evaluations
outside that list are invalid. The number of missing evaluations is based on
legal choices, so equal/lower bids never inflate coverage.

## Other structural checks

- Nonempty title, primary skill and skill tags; primary skill is one of the
  distinct tags. Difficulty is beginner/intermediate/advanced.
- Seats are north/east/south/west. A bidding hand has 13 distinct canonical cards.
- Each evaluation has a decision, strong/reasonable/risky/weak rating, and feedback
  with a nonempty title/summary and an array of nonempty evidence points.
- Each legal decision has at most one evaluation. No fallback rating is invented.
- Lists are immutable snapshots. Additional properties remain permitted but do
  not introduce behavior. Nested schema constraints catch malformed shapes;
  cross-field and game-rule checks remain in Dart.

## Coverage and coaching review

```sh
dart run tool/validate_scenarios.dart --require-complete
```

Default validation permits incomplete feedback with a warning. Strict coverage
fails until every legal choice has an evaluation. Both bundled scenarios now
pass strict coverage (19 choices total). Neither mode certifies the authored
coaching. The app rejects incomplete catalogs rather than inventing a rating.

| Exit code | Meaning |
| --- | --- |
| 0 | Selected files passed schema and supported bidding-rule checks |
| 1 | Invalid/missing content, duplicate IDs, or incomplete strict coverage |
| 2 | Invalid options or schema configuration |

The canonical situation has been reviewed for rule legality: 4 Spades legally
raises 4 Hearts, no late Dash is offered, and Sans is supported. The strategic
review is recorded in [COACHING_REVIEW.md](COACHING_REVIEW.md), including why
4 Spades is reasonable rather than strong. Tests
cover phase boundaries, bid order, Dash participation and feedback coverage.
