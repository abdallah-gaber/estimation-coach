# Estimation Coach

A visual Flutter training app for improving decisions in the **Estimation card game**.

This repository is intentionally starting small.

The goal is not to build another digital card game.
The goal is to build a **coach** that repeatedly puts the player in meaningful situations, lets them make fast visual decisions, and teaches them how to reason better about the game.

## What should it teach?

The first versions focus on:

- Dash vs entering a bid
- choosing trump
- estimating the number of tricks
- safe vs probable tricks
- tracking void suits
- reacting when a round develops differently from the original plan
- protecting an exact bid
- avoiding overtricks

## Product feel

The interaction should feel like:

```text
See the table
→ make a quick visual decision
→ watch what happens
→ get concise coaching
→ continue
```

Not like:

```text
Read a long question
→ write an explanation
→ read an essay answer
```

Cards, table state, compact choices and visual feedback are the primary UI.

## MVP

The planned MVP contains four areas:

### Training Hub
A compact home showing:
- Continue Training
- Bid Practice
- Play Practice
- Weak Areas

### Bid Practice
Visual scenarios for:
- Dash / enter
- bid size
- trump selection

### Play Practice
Short table scenarios where the player selects cards and reacts to changing information.

### Progress
Track skill areas and detect recurring weaknesses.

## AI strategy

The MVP does **not** require a runtime AI API.

The game/coaching core should be deterministic and testable.

AI may later be used as an optional layer for:
- alternative explanations;
- scenario authoring assistance;
- scenario variations;
- natural-language coaching.

Any AI-produced game content must be validated against the deterministic rules engine before it becomes trusted content.


## Scenario authoring

Training scenarios are intentionally separated from application code.

They live under:

```text
content/scenarios/v1/
```

The format is documented in [docs/SCENARIO_AUTHORING.md](./docs/SCENARIO_AUTHORING.md) and versioned by [schemas/scenario.v1.schema.json](./schemas/scenario.v1.schema.json).

This allows a human or AI agent to add new supported scenarios later through a content-only PR without changing Flutter code.

## Tech direction

- Flutter
- local-first
- no login/backend in MVP
- scenario-driven architecture
- deterministic rules and coaching engine

Detailed repository rules live in [AGENTS.md](./AGENTS.md).

Architectural/product decisions live in [docs/DECISIONS.md](./docs/DECISIONS.md).

Current work lives in [PROJECT_TRACKER.md](./PROJECT_TRACKER.md).

## Roadmap

### Phase 0 — Foundation
- repository rules
- Flutter bootstrap
- card/game domain model
- first scenario format

### Phase 1 — First playable coach
- visual hand
- bid scenario
- Dash/bid/trump interaction
- deterministic coaching result
- first 10 authored scenarios

### Phase 2 — Mid-hand training
- four-seat table
- trick flow
- legal card selection
- void tracking scenarios
- exact-bid protection scenarios

### Phase 3 — Personal coaching
- skill profile
- mistake categorization
- weak-area recommendations
- targeted training sessions

### Later
Potential ideas, not current commitments:
- richer scenario generator
- AI explanation layer
- scenario authoring tool
- daily challenges
- full-round simulation
- optional cloud sync

## Status

See [PROJECT_TRACKER.md](./PROJECT_TRACKER.md) for the current implementation status and next task.

## Run the first bidding trainer

This checkpoint has two independent hands: Dash versus enter, then a normal
bid facing 4 Hearts. All 19 legal choices have deterministic authored feedback.
Read the [coaching review](docs/COACHING_REVIEW.md) for rating rationale.
There is no full auction, simulated outcome, saved progress, or mid-hand play yet.

Validated toolchain: Flutter 3.44.1 stable / Dart 3.12.1.

```sh
git switch codex/first-bidding-trainer
flutter pub get
flutter run -d chrome
```

Alternatively, run `flutter run -d web-server --web-port 8082` and open
http://localhost:8082. Stop the app with `q` in its terminal. Native runners are
generated but unvalidated; use `flutter devices` to see available targets.

### What to test

1. See a 13-card hand, South's position, and **Before bidding · Trump unknown**.
2. Choose **Dash · 0 tricks**: expect **Weak decision** and a fixed zero estimate.
   Open **Why?** for the evidence. Choose **Try another choice**, then
   **Enter bidding**: expect **Strong decision**, with no target chosen yet.
3. Choose **Next hand**: a different hand appears with West's pass and North's
   4 Hearts. Dash must not be available during normal bidding.
4. Choose **4**: only Spades and Sans are enabled. Choose **5**: all suits unlock.
   Select Hearts, then change to 4: Hearts clears and **Review bid** is disabled.
5. Submit **4 Spades**: expect **Reasonable**. Try **4 Sans** (Risky),
   **5 Spades** (Risky), and **7 Clubs** (Weak decision). Check that the explanation
   matches your choice. Outcomes are explicitly not simulated.
6. Choose **Finish session**, then **Practice again**: the first hand resets.
7. Resize to 320px and increase text size: cards and controls should wrap and
   remain reachable by scrolling. Use Tab/Enter to choose buttons and chips.
8. Refresh: the session starts over. Progress is not persisted in this checkpoint.

### Automated checks

```sh
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
dart run tool/validate_scenarios.dart --require-complete
flutter build web
```

Strict validation should pass both scenario files with no missing evaluations.
Tests cover cards, game rules, parser/schema alignment, validator failure cases,
authored evaluation, bundled loading, legal choice controls, feedback, session
restart, load retry, and a 320px layout with double text scaling.
The older card specimen remains independently tested.

Canonical rules: [game_rules_v1](docs/GAME_RULES_V1.md).
Content contract and CLI usage: [authoring guide](docs/SCENARIO_AUTHORING.md).
