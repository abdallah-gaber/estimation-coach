# PROJECT_TRACKER.md

This file is the repository-level source of truth for planned and active work.
For milestone status and the remaining release path, see [MVP_STATUS.md](docs/MVP_STATUS.md).

## Frozen MVP finish order

The remaining MVP has exactly **seven checkpoints**, in the order below.
These supersede the historical milestone groupings later in this file.
Bounded PRs may split a checkpoint's implementation, but cannot add an eighth
checkpoint without explicit owner approval. Checkpoints 1 and 2 are complete;
checkpoint 3 (EC-055) is in progress — its first bounded PR froze the coverage
target and proved the variant mechanism at the domain level, its second
closed 6 of the 13 base-scenario gaps, its third closed the remaining 7
(32/32, matrix complete), its fourth decided against wiring the variant
mechanism into the product (D-024) and prepared the owner repeated-session
review, its fifth fixed a trick-winner inconsistency the review found
(D-025), its sixth fixed a target-feasibility contradiction the review found
(D-026), its seventh completed the public table with per-seat opponent
estimates (D-027), and its eighth made post-decision coaching concise by
default with full detail on demand (D-028). That review, continuing, is the
only item still open, so checkpoint 3 is not done.

| Order | Checkpoint | Tasks | Status |
| --- | --- | --- | --- |
| 1 | Finish EC-043 — two remaining reviewed exact-bid-protection scenarios; content-only | EC-043 | DONE (5/5 scenarios) |
| 2 | Anti-memorization sessions — shuffled selection, no immediate repeats, order independent of catalog/files | EC-049 | DONE |
| 3 | Scenario Variants + Content Breadth — controlled deterministic variants and sufficient reviewed reasoning variety | EC-055 | IN PROGRESS (32/32 base scenarios; variant decided against wiring, D-024; four owner-review fixes landed, D-025/D-026/D-027/D-028; owner review continues) |
| 4 | Personal Coaching — persist decisions locally, aggregate skills, prioritize weak areas | EC-050/051/052 | BACKLOG |
| 5 | Training Hub — Quick Mix, Bid Practice, Play Practice, Weak Areas, Continue | EC-053 | BACKLOG |
| 6 | Egyptian Arabic + UI polish — مصري terminology, localization/RTL, focused usability polish | EC-060 | READY (after checkpoint 5) |
| 7 | MVP Acceptance — repeated owner playtesting, intended-device fixes, then v1.0.0-mvp | EC-054 | BACKLOG |

### MVP Definition of Done

- Bid and Play practice are both usable.
- Repeated sessions do not expose a fixed memorized order.
- Sufficient variety requires reasoning rather than answer recall.
- Reviewed deterministic coaching explains the evidence behind decisions.
- Progress persists locally.
- Weak Areas can select targeted practice.
- English and مصري work reliably.
- The owner completes repeated real sessions on the intended device without an
  MVP-blocking issue.

### New discoveries and progress updates

Every new discovery must be labelled **MVP BLOCKER** or **POST-MVP** (default).
A blocker must cite the Definition of Done criterion it prevents, evidence or
reproduction, and the existing checkpoint responsible. Everything else goes to
Post-MVP; discoveries do not silently extend the roadmap. See the
[scope policy](docs/MVP_STATUS.md#discovery-and-scope-policy).

On checkpoint closure, update this table, the task status, MVP_STATUS gate
evidence, README current focus and docs/assets/mvp-readiness.svg together.
Readiness is currently **45%**, calculated from fixed gates in MVP_STATUS.
If a blocker invalidates a completed gate, reopen it and remove its credit.

## EC-056 — MVP Roadmap Lock & GitHub Landing Page
**Status:** DONE
**Scope:** Owner-requested documentation/governance; not an eighth implementation checkpoint.

Completed the frozen plan, gate-based 45% readiness, README landing page and
agent guardrails. Verified local links/heading anchors, unique IDs, seven ordered
checkpoints, weights summing to 100 and SVG fill 270/600. SVG loads with its
accessible description. Changes are Markdown/SVG only; no feature or checkpoint
1 implementation. Latest main CI was successful at the lock's base commit.

### Acceptance criteria
- Freeze the seven ordered checkpoints and the explicit Definition of Done.
- Document anti-memorization architecture and controlled-variant constraints.
- Classify new discoveries without silently extending MVP scope.
- Publish a concise README landing page with CI badge and locally owned,
  arithmetically derived readiness SVG; keep detailed testing below it.
- Add agent guardrails; do not implement features, start checkpoint 1 or merge.

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
**Status:** DONE

Run the bootstrap checks on pull requests and require them before merge.

Implemented on `feat/flutter-ci`: a GitHub Actions workflow
(`.github/workflows/ci.yml`) running on pull requests to and pushes on `main`,
pinned to Flutter 3.44.1 stable. It runs the same checks as the README's local
"Automated checks" section: format check, analyze, test, strict scenario
validation and a web build. Follow-up on 2026-09-07 enabled the required
GitHub Actions check `Format, analyze, test, validate, build` on main, with
up-to-date branches required and existing protections preserved.

### Acceptance criteria
- CI checks formatting, analysis, tests and a web build.
- GitHub main protection requires the passing CI job.

## EC-025 — Expand nested scenario schema constraints
**Status:** DONE

Bring the canonical schema's broad nested fields into alignment with the
supported bidding parser contract, in a separate schema-focused PR.

Implemented on `codex/scenario-schema`: nested definitions and conditional bidding
requirements, with 42 schema/parser alignment tests. All 107 tests, formatting,
analysis and default structural validation pass. The canonical fixture is
preserved; its game_rules_v1 conflicts are audited and tracked in EC-026.

### Acceptance criteria
- Define previous action, allowed decision, evaluation and feedback structures.
- Preserve the existing fixture and document any compatibility changes.
- Verify schema/parser agreement using valid and invalid fixtures.

## EC-026 — Implement canonical game_rules_v1 bidding
**Status:** DONE

Apply the owner's confirmed rules to domain models, validation and draft content.

Implemented on `codex/canonical-bidding`: count/trump bid ranking, Sans, immutable
Dash state, explicit scenario rules/phase metadata, phase-aware history checks
and filtered legal choices. Draft migrated to face 4 Hearts with 17 legal raises.
All 140 tests, formatting, analysis, default validation and web build pass.
Strict coverage correctly fails for 16 missing evaluations; coaching review is
still EC-024 work.

### Acceptance criteria
- Normal bids start at 4 tricks; raises compare count, then trump rank.
- Sans > Spades > Hearts > Diamonds > Clubs; Sans is distinct from card suits.
- Dash is a separate pre-bidding estimate of zero; Dash players do not bid.
- Scenario schema and parser represent the required phase and trump category.
- Migrate the conflicting draft and review its situation before rating review.
- Regression tests cover minimum bids, equal-bid ordering and Dash timing.
- Special/fixed-trump rounds remain out of scope.

## EC-024 — Confirm bidding rules and review the draft fixture
**Status:** DONE

Canonical normal-round bidding rules are confirmed in `docs/GAME_RULES_V1.md`.
EC-026 corrected the draft's 3-trick bids and late Dash choices. The strategic
review is now in `docs/COACHING_REVIEW.md`: 4 Spades is reasonable rather than
strong, and all 17 legal raises plus the two pre-bidding choices have feedback.
The pure evaluator returns null for missing feedback; the trainer rejects
incomplete catalogs before a session starts.

### Acceptance criteria
- Document Dash eligibility, minimum bids, equal-bid/suit ordering and no-trump support.
- Review prior actions and allowed decisions against those rules.
- Review authored ratings, and define behavior for choices without an evaluation.
- Record the outcome in the authoring guide before implementing bid evaluation.

---

# Milestone 2 — Domain Core

## EC-020 — Card domain model
**Status:** DONE

Define card, rank, suit and hand models.

Implemented on `codex/card-domain-model`: immutable card/hand value objects,
strict v1 notation parsing and a deterministic standard deck. The visual preview
now consumes typed cards. Nine domain tests and five existing widget tests pass,
as do formatting, analysis and the web build. See D-007 for equality semantics.

### Acceptance criteria
- Models have clear equality semantics.
- A standard deck can be represented.
- Unit tests cover basic behavior.

---

## EC-021 — Trick legality rules
**Status:** DONE

Implement legal-card selection for a trick.

Implemented on `codex/follow-suit-legality`: pure Dart `legalCards` and
`isLegalPlay`, including membership checks and immutable ordered results. Seven
rule tests and all 21 tests pass; formatting, analysis and web build pass.
Contract and caller responsibilities are documented in `docs/GAME_RULES.md`.
UI scenario integration remains with the planned play-training milestones.

### Acceptance criteria
- Following suit is enforced when possible.
- Off-suit play is allowed only when legal.
- Tests cover representative cases.

---

## EC-022 — Scenario data format v1
**Status:** DONE

Define the first structured scenario representation.

Implemented on `codex/scenario-validation`: immutable pure Dart bidding models
and field-path parsing checks using the existing canonical fixture. Hand, seats,
previous actions, allowed choices, ratings and feedback are typed. The schema and
fixture are unchanged; supported constraints are documented in the authoring guide.

### Acceptance criteria
- Scenario is independent from widgets.
- Bidding scenario can define hand, previous actions, choices and coaching metadata.
- Format is documented.
- At least one fixture exists.

---


## EC-023 — Standalone scenario validator
**Status:** DONE

Create a repository-level validation command that can validate scenario content independently from the Flutter UI.

Implemented `dart run tool/validate_scenarios.dart`: canonical schema checks,
domain parsing, recursive discovery and cross-file duplicate IDs. Incomplete
coverage warns by default and fails with `--require-complete`. Both CLI exit paths
verified. All 65 tests, formatting, analysis and web build pass. Structural
validation does not resolve EC-024 or certify authored coaching.

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
**Status:** DONE

Render authored bidding scenarios visually.

Completed: bundled JSON loading, a 13-card hand with font-independent suit
marks, prior-action chips, pre-bidding Dash/enter, and legal count/trump controls.
Widget coverage includes 320px with double text scaling and load-error retry.

### Acceptance criteria
- Player sees a card hand.
- Previous player actions are visible.
- Dash is a tap option.
- Bid number is selected visually.
- Trump is selected visually.
- No free-text response is required.

---

## EC-031 — Deterministic bid evaluation
**Status:** DONE

Evaluate the player's authored scenario choice.

Completed: pure exact authored lookup, illegal-choice rejection, explicit
missing feedback, and regression coverage across all 19 choices/four ratings.

### Acceptance criteria
- Returns a decision rating.
- Can distinguish strong / reasonable / risky / weak.
- Does not call a remote AI service.
- Unit tests exist.

---

## EC-032 — Coaching feedback card
**Status:** DONE

Show concise visual feedback after a bidding decision.

Completed: rating, choice-specific explanation, optional Why? evidence, explicit
unsimulated outcome, retry, next independent hand, and session restart.

### Acceptance criteria
- Decision quality is shown separately from outcome.
- Safe/probable/risky trick reasoning can be displayed.
- Feedback does not require scrolling through a long essay.
- Player can continue quickly.

---

## EC-033 — First 10 bidding scenarios
**Status:** DONE

Author a small curated scenario pack.

Progress: 10 reviewed hands and 53 evaluated choices are bundled. Four hands
cover pre-bidding Dash/enter; six cover normal bid sizing and trump choice.
Review rationale is in `docs/COACHING_REVIEW.md`. A catalog test verifies every
choice and a widget test completes all ten hands without UI implementation changes.
Validation: 153 tests, analysis, strict content validation and web build pass.

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
**Status:** DONE

Create the minimal table surface.

Completed on `codex/play-table-preview`: labelled four-seat layout specimen,
current trick, target/taken/trump, and follow-suit selection. The preview is
reachable from bidding and Back preserves the session. No card is committed,
no winner is resolved, and no coaching is authored in this fixture.
158 tests, analysis, strict content validation and web build pass; browser
rendering/selection and 320px tests at 1x/2x text checked.

### Acceptance criteria
- Four player positions are visually clear.
- Current trick is centered.
- User hand is bottom.
- Current target and tricks won are visible.
- Layout remains readable on small phones.

---

## EC-041 — Card play interaction
**Status:** DONE

Allow the player to choose and play a legal card.

Implemented on `codex/card-play-interaction`: single legal-card commitment from
the hand to the current trick, reusing existing follow-suit legality. A short
hand-to-table flight animates the commit and is skipped under reduced-motion
settings; further play locks during flight and after commitment. Reset hand
restores the fixture, and the overlay is cleaned up if the route is left mid-
animation. Winner resolution, scoring and coaching remain deferred to EC-047;
233 tests, formatting, analysis and web build pass, including 320px/large-text
coverage.

### Acceptance criteria
- Legal cards are tappable.
- Illegal cards are visually disabled.
- Selected card receives clear feedback.
- Card moves to the current trick with a simple animation.

---

## EC-047 — First coached play session
**Status:** DONE

Connect reviewed portable play scenarios to the table interaction after EC-041.

Implemented in PR #16: `PlayTrainingScreen` replaces the fixture-driven table
specimen, loading a bundled, reviewed two-scenario pack
(`content/scenarios/v1/play/`, four evaluated legal choices, both tagged
`safe_vs_probable`) through `PlayScenario`/`loadPlayScenarios`.
Reuses the EC-041 one-card commit/flight/reduced-motion/dispose behavior,
parameterized per scenario. Shows rating/title/summary/points separately from
an explicitly unsimulated outcome, with Try another choice, Next situation and
Finish session/Practice again. 235 tests, formatting, analysis, strict content
validation and web build pass; manually verified in-browser end to end.
`play_safe_probable_002` (a guaranteed-trick recognition case: acting last
while void, trump wins regardless of rank) is tagged `safe_vs_probable` rather
than `card_tracking`, since it does not test tracking previously played cards.
See [COACHING_REVIEW.md](docs/COACHING_REVIEW.md) for the content review.
Winner resolution, scoring, void-tracking and exact-bid packs remain deferred
to EC-042/043.

### Acceptance criteria
- Load a small reviewed pack through PlayScenario and reject incomplete feedback.
- Commit legal cards and show authored decision quality separately from outcome.
- Support retry, next scenario and session completion with navigation tests.
- Confirm and document trick-winner rules before coaching depends on them.
- Keep training content out of widgets and preserve bidding progress.

---

## EC-042 — Void tracking scenarios
**Status:** DONE

Create scenarios that coach observation of void suits.

Implemented on `feat/void-tracking-scenarios`: `PlaySituation` gains optional
`observedTricks` (curated prior tricks, never a claim of full history), and
`lib/core/game_rules/void_tracking.dart` derives known-void suits purely from
observed off-suit play using the confirmed EC-021 follow-suit rule — no
`known_voids` field or other authored void metadata exists anywhere. Schema,
parser and validator extended accordingly. Three reviewed scenarios
(`play_void_tracking_001`–`003`) ship in `content/scenarios/v1/play/`; one is
authored so its rating changes once the void is accounted for, and a
regression test confirms the stated rationale genuinely depends on the
observed evidence (not an algorithmic proof of optimality — ratings remain
authored judgment). `PlayTrainingScreen` shows a
compact, de-emphasized "Observed play" section above the current trick. See
[COACHING_REVIEW.md](docs/COACHING_REVIEW.md#void-tracking-pack-review-ec-042)
and [D-018](docs/DECISIONS.md) for the full design rationale. Winner
resolution, scoring and EC-043 remain deferred.

The owner confirmed the canonical counter-clockwise play direction
(North → West → South → East → North) on 2026-09-08. `lib/core/game_rules/
seat_rotation.dart` (`rotationFrom`) is the single source of seat succession,
used by `PlaySituation`'s `currentTrick` validation and `ObservedTrick`'s own
constructor. Every existing play scenario (including the two EC-047
originals and the synthetic contract fixture) was re-verified and, where
needed, corrected against this rotation. All three void-tracking scenarios'
seat assignments changed: South is 3rd to act only when North leads, so the
seat that plays after South is **East**, not West as originally authored —
their strategic ratings were re-reviewed and are unaffected in substance
(the coaching lesson still holds), only the seat identity changed. See
[D-019](docs/DECISIONS.md) for the correction record.

### Acceptance criteria
- Scenario can record known void information.
- Player decisions can be evaluated against that information.
- Feedback points out missed table information.

---

## EC-043 — Exact bid protection scenarios
**Status:** DONE

Frozen checkpoint 1 complete: five reviewed scenarios use the unchanged
PlayScenario contract and existing `classifyExactBid` pre-play status.
The final two files are content-only and introduce no capability changes.

Create situations where the player must avoid unwanted tricks.

A rule-domain audit (`docs/GAME_RULES_V1.md#rule-domain-status-audit-2026-09-08`)
reviewed what this depends on. The owner has since confirmed the core
estimate rules needed for exact-bid coaching: a non-Caller's estimate must
not exceed the Caller's, "With" (equal to the Caller's), the total of four
estimates must never equal 13, "Over"/"Under" (total ≥14 / ≤12), and the
exact-target rule itself (success is exact tricks taken, not "at least").
Minimal pure-domain modules implementing these already exist —
`lib/core/game_rules/estimate_totals.dart` and
`lib/core/game_rules/exact_bid_outcome.dart`.

Post-auction estimate ordering, Risk/complete scoring, multipliers, Mini/Micro
and fixed-round orchestration are POST-MVP, not EC-043 release prerequisites.
Trick winners are confirmed but have no resolver; none is needed to finish
these reviewed single-decision scenarios using the existing contract.

Implemented checkpoint: `play_target_protection_001`–`003` cover below,
exactly on, and already above target (six reviewed choices). The first two
use identical cards and reverse the preferred choice after reaching the target.
Play Practice loads these files automatically; its pre-play status calls
`classifyExactBid` without adding schema fields or resolving a trick.
Review rationale: `docs/COACHING_REVIEW.md`; manual steps: README.

Completed: `play_target_protection_004` adds safe undertrumping beneath a visible
higher trump while on target; `_005` weighs spending the ace versus a lower safe
winner when one trick short in Sans. All twelve choices across five scenarios
are reviewed; local certainty and future coaching judgments are distinguished.
No schema, UI, selection, scoring, simulation or test registration changed.
Checkpoint 2 remains BACKLOG. Readiness remains 45% because the Variety gate
requires checkpoints 1–3 all closed.

Validation: the full existing test suite and Flutter analysis pass, strict
validation accepts all 20 production files with complete feedback, and the web
build succeeds. Catalog-driven tests exercise the additions without code changes.

### Acceptance criteria
- Target tricks are visible.
- Scenario changes coaching after the target is reached.
- At least 5 manually reviewed scenarios exist.

---

## EC-048 — Enforce the known auction bound in play snapshots
**Status:** DONE

Review found a pre-existing mismatch after the newly confirmed estimate rules:
`play_safe_probable_001` has estimate 5 but winning auction bid 4. A Caller's
estimate equals that bid and a non-Caller's cannot exceed it, so this combination
was invalid regardless of caller identity.

`PlaySituation` now delegates this bound to `isValidNonCallerEstimate` when
auction context is supplied. Existing parser/CLI propagation rejects invalid
authored files under `$.situation`; no comparison was duplicated there.
No auction context still permits estimates 0–13. No caller identity, estimate
ordering or scoring was introduced, and EC-043 content was not expanded.

Reviewed all production scenarios, the contract fixture and inline test setups.
Corrected the sole affected JSON file's auction bid to 5 Clubs, preserving its
target, visible cards and coaching; rationale is in `docs/COACHING_REVIEW.md`.
Corrected the old estimate-13/bid-5 domain test and added domain, parser and
strict catalog regressions, including restoration of the original invalid case.

Validation: full Flutter tests and analysis pass; strict validation accepts all
18 production files plus the contract fixture; formatting and web build pass.

### Acceptance criteria
- Reject an estimate above a supplied winning auction bid using the owning rule helper.
- Add a regression and review/correct affected existing content and fixtures.
- Preserve snapshots with no auction context; do not infer caller identity or
  add estimate-phase ordering or scoring.
- Run strict catalog validation and the relevant domain/parser tests.

---

## EC-044 — Portable mid-hand scenario contract
**Status:** DONE

Split into EC-045 (public model) and EC-046 (portable schema/parser/feedback).
Budget policy: choose a checkpoint small enough to implement, validate, document
and push in one available context; keep unfinished follow-ups explicit.

Define the supported play-scenario schema and pure parser before replacing the
UI fixture with authored training content. Review any missing play rules with
the owner before implementing winner resolution or scenario continuation.

### Acceptance criteria
- Represent seats, remaining hand, current trick, leader, trump, target and tricks taken.
- Keep auctionBid distinct from each player's trickEstimate; do not apply the
  auction opening minimum to estimates. See docs/EGYPTIAN_ARABIC.md.
- Represent authored evaluations for legal card choices outside widgets.
- Validate duplicate cards, counts, follow-suit choices, and complete feedback.
- Document the contract in SCENARIO_AUTHORING.md and preserve bidding compatibility.
- Add parser/schema/evaluation tests before exposing coached play scenarios.

---

## EC-045 — Pure play-situation model
**Status:** DONE

First bounded EC-044 checkpoint: a validated, immutable public snapshot for one
player's next card decision, independent of Flutter and authored feedback.

Implemented `PlaySituation`, `SeatPlay` and `TrickEstimate` with 20 focused
regressions. All 178 tests, analysis and strict bidding-content validation pass.
The UI is unchanged; EC-046 completes the remaining portable contract.

### Acceptance criteria
- Keep optional winning auctionBid separate from the player's trickEstimate.
- Represent seats, remaining hand, current trick/leader, trump and taken counts.
- Reject duplicate cards/seats, impossible counts and inconsistent snapshots.
- Derive legal choices using the existing follow-suit rule.
- Test leading, following, voids, low estimates, overtricks and immutability.
- Document model limits; leave UI and portable bidding content working.

## EC-046 — Play JSON schema and parser
**Status:** DONE

Completed after EC-045: conditional play schema, immutable PlayScenario parser,
legal card feedback lookup and mixed-catalog CLI validation. Synthetic fixture
is test-only; production bidding content and UI remain unchanged.
230 tests, analysis, both strict validator paths and web build pass.
The contract is documented before coached UI integration in EC-041.

### Acceptance criteria
- Add supported play-scenario schema/parser with field-path errors.
- Reuse PlaySituation validation and preserve existing bidding compatibility.
- Keep coaching portable; validate evaluation membership and full legal coverage.
- Extend standalone validation with passing/failing play fixtures and tests.
- Document any unresolved rule dependencies rather than inventing behavior.

---

## EC-049 — Anti-memorization sessions
**Status:** DONE
**Roadmap:** Checkpoint 2; after completing EC-043.

Replaying the current small fixed packs causes the player to remember scenario
answers instead of reasoning from the table.

Implemented the frozen architecture boundary `Scenario Catalog → Session
Selector → existing trainer UI`: `selectSession<T>`
(`lib/core/session/session_selector.dart`) is a pure, generic function that
shuffles an eligible pool with an injected `Random` source, comparing items by
id rather than object identity. `ScenarioSession<T>`
(`lib/scenarios/scenario_session.dart`) composes a catalog loader with the
selector, caches the catalog, and tracks the previous session's last scenario
so a new session never starts with it when an alternative exists. Both
trainer screens consume one `nextSession` function — set once in `initState`,
either the production `ScenarioSession` or (in widget tests) the existing
`loader` override — and hold no randomization logic themselves. "Practice
again" calls that same function again instead of resetting to the first
loaded scenario, so it returns a freshly ordered session. See
[D-022](docs/DECISIONS.md).

303 tests pass (20 new: 12 for `selectSession`, 6 for `ScenarioSession`, plus
2 widget-level regressions proving "Practice again" requests a new order).
Analysis is clean, strict validation still accepts all 20 content files
unchanged, and the web build succeeds. No scenario content, schema or
evaluation logic changed.

### Acceptance criteria
- Session Selector chooses a shuffled order independently of catalog/filename order. ✅
- No immediate repeats within or between sessions when another eligible scenario
  exists; explicit behavior for empty, single-item and exhausted pools. ✅
- Controlled seeds make selection reproducible in tests; verify different valid
  orders and preserve scenario legality/feedback unchanged. ✅
- Existing trainer UI consumes selected scenarios without randomizing cards or
  owning generation logic. No runtime AI dependency. ✅

## EC-055 — Scenario Variants + Content Breadth
**Status:** IN PROGRESS
**Roadmap:** Checkpoint 3; after EC-049.

Architecture: `Scenario Catalog → Session Selector → Optional Validated Variant
Generator → existing trainer UI`.

### First bounded PR: coverage target + variant mechanism v1

Froze the finite MVP coverage target at **32 reviewed base scenarios**
(16 bidding + 16 play) and audited all 20 existing scenarios against it; see
the [coverage matrix](docs/MVP_STATUS.md#checkpoint-3-coverage-matrix-ec-055).
Result: **19 of 20 files count as distinct reasoning cases** —
`play_void_tracking_003` is a hand-authored suit-relabeled duplicate of
`play_void_tracking_001`, by its own `author_notes` — leaving **13 base
scenarios** still to author (not 12, which a flat 20-files-in reading would
suggest), plus `bid_training_009` reclassified from `trump_selection` into a
new Mixed/ambiguous bidding judgment category to keep Trump selection/control
at its 4-scenario target.

Implemented and domain-tested variant mechanism v1: `generateTricksTakenVariant`
(`lib/scenarios/scenario_variant.dart`) deterministically redistributes the
completed-trick total among the three non-player seats — the only field
audited and confirmed to be schema-validated yet never quoted by exact value
in any of the 20 scenarios' feedback text. `PlayScenario.withTricksTaken`
(`lib/scenarios/play_scenario.dart`) is the fail-closed apply step, reusing
`PlaySituation`'s own validation. Card/rank/suit substitution and seat
relabeling were both audited and found unsafe against the current free-text
feedback contract; see
[D-023](docs/DECISIONS.md) for the full audit and why UI integration waits for
a future PR. 10 new tests
(`test/scenarios/scenario_variant_test.dart`) prove: same base + seed → same
output; different seeds can differ; the source scenario is never mutated;
every production play scenario accepts the transformation; rating/evaluation
mapping and all referenced public evidence stay byte-identical; and invalid
`tricksTaken` maps are rejected (wrong sum, missing seat, out-of-range count).

313 tests pass, analysis is clean, strict validation still accepts all 20
content files unchanged (no scenario content, schema or evaluation logic
changed), and the web build succeeds. Readiness stays 45%; the Variety gate
stays 0% (checkpoint 3 is not closed). Checkpoint 4 was not started.

### Second bounded PR (this PR): 6 new base scenarios

Closed the highest-value gaps the first bounded PR identified: **+1 Dash/Enter,
+2 Bid sizing, +1 Mixed/ambiguous bidding, +1 Safe vs probable, +1 Void
tracking/table reading** (26 total). Updated matrix with explicit before/after
counts: [docs/MVP_STATUS.md](docs/MVP_STATUS.md#checkpoint-3-coverage-matrix-ec-055).

- `bid_training_011` — first Dash/Enter scenario rating Dash itself Strong
  (nothing above a six anywhere, no suit over four cards).
- `bid_training_012`/`_013` — first two dedicated bid_sizing scenarios besides
  `bid_safe_probable_001`; each offers only one trump so the decision is
  purely trick-count judgment, not trump comparison.
- `bid_training_014` — second Mixed/ambiguous scenario (after
  `bid_training_009`): two genuinely comparable four-card trump candidates,
  no side-suit help, no evaluation reaches Strong.
- `play_safe_probable_003` — first safe_vs_probable scenario where South does
  not act last; the strongest card is genuinely probable, not certain.
- `play_void_tracking_004` — a boundary-condition case, not a suit reskin:
  South leads last, so a shown void from an earlier, different-suit trick
  cannot matter here, for two independent reasons.

All 26 new legal choices are evaluated; every scenario passes strict
schema/domain validation on the first run. No schema, UI, or variant-mechanism
changes; no persistence, adaptive selection, or checkpoint 4 work. Existing
tests hard-coding the prior 10-hand/53-choice and 10-situation totals were
updated to the new 14-hand/66-choice and 12-situation totals — no test
behavior changed, only the counts they assert.

313 tests pass, analysis is clean, strict validation accepts all 26 content
files, and the web build succeeds. Readiness stays 45%; the Variety gate
stays 0% (checkpoint 3 remains open — 7 base scenarios and UI wiring for the
variant mechanism still needed). Checkpoint 4 was not started.

### Third bounded PR (this PR): 7 new base scenarios, matrix complete

Closed every remaining gap the second bounded PR left open: **+1 Bid sizing,
+1 Mixed/ambiguous bidding, +1 Safe vs probable, +1 Void tracking/table
reading, +1 Exact-target protection, +2 Mixed tactical reading** (33 total
files, 32 distinct reasoning cases). Matrix updated to 32/32:
[docs/MVP_STATUS.md](docs/MVP_STATUS.md#checkpoint-3-coverage-matrix-ec-055).

- `bid_training_015` — third bid_sizing scenario: a long (seven-card) suit
  with only one honor, testing length without concentration.
- `bid_training_016` — third Mixed/ambiguous scenario: a five-card Spade
  suit missing the King (risk, more length) versus a four-card Heart suit
  with a complete Ace-King sequence (no risk, less length).
- `play_safe_probable_004` — escalates `_003`: South acts second, with two
  seats (not one) still to act.
- `play_void_tracking_005` — first void-tracking scenario where South leads
  (empty current trick) rather than responds; the decision is which suit to
  lead around a known void, not how to respond to one.
- `play_target_protection_006` — a facet none of `_001`–`_005` cover:
  choosing between two of South's own legal trumps that both currently win
  (trump conservation), not deciding whether to win at all.
- `play_mixed_tactical_001`/`_002` — the two Mixed tactical reading
  scenarios required by this batch. Each combines two already-supported
  signals (`_001`: known trump void + below-target urgency; `_002`: visible
  opponent trump + target state, deliberately mirroring
  `play_target_protection_004`'s mechanism with the opposite target so the
  same evidence produces the opposite correct action) with an explicit
  decisive-vs-supporting split in the feedback. No new capability was added.

All 32 new legal choices across the 7 files are evaluated (`bid_training_015`:
3, `_016`: 4, `play_safe_probable_004`: 2, `play_void_tracking_005`: 2,
`play_target_protection_006`: 2, `play_mixed_tactical_001`/`_002`: 2 each).
Every scenario passes strict schema/domain validation on the first run after
one fixture-collision fix (see below). No schema, UI, or variant-mechanism
changes; no persistence, adaptive selection, or checkpoint 4 work.

`play_mixed_tactical_001`'s off-suit filler card was changed from the ace of
Clubs to the two of Clubs during authoring: the ace collided with
`play_void_tracking_005`'s hand, which broke an existing cross-scenario test
assertion (`scenarios.first.evaluate(scenarios.last...)` in
`play_training_test.dart`, sensitive to alphabetical file order) once the new
`play_mixed_tactical_001` file sorted before `play_safe_probable_001`. The
swapped card was never referenced by exact rank in that evaluation's own
rating (Weak, off-suit, cannot win); only its feedback text was reworded to
match. Existing tests hard-coding the prior 14-hand/66-choice totals (from
the second bounded PR) were updated to the new 16-hand/73-choice totals — no
test behavior changed, only the counts they assert.

313 tests pass, analysis is clean, strict validation accepts all 33 content
files, and the web build succeeds. Readiness stays 45%; the Variety gate
stays 0% (checkpoint 3 remains open — the variant UI-wiring decision and
owner repeated-session review still needed). Checkpoint 4 was not started.

### Fourth bounded PR (this PR): variant decision + owner-review prep

Closure PR for checkpoint 3. Docs-only: no new scenarios, no schema, UI or
variant-mechanism code changes.

1. **Made the variant decision explicit and final for the MVP**
   ([D-024](docs/DECISIONS.md)): variant v1 (opponent taken-trick-count
   redistribution, D-023) stays domain-tested only and is **not** wired into
   either trainer. Neither of D-023's revisit conditions changed (still one
   transformation; feedback still free text), and it only varies a field
   players do not reason from. The coverage matrix and Session Selector
   (EC-049) are the mechanisms actually expected to carry this checkpoint's
   anti-memorization requirement. The architecture extension point stays
   documented as-is for a future, richer variant; no new transformation was
   added, and the schema/feedback structure was not changed to enable one
   prematurely.
2. **Prepared the owner repeated-session review**: added an explicit
   five-question checklist to
   [docs/MVP_STATUS.md](docs/MVP_STATUS.md#checkpoint-3-owner-repeated-session-review),
   covering recognition-from-position, needing to read the table, whether
   repeated sessions feel different, any scenarios similar enough to answer
   from memory, and whether Bidding/Play both feel sufficiently varied.
   Product-focused, not "tests pass."
3. **Did not fake owner acceptance.** The owner has not yet run this review;
   this PR does not mark EC-055 DONE, does not change the Variety gate from
   0%, and does not change MVP Readiness from 45%. The review checklist is
   the sole remaining item; nothing else currently blocks EC-055.

313 tests pass, analysis is clean, strict validation accepts all 33 content
files unchanged, and the web build succeeds. Checkpoint 4 was not started.

### Fifth bounded PR (this PR): fix a trick-winner inconsistency found in owner review

The owner's repeated-session review (prepared by the fourth bounded PR) is now
**in progress** and found a real game-state inconsistency, not a wording
issue, in its first pass: `play_void_tracking_005`'s single observed trick
(East 7C, North 8C, West 5H, South 2C, trump Hearts) is won by **West**
(trumping with 5H), but the scenario's empty current trick authored
`"leader": "south"` — contradicting the rule that the trick's winner leads
next.

**Content fix** (smallest change preserving the lesson): West's discard
changed from `5H` (a trump) to `3D` (non-trump — the Club void this scenario
trains is unchanged); South's card changed from `2C` to `KC` (South's own
King, not the Ace still held now). With no trump played, South's King
legitimately wins, making the authored leader correct. Both evaluations'
ratings are unchanged; one feedback point's named suit was corrected
("Heart" → "Diamond") and one was strengthened with the new evidence, without
overclaiming. Full re-review: [docs/COACHING_REVIEW.md](docs/COACHING_REVIEW.md).

**Audited the same bug class** across every play scenario with
`observed_tricks` (`play_void_tracking_001/002/003/004/005`,
`play_mixed_tactical_001`). Only `_005` has an empty current trick — the only
case where `leader` is asserted with no other visible evidence to check it
against — so it was the only file needing a fix.

**Added the pure `trickWinner` helper; deliberately did not add a generic
validation rule** ([D-025](docs/DECISIONS.md)): `trickWinner`
(`lib/core/game_rules/trick_winner.dart`, 9 tests) applies the
already-confirmed game_rules_v1 trick-winner rule to one already-complete
trick. An earlier version of this fix also added a `PlaySituation` check —
leading with observed history shown required the leader to equal that
helper's answer for the last observed trick — and that check is what caught
the bug initially, but it assumed `observedTricks.last` is always the
immediately previous trick, which the `observed_tricks` contract does not
promise (it is curated, visible evidence, not a claim of recency). **That
check was removed before merge**, since it would reject a valid future
scenario with an unshown trick between the last observed one and the
current empty one. In its place, `test/scenarios/play_scenario_test.dart`
gained one targeted regression test proving specifically that
`play_void_tracking_005`'s authored leader matches its shown trick's actual
winner — the one file whose own intent requires that property, without
asserting it for every scenario. `SeatPlay`/`ObservedTrick` moved to a new
`lib/core/game_rules/seat_play.dart` so `trick_winner.dart` never imports
`play_situation.dart`, avoiding the circular dependency the first version
of this fix introduced.

`docs/GAME_RULES.md`, `docs/GAME_RULES_V1.md` and `docs/SCENARIO_AUTHORING.md`
document `trickWinner` as an available pure helper, explain why it is not
wired into `PlaySituation`'s validation, and tell future content authors to
add their own targeted test when a scenario's intent requires continuity —
without weakening any "no resolver, no round, no scoring" statement, which
remain true everywhere else.

324 tests pass, analysis is clean, strict validation accepts all 33 content
files (unchanged count — a correction, not new content), and the web build
succeeds. This is a bounded correctness fix, not checkpoint 3 acceptance work:
the coverage matrix stays 32/32, the Variety gate stays 0%, MVP Readiness
stays 45%, EC-055 is not marked DONE, and checkpoint 4 was not started. The
owner's repeated-session review continues.

### Sixth bounded PR (this PR): fix a target-feasibility contradiction found in owner review

The owner's repeated-session review found a second, systemic issue: a
coaching heuristic (void avoidance) was evaluated in isolation from whether
its recommendation was even compatible with the player's own exact-target
math for the current trick.

**Audit** (all 17 production play scenarios, full table and per-scenario
review in [D-026](docs/DECISIONS.md)): classified each by taken/target/
remaining-hand-size. **6 of 17 are `mustWinAll`** (every remaining trick,
including the current one, must be won); **5 of those 6 already correctly
recommend a winning card**. `play_void_tracking_005` was the sole exception:
with South needing both remaining tricks, it rated a bare low card (4D, no
case for winning at all) Strong over an Ace (AC, wins outright except for
one named, confirmed risk) Risky — the void-avoidance heuristic overriding
basic card-strength logic in a spot where losing wasn't affordable.
Separately, **0 of 17** scenarios' feedback text makes a claim that requires
knowing an opponent's specific estimate (as opposed to their derived void,
visible cards, or acting order) — the opponent-estimates contract gap is
real (see "Not started" below) but has not produced a false claim in current
content.

**Added `TargetFeasibility`** (`lib/core/game_rules/target_feasibility.dart`,
10 tests): `classifyTargetFeasibility({taken, target, remainingTricks})` →
`alreadyOver` / `onTarget` / `mustWinAll` / `slack` / `unreachable` — two
distinct "impossible" states (too many taken vs. too few tricks left), per
the requirement not to silently fold either into ordinary `slack`. Sits
alongside `exact_bid_outcome.dart`/`estimate_totals.dart` as the same shape
of small, pure module.

**Content fix**: rebalanced `play_void_tracking_005`'s `tricks_taken` —
South 2→3, North 3→2 (East/West unchanged; sum stays 11, matching
`13 - hand.length` for the unchanged 2-card hand). No card, void evidence,
or rating changed; confirmed no evaluation referenced North's specific taken
count, so the rebalance is strategically neutral. This moves the scenario
from `mustWinAll` to `slack` (need 1 of 2, not both), making the existing
recommendation coherent — losing this trick no longer eliminates the
target, it shifts the requirement to the final trick and the ace still in
hand, the same shape `play_void_tracking_001` already uses successfully.
Both evaluations' feedback now say this explicitly. Full re-review:
[docs/COACHING_REVIEW.md](docs/COACHING_REVIEW.md).

**Regression coverage, and its documented limit**:
`test/scenarios/play_target_feasibility_test.dart` classifies all 17
scenarios against a reviewed table (forces conscious review on any future
add/edit), proves `_005` is now `slack`, and — for the *mechanically
checkable* subset of `mustWinAll` scenarios where South acts last, so
`trickWinner` can resolve a hypothetical completed trick from public
information alone — asserts every Strong-rated card actually wins (only
`play_target_protection_006` currently qualifies). The other 4 `mustWinAll`
scenarios cannot be checked this way without reimplementing the coaching's
own reasoning as a second engine; that limit is documented in the test file
and D-026 rather than papered over with an invented heuristic validator.

`docs/GAME_RULES.md`, `docs/GAME_RULES_V1.md` and `docs/SCENARIO_AUTHORING.md`
document the new module and tell future authors to check feasibility before
rating a card that concedes the current trick, and to rebalance a *different*
seat's `tricks_taken` (never referenced by feedback text) when one seat's
count needs to change.

**Not started**: the opponent-estimates contract extension (public per-seat
`trickEstimate` in the `PlayScenario`/domain contract, plus a compact
`Target / Taken` display) is a separate, non-optional bounded PR, to start
only after this one is reviewed and merged.

338 tests pass, analysis is clean, strict validation accepts all 33 content
files (unchanged count — a correction, not new content), and the web build
succeeds. This is a bounded correctness fix, not checkpoint 3 acceptance
work: the coverage matrix stays 32/32, the Variety gate stays 0%, MVP
Readiness stays 45%, EC-055 is not marked DONE, checkpoint 4 was not
started. The owner's repeated-session review continues.

### Seventh bounded PR (this PR): public opponent estimates

The queued follow-up from the sixth bounded PR: the public play table showed
each opponent's tricks taken with no target to compare it against. Revised
inside the same PR after owner review rejected a first version that added the
field but left all 17 scenarios empty — which would have shipped the same
incomplete table, since every opponent still rendered as `Target unknown`.
Authored synthetic game states make an opponent's target *missing public
state to author*, like the cards and taken counts already authored.

**Contract**: an additive, optional `opponent_estimates` object, each value
an exact 0–13 estimate; `scenario_version` stays 1. The schema allows **all
four** seat names and the domain rejects whichever equals `player_position`,
so the field does not narrow the root contract's any-seat pending player to
South. `PlaySituation.opponentEstimates` is a `Map<PlayerSeat, TrickEstimate>`
(default empty), and three game_rules_v1 estimate rules previously unchecked
are now enforced through the modules that own them, with no caller identity
inferred: every authored estimate is bounded by a supplied `auction_bid`
(rule 2, reusing `isValidNonCallerEstimate`; equalling it is "With", rule 3);
a complete set combined with `trick_estimate` must not total 13 (rule 4) and
must contain some seat at exactly the winning bid, because the Caller is one
of the four and their estimate *is* that bid (rule 1, via the one new helper
`includesCallerEstimate`). Partial sets are never measured against either
whole-set rule. Full rationale: [D-027](docs/DECISIONS.md).

**UI**: opponent seats read `Target N · Taken M`, or an honest
`Target unknown · Taken M` when a seat's estimate is absent. The leading seat
keeps its `Led <suit>` line but no longer *instead* of its target and taken
counts — hiding those for the seat that opened the trick left the table
incomplete. South's own chips are unchanged. Verified in a browser at desktop
and 375px widths: no overflow, no console errors.

**Content**: all 17 bundled play scenarios now author a complete three-seat
set, each individually reviewed against its own lesson. Every set is
rule-valid (no seat over a supplied bid, some seat at the bid, no total of 13,
maximum at least the auction minimum of 4 even where `auction_bid` is absent,
no opponent at 0 which would be a Dash declaration). **No opponent is exactly
on target in any scenario** — the one state that would give the player a
reason to hand a seat a trick to break it, which this MVP does not teach. In
the five `play_target_protection_001`–`005` scenarios whose reviewed line
concedes the trick, North is authored so that trick does not complete North's
target (or, in `_003`, so North's target is already missed and the outcome is
inert), keeping the decision about South's own exact target; each choice is
recorded in that file's `author_notes`. Where the arithmetic left no neutral
option (a seat on 3 taken under a 4-trick bid can only be 4 to stay below
target), that is stated rather than resolved with an on-target value. **No
rating changed.** Per-scenario table and re-review:
[docs/COACHING_REVIEW.md](docs/COACHING_REVIEW.md).

**Tests** (+20, 358 total): `estimate_totals_test.dart` (+2) for
`includesCallerEstimate` directly; `play_situation_test.dart` (+4) for
absent/partial/full acceptance, immutable exposure, the excluded seat
following `playerPosition` across all four pending seats, the auction bound
including "With" and no bound without a bid, and both whole-set rules shown
not to fire on a partial set; `play_scenario_test.dart` (+8) for the
schema/parser round trip plus seven rejection cases; `play_training_test.dart`
(+2) asserting all 17 scenarios render a real `Target · Taken` for every
opponent including the leading seat, with no `Target unknown` anywhere, and
the honest fallback when a seat's estimate is removed.

Also corrected a stale row in `docs/GAME_RULES_V1.md`'s rule-status audit that
still claimed no trick-winner resolver existed anywhere in the app, which
D-025 had made untrue.

358 tests pass, analysis is clean, strict validation accepts all 33 content
files, and the web build succeeds. No coaching rating changed; no opponent
behavioral modeling, strategic objectives, or multi-trick simulation was
added — the trainer stays local, tactical and exact-target-aware. Coverage
matrix stays 32/32 (edits to existing scenarios, not new ones), the Variety
gate stays 0%, MVP Readiness stays 45%, EC-055 is not marked DONE, checkpoint
4 was not started. The owner's repeated-session review continues.

### Eighth bounded PR (this PR): concise coaching by default

A small owner-review UX improvement, not new capability: the post-decision
coaching was too verbose for the intended loop (*see table → decide → short
useful feedback → continue*). Both trainers showed the authored `title` **and**
the full `summary` immediately, with `points` behind a collapsed "Why?".

**Reported mismatch**: the suggested mapping (`summary` as the default
one-liner, first 1–2 `points` as default evidence) does not fit the existing
content. Measured across all 109 authored evaluations, play summaries reach
250 characters and three sentences (median 153) and first points reach 156
characters — that default would have shown ~350 characters of prose, *more*
verbose than before. Full measurements in [D-028](docs/DECISIONS.md).

**Decision**: use the field that already is short. The authored feedback
`title` (16–55 chars, median 33–40) is the default one-line verdict; the
`summary` and **all** `points` sit behind one `More detail · N points`
action. This required **no content change** — no new field, no parallel
feedback model, no rewriting, and no truncating or sentence-splitting of
authored prose in any widget. Only which authored field is shown when
changed, and the default is strictly shorter than before.

One shared `lib/shared/widgets/coaching_result_card.dart` renders this for
both the Play and Bid trainers, so the interaction cannot drift between them;
it takes resolved strings and knows nothing about scenario/evaluation types.
Each trainer owns the disclosure state explicitly and resets it on next
scenario, retry and Practice again.

The "at most 1–2 short points" part of the target shape is deliberately
satisfied as zero: no authored field is short enough to promote, and
length-thresholding points inside the widget would be the scenario-specific
truncation the task rules out. An evidence bullet in the compact view would
need a dedicated short authored field (~109 strings) as its own content task.
This also brings the implementation in line with what AGENTS.md section 5
already prescribed ("Long-form explanation should never interrupt the default
flow").

**Tests** (+8, 366 total): a new `test/shared/widgets/coaching_result_card_test.dart`
(5) covering the compact default, the point-count action label, expansion
revealing the complete authored coaching unaltered, collapsing again, and
singular/plural labelling; plus trainer-level tests for Play and Bid (3)
proving the default is collapsed, that no evidence point renders by default,
that expand/collapse works, and that expansion resets across next
scenario/hand, retry and Practice again. Existing assertions that relied on
the summary being visible now assert the headline instead and that the
summary is *not* shown. Verified in a browser: the compact result reads
rating → one-line verdict → `More detail · 3 points` → continue.

No rating, strategic meaning or authored text changed. Readiness stays 45%,
EC-055 is not closed, checkpoint 4 not started, and no trainer screen was
redesigned beyond this one panel.

### Acceptance criteria
- Deterministic variants are traceable to a reviewed base and seed/variant ID. ✅ (v1 mechanism)
- Each allowed transformation documents and preserves game/coaching invariants:
  legality, public evidence, target state, seat order and rating rationale. ✅ (v1 mechanism; see D-023 for what remains out of reach)
- Validate generated content before display; test invariant preservation and
  rejection of invalid variants. No arbitrary random card substitution or UI generation. ✅
- Establish and close a finite reviewed coverage matrix for bidding decisions
  and safe/probable, void-tracking and exact-target play concepts. Distinct
  tactical evidence counts as breadth; cosmetic variants alone do not. **Matrix
  complete: 32/32 scenarios authored.** ✅
- Record owner repeated-session review showing reasoning rather than answer recall.
  **In progress**: the owner's review has found and this project has fixed
  three genuine issues so far (`play_void_tracking_005`'s trick-winner
  inconsistency, D-025; its target-feasibility contradiction, D-026; and the
  incomplete public table, now carrying per-seat opponent estimates in all 17
  scenarios, D-027); the review itself continues — this is the only open
  acceptance criterion for EC-055.
- New scenarios using supported contracts remain content-only; no runtime AI. ✅

---

# Egyptian Arabic

## EC-060 — English / مصري language switch and Egyptian game terminology
**Status:** READY

Add an explicit language switch between English and Egyptian Arabic (مصري),
including everyday Egyptian phrasing and the owner's preferred game terms.
Checkpoint 6; follows the Training Hub. Includes focused UI/usability polish.

### Acceptance criteria
- Both languages can be selected in-app; the choice survives restart.
- Egyptian Arabic screens use RTL layout; card identity, seat positions and play
  order remain correct and do not change with display language.
- Translate navigation, controls, accessibility labels and authored coaching,
  including Why? evidence, with no runtime AI or translation service.
- Maintain a reviewed glossary for suits, ranks, trick, estimate/bid, trump,
  Dash, and Sans. Record owner confirmation; do not silently guess terms.
- Keep scenario IDs, rule codes, ratings and legal decisions language-independent.
- Keep translations in portable content and define missing-translation behavior.
- Test switching during training, saved preference, RTL, mixed numbers/card
  notation, small screens and large text. Include Arabic glyph rendering checks.
- Complete focused visual/usability polish for the actual training and hub flows;
  preserve suit/card identities, seat positions and canonical play order.

Requested 2026-09-08. The feature is planned; it is not enabled in the table preview.
Core glossary confirmed by the owner on 2026-09-08 in
`docs/EGYPTIAN_ARABIC.md`, including the auctionBid/trickEstimate distinction.
Rank names and other unlisted vocabulary will be reviewed during implementation.

---

# Milestone 5 — Personal Coaching

Historical grouping; these three tasks form frozen checkpoint 4 and follow EC-055.

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

## EC-053 — Training hub
**Status:** BACKLOG

Connect the MVP's training modes and personal progress in one simple home.
Depends on play training and EC-051/052; avoid presenting invented progress.

### Acceptance criteria
- Continue Training resumes a meaningful saved training position.
- Quick Mix combines supported bidding/play scenarios through the session selector.
- Bid Practice and Play Practice start their supported scenarios.
- Weak Areas leads to practice recommended from real decisions.
- Recent progress is visible and an empty-history state is honest and useful.
- Critical navigation and resume flows have widget tests.

## EC-054 — MVP acceptance and device verification
**Status:** BACKLOG

Validate the complete experience with the owner before declaring the MVP done.

### Acceptance criteria
- Agree the intended release device/target and verify the build there.
- Verify bidding, play, reviewed feedback, saved history/resume and recommendations.
- Verify English/مصري switching, Arabic glyphs, RTL, accessibility and small screens.
- Verify local training has no runtime AI dependency and required local assets work offline.
- Fix acceptance-blocking defects; record tested flows and remaining limitations.
- Owner completes repeated real sessions, not just one walkthrough, including
  varied practice, weak-area selection, resume and both languages. Record device,
  build, dates, issues and acceptance against every frozen Definition of Done criterion.
- Verify scenario variety requires reasoning rather than recall of a fixed order
  or answer; resolve MVP BLOCKER findings within the existing checkpoints.
- Only after owner acceptance and no open MVP BLOCKER, release `v1.0.0-mvp`.

---

# Post-MVP

All items here are classified **POST-MVP**, not MVP commitments. Promotion
requires evidence of blocking the frozen Definition of Done and explicit owner
approval of the scope change; see MVP_STATUS. Already-delivered scenario
validation tooling is not a remaining release prerequisite.

- AI-generated explanation variants
- AI-assisted scenario authoring
- additional scenario editor/authoring tooling
- adaptive difficulty
- daily challenge
- full round simulator
- opponent behavior profiles
- replay timeline
- cloud sync
- runtime AI
- backend/accounts
- multiplayer
- complete scoring and Risk scoring
- Mini/Micro orchestration
