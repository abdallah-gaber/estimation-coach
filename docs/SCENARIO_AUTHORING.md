# Scenario Authoring Guide

This document defines how humans and AI agents add training content without changing application code.

[game_rules_v1](GAME_RULES_V1.md) is authoritative for normal bidding. The
historical examples below illustrate structure but conflict with its minimum bid
and Dash timing. They are not approved gameplay content; EC-026 tracks migration.

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

```json
{
  "scenario_version": 1,
  "id": "bid_safe_probable_001",
  "type": "bidding",
  "title": "Strong Spades, uncertain side winners",
  "difficulty": "beginner",
  "primary_skill": "bid_sizing",
  "skills": [
    "bid_sizing",
    "trump_selection",
    "safe_vs_probable"
  ],
  "player_position": "south",
  "hand": [
    "AS", "JS", "8S", "4S",
    "KH", "7H",
    "AD", "QD", "9D",
    "JC", "10C", "5C", "2C"
  ],
  "previous_actions": [
    {
      "player": "west",
      "action": "pass"
    },
    {
      "player": "north",
      "action": "bid",
      "tricks": 3,
      "trump": "hearts"
    }
  ],
  "allowed_decisions": {
    "dash": true,
    "bids": {
      "min": 3,
      "max": 7
    },
    "trumps": [
      "spades",
      "hearts",
      "diamonds",
      "clubs"
    ]
  },
  "evaluations": [
    {
      "decision": {
        "action": "bid",
        "tricks": 4,
        "trump": "spades"
      },
      "rating": "strong",
      "feedback": {
        "title": "Balanced bid",
        "summary": "Four Spades uses your strongest suit without assuming every side honor will win.",
        "points": [
          "Ace of Spades is a strong control card.",
          "Ace of Diamonds is a strong side winner.",
          "King of Hearts is conditional, not guaranteed."
        ]
      }
    },
    {
      "decision": {
        "action": "bid",
        "tricks": 5,
        "trump": "spades"
      },
      "rating": "risky",
      "feedback": {
        "title": "You are counting too much upside",
        "summary": "Five requires several conditional cards to behave well.",
        "points": [
          "Trump control is useful but not enough by itself.",
          "The Heart King may lose immediately.",
          "Diamond Queen needs favorable distribution."
        ]
      }
    },
    {
      "decision": {
        "action": "dash"
      },
      "rating": "weak",
      "feedback": {
        "title": "Too conservative",
        "summary": "This hand has enough structure to compete rather than Dash.",
        "points": [
          "You have two Aces.",
          "Spades provide a credible trump direction."
        ]
      }
    }
  ],
  "author_notes": "Teaching scenario. Exact ratings should be reviewed against the agreed Estimation rules before release."
}
```

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

## Standalone validation (EC-022 / EC-023)

From the repository root, after `flutter pub get`:

```sh
dart run tool/validate_scenarios.dart
```

The command recursively scans `content/scenarios/v1/`, validates each JSON file
against `schemas/scenario.v1.schema.json`, then parses it through the same pure
Dart `BiddingScenario.fromJson` representation available to the application.
No Flutter engine, Python installation or runtime network service is required.
`json_schema` is a development-only dependency using synchronous local validation.

You may select files or directories explicitly:

```sh
dart run tool/validate_scenarios.dart content/scenarios/v1/bidding
```

Files are checked in sorted order. Duplicate IDs across the selected files fail.
Overlapping paths are deduplicated. Missing paths, empty directories and invalid
JSON fail; the checker continues through the other files. Symlinks are not followed.

### Supported representation

Only `scenario_version: 1`, `type: bidding` is implemented. `play` remains reserved
by the schema but produces an unsupported-type error until its model is defined.
The schema now defines nested bidding fields, and the parser enforces the
remaining cross-field checks:

- Required nonempty title, primary skill and skill tags; primary skill must be
  included in distinct `skills`. Skill strings remain extensible tags.
- `difficulty`: beginner, intermediate, advanced; seats: north, east, south, west.
- A bidding hand contains exactly 13 distinct canonical cards.
- Previous actions contain a player and pass/dash/bid action. Bid requires integer
  tricks (1–13) and a supported suit; pass/dash must omit tricks and trump.
- `allowed_decisions` requires boolean `dash`, integer bid min/max (1–13,
  min ≤ max), and a nonempty distinct list of suits. These are representable
  ranges, not a ruling on minimum legal bids or auction precedence.
- Suits are spades, hearts, diamonds, clubs. No-trump is not currently represented.
- Each evaluation has a dash/bid decision, strong/reasonable/risky/weak rating,
  and feedback containing nonempty title/summary plus an array of nonempty points.
- Evaluated choices must be allowed and may appear at most once.
- Missing or malformed nested data produces a field-path diagnostic.

Model lists are immutable snapshots. Top-level additional properties allowed by
v1 are not interpreted as coaching or new behavior. No authored content is
hardcoded into the models or validator. EC-025 aligns schema shape checks with this provisional parser contract.
The schema cannot replace cross-field validation in the parser.

### Coverage and review are separate

Normal validation allows an incomplete draft with a warning. For complete
feedback coverage, use:

```sh
dart run tool/validate_scenarios.dart --require-complete
```

The current canonical fixture has **one evaluation out of 21 choices**, so default
validation exits 0 with a warning about 20 missing evaluations. Strict coverage
exits 1 for that fixture. The longer example above illustrates three evaluations;
it is not the exact content of the canonical fixture.

| Exit code | Meaning |
| --- | --- |
| 0 | Selected files passed structural checks (coverage warnings may remain) |
| 1 | Invalid/missing content, duplicate IDs, or incomplete strict coverage |
| 2 | Invalid options or schema configuration |

Even complete coverage does not certify game legality or coaching quality.
Canonical bidding rules are now documented in [game_rules_v1](GAME_RULES_V1.md).
The draft conflicts with its minimum opening bid and Dash timing. EC-026 will
add rule enforcement and migrate the content; the authored advice still requires
EC-024 review. The parser never supplies a rating for an unevaluated
choice. Do not use a structural pass as permission to publish a coaching pack.

Run parser and validator tests with:

```sh
flutter test test/scenarios
```

### Schema alignment compatibility (EC-025)

The v1 field names and canonical fixture are preserved. Bidding now requires its
previously parser-required title, seat, 13-card hand, previous actions, allowed
decisions and evaluations at schema level. Nested action/decision shapes, numeric
bounds, supported enum values and nonblank feedback are enforced by the schema.
Non-bid actions cannot carry tricks/trump, even with null values. Additional
properties remain permitted. The ID regex now matches the parser's permitted
lowercase letters, digits, underscores and hyphens.

Documents accepted by the old broad schema but rejected by the parser may now
fail earlier at the schema stage, with JSON-pointer paths. This is an intentional
validation tightening, not a new game rule. The reserved play schema is unchanged
and remains unsupported by the application parser.

Some checks still require Dart: primary-skill membership, min ≤ max, evaluation
membership in allowed choices, duplicate decisions with differing feedback, and
cross-file duplicate IDs. Schema `uniqueItems` catches exact duplicate evaluation
objects only. Coverage and canonical rule compliance are separate concerns.

The provisional 1–13 shape bounds and four-suit trump enum are not the canonical
bidding rules. They remain implementation gaps tracked in EC-026; external tools
must also respect [game_rules_v1](GAME_RULES_V1.md).
