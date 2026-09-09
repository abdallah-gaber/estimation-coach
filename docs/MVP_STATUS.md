# MVP Roadmap Lock

Updated 2026-09-09. **Runnable preview; not ready to ship.** Fourteen reviewed
bidding hands and twelve play scenarios are available. EC-048 is merged;
EC-043 has all five reviewed exact-target scenarios. EC-049's Session Selector
shuffles both practice sessions. EC-055 (checkpoint 3) has frozen a
32-scenario coverage target, closed 6 of the 13 gaps identified by its first
bounded PR (7 remain), and proven a variant mechanism at the domain level.
Progress storage, the remaining scenario variety, the hub and English/مصري
switching remain unfinished.

[Task tracker](../PROJECT_TRACKER.md) owns individual task statuses. This page
owns the frozen finish order, release Definition of Done and readiness formula.
Historical milestone headings in the tracker do not define another roadmap.

## Frozen seven-checkpoint finish plan

Complete these checkpoints **in this order**. A checkpoint may use bounded PRs
to fit review/context limits; those PRs are not additional roadmap checkpoints.
Checkpoints 1 and 2 are complete. Checkpoint 3 (EC-055) is in progress: its
first bounded PR froze the coverage target and proved the variant mechanism
at the domain level; its second bounded PR closed 6 of the 13 base-scenario
gaps (7 remain).

| # | Checkpoint | Tasks | Status | Exit criteria |
| --- | --- | --- | --- | --- |
| 1 | Finish EC-043 | EC-043 | DONE — 5/5 scenarios | Two final scenarios add undertrumping evidence and a choice between safe winners in Sans. Content-only, existing contract, complete legal-choice coaching and documented review. |
| 2 | Anti-memorization sessions | EC-049 | DONE | A pure `selectSession` shuffles the eligible pool with an injected `Random`; `ScenarioSession` composes it with catalog loading, caching and previous-session-last tracking. Both trainers consume one `nextSession` call; "Practice again" requests a new order. Reproducible under test with controlled seeds; empty/single-item/exhausted pools have explicit behavior. |
| 3 | Scenario Variants + Content Breadth | EC-055 | IN PROGRESS — 25/32 base scenarios | Controlled deterministic variants preserve reviewed invariants and pass validation. A reviewed coverage matrix demonstrates distinct reasoning situations across bidding and the three MVP play concepts; variants alone do not count as new reasoning breadth. Owner repeated practice confirms variety requires reasoning, not answer recall. |
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

**Bidding — 16 target**

| Category | Target | Before | After | Scenario IDs (new in bold) | Gap after |
| --- | ---: | ---: | ---: | --- | ---: |
| Dash / Enter | 5 | 4 | 5 | `bid_enter_controls_001`, `bid_training_003`, `_004`, `_005`, **`_011`** | 0 |
| Bid sizing | 4 | 1 | 3 | `bid_safe_probable_001`, **`bid_training_012`**, **`_013`** | 1 |
| Trump selection/control | 4 | 4 | 4 | `bid_training_006`, `_007`, `_008`, `_010` | 0 |
| Mixed/ambiguous bidding judgment | 3 | 1 | 2 | `bid_training_009`, **`_014`** | 1 |
| **Bidding total** | **16** | **10** | **14** | | **2** |

- `bid_training_011` ("Nothing above a six") is the first Dash/Enter scenario
  where Dash itself is rated Strong: no card above a six anywhere, no suit
  over four cards, deliberately lower and shorter than `bid_training_003`'s
  "reasonable" low hand.
- `bid_training_012`/`_013` are the first two dedicated bid_sizing scenarios
  besides `bid_safe_probable_001`, each offering only **one** trump so the
  decision is purely a trick-count judgment, not a trump comparison: a
  near-solid six-card Spade run (`_012`) and a moderate five-card Heart
  suit backed by two side Aces (`_013`) — deliberately different strength
  profiles.
- `bid_training_014` is the second Mixed/ambiguous scenario (see
  `bid_training_009` for the first): two genuinely comparable four-card
  trump candidates (King-Queen of Spades vs. Ace-Jack of Hearts) with no
  side-suit help anywhere else in the hand. No evaluation reaches Strong.
  Its `primary_skill` stays `trump_selection` (no dedicated tag exists yet);
  the Mixed/ambiguous classification is a coverage-matrix judgment recorded
  here, same as `bid_training_009`.

**Play — 16 target**

| Category | Target | Before | After | Scenario IDs (new in bold) | Gap after |
| --- | ---: | ---: | ---: | --- | ---: |
| Safe vs probable | 4 | 2 | 3 | `play_safe_probable_001`, `_002`, **`_003`** | 1 |
| Void tracking / table reading | 4 | 2 | 3 | `play_void_tracking_001`, `_002`, **`_004`** | 1 |
| Exact-target protection | 6 | 5 | 5 | `play_target_protection_001`–`_005` | 1 |
| Mixed tactical reading | 2 | 0 | 0 | — | 2 |
| **Play total** | **16** | **9** | **11** | | **5** |

- `play_safe_probable_003` ("A likely trump winner, not a certain one") is
  the first safe_vs_probable scenario where South does not act last: East
  still plays after South, so the strongest legal card is genuinely
  *probable*, not certain — unlike `_001`/`_002`, where South is always
  last and the win is guaranteed. No void or other resolving evidence is
  given; the uncertainty is deliberately left open.
- `play_void_tracking_004` ("A known void that doesn't apply here") is a
  boundary-condition case, not a suit reskin: South leads last in this
  trick (order East→North→West→South), so a shown void (North, an earlier
  Diamonds trick) cannot matter here for two independent reasons — wrong
  suit, and North has already acted this trick regardless. `_001`/`_002`
  both depend on East still acting after South; this scenario tests
  recognizing when that condition does *not* hold.
- `play_void_tracking_003` ("The same trap in a different suit") still does
  **not** count as a fourth distinct case — see the first bounded PR's
  finding, unchanged by this PR: its own `author_notes` call it a
  suit-relabeled repeat of `play_void_tracking_001`.

**Total: 32 target, 19 → 25 distinct existing (+6), 13 → 7 gap.** Remaining
base scenarios needed: 1 Bid sizing, 1 Mixed/ambiguous bidding, 1 Safe vs
probable, 1 Void tracking/table reading, 1 Exact-target protection, 2 Mixed
tactical reading (category shape still undefined). Content-only; no schema,
UI, variant or selection changes in this PR.

Identify recall-prone gaps, close this matrix, and record the owner's
repeated-session review before closing the checkpoint. Any new capability is
implemented once; new scenarios using supported contracts remain
content-only. No runtime AI is needed for selection, variants or coaching.

## Fixed weighted readiness gates

This is **MVP Readiness to Ship**, not effort spent, feature count or a calendar
estimate. Each gate earns its full fixed weight only when all its exit evidence
is satisfied; otherwise it earns zero. No subjective partial percentages.

| Gate | Weight | Earned | Completion evidence / remaining condition |
| --- | ---: | ---: | --- |
| Foundation / architecture | 15% | 15% | EC-001/002/010/012/020/021/022/023/026 and portable content/domain separation delivered; required CI exists. |
| Bidding Coach | 15% | 15% | EC-030/031/032/033 delivered: the original ten reviewed hands, 53 evaluated choices, visual legal decisions and evidence-based feedback. Content added since (EC-055) belongs to the variety gate. |
| Play Coach core | 15% | 15% | EC-040/041/044/045/046/047/042/048 delivered: legal card play, portable scenarios, reviewed feedback, void evidence and known auction-bound validation. EC-043 content belongs to the variety gate. |
| Variety / anti-memorization | 20% | 0% | Requires checkpoints 1–3 closed. Checkpoints 1 and 2 are complete; 3 remains open. Session selection is delivered; no credit yet for validated variants or broader reviewed content. |
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
