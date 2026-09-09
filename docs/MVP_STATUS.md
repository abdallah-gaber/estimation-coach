# MVP Roadmap Lock

Updated 2026-09-09. **Runnable preview; not ready to ship.** Sixteen reviewed
bidding hands and seventeen play scenario files (16 distinct reasoning cases)
are available. EC-048 is merged; EC-043 has all five reviewed exact-target
scenarios. EC-049's Session Selector shuffles both practice sessions. EC-055
(checkpoint 3) has frozen a 32-scenario coverage target and reached it
(32/32) across three bounded PRs, and decided not to wire its domain-tested
variant mechanism into the product for the MVP (D-024). The owner's
repeated-session review is in progress and has found and fixed two genuine
correctness issues so far: a trick-winner inconsistency (D-025) and a
target-feasibility contradiction (D-026). A separate, non-optional
opponent-estimates contract PR is queued next. Progress storage, the hub
and English/مصري switching remain unfinished; the owner's review continuing
to a pass, plus that queued PR, are what's left to close checkpoint 3
itself.

[Task tracker](../PROJECT_TRACKER.md) owns individual task statuses. This page
owns the frozen finish order, release Definition of Done and readiness formula.
Historical milestone headings in the tracker do not define another roadmap.

## Frozen seven-checkpoint finish plan

Complete these checkpoints **in this order**. A checkpoint may use bounded PRs
to fit review/context limits; those PRs are not additional roadmap checkpoints.
Checkpoints 1 and 2 are complete. Checkpoint 3 (EC-055) is in progress: its
first bounded PR froze the coverage target and proved the variant mechanism
at the domain level; its second bounded PR closed 6 of the 13 base-scenario
gaps; its third closed the remaining 7 (32/32, matrix complete); its fourth
decided not to wire the variant mechanism into the product (D-024) and
prepared the owner repeated-session review; its fifth fixed a real
game-state inconsistency the owner's review found (D-025); its sixth fixed
a target-feasibility contradiction the same review found (D-026). That
review, continuing to a pass, plus a queued opponent-estimates contract PR,
are what's still open.

| # | Checkpoint | Tasks | Status | Exit criteria |
| --- | --- | --- | --- | --- |
| 1 | Finish EC-043 | EC-043 | DONE — 5/5 scenarios | Two final scenarios add undertrumping evidence and a choice between safe winners in Sans. Content-only, existing contract, complete legal-choice coaching and documented review. |
| 2 | Anti-memorization sessions | EC-049 | DONE | A pure `selectSession` shuffles the eligible pool with an injected `Random`; `ScenarioSession` composes it with catalog loading, caching and previous-session-last tracking. Both trainers consume one `nextSession` call; "Practice again" requests a new order. Reproducible under test with controlled seeds; empty/single-item/exhausted pools have explicit behavior. |
| 3 | Scenario Variants + Content Breadth | EC-055 | IN PROGRESS — owner review underway | Controlled deterministic variants preserve reviewed invariants and pass validation. A reviewed coverage matrix demonstrates distinct reasoning situations across bidding and the three MVP play concepts; variants alone do not count as new reasoning breadth. Owner repeated practice confirms variety requires reasoning, not answer recall. |
| 4 | Personal Coaching | EC-050/051/052 | BACKLOG | Decisions persist locally across restart, map to documented skills, aggregate deterministically, and drive targeted weak-area practice. |
| 5 | Training Hub | EC-053 | BACKLOG | Quick Mix, Bid Practice, Play Practice, Weak Areas and Continue are usable, including honest empty states and meaningful saved-session resume. |
| 6 | Egyptian Arabic + UI polish | EC-060 | READY — after checkpoint 5 | English and مصري navigation/coaching, persisted preference, RTL and confirmed terminology work reliably. Focused visual, accessibility and usability polish preserves card identities and canonical seat order. |
| 7 | MVP Acceptance | EC-054 | BACKLOG | Owner completes repeated real sessions on the intended device, acceptance-blocking defects are fixed, evidence is recorded against every criterion below, then release `v1.0.0-mvp`. |

No eighth checkpoint may be added without explicit owner approval. Closing a
checkpoint requires updating this page, the tracker, README current focus and
readiness SVG together. Test success alone does not close a product checkpoint.

## MVP Definition of Done

MVP is done **only when all** of these hold:

- Bid and Play practice are both usable.
- Repeated sessions do not expose a fixed memorized order.
- Sufficient scenario variety requires reasoning rather than answer recall.
- Reviewed deterministic coaching explains the evidence behind decisions.
- Progress persists locally.
- Weak Areas can select targeted practice.
- English and مصري work reliably.
- The owner completes repeated real sessions on the intended device without an
  MVP-blocking issue.

Acceptance evidence must record the build/commit, intended device and OS,
language, session dates/modes, observed issues and their disposition. The owner
must confirm repeated use, including both languages and weak-area/resume flows;
a scripted test or a single successful walkthrough is insufficient. The intended
device is not yet recorded and must be confirmed during acceptance planning.

## Anti-memorization is an MVP requirement

> Replaying the current small fixed packs causes the player to remember scenario answers instead of reasoning from the table.

The intended architecture is:

```text
Scenario Catalog → Session Selector → Optional Validated Variant Generator → existing trainer UI
```

The Session Selector stage is implemented (EC-049,
[D-022](DECISIONS.md)):
it owns session order, independent of asset filenames, avoids immediate
repeats within a session, and avoids starting a new session with the previous
session's last scenario across session boundaries when the eligible pool
allows an alternative. An empty pool returns an empty session; a single-item
pool necessarily repeats. Tests use controlled seeds to prove reproducibility
and different valid session orders.

The optional variant stage means not every scenario must be transformed.
Supported transformations are deterministic from a base scenario and seed or
variant identifier, validated before presentation, and traceable to the reviewed
base. Review must state which game and coaching invariants each transformation
preserves: legality, visible evidence, target state, seat order and the rationale
for every rating. **No arbitrary random card substitution.** The UI must neither
randomize cards nor contain scenario-generation logic.

Variant mechanism v1 is implemented and domain-tested, not yet wired into
either trainer (EC-055 first bounded PR,
[D-023](DECISIONS.md)):
`generateTricksTakenVariant` (`lib/scenarios/scenario_variant.dart`)
redistributes the three non-player seats' shares of the completed-trick
total, the only field checked to be both schema-validated and never quoted
by exact value in any of the 20 production scenarios' feedback text. Card,
rank, suit and seat substitution were all found unsafe against the current
free-text feedback contract — see D-023 for the full audit. UI integration
waits for either a second, independent transformation or a move toward
structured feedback content.

### Checkpoint 3 coverage matrix (EC-055)

Frozen MVP target, owner-set 2026-09-09: **32 reviewed base scenarios**
(16 bidding + 16 play), not an open-ended backlog. Do not raise these numbers
without explicit owner approval. A scenario counts toward a category only
where it genuinely covers a distinct reasoning case — matching content to a
category name is not sufficient by itself.

Updated 2026-09-09 (checkpoint 3's second bounded PR): **+6 base scenarios**
closing the highest-value gaps identified by the first bounded PR. No variant
transformations, schema, or UI changes in this PR.

Updated again 2026-09-09 (checkpoint 3's third bounded PR): **+7 base
scenarios**, closing every remaining gap. **32/32 — the coverage matrix is
now complete.** No variant, schema, or UI changes in this PR either; see
"Checkpoint 3 remains open" below for what still gates closing EC-055 itself.

**Bidding — 16 target, 16 achieved**

| Category | Target | Achieved | Scenario IDs (newest in bold) |
| --- | ---: | ---: | --- |
| Dash / Enter | 5 | 5 | `bid_enter_controls_001`, `bid_training_003`, `_004`, `_005`, `_011` |
| Bid sizing | 4 | 4 | `bid_safe_probable_001`, `bid_training_012`, `_013`, **`_015`** |
| Trump selection/control | 4 | 4 | `bid_training_006`, `_007`, `_008`, `_010` |
| Mixed/ambiguous bidding judgment | 3 | 3 | `bid_training_009`, `_014`, **`_016`** |
| **Bidding total** | **16** | **16** | |

- `bid_training_015` ("Seven Clubs, only one honor") is the third bid_sizing
  scenario: a long (seven-card) suit with only one honor, testing length
  without concentration — a different profile from `_012`'s short-but-solid
  six-card run and `_013`'s moderate five-card suit with side Aces.
- `bid_training_016` ("Length with a gap, or short and solid?") is the third
  Mixed/ambiguous scenario (after `_009` and `_014`): a five-card Spade suit
  with a missing King (real risk, more length) against a four-card Heart
  suit with a complete Ace-King sequence (no risk, less length) — a
  risk-versus-length tension neither `_009` (spread, no length anywhere) nor
  `_014` (two similarly-shaped moderate candidates) tests. No evaluation
  reaches Strong.

**Play — 16 target, 16 achieved**

| Category | Target | Achieved | Scenario IDs (newest in bold) |
| --- | ---: | ---: | --- |
| Safe vs probable | 4 | 4 | `play_safe_probable_001`, `_002`, `_003`, **`_004`** |
| Void tracking / table reading | 4 | 4 | `play_void_tracking_001`, `_002`, `_004`, **`_005`** |
| Exact-target protection | 6 | 6 | `play_target_protection_001`–`_005`, **`_006`** |
| Mixed tactical reading | 2 | 2 | **`play_mixed_tactical_001`**, **`_002`** |
| **Play total** | **16** | **16** | |

- `play_safe_probable_004` ("Two unknowns instead of one") escalates `_003`
  rather than repeating it: South acts second, with **two** seats (not one)
  still to act, a genuinely greater degree of uncertainty than `_003`'s
  single unresolved responder.
- `play_void_tracking_005` ("Leading around a known void") is the first
  void-tracking scenario where South leads (current trick empty) rather than
  responds — a structurally distinct decision (which suit to lead around a
  known void) from `_001`/`_002`/`_004`, all of which respond mid-trick.
- `play_target_protection_006` ("Either trump wins — save the stronger one")
  is a facet none of `_001`–`_005` cover: choosing between two of South's
  own legal trumps that both currently win, not deciding whether to win at
  all. The lesson is trump conservation, distinct from `_004`'s undertrumping
  (avoiding an unwanted win) and `_005`'s Sans winner choice.
- `play_mixed_tactical_001`/`_002` are the two Mixed tactical reading
  scenarios, each combining two already-supported signals in one decision
  with an explicit decisive-vs-supporting split in the feedback (no new
  capability was added to produce them):
  - `_001` ("Below target, and a known void backs the play"): **decisive** —
    East's known void in trump (derived from an observed trick, the same
    mechanism as `play_void_tracking_001`/`_005`) means East cannot
    overtrump, elevating the play from merely probable (as in
    `play_safe_probable_003`/`_004`) to effectively certain. **Supporting**
    — South is below target and needs this trick, which is why taking it
    deliberately is the reviewed choice.
  - `_002` ("The same visible trump, an opposite target"): reuses
    `play_target_protection_004`'s exact mechanism (an opponent's trump
    already visible in the current trick) but **decisive** — South is below
    target here rather than exactly on it, so overtrumping is correct where
    `_004`'s undertrumping was correct. **Supporting** — the visible trump
    only establishes what card is needed to win, not whether winning is
    wanted.
- `play_void_tracking_003` ("The same trap in a different suit") still does
  **not** count as a distinct case — unchanged from the first bounded PR's
  finding: its own `author_notes` call it a suit-relabeled repeat of
  `play_void_tracking_001`.

**Total: 32 target, 32 achieved.** All three bounded PRs together: 19 → 25 →
32 distinct scenarios (13 → 7 → 0 gap). Every new scenario across all three
PRs is a genuinely distinct reasoning case, verified against existing content
before authoring, not a suit/rank reskin. Content-only across all three PRs;
no schema, UI, variant-mechanism, or selection changes.

### Variant mechanism: decided, not wired

[D-024](DECISIONS.md) makes this final for the MVP rather than leaving it
open: **variant v1 (opponent taken-trick-count redistribution) stays
domain-tested only and is not wired into either trainer.** It varies one
field players do not reason from when choosing a card; the coverage matrix
above and the Session Selector (EC-049) are the mechanisms actually expected
to carry this checkpoint's anti-memorization requirement. This is a scope
decision, not a quality verdict — `generateTricksTakenVariant` and
`PlayScenario.withTricksTaken` remain correct, tested, and available. The
architecture extension point stays documented exactly as designed (see
above) for a future, richer variant, without adding a second transformation
now or changing the schema/feedback structure to enable one prematurely.

### Checkpoint 3 owner repeated-session review

With the variant decision made and the coverage matrix complete, **the
owner's repeated-session review is the only remaining item closing
checkpoint 3.** No automated check can substitute for it. The product now
has 16 bidding scenarios, 17 play scenario files (32 distinct reviewed
reasoning cases), a shuffled session order (EC-049) that avoids an
avoidable immediate repeat at a session boundary, and a variant mechanism
deliberately left unwired (above). The owner should play multiple full
practice sessions (both Bid Practice and Play Practice, more than once
each, including at least one "Practice again" restart) and judge:

1. Do I still recognize answers mainly from scenario position/order, or has
   the shuffle broken that?
2. Do I need to read the actual cards/table state before deciding, or can I
   answer without looking?
3. Do repeated sessions feel meaningfully different because of shuffled
   order and broader reasoning coverage?
4. Are any scenarios so similar to each other that I answer from memory
   without reasoning? (Name them if so — that is a coverage-matrix gap, not
   a bug.)
5. Do Bidding and Play both feel sufficiently varied for the MVP, or does
   one side feel thinner than the other?

Record the result here (pass/fail per question, with any named
look-alike scenarios) once the owner completes it. A "pass" on all five
closes checkpoint 3 and the Variety gate; a "fail" on any of them is
specific, actionable feedback — likely a coverage-matrix gap (an additional
distinct scenario needed) rather than a defect in what already exists. Test
success alone does not satisfy this criterion.

**Review log** (append an entry per pass; do not overwrite prior entries):

- **Pass 1, 2026-09-09** — In progress. Found one genuine game-state
  inconsistency, not a coaching-wording issue: `play_void_tracking_005`'s
  observed trick was actually won by West (a trump), not South, contradicting
  the authored leader. Fixed with the smallest content change that preserves
  the lesson, plus a small pure `trickWinner` helper for content authors and
  a targeted regression test for that one scenario — deliberately not a
  generic validation rule, since `observed_tricks` is not guaranteed
  contiguous with the current trick (see [D-025](DECISIONS.md) for why).
- **Pass 1 continued, 2026-09-09** — Found a second, systemic issue: opponent
  estimates are not shown at all (question 2's "sufficiently varied" is hard
  to fully judge without them — scoped as its own required follow-up, not
  post-MVP), and — the correctness blocker fixed in this pass —
  `play_void_tracking_005` again: its void-avoidance heuristic recommended a
  card (4D) with no case for winning at all over the Ace, in a state where
  South needed *both* remaining tricks. Audited all 17 scenarios; 5 of 6
  `mustWinAll` scenarios were already correct, this was the one exception.
  Fixed by rebalancing `tricks_taken` (South 2→3, North 3→2, sum unchanged)
  so the scenario genuinely has slack instead of needing every remaining
  trick — no card or rating changed. Added `classifyTargetFeasibility`
  (see [D-026](DECISIONS.md)) plus regression coverage across all 17
  scenarios. The five questions above have not yet been answered
  end-to-end; the review continues, and the opponent-estimates contract
  extension is queued as a separate bounded PR next.
- **Pass 1 continued, 2026-09-09** — Delivered the queued opponent-estimates
  follow-up, then corrected it in the same review round. The first version
  added an optional `opponent_estimates` field but authored it in none of the
  17 scenarios, so the trainer still showed `Target unknown` for every
  opponent — the same incomplete table the review had flagged. Owner review
  rejected that reasoning: these are authored synthetic game states, and an
  opponent's target is missing public state to author, like the cards and
  taken counts already authored. **All 17 scenarios now carry a complete
  three-seat estimate set**, each re-reviewed against its own lesson with the
  targets visible; no rating changed, and no opponent is authored exactly on
  target (the one state that would invite opponent-punishing play). The
  contract was also generalized: the schema accepts any seat name and the
  domain excludes whichever seat is `player_position`, rather than assuming
  South, and three previously unchecked game_rules_v1 estimate rules (the
  per-seat bid bound, some seat matching the winning bid in a complete set,
  and the total-13 rule) are now enforced. See [D-027](DECISIONS.md) and the
  per-scenario table in [COACHING_REVIEW.md](COACHING_REVIEW.md). Question 2
  above ("do I need to read the actual table state?") can now genuinely be
  judged, since the table finally shows the full public state. The five
  questions above still have not been answered end-to-end; the review
  continues.

This criterion is not satisfied by the PR that added this log: it remains
prepared and in progress, not completed. The Variety gate stays at 0% and
MVP Readiness stays at 45% until the owner explicitly records a pass on all
five questions here.

## Fixed weighted readiness gates

This is **MVP Readiness to Ship**, not effort spent, feature count or a calendar
estimate. Each gate earns its full fixed weight only when all its exit evidence
is satisfied; otherwise it earns zero. No subjective partial percentages.

| Gate | Weight | Earned | Completion evidence / remaining condition |
| --- | ---: | ---: | --- |
| Foundation / architecture | 15% | 15% | EC-001/002/010/012/020/021/022/023/026 and portable content/domain separation delivered; required CI exists. |
| Bidding Coach | 15% | 15% | EC-030/031/032/033 delivered: the original ten reviewed hands, 53 evaluated choices, visual legal decisions and evidence-based feedback. Content added since (EC-055) belongs to the variety gate. |
| Play Coach core | 15% | 15% | EC-040/041/044/045/046/047/042/048 delivered: legal card play, portable scenarios, reviewed feedback, void evidence and known auction-bound validation. EC-043 content belongs to the variety gate. |
| Variety / anti-memorization | 20% | 0% | Requires checkpoints 1–3 closed. Checkpoints 1 and 2 are complete; 3 remains open. Session selection is delivered, the 32/32 coverage matrix is complete, and the variant mechanism decision is made (D-024, not wired); the owner's repeated-session review (two correctness fixes landed so far, D-025/D-026) and a queued opponent-estimates contract PR still gate closing checkpoint 3. |
| Personal coaching | 15% | 0% | Checkpoint 4 closed: persistence, skill aggregation and targeted weak-area practice. |
| Training hub + localization/polish | 10% | 0% | Both checkpoints 5 and 6 closed. |
| Acceptance / ship | 10% | 0% | Checkpoint 7's Definition of Done evidence, owner acceptance and release tag `v1.0.0-mvp` recorded. |
| **Total** | **100%** | **45%** | **15 + 15 + 15 + 0 + 0 + 0 + 0 = 45%.** |

The repository-owned [readiness SVG](assets/mvp-readiness.svg) displays that sum:
a 600-unit track contains 270 filled units (`600 × 45 / 100`), divided into
three earned 90-unit segments. The remaining gate widths are 120, 90, 60 and
60. On a gate closure, recalculate earned weights and update the SVG's text,
accessible description and segments in the same docs change. Weights are frozen;
changing them or the finish plan requires explicit owner approval recorded in
[DECISIONS.md](DECISIONS.md).

The README's GitHub Actions badge separately reports **main CI/build state**.
Green CI means format, analysis, tests, strict content validation and web build
passed; it is not owner acceptance or readiness credit by itself.

## Discovery and scope policy

Every newly discovered item must be classified in the tracker as:

- **MVP BLOCKER** — a correctness/usability issue that demonstrably prevents a
  specific Definition of Done criterion. Record the criterion, reproduction or
  evidence, and the existing checkpoint that will resolve it.
- **POST-MVP** — everything else; this is the default.

A blocker is handled within an existing checkpoint, not by silently extending
the roadmap. If the frozen plan cannot accommodate it, request explicit owner
approval for a scope change before adding another checkpoint. A blocker found
after a gate closes reopens the affected gate and removes its earned weight
until resolved. Preserve evidence rather than claiming completion prematurely.

Runtime AI, backend/accounts, multiplayer, full-round simulation, complete
scoring, Risk scoring, Mini/Micro orchestration and cloud sync are explicitly
**POST-MVP** unless later promoted with evidence that they block this Definition
of Done and explicit owner approval of the scope change. They are not
prerequisites for single-decision coaching or the release.
