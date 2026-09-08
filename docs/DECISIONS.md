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
