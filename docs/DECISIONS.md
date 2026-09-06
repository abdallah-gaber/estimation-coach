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
