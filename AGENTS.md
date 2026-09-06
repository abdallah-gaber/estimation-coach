# AGENTS.md — Estimation Coach

## 1. Purpose

This repository contains **Estimation Coach**, a visual training app for the Estimation card game.

The product is not primarily a digital implementation of the full multiplayer game.
Its main purpose is to **coach a player to make better decisions** through short, visual, interactive scenarios.

The app should help the player improve at:

- deciding whether to **Dash** or enter the bidding;
- choosing a suitable **trump suit / qatou‘**;
- estimating an appropriate number of tricks;
- distinguishing safe, probable, and speculative tricks;
- reacting when the original plan breaks during a round;
- tracking played cards and detecting void suits;
- deciding when to pull trump and when to preserve it;
- protecting an exact bid;
- avoiding unwanted overtricks;
- adapting play based on opponents’ behavior and known information.

The product should feel like a **fast visual trainer**, not a written quiz and not a textbook.

---

## 2. Product Principles

These principles are mandatory unless a later documented decision explicitly changes them.

### 2.1 Visual first

The default interaction is visual.

Prefer:
- cards;
- chips;
- icons;
- table positions;
- highlighted suits;
- simple meters;
- timelines;
- compact choice buttons;
- animated card movement;
- visual feedback.

Avoid:
- essay questions;
- large text inputs;
- long paragraphs before a decision;
- requiring the player to explain reasoning in writing.

The player should usually be able to answer by:
- tapping a card;
- tapping Dash;
- choosing a bid number;
- choosing a suit;
- selecting one of a few compact tactical options.

### 2.2 Short training rhythm

Target loop:

1. See the situation.
2. Make a decision.
3. See the consequence.
4. Receive concise coaching.
5. Move immediately to the next decision.

A normal micro-scenario should take roughly 20–90 seconds.

### 2.3 Coach decisions, not outcomes

The app must distinguish:

- **decision quality**
- **actual outcome**

A strong decision can still have a bad result because of card distribution.
A poor decision can occasionally succeed.

Feedback should therefore use concepts such as:

- Strong decision
- Reasonable
- Risky
- Weak
- Good decision, bad outcome
- Lucky outcome, weak decision

Never reduce all coaching to `Correct / Wrong`.

### 2.4 Deterministic core

The MVP must NOT depend on an LLM or remote AI API to decide whether a move is good.

Core evaluation should be based on:

- game rules;
- scenario metadata;
- known cards;
- probability heuristics;
- deterministic scoring rules;
- authored scenario coaching.

Reasons:

- reproducibility;
- trust;
- offline use;
- zero runtime AI cost;
- easier testing;
- no hallucinated rules.

AI can be added later as an optional layer for:
- alternative explanations;
- scenario drafting;
- coaching phrasing;
- generating candidate scenarios that are validated by the deterministic engine.

The deterministic engine remains the source of truth.

---

## 3. MVP Scope

### 3.1 In scope

#### A. Home / Training Hub

Show:
- Continue Training
- Bid Practice
- Play Practice
- Weak Areas
- recent progress summary

Keep the screen visually simple.

#### B. Bidding Scenarios

Each scenario can visually show:
- player position;
- current bids/pass decisions;
- player hand;
- relevant score/context when needed.

User decisions:
1. Dash or enter.
2. If entering: number of tricks.
3. Trump suit.

Feedback should explain:
- likely safe tricks;
- probable tricks;
- risky assumptions;
- why the selected trump is strong/weak;
- why the bid is conservative/aggressive.

#### C. Mid-hand Scenarios

Show:
- four-seat table;
- current trick;
- user hand;
- current target;
- tricks already taken;
- trump suit;
- known/important public information.

User chooses a card visually.

The scenario may continue for multiple decisions.

#### D. Coaching Concepts for MVP

Start with only these:

1. Safe vs probable tricks.
2. Tracking void suits.
3. Protecting the exact bid / avoiding overtricks.

Do not expand the concept list until these are enjoyable and reliable.

#### E. Player Profile

Track skill areas such as:
- Dash decisions
- Bid sizing
- Trump selection
- Card tracking
- Mid-hand adaptation
- Exact-bid protection

The app should identify recurring weaknesses from actual decisions.

---

## 4. Explicitly Out of Scope for MVP

Do not add these unless explicitly requested and tracked:

- login;
- accounts;
- backend;
- cloud sync;
- multiplayer;
- real-time networking;
- leaderboards;
- social features;
- ads;
- subscriptions;
- runtime AI dependency;
- full online Estimation game;
- complex 3D animation;
- unnecessary gamification systems;
- large architecture abstractions without a current need.

The MVP is a **local Flutter app**.

---

## 5. UX Direction

### 5.1 Card table

The main play surface should resemble a clean card table without becoming visually heavy.

Suggested structure:

- opponent top;
- opponent left;
- opponent right;
- player hand bottom;
- active trick in center;
- bid/tricks summary near each player.

### 5.2 Player hand

Cards should:
- be easy to identify;
- be tappable;
- clearly show suit/rank;
- slightly raise or highlight on selection;
- visibly disable illegal choices.

Do not rely only on color to communicate suits or states.

### 5.3 Animations

MVP animation should be simple and purposeful:

- card slides from hand to table;
- current player indicator;
- trick collection;
- subtle selected-card elevation;
- short feedback transitions.

Avoid animation work that delays validating the training loop.

### 5.4 Feedback

Immediate feedback should fit on one compact panel.

Example:

`Strong decision`

`You preserved your low Diamond and avoided taking an unwanted fifth trick.`

Optional compact actions:
- Why?
- Show safer line
- Next

Long-form explanation should never interrupt the default flow.

---

## 6. Scenario Model

Scenarios are content and must be separated from UI code.

A scenario should be representable as structured data.

Conceptual example:

```yaml
id: bid_001
type: bidding
difficulty: beginner
concepts:
  - safe_vs_probable
dealer_position: 0
player_position: 2
hand:
  spades: [A, J, 8, 4]
  hearts: [K, 7]
  diamonds: [A, Q, 9]
  clubs: [J, 10, 5, 2]
previous_actions:
  - player: 0
    action: pass
  - player: 1
    action: bid
    tricks: 3
    trump: hearts
choices:
  dash:
    rating: reasonable
  bids:
    - tricks: 4
      trump: spades
      rating: strong
    - tricks: 5
      trump: spades
      rating: risky
coaching:
  safe_tricks: 2
  probable_tricks: 2
  key_risk: "Heart King is conditional and should not be counted as guaranteed."
```

The actual schema may evolve.

Requirements:

- scenario data must not be hardcoded directly into widgets;
- scenario evaluation must be independently testable;
- scenarios should support tags and difficulty;
- scenario content should be easy to author manually;
- later tooling should be able to generate/validate scenarios.

---

## 7. Architecture Direction

Prefer boring, clear architecture.

Suggested initial modules:

```text
lib/
  app/
  core/
    cards/
    game_rules/
    coaching/
  features/
    training_hub/
    bidding_training/
    play_training/
    progress/
  scenarios/
```

Keep domain logic independent from Flutter widgets where practical.

Important domain concepts may include:

- Card
- Suit
- Rank
- Hand
- PlayerSeat
- Bid
- Trick
- RoundState
- Scenario
- Decision
- DecisionRating
- CoachingInsight
- SkillArea

Do not over-engineer repositories/services/interfaces before a real need exists.

---

## 8. State Management

Use a simple, explicit approach suitable for Flutter.

If a state-management library is selected, document the choice in `docs/DECISIONS.md`.

Do not change state-management approach casually mid-project.

---

## 9. Testing

Priority order:

1. Game-rule tests.
2. Scenario evaluation tests.
3. Coaching classification tests.
4. Widget tests for critical decisions.
5. Golden tests only where they add real visual regression value.

Every rule bug that is found should receive a regression test.

---

## 10. AI / Agent Independence

This repository must remain usable with:

- Codex;
- Claude Code;
- another coding agent;
- a human developer working without an agent.

Therefore:

### Agents must

- read `AGENTS.md`;
- read `README.md`;
- read `PROJECT_TRACKER.md`;
- read `docs/DECISIONS.md` before architectural changes;
- inspect the existing code before proposing replacement architecture;
- make the smallest coherent change;
- keep documentation synchronized;
- leave the repository in a buildable/testable state.

### Agents must not

- create agent-specific architecture;
- depend on hidden conversation history;
- assume previous agent context;
- place essential knowledge only inside prompts/chats;
- rewrite unrelated files;
- silently change product scope;
- silently change game rules.

Anything another contributor needs later must live in the repository.

---

## 11. Git Workflow

### Initial state

`main` should contain only the repository foundation:

- README.md
- AGENTS.md
- PROJECT_TRACKER.md
- docs/DECISIONS.md
- Flutter bootstrap once explicitly started

No feature development happens directly on `main`.

### Branch policy

Every meaningful change starts from updated `main`.

Naming examples:

```text
feat/training-hub
feat/card-model
feat/bid-scenario-engine
feat/play-table-ui
fix/trump-evaluation
docs/scenario-format
chore/flutter-bootstrap
```

### Workflow

```text
main
  ↓
new branch
  ↓
small coherent commits
  ↓
push branch
  ↓
Pull Request
  ↓
review
  ↓
merge to main
```

Never commit feature work directly to `main`.

### PR rules

Each PR should:

- solve one coherent problem;
- include a short description;
- list notable decisions;
- include tests where applicable;
- mention tracker items closed/advanced;
- update docs if behavior or architecture changed.

Suggested PR body:

```md
## What
What changed?

## Why
Why is this needed?

## How to test
Exact validation steps.

## Decisions / trade-offs
Anything future contributors should know.

## Tracker
- Closes: EC-XXX
```

### Main branch protection

When the GitHub repository exists, configure:

- Pull request required before merge.
- At least 1 approval if practical.
- Require status checks once CI exists.
- Block force pushes.
- Block deletion of `main`.

---

## 12. Task Tracking

`PROJECT_TRACKER.md` is the local source of truth for current work.

Every task must have:
- ID;
- status;
- short description;
- acceptance criteria.

Allowed statuses:

- `BACKLOG`
- `READY`
- `IN PROGRESS`
- `BLOCKED`
- `DONE`

Before starting work:
- mark the task `IN PROGRESS`.

When finishing:
- validate acceptance criteria;
- mark `DONE`;
- add follow-up tasks discovered during implementation.

Do not hide work only in GitHub issues or chat history.
GitHub Issues may be added later, but the repository tracker remains readable offline.

---

## 13. Definition of Done

A task is done only when:

- requested behavior works;
- no known broken interaction was introduced;
- relevant tests pass;
- code is formatted/analyzed;
- documentation is updated when needed;
- tracker is updated;
- the change is suitable for a PR.

---

## 14. Product Decision Rule

When choosing between:

- more features;
- better visual interaction;
- better scenario quality;

prefer:

1. better scenario quality;
2. better visual interaction;
3. more features.

The training experience is the product.


---

## 15. Scenario Content Contract

Scenario content is maintained independently from application code.

Canonical locations:

```text
content/scenarios/v1/
schemas/scenario.v1.schema.json
docs/SCENARIO_AUTHORING.md
```

Any human or AI contributor adding supported scenarios should normally make a **content-only change**.

Before adding or editing scenarios, read `docs/SCENARIO_AUTHORING.md`.

Do not hardcode authored scenario content inside Dart widgets or feature controllers.

The application may parse, validate, cache, filter, and render scenario files, but the authored content remains portable data.

A future standalone scenario editor or external AI workflow must produce the same versioned files.
