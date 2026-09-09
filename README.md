# Estimation Coach

A visual, local-first Flutter coach for the **Estimation card game**. Read the
table, tap a bid or card, and get concise, reviewed coaching that explains the
evidence behind the decision.

[![Main CI and web build](https://github.com/abdallah-gaber/estimation-coach/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/abdallah-gaber/estimation-coach/actions/workflows/ci.yml)

![MVP Readiness to Ship: 45%. Foundation, bidding coach and play core gates complete.](docs/assets/mvp-readiness.svg)

**Status: runnable preview, not yet MVP.** Sixteen bidding hands and
seventeen play scenarios work with deterministic feedback, presented in a
shuffled session order. Saved personal coaching, the hub and English/مصري
switching are still ahead.
**Current focus:** checkpoints 1 and 2 are complete; checkpoint 3
(**EC-055 — Scenario Variants + Content Breadth**) is in progress. Its
32-scenario coverage target is fully authored (32/32), and its variant
mechanism stays domain-tested only, deliberately not wired into either
trainer for the MVP ([D-024](docs/DECISIONS.md)). An owner repeated-session
review is the only remaining item to close the checkpoint.

Readiness is calculated from [fixed weighted gates](docs/MVP_STATUS.md#fixed-weighted-readiness-gates):
**15 + 15 + 15 = 45%**. Session selection and content breadth (checkpoint 2
and the checkpoint 3 coverage matrix) earn no Variety gate credit by
themselves: checkpoint 3 must fully close. The CI badge reports main's
formatting, analysis, tests, scenario validation and web build separately.

## Seven checkpoints to MVP

1. **Finish EC-043 — DONE** — five reviewed exact-bid-protection scenarios.
2. **Anti-memorization sessions — DONE** — a Session Selector shuffles both
   practice sessions, independent of catalog/file order.
3. **Scenario Variants + Content Breadth — IN PROGRESS** — coverage matrix
   complete (32/32); variant mechanism v1 stays domain-tested only, not
   wired in for the MVP (D-024). An owner repeated-session review remains.
4. **Personal Coaching** — local decisions, skill aggregation and weak areas.
5. **Training Hub** — Quick Mix, Bid Practice, Play Practice, Weak Areas, Continue.
6. **Egyptian Arabic + UI polish** — مصري terms, localization/RTL and usability.
7. **MVP Acceptance** — repeated owner sessions, intended-device fixes, then
   `v1.0.0-mvp`.

The finish plan is frozen. New work is classified as **MVP BLOCKER** or
**POST-MVP**, not silently added to the roadmap.

[MVP status & Definition of Done](docs/MVP_STATUS.md) ·
[Task tracker](PROJECT_TRACKER.md) ·
[Canonical rules](docs/GAME_RULES_V1.md) ·
[Scenario authoring](docs/SCENARIO_AUTHORING.md)

## Run and contribute

```sh
flutter pub get
flutter run -d chrome
```

Scenarios live in `content/scenarios/v1/`; adding supported content needs no
widget changes. See [contributor rules](AGENTS.md),
[decisions](docs/DECISIONS.md) and [coaching review](docs/COACHING_REVIEW.md).
Runtime AI, backend/accounts, multiplayer, full-round simulation and complete
scoring are post-MVP. The trainer's decisions and coaching work locally.

## Development and manual testing

This checkpoint has sixteen independent hands: five Dash/enter decisions and
eleven normal-bidding situations. All 73 legal choices have deterministic authored feedback.
Read the [coaching review](docs/COACHING_REVIEW.md) for rating rationale.
A reviewed play-practice session is available from the table icon in the top
bar (see below). There is no full auction, simulated outcome, saved progress,
winner resolution or scoring yet.

A Session Selector (EC-049) shuffles each session's scenario order,
independent of catalog/filename order; **Practice again** requests a new
shuffled order rather than resetting to the first loaded scenario. Hand/
situation position in a session is therefore not fixed — identify a hand or
situation by its title, not by its number in the list below.

Validated toolchain: Flutter 3.44.1 stable / Dart 3.12.1.

```sh
flutter pub get
flutter run -d chrome
```

Alternatively, run `flutter run -d web-server --web-port 8082` and open
http://localhost:8082. Stop the app with `q` in its terminal. Native runners are
generated but unvalidated; use `flutter devices` to see available targets.

### What to test

1. See a 13-card hand and South's position. The first hand loads at random:
   either **Before bidding · Trump unknown** (a Dash/enter hand) or
   **Normal bidding · Choose a legal raise** (a hand with prior bid history,
   Dash unavailable).
2. On a Dash/enter hand, choose **Dash · 0 tricks**: expect **Weak decision**
   and a fixed zero estimate. Open **More detail** for the explanation and
   evidence. Choose
   **Try another choice**, then **Enter bidding**: expect **Strong decision**,
   with no target chosen yet.
3. On a normal-bidding hand, choose **4**: only the suits legal at that trick
   count are enabled. Choose **5**: more suits unlock. Select an enabled suit,
   then drop back to a trick count that no longer supports it: the suit
   clears and **Review bid** is disabled until a legal pair is chosen.
4. Submit a legal raise and check the rating (**Strong**, **Reasonable**,
   **Risky** or **Weak decision**) against its one-line verdict, then open
   **More detail** for the full explanation. Outcomes are explicitly not
   simulated.
5. Choose **Next hand** repeatedly through all sixteen hands — five
   Dash/enter decisions and eleven normal-bidding situations, comparing
   balanced vs. singleton-heavy hands, trump-control targets, single-trump
   sizing judgments (both short-and-solid and long-but-light suits) and
   two-suit ambiguous choices. All 73 legal choices across the pack have
   deterministic authored feedback; read the
   [coaching review](docs/COACHING_REVIEW.md) for rating rationale.
6. Finish all sixteen hands, then **Practice again**: a freshly shuffled
   session order loads — not necessarily the same first hand as before.
7. Resize to 320px and increase text size: cards and controls should wrap and
   remain reachable by scrolling. Use Tab/Enter to choose buttons and chips.
8. Refresh: a new shuffled session starts. Progress is not persisted in this
   checkpoint.

### Test Play practice

1. Tap the table icon at the top right (tooltip/accessibility label:
   **Play practice**).
2. Verify North above, West left, East right, and **You · South** below the
   current trick, with the leader's seat labelled **Led &lt;suit&gt;** and the
   other two opponents labelled with their taken-trick count.
3. The session presents all seventeen situations in a shuffled order; find
   each one by its title rather than its position:
   - **"A free trick with the ace of Hearts"**: Hearts were led; the 2 of
     Clubs and 5 of Diamonds are locked because you hold Hearts. Playing the
     ace is **Strong decision**; playing the three is **Weak decision**.
   - **"The last spade wins an open trick"**: you are void in the led suit,
     so both 2 of Spades (trump) and 7 of Clubs are legal. Play the 2 of
     Spades: expect **Strong decision** — it wins the open trick outright
     since you act last. Try **Try another choice**, then play 7 of Clubs
     instead: expect **Weak decision** for giving away a needed trick.
   - **"A likely trump winner, not a certain one"**: unlike the two
     situations above, you do not act last here — East still plays after
     you. Playing the king of trump is **Strong decision** as the likely
     best card, but the feedback is explicit that East holding the trump
     ace is a real, unresolved possibility, not ruled out.
   - **"Two unknowns instead of one"**: an even more uncertain variant —
     you act second, with both East and North still to act after you, not
     just one. The jack of trump is still **Strong decision**, but the
     feedback names the compounded uncertainty explicitly.
4. Three situations train the exact target:
   - **"One trick short of your target"**: status **Below target**, taken 3,
     target 4. King of Hearts is **Strong decision**; three is **Risky**.
   - **"Four is enough"**: same cards, taken 4, target 4, **Exactly on
     target**. Three of Hearts is **Strong decision** for deliberately
     losing; king is **Weak decision** for taking an unwanted fifth trick.
   - **"Already past four"**: **Already above target**, taken 5, target 4.
     Club loses and spade wins. Both are **Reasonable**: neither restores
     four, and no scoring preference is asserted. Read both explanations.
   Use **Try another choice** to compare. Counts and **Before this play**
   status remain the original snapshot after committing either card.
5. **"A trump is already on the table"**: on four of four, play 2S beneath
   the visible JS for **Strong decision**; KS takes an unwanted fifth
   (**Weak decision**); 7C also loses (**Reasonable**).
   **"One more trick in Sans"**: below target in Sans, AH is **Strong**, QH
   **Reasonable**, 3H **Risky**; 2C is locked. Compare under **More
   detail**: both high Hearts win now; future leads are not predicted.
   **"Either trump wins — save the stronger one"**: below target, no trump
   played yet, and both of your own trumps would currently win — the lower
   one is **Strong decision** (wins while preserving the stronger card for
   later); the higher one is **Reasonable** (also wins, just less
   efficiently).
6. Six situations add an **Observed play** section above the current trick
   (or, in one case, above an empty one — see below): a compact, muted
   earlier trick, not labelled as "the last trick" since it is only the
   evidence relevant to this decision. In **"Save the king from a known
   void"**, that trick shows East failing to follow Diamonds — playing the 3
   (saving the now-unbeatable king) is **Strong decision**; playing the king
   is **Risky** because East's void means East decides whether it gets
   trumped. The pack does not compute this itself — voids are never
   authored, only derived from the shown history. In **"A known void that
   doesn't apply here"**, South acts last in the current trick, so an
   observed void from an earlier, different-suit trick cannot matter to this
   decision either way — the king is **Strong decision** regardless, and the
   four discards a trick that was already safe. In **"Leading around a known
   void"**, there is no current trick yet — you lead. Leading the ace into
   the suit where West is known void is **Risky**; leading a different suit
   with no such evidence is **Strong decision**.
7. **"Below target, and a known void backs the play"**: two signals in one
   decision — East's known trump void (from an observed trick) and South
   being below target. **More detail** distinguishes them explicitly: the void is
   decisive (it means East cannot overtrump at all), being below target is
   supporting context (it is why taking the trick, rather than passing,
   matters here).
   **"The same visible trump, an opposite target"**: reuses "A trump is
   already on the table"'s exact mechanism — an opponent's trump already
   visible in the current trick — but this time South is below target
   instead of exactly on it, so overtrumping (not undertrumping) is the
   **Strong decision**. Compare the two side by side: identical evidence,
   opposite target, opposite correct action.
8. Selecting a card moves it visually into the current trick with a short
   flight animation and locks further play; reduced-motion settings skip the
   flight. Coaching opens compact — rating plus a one-line verdict — with
   **More detail** revealing the full explanation and every evidence point,
   same as bidding feedback.
   **Outcome: not simulated** — no winner is resolved or scored yet.
9. Finish all seventeen situations, then **Practice again**: a freshly
   shuffled session order loads — not necessarily the same first situation
   as before.
10. Back returns to the same bidding hand and any feedback already displayed.
11. At 320px width and large text, scroll through the table and hand. Seat
    labels, suit shapes, cards and selection controls should remain readable.

This is a reviewed pack (17 situations, 36 evaluated choices) connecting the
completed portable play contract (EC-046) to coached play (EC-047), derived
void tracking (EC-042), six exact-bid-protection scenarios (EC-043), and two
Mixed tactical reading scenarios that each combine two of these signals in
one decision (EC-055). Winner resolution and scoring remain out of scope; see
the confirmed [trick-winner rules](docs/GAME_RULES_V1.md#trick-winners), not
yet used by any resolver.

Egyptian Arabic language switching and local game terminology are tracked in
EC-060. The language option is not implemented yet. The owner-confirmed
[glossary](docs/EGYPTIAN_ARABIC.md) distinguishes الكول from each player's trick
estimate (طالب كام؟).

### Automated checks

```sh
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
dart run tool/validate_scenarios.dart --require-complete
flutter build web
```

Strict validation should pass all thirty-three scenario files (sixteen bidding, seventeen play)
with no missing evaluations. Tests cover cards, game rules, derived void
tracking and the known winning auction bound: a supplied bid of 4 cannot
accompany estimate 5; absent auction context stays supported. Regression tests
exercise domain, parser and strict catalog rejection. Tests also cover
parser/schema alignment, validator failure cases, authored
evaluation, bundled loading, legal choice controls, feedback, session
restart, load retry, card-commit animation (including reduced motion and
route disposal mid-flight), and a 320px layout with double text scaling for
both the bidding and play trainers. The Session Selector (EC-049) is tested
separately for reproducible seeded order, permutation/no-duplicate guarantees
and previous-session-last avoidance; both trainers are tested to request a
new session order on "Practice again" rather than resetting to the first
loaded scenario. The variant mechanism v1 (EC-055) is tested separately for
same-seed reproducibility, source-scenario immutability, unchanged
rating/evaluation mapping and rejection of an invalid taken-trick
redistribution; it is domain-tested only and not yet reachable from either
trainer's UI.
The older card specimen remains independently tested.

Canonical rules: [game_rules_v1](docs/GAME_RULES_V1.md).
Content contract and CLI usage: [authoring guide](docs/SCENARIO_AUTHORING.md).
