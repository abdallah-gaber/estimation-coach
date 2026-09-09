# MVP Roadmap Lock

Updated 2026-09-09. **Runnable preview; not ready to ship.** Ten reviewed bidding
hands and eight play scenarios are available. EC-048 is merged; EC-043 has three
of its five exact-target scenarios. Progress storage, varied sessions, the hub
and English/مصري switching remain unfinished.

[Task tracker](../PROJECT_TRACKER.md) owns individual task statuses. This page
owns the frozen finish order, release Definition of Done and readiness formula.
Historical milestone headings in the tracker do not define another roadmap.

## Frozen seven-checkpoint finish plan

Complete these checkpoints **in this order**. A checkpoint may use bounded PRs
to fit review/context limits; those PRs are not additional roadmap checkpoints.
This documentation lock does not start checkpoint 1.

| # | Checkpoint | Tasks | Status | Exit criteria |
| --- | --- | --- | --- | --- |
| 1 | Finish EC-043 | EC-043 | IN PROGRESS — 3/5 scenarios | Add only the two remaining reviewed exact-bid-protection scenarios. Content-only, existing contract, complete legal-choice coaching and review rationale; strict validation passes. |
| 2 | Anti-memorization sessions | EC-049 | BACKLOG | Shuffled selection, no immediate repeats, and session order independent of catalog/file order. Selector is reproducible under test and handles small/exhausted pools explicitly. |
| 3 | Scenario Variants + Content Breadth | EC-055 | BACKLOG | Controlled deterministic variants preserve reviewed invariants and pass validation. A reviewed coverage matrix demonstrates distinct reasoning situations across bidding and the three MVP play concepts; variants alone do not count as new reasoning breadth. Owner repeated practice confirms variety requires reasoning, not answer recall. |
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

The selector owns session order, independent of asset filenames. It must avoid
immediate repeats within a session and across session boundaries when the
eligible pool allows an alternative. Define an explicit empty/single-item policy
rather than pretending a repeat can always be avoided. Tests should use
controlled seeds to prove reproducibility and different valid session orders.

The optional variant stage means not every scenario must be transformed.
Supported transformations are deterministic from a base scenario and seed or
variant identifier, validated before presentation, and traceable to the reviewed
base. Review must state which game and coaching invariants each transformation
preserves: legality, visible evidence, target state, seat order and the rationale
for every rating. **No arbitrary random card substitution.** The UI must neither
randomize cards nor contain scenario-generation logic.

Checkpoint 3 must record a finite reviewed coverage matrix of bidding decisions
and the MVP play concepts (safe/probable tricks, void tracking, exact-target
protection). Distinct evidence and tactical contrasts count as breadth; cosmetic
suit changes alone do not. Identify recall-prone gaps, close that matrix, and
record the owner's repeated-session review before closing the checkpoint.
Any new capability is implemented once; new scenarios using supported contracts
remain content-only. No runtime AI is needed for selection, variants or coaching.

## Fixed weighted readiness gates

This is **MVP Readiness to Ship**, not effort spent, feature count or a calendar
estimate. Each gate earns its full fixed weight only when all its exit evidence
is satisfied; otherwise it earns zero. No subjective partial percentages.

| Gate | Weight | Earned | Completion evidence / remaining condition |
| --- | ---: | ---: | --- |
| Foundation / architecture | 15% | 15% | EC-001/002/010/012/020/021/022/023/026 and portable content/domain separation delivered; required CI exists. |
| Bidding Coach | 15% | 15% | EC-030/031/032/033 delivered: ten reviewed hands, 53 evaluated choices, visual legal decisions and evidence-based feedback. Variety is assessed separately. |
| Play Coach core | 15% | 15% | EC-040/041/044/045/046/047/042/048 delivered: legal card play, portable scenarios, reviewed feedback, void evidence and known auction-bound validation. The remaining EC-043 content belongs to the variety gate. |
| Variety / anti-memorization | 20% | 0% | Checkpoints 1–3 closed: complete exact-target pack, independent session selection, validated variants and owner-reviewed content breadth. |
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
