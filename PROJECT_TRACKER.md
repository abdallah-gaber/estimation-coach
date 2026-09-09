# PROJECT_TRACKER.md

This file is the repository-level source of truth for planned and active work.
For milestone status and the remaining release path, see [MVP_STATUS.md](docs/MVP_STATUS.md).

## Frozen MVP finish order

The remaining MVP has exactly **seven checkpoints**, in the order below.
These supersede the historical milestone groupings later in this file.
Bounded PRs may split a checkpoint's implementation, but cannot add an eighth
checkpoint without explicit owner approval. Checkpoint 1 is complete;
next focus is checkpoint 2 (EC-049), which has not started.

| Order | Checkpoint | Tasks | Status |
| --- | --- | --- | --- |
| 1 | Finish EC-043 — two remaining reviewed exact-bid-protection scenarios; content-only | EC-043 | DONE (5/5 scenarios) |
| 2 | Anti-memorization sessions — shuffled selection, no immediate repeats, order independent of catalog/files | EC-049 | BACKLOG |
| 3 | Scenario Variants + Content Breadth — controlled deterministic variants and sufficient reviewed reasoning variety | EC-055 | BACKLOG |
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
**Status:** BACKLOG
**Roadmap:** Checkpoint 2; after completing EC-043.

Replaying the current small fixed packs causes the player to remember scenario
answers instead of reasoning from the table.

### Acceptance criteria
- Session Selector chooses a shuffled order independently of catalog/filename order.
- No immediate repeats within or between sessions when another eligible scenario
  exists; explicit behavior for empty, single-item and exhausted pools.
- Controlled seeds make selection reproducible in tests; verify different valid
  orders and preserve scenario legality/feedback unchanged.
- Existing trainer UI consumes selected scenarios without randomizing cards or
  owning generation logic. No runtime AI dependency.

## EC-055 — Scenario Variants + Content Breadth
**Status:** BACKLOG
**Roadmap:** Checkpoint 3; after EC-049.

Architecture: `Scenario Catalog → Session Selector → Optional Validated Variant
Generator → existing trainer UI`.

### Acceptance criteria
- Deterministic variants are traceable to a reviewed base and seed/variant ID.
- Each allowed transformation documents and preserves game/coaching invariants:
  legality, public evidence, target state, seat order and rating rationale.
- Validate generated content before display; test invariant preservation and
  rejection of invalid variants. No arbitrary random card substitution or UI generation.
- Establish and close a finite reviewed coverage matrix for bidding decisions
  and safe/probable, void-tracking and exact-target play concepts. Distinct
  tactical evidence counts as breadth; cosmetic variants alone do not.
- Record owner repeated-session review showing reasoning rather than answer recall.
- New scenarios using supported contracts remain content-only; no runtime AI.

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
