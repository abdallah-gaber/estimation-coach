# PROJECT_TRACKER.md

This file is the repository-level source of truth for planned and active work.

## Status legend

- `BACKLOG`
- `READY`
- `IN PROGRESS`
- `BLOCKED`
- `DONE`

---

# Milestone 0 — Repository Foundation

## EC-001 — Repository foundation
**Status:** DONE

Create the initial repository files and commit them to `main`.

### Acceptance criteria
- `README.md` exists.
- `AGENTS.md` exists.
- `PROJECT_TRACKER.md` exists.
- `docs/DECISIONS.md` exists.
- No feature code exists yet.
- Repository is pushed to GitHub.

---

## EC-002 — Protect main branch
**Status:** DONE

Configured on GitHub: PRs required (including admins), force pushes and deletion
disabled. Zero required approvals for the current solo-contributor workflow;
add one when another reviewer is available. Required checks are deferred to EC-012.

Configure GitHub branch protection.

### Acceptance criteria
- PR required before merging.
- Force pushes disabled.
- Deletion of `main` disabled.
- Status checks can be added when CI exists.

---

# Milestone 1 — Flutter Bootstrap

## EC-010 — Bootstrap Flutter app
**Status:** DONE

Create the Flutter application structure without implementing product features.

Implementation and local checks complete on `chore/flutter-bootstrap`:
analysis, two widget tests and a web build pass. User testing accepted;
merged through PR #1.

### Acceptance criteria
- App runs on at least one target.
- `flutter analyze` passes.
- Tests run successfully.
- Initial folder structure follows `AGENTS.md`.
- No unnecessary packages are introduced.
- Work is done on `chore/flutter-bootstrap`.
- Merged through PR.

---

## EC-011 — Define visual foundations
**Status:** DONE

Create only the visual primitives needed for the first training scenario.

Implemented on `codex/visual-foundations`: reusable card widget, visual tokens,
and an interactive four-card specimen preview. Five widget tests, analysis,
formatting and web build pass; browser rendering and selection visually checked.
No authored training content or game rules were changed.

### Acceptance criteria
- Card visual supports rank + suit.
- Selected and disabled card states exist.
- Basic spacing/typography tokens exist.
- UI works on a typical phone width.
- No heavy design system is created.

## EC-012 — Add Flutter continuous integration
**Status:** READY

Run the bootstrap checks on pull requests and require them before merge.

### Acceptance criteria
- CI checks formatting, analysis, tests and a web build.
- GitHub main protection requires the passing CI job.

## EC-024 — Confirm bidding rules and review the draft fixture
**Status:** READY

Agree the rules needed before exposing authored coaching. The existing fixture
has only three evaluated choices, so most allowed combinations have no rating.

### Acceptance criteria
- Document Dash eligibility, minimum bids, equal-bid/suit ordering and no-trump support.
- Review prior actions and allowed decisions against those rules.
- Review authored ratings, and define behavior for choices without an evaluation.
- Record the outcome in the authoring guide before implementing bid evaluation.

---

# Milestone 2 — Domain Core

## EC-020 — Card domain model
**Status:** BACKLOG

Define card, rank, suit and hand models.

### Acceptance criteria
- Models have clear equality semantics.
- A standard deck can be represented.
- Unit tests cover basic behavior.

---

## EC-021 — Trick legality rules
**Status:** BACKLOG

Implement legal-card selection for a trick.

### Acceptance criteria
- Following suit is enforced when possible.
- Off-suit play is allowed only when legal.
- Tests cover representative cases.

---

## EC-022 — Scenario data format v1
**Status:** BACKLOG

Define the first structured scenario representation.

### Acceptance criteria
- Scenario is independent from widgets.
- Bidding scenario can define hand, previous actions, choices and coaching metadata.
- Format is documented.
- At least one fixture exists.

---


## EC-023 — Standalone scenario validator
**Status:** BACKLOG

Create a repository-level validation command that can validate scenario content independently from the Flutter UI.

### Acceptance criteria
- Validates files under `content/scenarios/v1/`.
- Checks schema validity.
- Checks duplicate card usage where applicable.
- Checks supported enum/domain values.
- Returns non-zero exit code on invalid content.
- Can be run locally and later from CI.
- Documented in `docs/SCENARIO_AUTHORING.md`.

---

# Milestone 3 — First Playable Bidding Coach

## EC-030 — Visual bidding scenario screen
**Status:** BACKLOG

Render one authored bidding scenario visually.

### Acceptance criteria
- Player sees a card hand.
- Previous player actions are visible.
- Dash is a tap option.
- Bid number is selected visually.
- Trump is selected visually.
- No free-text response is required.

---

## EC-031 — Deterministic bid evaluation
**Status:** BACKLOG

Evaluate the player's authored scenario choice.

### Acceptance criteria
- Returns a decision rating.
- Can distinguish strong / reasonable / risky / weak.
- Does not call a remote AI service.
- Unit tests exist.

---

## EC-032 — Coaching feedback card
**Status:** BACKLOG

Show concise visual feedback after a bidding decision.

### Acceptance criteria
- Decision quality is shown separately from outcome.
- Safe/probable/risky trick reasoning can be displayed.
- Feedback does not require scrolling through a long essay.
- Player can continue quickly.

---

## EC-033 — First 10 bidding scenarios
**Status:** BACKLOG

Author a small curated scenario pack.

### Acceptance criteria
- At least 10 scenarios.
- Includes Dash decisions.
- Includes trump selection.
- Includes conservative vs aggressive bid sizing.
- Scenarios contain coaching metadata.
- Each scenario is manually reviewed.

---

# Milestone 4 — Mid-hand Training

## EC-040 — Four-seat table UI
**Status:** BACKLOG

Create the minimal playable table.

### Acceptance criteria
- Four player positions are visually clear.
- Current trick is centered.
- User hand is bottom.
- Current target and tricks won are visible.
- Layout remains readable on small phones.

---

## EC-041 — Card play interaction
**Status:** BACKLOG

Allow the player to choose and play a legal card.

### Acceptance criteria
- Legal cards are tappable.
- Illegal cards are visually disabled.
- Selected card receives clear feedback.
- Card moves to the current trick with a simple animation.

---

## EC-042 — Void tracking scenarios
**Status:** BACKLOG

Create scenarios that coach observation of void suits.

### Acceptance criteria
- Scenario can record known void information.
- Player decisions can be evaluated against that information.
- Feedback points out missed table information.

---

## EC-043 — Exact bid protection scenarios
**Status:** BACKLOG

Create situations where the player must avoid unwanted tricks.

### Acceptance criteria
- Target tricks are visible.
- Scenario changes coaching after the target is reached.
- At least 5 manually reviewed scenarios exist.

---

# Milestone 5 — Personal Coaching

## EC-050 — Skill taxonomy
**Status:** BACKLOG

Define initial measurable skill areas.

Candidate list:
- Dash decisions
- Bid sizing
- Trump selection
- Card tracking
- Mid-hand adaptation
- Exact-bid protection

### Acceptance criteria
- Each evaluated decision maps to one or more skills.
- Skill definitions are documented.

---

## EC-051 — Local progress history
**Status:** BACKLOG

Store training results locally.

### Acceptance criteria
- No account is required.
- Decision history survives app restart.
- Storage implementation remains replaceable.

---

## EC-052 — Weak-area recommendation
**Status:** BACKLOG

Recommend what the player should train next.

### Acceptance criteria
- Recommendation is computed from actual local performance.
- Rule is deterministic.
- User can start relevant scenarios directly.

---

# Icebox

These are ideas, not commitments.

- AI-generated explanation variants
- AI-assisted scenario authoring
- scenario validation tooling
- adaptive difficulty
- daily challenge
- full round simulator
- opponent behavior profiles
- replay timeline
- cloud sync
