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
feature implementation. It remains unmerged until review. Android, iOS, macOS
and web runners are generated; web is the first validated target. The browser
runner is a convenient local Flutter test target, not a hosted product.

Use Flutter's built-in widgets and state mechanisms; no state-management package
is needed yet. Add the domain and feature directories when implementation begins.
Keep machine-specific signing teams out of the shared iOS project.

The supplied scenario is a draft, with incomplete choice evaluations and a note
requiring agreed-rule review. Do not expose it as trusted coaching before EC-022,
EC-023 and the rules clarification task are complete.

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
