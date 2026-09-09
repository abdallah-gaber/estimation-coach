# Scenario Authoring Guide

This document defines how humans and AI agents add training content without changing application code.

[game_rules_v1](GAME_RULES_V1.md) is authoritative for normal bidding. The first ten training hands have complete feedback; see the [coaching review](COACHING_REVIEW.md).

## Goal

Scenario content must be independently maintainable from the Flutter UI and domain implementation.

A contributor should be able to:

1. open this repository;
2. read this guide;
3. add or modify scenario files;
4. validate them;
5. open a content-only Pull Request;

without editing Flutter widgets, navigation, or unrelated application code.

---

## Source of truth

All authored scenarios live under:

```text
content/
  scenarios/
    v1/
      bidding/
      play/
```

Scenario structure is versioned.

The current format is:

```text
scenario_version: 1
```

The schema lives at:

```text
schemas/scenario.v1.schema.json
```

Do not invent new fields silently.

If a scenario needs information the current schema cannot express:

1. do not work around it with arbitrary metadata;
2. document the need in `docs/DECISIONS.md`;
3. propose a schema change separately;
4. keep backward compatibility where practical.

---

## Content-only workflow

Adding scenarios should normally require only:

```text
content/scenarios/...
```

and, when appropriate:

```text
PROJECT_TRACKER.md
```

Do not modify Flutter implementation just to add another scenario of an already-supported type.

Suggested branch naming:

```text
content/bidding-dash-pack-01
content/void-tracking-pack-01
content/exact-bid-pack-01
```

---

## Scenario authoring rules

### Visual interaction first

A scenario should ask the player to respond using an interaction the app can render visually:

- Dash / Enter
- trick count
- trump suit
- card selection
- compact tactical choice

Do not create scenarios whose required answer is free-text.

### One main lesson

Each scenario should have one main teaching objective.

Examples:

- Do not count a conditional King as guaranteed.
- Distinguish a plausible zero-trick plan from a hand that is merely too weak to open.
- A player who failed to follow Clubs is now known void in Clubs.
- After reaching the exact bid, stop maximizing trick count.

Secondary concepts may be tagged, but the coaching should not become unfocused.

### Decision quality is graded

Choices may use:

- `strong`
- `reasonable`
- `risky`
- `weak`

Avoid binary correct/incorrect unless the choice is illegal by game rules.

### Coaching text is concise

Default coaching should normally fit in:

- one title;
- one short explanation;
- up to three compact evidence points.

Long explanations should be optional expansion content later.

### No hidden assumptions

Everything needed to evaluate the authored scenario must exist in the scenario file or deterministic game rules.

Do not rely on:
- chat history;
- the author's memory;
- undocumented conventions.

---

## Bidding scenario example

The complete examples are maintained directly in portable content:

- [Pre-bidding: Dash or enter](../content/scenarios/v1/bidding/bid_enter_controls_001.json)
- [Normal bidding: 17 legal raises](../content/scenarios/v1/bidding/bid_safe_probable_001.json)

Read those files for the exact schema, decisions, and authored feedback used by
the app. Avoid maintaining a second, divergent copy in this guide.

---

## Card notation

Use:

```text
A K Q J 10 9 8 7 6 5 4 3 2
```

Suit suffixes:

```text
S = Spades
H = Hearts
D = Diamonds
C = Clubs
```

Examples:

```text
AS
10H
QD
2C
```

---

## Required review for authored scenarios

Before a scenario is accepted:

- cards are valid;
- no duplicate card exists where duplication is impossible;
- hand size is valid for the scenario;
- previous actions are legal;
- available choices are legal;
- evaluation ratings are internally consistent;
- coaching does not contradict the game state;
- the main lesson is clear;
- the scenario is visually answerable;
- scenario passes schema validation;
- scenario passes domain validation once the validator exists.

AI-generated scenarios require exactly the same review.

---

## Instructions for AI agents

When asked to add scenarios:

1. Read:
   - `AGENTS.md`
   - this file
   - `docs/DECISIONS.md`
2. Inspect several existing scenarios of the same type.
3. Do not modify application code unless the requested scenario cannot be represented by the current supported schema.
4. Create scenarios only under `content/scenarios/v1/...`.
5. Keep each scenario focused on one primary learning objective.
6. Never invent or reinterpret game rules.
7. If the requested game rule is undocumented or ambiguous, mark the task blocked and identify the exact missing rule.
8. Validate all scenario files.
9. Provide a content-only PR whenever possible.

---

## Future authoring tool

A future editor may provide a visual UI for creating scenarios, but it must produce the same versioned scenario files.

The files remain the portable source of truth.

## Standalone validation

From the repository root after `flutter pub get`:

```sh
dart run tool/validate_scenarios.dart
flutter test test/scenarios
```

The command recursively scans `content/scenarios/v1/`, checks the canonical JSON
schema, then parses and checks `game_rules_v1` bidding constraints using the same
pure Dart model available to the app. No Flutter engine or network service is
required; `json_schema` is a development-only dependency using local validation.
Explicit file/directory paths are supported. Files are sorted and deduplicated;
missing paths, empty directories, invalid JSON and duplicate IDs fail. Symlinks
are not followed. Errors identify the file and field; scanning continues.

## Required bidding context

Scenario v1 supports bidding and single-decision play with
`rules_version: game_rules_v1`. Both are bundled in the app: bidding in Bid
Practice, and a small reviewed play pack in Play Practice (EC-047). Every
bidding file requires:

- `rules_version`: exactly `game_rules_v1`.
- `bidding_phase`: `pre_bidding` or `normal`.
- `dash_players`: distinct seats that declared Dash before the listed history.
  Do not repeat these declarations in `previous_actions`.

This intentionally rejects legacy files lacking phase/rules metadata. There is
no silent inference from old mixed Dash/bid data. Scenario version 1 is still a
pre-release content contract; these required fields migrate that contract.

### Pre-bidding phase

Trump is not known and no normal bids have occurred. The player chooses Dash
(exactly zero tricks) or enter (continue into normal bidding). Choices contain no
trick or trump fields:

```json
"allowed_decisions": {"dash": true, "enter": true}
```

At least one of the two flags must be true. `bids` and `trumps` are forbidden.
Evaluation decisions use `{"action":"dash"}` or `{"action":"enter"}`.
Previous actions may only be Dash/enter with a player seat. Each player may have
only one recorded pre-bidding decision, and the current player must not already
have decided. Recorded Dash declarations update the parsed bidding state and
fix that player's estimate at zero.

### Normal bidding phase

Dash players are excluded. Previous actions may be pass or bid; bids require
4–13 integer tricks and a trump category and must strictly outrank the preceding
bid. Pass/enter/Dash are not interchangeable: no new Dash/enter declaration is
allowed once normal bidding starts. Turn order and pass re-entry are outside
this model's scope.

```json
"allowed_decisions": {
  "dash": false,
  "bids": {"min": 4, "max": 7},
  "trumps": ["clubs", "diamonds", "hearts", "spades", "no_trump"]
}
```

Normal choices are bids only (`enter` must be absent or false). `min <= max`,
trumps must be nonempty and distinct. Trump codes map to the canonical ranking;
`no_trump` means Sans, not a fifth card suit.

These are authored bounds, not a claim that every count/trump combination is
legal. `allowedDecisions.choices` filters them through the bid engine; use that
list in UI and evaluation. At least one legal choice must remain. Evaluations
outside that list are invalid. The number of missing evaluations is based on
legal choices, so equal/lower bids never inflate coverage.

## Other structural checks

- Nonempty title, primary skill and skill tags; primary skill is one of the
  distinct tags. Difficulty is beginner/intermediate/advanced.
- Seats are north/east/south/west. A bidding hand has 13 distinct canonical cards.
- Each evaluation has a decision, strong/reasonable/risky/weak rating, and feedback
  with a nonempty title/summary and an array of nonempty evidence points.
- Each legal decision has at most one evaluation. No fallback rating is invented.
- Lists are immutable snapshots. Additional properties remain permitted but do
  not introduce behavior. Nested schema constraints catch malformed shapes;
  cross-field and game-rule checks remain in Dart.

## Coverage and coaching review

```sh
dart run tool/validate_scenarios.dart --require-complete
```

Default validation permits incomplete feedback with a warning. Strict coverage
fails until every legal choice has an evaluation. All ten bundled scenarios now
pass strict coverage (53 choices total). Neither mode certifies the authored
coaching. The app rejects incomplete catalogs rather than inventing a rating.

| Exit code | Meaning |
| --- | --- |
| 0 | Selected files passed schema and supported bidding-rule checks |
| 1 | Invalid/missing content, duplicate IDs, or incomplete strict coverage |
| 2 | Invalid options or schema configuration |

The canonical situation has been reviewed for rule legality: 4 Spades legally
raises 4 Hearts, no late Dash is offered, and Sans is supported. The strategic
review is recorded in [COACHING_REVIEW.md](COACHING_REVIEW.md), including why
4 Spades is reasonable rather than strong. Tests
cover phase boundaries, bid order, Dash participation and feedback coverage.


## Single-decision play contract (EC-046)

`type: play` uses the same `scenario_version`, `rules_version`, `id`, `title`,
`difficulty`, `primary_skill`, `skills`, `player_position`, `hand`, `evaluations`
and optional `author_notes` conventions. IDs must be unique across bidding and
play. The hand contains 1–13 remaining cards rather than exactly 13.

See [the complete synthetic fixture](../test/fixtures/play_contract.json) for
the schema/parser contract itself — it is an executable contract example,
**not reviewed training content**, and is not bundled.

For reviewed, bundled examples, read the files under
`content/scenarios/v1/play/` directly — `play_safe_probable_001.json` and
`play_safe_probable_002.json` for a single-decision situation, or
`play_void_tracking_001.json` through `_003.json` for `observed_tricks`; see
their review in
[COACHING_REVIEW.md](COACHING_REVIEW.md#first-play-pack-review-ec-047) and
[COACHING_REVIEW.md](COACHING_REVIEW.md#void-tracking-pack-review-ec-042).
Avoid
maintaining a second, divergent copy of their content in this guide.

### Public situation

Required `situation` fields:

| Field | Contract |
| --- | --- |
| `leader` | Seat of the first current-trick card; the player seat when leading an empty trick |
| `current_trick` | Ordered array of 0–3 `{player, card}` objects, following the seats below |
| `trump` | A canonical trump code, including `no_trump` |
| `trick_estimate` | This player's already assigned target, integer 0–13 |
| `tricks_taken` | Object with north/east/south/west nonnegative integer counts |
| `auction_bid` (optional) | Known winning `{tricks: 4–13, trump}`; omit if unknown |
| `opponent_estimates` (author for every new scenario) | Object keyed by seat, excluding `player_position`'s own seat, each an exact 0–13 target. Author all three; see the rules below |
| `observed_tricks` (optional) | Array of prior tricks, each exactly four `{player, card}` objects, following the seats below |

These fields map to the validated PlaySituation contract in
[GAME_RULES.md](GAME_RULES.md#ec-045-public-play-situation). Taken counts must total
`13 - hand.length`; the pending player has not played into this trick. Cards must
be distinct across the hand, current trick and every observed trick.

`current_trick` and each `observed_tricks` entry must follow the
owner-confirmed counter-clockwise seat rotation from
[game_rules_v1](GAME_RULES_V1.md#play-direction--seat-rotation) —
North → West → South → East → North — starting from that trick's own leader
(`current_trick`'s leader is the `leader` field; each observed trick's leader
is its own first entry). For `current_trick`, `player_position` must be
exactly the next seat in that rotation after the last play. This is seat
succession within one trick only: it does not resolve a winner, and one
observed trick's leader is never checked against a previous trick's winner.

The estimate is **not** an auction bid. Values below four, including zero, are
representable without declaring Dash. No estimate-assignment rule is
introduced. Hidden hands and historical feasibility are not inferred.

If `auction_bid` is supplied, `trick_estimate` must not exceed its `tricks`.
For example, estimate 5 with winning bid 4 is rejected; estimate 4 with bid 4
or estimate 1 with bid 4 is accepted. Omitting `auction_bid` preserves the
full 0–13 estimate range without inventing auction context. `PlaySituation`
delegates the bound to `isValidNonCallerEstimate`; the parser and standalone
validator report violations under `$.situation`. This relational rule is
checked by domain validation, not JSON Schema alone. No caller identity,
estimate order, scoring or full four-player estimate set is inferred.

#### Observed tricks and void tracking (EC-042)

`observed_tricks` shows the player prior, completed tricks as visible
evidence for the *current* decision — **not** a claim that a shown trick is
the most recent one, or that it is the round's complete history. Author only
the tricks relevant to the lesson; `observed_tricks.length` must not exceed
`tricks_taken`'s total, but may be smaller.

Do not add a `known_voids` field or any other flat void flag. Void suits must
always be *derived*, never authored: `lib/core/game_rules/void_tracking.dart`
scans every observed trick (and the in-progress `current_trick`) for a seat
playing off the led suit, which the confirmed [follow-suit
rule](GAME_RULES.md#ec-021-following-suit) proves as a void. If a lesson
needs a specific seat known void in a specific suit, include a trick where
that seat is shown playing off that led suit — the app will derive the same
fact your coaching text relies on, keeping content and reasoning from
silently drifting apart.

Each observed trick's four seats must follow the same confirmed rotation as
`current_trick` (validated structurally — see above). Do not use
`observed_tricks` to encode a continuation across tricks, including between
the last observed trick and the current one: the model does not check that
one trick's leader plausibly follows from another trick's winner (that would
require a resolver, which does not exist), **even when you author an empty
`current_trick`** (the player is leading). `observed_tricks` is curated,
visible evidence, never a claim that it is the immediately previous trick —
a scenario may legitimately show the player leading now while its last
observed trick is older evidence someone else won, with unshown tricks in
between.

If your scenario's own intent genuinely is "the player just won this shown
trick and is now leading" (as in `play_void_tracking_005`), nothing enforces
that automatically — check it yourself with
`lib/core/game_rules/trick_winner.dart`'s `trickWinner`, which applies the
confirmed [trick-winner rule](GAME_RULES_V1.md#trick-winners) (led suit wins
unless trumped, highest trump wins, Sans only led-suit wins) to one
already-complete trick, and add a targeted test asserting
`trickWinner(observedTricks.last, trump) == leader` for that specific file
(see `test/scenarios/play_scenario_test.dart`'s `play_void_tracking_005`
check for the pattern to copy). This was a real bug once
(EC-055/D-025 — `play_void_tracking_005` originally had its shown trick won
by a different seat than the one it named as leading next); catch it in
review or a targeted test per scenario, not by assuming the general model
will catch it, since it deliberately does not.

#### Opponent estimates (EC-055/D-027)

`opponent_estimates` completes the public table: without it, an opponent's
`tricks_taken` is displayed with no target to compare it against, which is
what a real player reads to know whether that seat still wants tricks.
**Author a complete set (all three other seats) for every new play
scenario.** All 17 bundled scenarios do. These are authored synthetic table
states — an opponent's target is missing public state to supply, exactly like
the cards, taken counts and observed tricks already authored, not an external
historical fact being invented.

The field is still structurally optional, and a seat left out renders as an
honest `Target unknown` rather than an invented number — but that is a
fallback for partial content, not the normal case.

**Rules the set must satisfy** (all enforced; violations are rejected at
`$.situation`):

| Rule | Constraint |
| --- | --- |
| Own seat | Never include `player_position`'s own seat — its target is `trick_estimate`. Every other seat name is structurally allowed, so a scenario pending on any seat works |
| Bound (rule 2) | With `auction_bid`, no seat may estimate more than its `tricks`. Equalling it is fine — that is "With" (rule 3) |
| Caller (rule 1) | A complete set with `auction_bid` must have **some** seat at exactly `auction_bid.tricks`, because the Caller is one of the four and their estimate *is* the winning bid |
| Total (rule 4) | A complete set's four estimates must not total 13 |
| Implied auction | Even without `auction_bid`, the highest estimate in a complete set is the Caller's, and auction bids start at 4 — so keep the maximum at 4 or more. Not machine-checked without a bid, same as `trick_estimate`'s bound |
| Dash | Avoid 0 for an opponent: an estimate of exactly 0 is a Dash declaration (game_rules_v1), and a play scenario carries no Dash history to justify one |

**Choose values that do not compete with the lesson.** Opponent targets are
not decorative once visible — they can give the player a reason to win or
lose the current trick. Check each seat's state (`taken` vs. `estimate`)
against the decision being taught:

- **Below target** (estimate above taken) is the neutral default: it is what
  every scenario's coaching already assumes, that opponents contest tricks.
  Prefer it for all three seats.
- **Exactly on target** gives the player a reason to *hand* that seat a trick
  to break it. That is opponent-punishing strategy, which this MVP
  deliberately does not teach. **Avoid it.**
- **Already over** (estimate below taken) makes that seat's outcome fixed and
  therefore inert. Use it deliberately when inertness is what a scenario
  needs, not by accident.
- In a scenario whose reviewed line **concedes** the current trick, check
  which seat collects it, and prefer a value where that trick is *not* the
  one completing their target — otherwise "am I finishing their contract?"
  competes with the exact-target lesson. See
  `play_target_protection_001`–`005` for authored examples of this choice,
  each explained in its own `author_notes`.
- Where the arithmetic leaves no neutral option (an opponent on `taken` 3
  under a 4-trick bid can only be at 4 to stay below target), say so in the
  review entry rather than picking an on-target value.

Adding opponent estimates must not change any existing rating. Re-review each
evaluation with the targets visible and record the result in
`COACHING_REVIEW.md`; if a scenario becomes genuinely ambiguous at this
tactical scope, pick a more neutral valid set or flag it for owner review
instead of adding higher-level strategy to the coaching text.

#### Exact-target coaching (EC-043)

The owner-confirmed estimate rules in
[game_rules_v1](GAME_RULES_V1.md#post-auction-trick-estimates) — a
non-Caller's estimate bounded by the Caller's, "With", the total-must-not-equal-13
rule, "Over"/"Under" and the exact-target rule — are implemented as pure
functions (`lib/core/game_rules/estimate_totals.dart`,
`exact_bid_outcome.dart`). The existing `situation.trick_estimate` and
`tricks_taken` already support a single player's exact-target coaching;
EC-043 requires **no schema change**. Play Practice derives its pre-play
status with `classifyExactBid`, never with authored flags such as `on_target`,
`over_target`, or `must_avoid_trick`. The displayed status remains a snapshot
after submitting a card, because the app does not resolve or advance tricks.

Add another supported scenario as a JSON file in the existing play directory;
no registration or widget edit is needed. Supply feedback for every legal card
and review its reasoning in `COACHING_REVIEW.md`. See
`play_target_protection_001`–`005` for below/on/above examples, including
undertrumping and choosing which safe winner to spend; see
`play_void_tracking_001`–`004` for void-derivation examples, including the
boundary case where a derived void does not affect the current decision.
Distinguish avoiding a trick while exactly on target from avoiding another
trick after already exceeding the target: the latter cannot restore exact
success.

A complete four-player estimate set is represented via `opponent_estimates`
(see above), and rules 1, 2 and 4 are enforced against it. "With" and
room-total Over/Under are still not *surfaced* by the trainer UI; future
support should derive them with the existing pure helpers (`isWithCaller`,
`classifyEstimateTotal`), never redundant authored labels. No scoring, Risk,
opponent behavioral modeling or simulator is implied: the trainer stays local
and tactical, coaching one card decision against the player's own exact
target, not optimizing against the opponents' targets.

**Check target feasibility before rating a card that gives up the current
trick, and before choosing `tricks_taken` at all.** A real owner-review
finding (EC-055/D-026): a `mustWinAll` situation — where
`target - tricks_taken[player_position]` equals the player's remaining hand
size, meaning every remaining trick including the current one must be won —
makes a Strong rating for a card that concedes the current trick incoherent,
regardless of what other heuristic (a known void, a safe-vs-probable
trade-off) seems to recommend it. Run
`classifyTargetFeasibility(taken: ..., target: ..., remainingTricks:
hand.length)` (`lib/core/game_rules/target_feasibility.dart`) against a
new scenario's numbers before authoring ratings, and again after any edit
to `tricks_taken` or `trick_estimate` — changing one seat's count to satisfy
a different concern (as `play_void_tracking_005` needed) can silently flip
the feasibility class. When a scenario is intentionally isolating one
concept (a known void, a safe/probable choice, a visible trump), choose
`target`/`tricks_taken`/hand-size numbers that leave genuine slack
(`0 < target - taken < remaining`) unless the lesson specifically *is* about
a must-win-all trade-off — and if it is, the recommended card must actually
be the one more likely, or (where mechanically provable — see
`test/scenarios/play_target_feasibility_test.dart`) certain, to win.
Rebalancing `tricks_taken` for one seat requires rebalancing another to keep
`sum(tricks_taken) == 13 - hand.length` (`PlaySituation` already enforces
this); pick a seat whose count is not referenced by any evaluation's
feedback text, so the rebalance stays strategically neutral.

### Choices and feedback

There is no authored `allowed_decisions`: every card permitted by follow-suit
is available. An evaluation contains:

```json
{
  "decision": {"action": "play", "card": "3H"},
  "rating": "reasonable",
  "feedback": {
    "title": "Short title",
    "summary": "Reviewed coaching for this specific decision.",
    "points": ["Optional supporting evidence"]
  }
}
```

This fragment illustrates shape, not an approved rating. All four decision
ratings are supported. Each legal card may have at most one evaluation;
non-held and follow-suit-illegal cards cannot receive evaluations. Empty or
incomplete evaluations are valid drafts, but strict coverage fails. `evaluate`
returns the exact authored entry, null for a legal unreviewed choice, and throws
for an illegal choice. It does not simulate an outcome.

`allowed_decisions`, `previous_actions`, `bidding_phase` and `dash_players` are
forbidden on play files. Situation, current-trick entries, taken counts, optional
auction bid and play decisions reject unknown keys. Extra root/evaluation/
feedback annotations remain permitted but carry no runtime behavior.

### Validation

```sh
dart run tool/validate_scenarios.dart --require-complete test/fixtures/play_contract.json
flutter test test/scenarios/play_scenario_test.dart
```

Expected: the synthetic fixture passes strict checks. Default validation scans
the production content directory, currently containing fourteen bidding hands
and twelve reviewed play situations. Mixed bidding/play catalogs receive the same
schema, domain, duplicate-ID and coverage checks. Syntax errors include field
paths; relational snapshot errors are reported under `$.situation`. Bidding
compatibility remains tested.

Do not use extra fields to invent known voids, a continuation, trick winners, or
outcomes. Those need documented extensions and reviewed content in later tasks.
