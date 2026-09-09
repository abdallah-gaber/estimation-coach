# DECISIONS.md

Important product and technical decisions should be recorded here so that future contributors and coding agents do not depend on hidden chat context.

---

## D-001 — MVP is visual-first

**Status:** Accepted

The app is a visual training experience.

Default player answers must use visual/tap interactions rather than free-text reasoning.

Long written explanations are secondary and optional.

---

## D-002 — Runtime AI is not required for MVP

**Status:** Accepted

The deterministic game/scenario engine is the source of truth.

The MVP should work without:
- OpenAI API;
- Claude API;
- Gemini API;
- any other LLM endpoint.

AI may later improve explanation or scenario-authoring workflows, but it must not become the authoritative judge of card rules.

---

## D-003 — Local-first MVP

**Status:** Accepted

The MVP has no backend, authentication or cloud dependency.

Progress may be stored locally.

---

## D-004 — Scenario quality before feature count

**Status:** Accepted

When time is limited, prioritize:

1. high-quality training scenarios;
2. clear visual interaction;
3. additional features.

---

## D-005 — First runnable checkpoint is the Flutter bootstrap

**Status:** Accepted

The initial `main` contains the supplied documents, schema and draft content.
`chore/flutter-bootstrap` adds a minimal launch screen for user testing before
feature implementation. It was reviewed and merged through PR #1. Android, iOS, macOS
and web runners are generated; web is the first validated target. The browser
runner is a convenient local Flutter test target, not a hosted product.

Use Flutter's built-in widgets and state mechanisms; no state-management package
is needed yet. Add the domain and feature directories when implementation begins.
Keep machine-specific signing teams out of the shared iOS project.

The supplied scenario is a draft, with incomplete choice evaluations and a note
requiring agreed-rule review. Do not expose it as trusted coaching before EC-022,
EC-023 and the rules clarification task are complete.

## D-006 — Small reusable card surface with a temporary preview

**Status:** Accepted

EC-011 introduces `shared/widgets/playing_card.dart` and a small set of spacing,
color and card typography values in `app/visual_tokens.dart`. App text continues
to use Material's text theme. Selection is caller-owned, and a null tap callback
makes a card unavailable. The widget announces full card identity and state,
supports keyboard focus, and respects the reduced-motion setting for selection.

`features/visual_preview/` provides four UI specimens with local `setState`.
They are not scenario content and do not claim to model a legal hand or evaluate
a decision. `SuitVisual` only supplies display metadata; card equality, deck,
hand and rules remain EC-020/EC-021 work. The domain can later map suits to this
presentation widget. No state-management package or runtime dependency is added.

Cards wrap rather than overlap so the preview remains tappable on phones. Card
faces scale with text size. The preview will be replaced by the training hub
when the first scenario is ready; authored scenarios remain portable content.

## D-007 — Immutable card domain and presentation mapping

**Status:** Accepted

`core/cards/cards.dart` is pure Dart with no Flutter dependency. `Suit`, `Rank`
and `GameCard` encode card identities. A card compares by rank and suit, with a
matching hash code. Strict parsing accepts only the uppercase v1 notation;
whitespace, lowercase, jokers and alternate ten notation are rejected with
`FormatException`. Content errors should be visible to future validators.

`Hand` snapshots 0–13 distinct cards, including partial/empty hands during play.
It preserves input order for rendering but compares and hashes by membership.
Duplicate cards and oversized hands throw `ArgumentError` in release builds too.
Its exposed list and the deterministic `standardDeck()` list are immutable.
Deck enumeration is suit then rank; it does not define bidding precedence,
shuffle behavior, dealing or trick-winner rules.

`PlayingCard` now takes one `GameCard`; presentation extensions in
`shared/widgets/card_labels.dart` provide labels, symbols and suit color.
This replaces the temporary `SuitVisual` metadata described in D-006. The preview
still uses four UI specimens with the same behavior. EC-021 will add legality;
EC-024 remains the prerequisite for resolving bidding-rule ambiguity.

## D-008 — Scenario parsing and offline content validation

**Status:** Accepted

EC-022/EC-023 add an immutable, pure Dart bidding representation under
`lib/scenarios/` and a standalone command under `tool/`. The existing 2020-12 JSON
Schema and canonical fixture remain unchanged. Its broad nested fields receive
explicit parser validation; supported fields and constraints are documented in
the authoring guide. This is not a reinterpretation of bidding rules.

Use `json_schema` 5.2.2 as a dev dependency for the canonical schema check.
Its synchronous API resolves locally, without network fetching. Application
models do not import that dependency, Flutter or dart:io. CLI file discovery and
cross-file duplicate-ID checks remain outside the domain.

Incomplete authored evaluation coverage is a warning by default, so draft content
can be maintained. `--require-complete` makes it an error. Neither mode certifies
coaching quality or auction legality. EC-024 remains required before presenting
the draft as trusted coaching. No fallback ratings are fabricated. Play content
is explicitly unsupported until its model is introduced.

## D-009 — Align bidding schema with the supported parser

**Status:** Accepted

EC-025 expands the existing v1 schema's bidding constraints, preserving the
canonical fixture and field names. Conditional bidding requirements leave the
reserved play shape unchanged; the application still rejects unsupported play
content. Nested action, bid range, suit, evaluation and feedback structures are
defined using local schema references. Additional properties remain permitted,
matching the current parser's extensibility behavior.

This tightens schema acceptance of malformed data that the parser already
rejected. Cross-field checks (primary skill membership, min <= max, evaluation
membership and uniqueness by decision) remain in Dart. Schema acceptance alone
does not imply feedback coverage, game legality or coaching review.

The owner has now confirmed canonical `game_rules_v1` in `GAME_RULES_V1.md`.
It takes precedence over provisional parser/schema bounds and historical examples.
EC-026 tracks the coordinated model/schema/content migration, including Sans and
the pre-bidding Dash phase; EC-024 tracks the remaining coaching review.

## D-010 — Enforce game_rules_v1 with explicit bidding phases

**Status:** Accepted

Add a pure Dart bid and immutable bidding state, with a trump category distinct
from card suits. Scenarios must explicitly identify `rules_version: game_rules_v1`,
`bidding_phase: pre_bidding|normal`, and `dash_players`. This pre-release v1
migration intentionally rejects older ambiguous files; the canonical draft is
migrated in the same PR. No silent legacy fallback is used.

Pre-bidding choices are Dash/enter without trick or trump fields. Normal choices
are bids only; authors supply count/suit bounds and the engine filters them to
legal raises above the prior bids. Coverage counts only available legal choices.
Previous actions are checked in order against the known phase and Dash players.
Turn order, pass re-entry and auction termination are not inferred.

## D-011 — First bidding trainer uses complete local authored feedback

**Status:** Accepted

Load bidding JSON assets from Flutter's asset manifest, parse with the domain
model and require complete evaluation coverage before showing a training session.
Evaluation is an exact authored lookup; illegal decisions throw and a missing
rating is explicitly unreviewed, never guessed. UI uses only legal choices.

The first session contains two independent hands: a pre-bidding Dash/enter
exercise, then a normal-bidding exercise. “Next hand” never implies a player who
Dashed later bids in that same hand. Feedback describes the decision and its
commitment; no played outcome is invented. Long evidence sits behind “Why?”.
Local StatefulWidget state is enough; results are session-only, with no storage
or new runtime dependencies. The previous card specimen remains testable as a
widget while the app now opens the trainer. Content review is recorded in
`docs/COACHING_REVIEW.md` and portable JSON remains the source of feedback.
Card suits use small vector painters because browser font fallback failed during
visual verification. Trump controls use explicit suit names.

## D-012 — Separate the play-table specimen from authored training

**Status:** Accepted

EC-040 exposes a labelled table/selection preview from bidding via a separate
route. Bidding state survives returning. Like the original card specimen, its
small fixture lives outside widgets and contains no authored rating, coaching,
or outcome. It is not loaded by the scenario catalog or presented as training.
The existing follow-suit helper determines selectable cards. Selection does not
play a card, resolve a trick, or assume a direction of play.

EC-044 defines the portable play-scenario contract before the preview can become
coached play. EC-041 retains card movement/commit interaction. This checkpoint
uses existing StatefulWidget state and adds no dependencies or game rules.

EC-060 tracks the requested English/مصري switch and Egyptian glossary. The core terms
are owner-confirmed in `EGYPTIAN_ARABIC.md`; localization must preserve physical
seats and rule codes.

## D-013 — Distinguish auction bids from player estimates

**Status:** Accepted (owner clarification, 2026-09-08)

`auctionBid` and `trickEstimate` are separate concepts. Existing `Bid` represents
an auction call with count/trump; it must not be repurposed as every player's
post-auction target. In Egyptian UI, الكول usually means the winning auction
bid; a player's estimate uses wording such as طالب كام؟ or قال كام لمة.
The confirmed glossary is in `EGYPTIAN_ARABIC.md`.

Keep neutral English model names and stable content codes. EC-044 must model
the distinction before coached play is introduced, and EC-060 must preserve it
in translations. This decision defines terminology and model responsibility,
not previously unspecified estimation, auction, or scoring rules.

## D-014 — Validate a pending play decision before defining its JSON contract

**Status:** Accepted

Split EC-044 into a pure model checkpoint (EC-045) and the portable contract
(EC-046). `PlaySituation` is immutable public context immediately before a
player plays, and `TrickEstimate` is separate from the optional known winning
`auctionBid`. Zero is a target value, not an inferred Dash declaration.

Validate physical card/count consistency and derive follow-suit choices using
the existing rule. Do not infer turn direction, opponent hidden cards, estimate
assignment rules, trick winners or outcomes. A nonempty remaining hand and at
most three current-trick cards deliberately exclude completed decisions.

The model does not change widgets or claim that play JSON is supported yet.
Keep the bidding catalog and the explicit table specimen intact until EC-046.
The project checkpoint-budget policy is recorded in AGENTS.md section 16.

## D-015 — Add a single-decision portable play contract

**Status:** Accepted

Extend the existing v1 schema's reserved `play` branch with an explicit
`situation` object and card-keyed authored evaluations. Reuse PlaySituation,
Difficulty, DecisionRating and ScenarioFeedback; expose feedback parsing for
both scenario types without introducing a repository/interface abstraction.

Every legal card is a choice, derived from the hand and lead. Play authors cannot
supply a reduced allowed_decisions list. Missing feedback is counted and returns
null; illegal cards are rejected. The CLI dispatches by type and checks IDs
across both types, retaining default warnings and strict coverage failures.

This tightens the previously unsupported reserved play shape. Existing bidding
files and Flutter asset loading are unchanged. The complete play fixture lives
under test/fixtures, is explicitly synthetic, and is not approved coaching or
bundled training. Real play content and UI integration follow in EC-041.

The first contract models one pending decision. Hidden hands, void-history
annotations, winner resolution, outcomes and multi-step continuation are not
silently encoded in unknown fields. EC-042/043 can extend the contract when
needed after documented rule/content review.

## D-016 — Commit one card in the preview before coached integration

**Status:** Accepted

With the owner reporting 18% session credit remaining, bound EC-041 to legal
selection/commitment, a short hand-to-table flight, reset and regression tests.
Split reviewed scenario loading and feedback into EC-047 rather than beginning
an incomplete coached session. Winner rules were separately confirmed by the
owner and recorded in GAME_RULES_V1.md, but winner resolution is not implemented.

The preview commits at most one card. During flight and after commitment, further
play is locked. The card leaves the hand and appears once in the current trick;
completed-trick counts stay unchanged until a future resolver exists. Reset
restores the fixture. Reduced-motion settings skip flight; route disposal removes
its overlay. This remains a labelled demo with no authored coaching or scoring.

## D-017 — Replace the play-table specimen with a coached play session

**Status:** Accepted

EC-047 retires the fixture-driven table specimen (`PlayTablePreviewScreen`,
`PlayTableFixture`) and replaces it with `PlayTrainingScreen`, which loads a
bundled, reviewed `PlayScenario` pack (`content/scenarios/v1/play/`) the same
way `BiddingTrainingScreen` loads bidding content: reject incomplete feedback
before a session starts, commit a legal card, show the authored rating/summary/
points separately from an explicitly unsimulated outcome, then retry, advance,
or complete the session. The one-card commit/flight/reduced-motion/dispose
behavior from EC-041 is preserved unchanged, now parameterized by each
scenario's `PlaySituation` instead of a static fixture.

The first pack is intentionally small: two scenarios (four evaluated legal
choices), both tagged `safe_vs_probable` and both using the confirmed
last-to-act trick-winner rule from `docs/GAME_RULES_V1.md#trick-winners` as
their reasoning — without implementing a winner resolver. `play_safe_probable_002`
was drafted and briefly tagged `card_tracking`, but that scenario only asks
the player, acting last, to recognize that a guaranteed trump win beats
discarding; it does not test tracking previously played cards or deduced void
information (that is EC-042's subject), so `card_tracking` would have been a
misleading skill label. It was retagged before this checkpoint's coaching
review (see `docs/COACHING_REVIEW.md`). Void-tracking and exact-bid-protection
content packs remain separate, deliberately out of scope (EC-042/043).

## D-018 — Derive void tracking from observed play, never author it as a fact

**Status:** Accepted

EC-042 adds `observedTricks` to `PlaySituation`: an optional list of
`ObservedTrick`, each exactly four `SeatPlay`s (one per seat, first is that
trick's own leader). It represents prior tricks the player can see for the
current decision — an author-curated, visible *subset* of history, not a
claim of recency (it is never labelled "the last trick") or of the round's
complete history. Its cards must not duplicate the hand, current trick, or
each other, and its length cannot exceed the completed-trick total implied
by `tricksTaken`; no cross-trick leader-succession check is performed, since
that would require a trick-winner resolver this project does not have.

Known-void suits are always *derived*, never authored: `knownVoidSuits`
(`lib/core/game_rules/void_tracking.dart`) scans a seat's plays across
`observedTricks` and the unfinished `currentTrick` uniformly (an empty trick,
e.g. when leading, is skipped safely) and infers a void from any off-suit
play, using the already-confirmed EC-021 follow-suit rule as proof — a seat
that could follow suit must, so failing to do so proves it held none. No
`known_voids` field, or any other flat void metadata, exists anywhere in the
schema or content; nothing infers a void from the *absence* of shown history.
This keeps content and derivable fact from silently drifting apart, and
avoids inventing a new rule where the existing one already proves the point.

The first pack (EC-042) has three scenarios, all tagged `void_tracking`. At
least one (`play_void_tracking_001`) is authored so its rating *changes* once
the observed void is accounted for. A regression test confirms this is not
decorative: stripping `observed_tricks` leaves nothing else in the situation
that reveals the void, so the authored rating's stated rationale genuinely
depends on the shown evidence. This is not an algorithmic proof that the
rating is the objectively optimal decision — ratings remain authored
judgment here, same as everywhere else in this project. A second scenario
uses Sans to show a void becomes a full guarantee rather than a mere risk
signal, and a third reinforces the first pattern with different cards. The
UI shows observed tricks as a compact, visually de-emphasized "Observed play"
section above the current trick; it never displays a live computed void
badge, since that would hand the player the answer instead of letting them
read the same history the coaching evidence points back to afterward.

## D-019 — Confirm and enforce the canonical seat rotation; correct EC-042 content

**Status:** Accepted (owner confirmation, 2026-09-08)

The owner confirmed normal-round play is counter-clockwise:
`North → West → South → East → North`, defining seat succession *within one
trick* only — not a trick winner, not a full deal/round turn order, and not
which seat leads the next trick. Documented in
[game_rules_v1](GAME_RULES_V1.md#play-direction--seat-rotation).

`lib/core/game_rules/seat_rotation.dart` (`rotationFrom`) is the single pure
implementation, used by both `PlaySituation` (for `currentTrick`: every play
must be an ordered prefix of the rotation from `leader`, and `playerPosition`
must be exactly the next seat) and `ObservedTrick`'s own constructor (all
four seats, in rotation order from its own first entry). Neither parsers nor
widgets duplicate this ordering logic. This validates seat succession only —
not trick-winner resolution or next-trick-leader computation, both still out
of scope.

D-018's three void-tracking scenarios were authored before this confirmation
using an unconfirmed, as it turned out impossible, seat sequence (their
current tricks had South 3rd to act with a *West*-led trick, which the
confirmed rotation cannot produce — North-led is the only leader that puts
South 3rd, and its 4th seat is East, not West). All three scenarios' seat
assignments were corrected: the seat that plays after South is **East**, not
West as originally authored. The two EC-047 originals
(`play_safe_probable_001`/`_002`, where South is last to act) and the
synthetic contract fixture were also re-verified; South is only ever last
when East leads, so both were corrected from West/North leaders to East.

Each corrected scenario's strategic rating was re-reviewed, not just
mechanically reseated, since changing who acts after South can change what
is deterministically knowable. In every case the lesson itself was
unaffected — only the seat identity changed — because none of the three
authored ratings depended on anything specific to *which* seat besides "the
one seat that plays after South," which is now East instead of West. No
rating changed as a result of this correction.

## D-020 — Exact-target practice uses the existing play contract

**Status:** Accepted

EC-043's first three scenarios use existing estimate/taken counts, hand, trump
and current trick fields. No schema or parser extension is needed. The generic
pre-play status calls `classifyExactBid`; authored feedback explains each card's
local consequence. Submission does not update the snapshot or resolve winners.
Further supported scenarios remain content-only. Already-above-target feedback
does not claim that losing restores exact success or invent a scoring preference.
Scoring, Risk and full-round orchestration remain outside this checkpoint.

## D-021 — Freeze the seven-checkpoint MVP finish plan

**Status:** Accepted — owner requested 2026-09-09

Replace the open-ended delivery estimate with the seven ordered checkpoints,
Definition of Done and discovery policy in [MVP_STATUS.md](MVP_STATUS.md).
Anti-memorization requires both independent session selection and reviewed
scenario variety. Controlled deterministic variants sit outside widgets and
must preserve explicit game/coaching invariants; new supported scenarios remain
content-only.

New work defaults to POST-MVP. MVP BLOCKER requires evidence against the explicit
Definition of Done and placement within an existing checkpoint. Adding an eighth
checkpoint requires explicit owner approval. The seven readiness gates have fixed
weights of 15/15/15/20/15/10/10 and binary completion credit; the current sum is
45%, separate from CI status. Update docs and the local SVG when gates change.
This decision authorizes documentation/governance only, not feature implementation.

## D-022 — Session Selector: shuffled sessions without touching the trainer UI

**Status:** Accepted

EC-049 (checkpoint 2) needed session order independent of catalog/filename
order without adding randomization logic to `BiddingTrainingScreen` or
`PlayTrainingScreen`. Two new, independently testable pieces implement the
architecture boundary from `MVP_STATUS.md`:
`Scenario Catalog → Session Selector → existing trainer UI`.

`selectSession<T>` (`lib/core/session/session_selector.dart`) is a pure
function: given a pool, a `Random` source and an optional previous session's
last item, it returns a shuffled permutation. It compares items by an injected
`idOf` rather than object identity, since a reloaded catalog is a fresh list
of equivalent instances. Explicit contract: an empty pool returns an empty
list; a single-item pool returns that item and necessarily repeats the
previous session's last scenario when there is no alternative; otherwise the
result never starts with the previous session's last item.

`ScenarioSession<T>` (`lib/scenarios/scenario_session.dart`) composes a
catalog loader with `selectSession`, caching the catalog (retried
automatically if a prior load failed) and tracking the previous session's
last scenario across calls, so repeated calls — including "Practice again" —
return fresh orders without reloading or mutating scenario content.

Both trainer screens now depend on one function, `nextSession`, wired in
`initState` (production default) or supplied via the existing `loader`
constructor parameter (widget tests inject a fixed, deterministic list, same
as before this checkpoint). "Practice again" calls the same function again
instead of resetting to index 0 of the originally loaded list, so it produces
a new order rather than always returning to the first loaded scenario.

No variant generation, weak-area weighting, decision persistence, Training
Hub or runtime AI is introduced. Cards are never randomized — only the
scenario pool's order.

## D-023 — Variant mechanism v1: redistribute opponents' taken counts only

**Status:** Accepted — first bounded PR inside checkpoint 3 (EC-055)

### Contract limitation discovered

Before choosing a transformation, every evaluation's `feedback.summary` and
`feedback.points` across all 20 production scenarios were read in full (not
sampled). The free-text feedback contract is tightly coupled to almost every
visible fact:

- **Play scenarios** name specific cards and suits directly in prose —
  `"the ace of Diamonds is already out"`, `"North's jack of trump"`,
  `"the two of Spades loses beneath..."` — for every card a rating discusses,
  including cards mentioned only to explain why another card is locked.
  Swapping a card's suit or rank would silently leave the sentence
  describing the old card, since nothing re-derives or re-checks that prose
  against the data it describes.
- **Bidding scenarios** are the same or worse: dash/enter feedback quotes
  exact rank groups (`"three Aces and a strong Spade sequence"`,
  `"Ace-King-Queen-Jack of Hearts"`, `"7-4-2 of Clubs"`), so almost the
  entire 13-card hand is referenced by exact identity somewhere in its own
  feedback.
- Seat identity cannot be relabeled either, independent of the feedback
  problem: the table has a fixed topology (the player is always South; the
  canonical rotation North → West → South → East → North is a fixed game
  rule, not scenario data), so "the seat after South" is always East — there
  is no seat-identity axis to vary at all.

Given this, **no card, rank, suit or seat substitution is safe** without
either rewriting prose per-transformation (out of scope: it would need
natural-language understanding of what each sentence claims, which this
checkpoint explicitly does not build) or moving feedback from free text to a
structured, re-renderable template (a schema change, which the task
instructed against doing prematurely).

### What is safe: opponents' taken-trick counts

Every play scenario's `situation.tricks_taken` map was checked against its
own feedback text (see the generator's doc comment and
`test/scenarios/scenario_variant_test.dart`): **no scenario's feedback
quotes an opponent's exact taken-trick count.** Feedback only ever discusses
the *player's own* count relative to the estimate (e.g. "You are exactly on
four"), which this transformation never touches. `PlaySituation`'s own
validation (`lib/core/game_rules/play_situation.dart`) requires only that
all four seats are present, each count is in `[0, 13]`, and the total equals
`13 - hand.length` — nothing ties an individual opponent's count to the
current trick, observed history, or any other field. Redistributing the
three non-player seats' shares of the (fixed) completed-trick total is
therefore mechanically provable safe, not just safe by inspection of the
current 20 files.

`generateTricksTakenVariant` (`lib/scenarios/scenario_variant.dart`) does
exactly this, seeded by an injected `Random` for determinism.
`PlayScenario.withTricksTaken` (`lib/scenarios/play_scenario.dart`) is the
fail-closed apply step: it rebuilds `PlaySituation` with the proposed map,
so a map that violates the domain contract throws `ArgumentError` — the same
error an authored scenario's bad JSON would produce — rather than presenting
something unvalidated.

This mechanism does not apply to bidding scenarios: normal-phase bidding
scenarios have no field comparable to "opponents' taken counts" that is both
schema-validated and never quoted in feedback (their only substantial data
is the 13-card hand, which is quoted almost everywhere; `previous_actions`
is empty in every current normal-phase scenario, so there is nothing there
to redistribute either).

### UI integration deferred

The mechanism is domain-tested only in this PR; it is not wired into either
trainer. Two reasons, both explicit per this checkpoint's scope:

1. **Not generic enough yet.** It applies to play scenarios only, and only
   to one field. Wiring "the Variant Generator" into the architecture now
   would present a single-field, play-only transformation as if it were the
   general mechanism the architecture diagram implies.
2. **Low standalone anti-memorization value.** Opponents' taken-trick counts
   are shown as small chip labels a player is not reasoning from; varying
   them does not meaningfully disrupt memorizing "always play the 3H here."
   Shipping it as *the* proof of the Variety gate would overstate progress
   the Variety gate is explicitly meant to still deny (it stays at 0% until
   checkpoints 1–3 all close).

A future PR inside checkpoint 3 should revisit UI wiring once either (a) a
second, independent transformation exists (so the stage is demonstrably
generic across more than one field/scenario type), or (b) feedback moves
toward structured, re-renderable content that makes card/suit substitution
safe.

### Also discovered during the coverage audit

`play_void_tracking_003` ("The same trap in a different suit") is a
suit-relabeled duplicate of `play_void_tracking_001`, authored by hand
before this checkpoint — its own `author_notes` says so directly ("a second,
independent example of the same... pattern... to reinforce pattern
recognition rather than a single memorized case"). It does not count as a
distinct reasoning case in the checkpoint 3 coverage matrix
([MVP_STATUS.md](MVP_STATUS.md#checkpoint-3-coverage-matrix-ec-055)); the
gap count to reach 32 base scenarios is 13, not the 12 that a flat
20-files-in/20-files-count reading would suggest. This is exactly the kind
of manual duplication the variant mechanism exists to replace once it can
safely vary something more visible than an opponent's trick count.

## D-024 — Variant v1 stays unwired for the MVP; checkpoint 3 closes on content + review only

**Status:** Accepted — checkpoint 3 (EC-055) closure PR

### The decision

D-023 deferred wiring `generateTricksTakenVariant` into either trainer as an
open question, to be revisited "once either (a) a second, independent
transformation exists... or (b) feedback moves toward structured,
re-renderable content." Now that the checkpoint 3 coverage matrix is
complete (32/32) and this is the closure PR, that question needs a final
answer for the MVP rather than staying open indefinitely.

**Decision: do not wire variant v1 into the UI for the MVP.** Neither
precondition from D-023 has changed — there is still exactly one
transformation, and feedback is still free text — and no new evidence from
authoring the final 13 coverage scenarios changed the underlying assessment:

- It only varies opponents' taken-trick count chips, a field players do not
  reason from when choosing a card. Wiring it in would add UI-surfaced
  randomness for a field with no coaching weight, not meaningfully reduce
  memorization risk.
- The 32-scenario coverage matrix (this checkpoint's main anti-memorization
  investment) and the Session Selector (EC-049) are the mechanisms actually
  expected to carry the anti-memorization requirement for the MVP. Wiring in
  a single-field, play-only transformation alongside them would not add
  reasoning variety proportional to the added surface area (schema-adjacent
  UI wiring, a new code path in both trainers, new test surface).
- This is a scope decision, not a quality verdict on the mechanism itself:
  `generateTricksTakenVariant` and `PlayScenario.withTricksTaken` remain
  correct, tested, and available. Nothing about this decision deprecates or
  removes them.

### What stays in place for future richer variants

No code changes accompany this decision. The architecture extension point
from `docs/MVP_STATUS.md` stays exactly as designed and documented:

```text
Scenario Catalog → Session Selector → Optional Validated Variant Generator → existing trainer UI
```

`lib/scenarios/scenario_variant.dart` and `lib/scenarios/play_scenario.dart`
(`withTricksTaken`) remain in the codebase, tested, as the reference
implementation of "one validated, fail-closed transformation slotted into
this stage." A future POST-MVP task revisiting variants should start from
the same audit discipline D-023 used (read every scenario's feedback in
full before proposing a transformation) rather than assume card/suit
substitution has become safe; it has not, unless feedback itself moves to a
structured, re-renderable format first.

### Consequence for checkpoint 3

This decision, combined with the coverage matrix reaching 32/32, removes
the variant-mechanism acceptance criterion as an open item for EC-055. The
sole remaining item to close checkpoint 3 is the owner's repeated-session
review (see the checklist in
[MVP_STATUS.md](MVP_STATUS.md#checkpoint-3-owner-repeated-session-review)).
No automated check can substitute for that review; the Variety gate stays
at 0% and MVP Readiness stays at 45% until the owner confirms it explicitly.

## D-025 — Add a bounded `trickWinner` helper; do not enforce leader/history continuity generically

**Status:** Accepted — found during the owner's checkpoint 3 repeated-session review

### The finding

The owner's first repeated-session review pass found a genuine game-state
inconsistency in `play_void_tracking_005`: its single observed trick had
East lead a Club, North follow, **West trump with 5H**, and South follow low
with 2C. Per game_rules_v1's confirmed trick-winner rule (highest card of
the led suit wins unless trump is played, then highest trump wins), **West**
— not South — won that trick. The scenario's current (empty) trick then
authored `"leader": "south"`, contradicting the standard, already-documented
relationship that the winner of a trick leads the next one.

`PlaySituation`'s existing validation could not catch this: it deliberately
does not resolve trick winners (see
[GAME_RULES.md](GAME_RULES.md#ec-045-public-play-situation) — "one observed
trick's leader is never checked against a previous trick's winner, since
that would require a winner resolver this project does not have"). That
carve-out was correct when written; nothing before this checkpoint needed a
leading (empty-current-trick) scenario with observed history behind it, so
the gap was never exercised. `play_void_tracking_005` (EC-055's third
bounded PR, the first-ever leading scenario) is what finally hit it.

### The content fix

Smallest change that preserves the training goal: changed West's discard
from `5H` (a trump) to `3D` (an off-suit, non-trump card) and South's card
from `2C` to `KC` — South's own Ace of Clubs, still held now, was never the
card played there. With no trump played, the highest Club (South's King)
legitimately wins, so South leading next is game-consistent. West's Club
void — the evidence this scenario trains leading around — is unchanged;
both evaluations' ratings (Risky for the Ace into the void, Strong for
avoiding it) are unaffected, and the one feedback point naming West's
discarded suit was updated from "Heart" to "Diamond" to match. See
`content/scenarios/v1/play/play_void_tracking_005.json`'s `author_notes`
for the full before/after.

**Audit of the same bug class**: every production play scenario with
`observed_tricks` was checked (`play_void_tracking_001/002/003/004/005`,
`play_mixed_tactical_001`). Only `play_void_tracking_005` has an empty
current trick — the one situation where the authored `leader` is not
already independently visible as the owner of `currentTrick`'s first play —
so it was the only file needing a fix.

### The helper: added; a generic validation rule: deliberately not added

`lib/core/game_rules/trick_winner.dart` adds `trickWinner(ObservedTrick,
Trump)`, a pure function applying game_rules_v1's already-confirmed rule to
exactly one already-complete trick (led suit wins unless trumped; highest
trump wins; Sans only led-suit cards can win). It lives in its own file with
no dependency on `play_situation.dart` (see "Avoiding a circular
dependency" below) and is fully covered by
`test/core/game_rules/trick_winner_test.dart`.

An earlier version of this fix also added a `PlaySituation` check —
"when the current trick is empty and history exists, `leader` must equal
`trickWinner` of `observedTricks.last`" — and that check is what caught the
`play_void_tracking_005` bug in the first place. **It was removed before
merge.** The check assumed something the `observedTricks` contract does not
promise: that the last observed trick is *immediately* previous to the
current one. `observedTricks` is explicitly curated, visible evidence —
"not a claim of recency... or completeness" (see GAME_RULES.md's EC-045
section, unchanged) — precisely so an author can show only the trick(s)
relevant to a lesson, skipping any number of intervening tricks that
happened but were not worth showing. A future scenario could legitimately
have South as the current, empty trick's leader while the last authored
`observed_trick` is an older piece of evidence someone *else* won, with one
or more unshown tricks in between. The removed check would have rejected
that valid scenario outright. Enforcing continuity correctly would require
either an explicit "this observed trick is immediately previous" flag in the
schema (a schema change the task instructed against, and one this checkpoint
has no confirmed need for beyond this single scenario) or a way to prove a
gap doesn't exist (which nothing in the current contract can do). Neither is
worth adding for one file.

**What replaced it**: a targeted, scenario-specific regression test,
`test/scenarios/play_scenario_test.dart` — `play_void_tracking_005 authors
South as its empty-trick leader consistently with who actually wins its
shown prior trick`. It loads that one file, confirms its situation intends
direct continuation (empty current trick, exactly one observed trick — this
scenario's own narrative point is "you just won this, now lead"), and
asserts `trickWinner(observedTricks.single, trump) == leader`. This proves
the one scenario that actually needs the property continues to hold it,
without asserting the property for every scenario that will ever exist.

**Avoiding a circular dependency**: `SeatPlay` and `ObservedTrick` moved out
of `play_situation.dart` into their own file,
`lib/core/game_rules/seat_play.dart` (no behavior change — same
constructors, same validation, same rotation check). `play_situation.dart`
imports and re-exports them (`export 'seat_play.dart' show ObservedTrick,
SeatPlay;`) so every existing import of `SeatPlay`/`ObservedTrick` via
`play_situation.dart` keeps working unchanged. `trick_winner.dart` imports
`seat_play.dart` directly, never `play_situation.dart` — so
`play_situation.dart → trick_winner.dart → play_situation.dart` cannot
happen; `trick_winner.dart` has no dependency on `PlaySituation` at all now
that no invariant inside it calls the helper.

`trickWinner` is not a full-round simulator and does not become one: it is
the same "small, independent pure Dart module" pattern as
`estimate_totals.dart` and `exact_bid_outcome.dart`, applying a rule the
owner already confirmed and game_rules_v1 already documents, resolving
nothing beyond one already-complete trick, and available for authors and
tests to use directly wherever a scenario's own intent already establishes
the trick as immediately previous — without the domain model asserting that
intent for every scenario.

### Consequence

`docs/GAME_RULES.md`, `docs/GAME_RULES_V1.md` and `docs/SCENARIO_AUTHORING.md`
document `trickWinner` as an available pure helper and explain why it is not
wired into `PlaySituation`'s validation, without weakening any "no resolver,
no turn order, no scoring" statement elsewhere — those remain true, and are
now explicitly true for cross-trick leader/winner continuity in general too,
not just for chaining multiple observed tricks. This is a bounded
correctness fix, not checkpoint 3 content or acceptance work: it does not
change the coverage matrix (still 32/32), does not touch readiness (still
45%), and does not mark EC-055 done. The owner's repeated-session review
continues.

## Decision template

Copy this section for future decisions.

```md
## D-XXX — Title

**Status:** Proposed | Accepted | Superseded

### Context
Why is a decision needed?

### Decision
What are we choosing?

### Consequences
What becomes easier, harder, or intentionally deferred?
```
