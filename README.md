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

## Run the card domain checkpoint

The preview now uses immutable typed cards backed by a pure Dart domain model.
It retains the interactive card preview: all four suits, selected and
disabled states, keyboard controls and a responsive layout. The four cards are UI
specimens, not a dealt hand or scored scenario. Bidding, game-rule enforcement,
progress storage and coaching evaluation remain future milestones.

Validated toolchain: Flutter 3.44.1 stable / Dart 3.12.1.

```sh
git switch codex/card-domain-model
flutter pub get
flutter run -d chrome
```

Alternatively, run `flutter run -d web-server --web-port 8080` and open
http://localhost:8080 in your browser. Stop the running app with `q` in its terminal.
The native runners are generated but not yet validated; use `flutter devices`
to see available targets. iOS device builds require your own signing setup.

### What to test

1. Launch: see **Get a feel for the cards** and A ♠, K ♥, 10 ♦, J ♣.
2. Tap an available card: it rises with a gold border and checkmark; its name
   appears below the table. Tap another to switch, or tap it again to deselect.
3. Tap the locked 10 ♦: selection must not change. Its disabled state is a UI
   demonstration, not a claim about legal play.
4. Tap **Clear selection**: selection resets and the button becomes disabled.
5. Use Tab and Enter: available cards can be selected; the locked card is skipped.
6. Resize to a 320-pixel phone width: cards wrap into rows without overlap.
   At large text sizes, scroll to reach the remaining cards and controls.
7. Refresh/relaunch: selection resets; this preview does not persist progress.

### Automated checks

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web
```

Nine domain tests cover card equality and parsing, deck completeness/immutability,
and hand equality, defensive copying and validation. Run these alone with
`flutter test test/core/cards/cards_test.dart`.

Five widget tests cover selection/toggle/reset, disabled interaction, accessibility
labels and states, keyboard activation, and a 320×568 layout at 1× and 2× text
scaling. All 14 tests run with `flutter test`. Follow-suit rules remain the next
domain task (EC-021).
