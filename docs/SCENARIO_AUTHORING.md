# Scenario Authoring Guide

This document defines how humans and AI agents add training content without changing application code.

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
