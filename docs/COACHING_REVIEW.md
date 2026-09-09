# First bidding trainer content review

Reviewed during implementation on 2026-09-07 for the first user-test checkpoint.
These are authored strategic judgments, not measured win probabilities or an
owner endorsement. User testing should assess both the interaction and coaching.
The authoritative rules remain [game_rules_v1](GAME_RULES_V1.md).

## Three Aces: Dash or enter

`bid_enter_controls_001` is a pre-bidding hand with no known trump or earlier
actions. All 13 cards are unique. Both Dash and enter are legal.

Entering is strong: three Aces and AKQ in a five-card Spade suit provide controls
and options. Dash is weak because committing to exactly zero with these cards is
fragile. Neither rating assumes every Ace wins; trump and distribution are unknown.
Both choices have feedback. Enter does not invent a winning bid or trump.

## Strong Spades, uncertain side winners

`bid_safe_probable_001` faces North's 4 Hearts after West passes. Its 13-card hand
is unchanged. Legal authored raises are 4 Spades, 4 Sans, and all five trump
categories for bids 5–7: 17 choices, all evaluated.

The old 4 Spades rating changes from strong to reasonable. The Spade Ace controls
trump; the Diamond Ace is a likely side winner when opponents follow suit. Extra
Spade tricks require promotion or useful ruffs. The Heart King and Diamond Queen
are conditional. This is a plausible four-trick plan, not four guaranteed tricks.

4 Sans and 5 Spades are risky: the former loses ruffing opportunities, while the
latter requires additional conditional winners. The remaining choices are weak
for this hand: higher targets stretch the controls; Hearts and Diamonds are short;
Clubs lack top control. Each choice explains its own target and trump risk.
These coarse ratings compare plans in this authored situation; they do not claim
an optimal bid proven by simulation or unknown opponent cards.

## Runtime contract

The evaluator returns the exact authored entry for a legal choice, returns null
for missing legal feedback, and rejects illegal choices. The training loader
rejects incomplete catalogs before showing decisions. It discovers JSON assets
in sorted filename order and rejects duplicate IDs. Content additions must pass
strict validation and receive the same strategic review.

Sorted filename order is a catalog-loading detail only, not the order shown to
the player: the Session Selector (EC-049) shuffles the loaded catalog into
each practice session, so scenario position in a session carries no
authorial/reasoning intent.

The initial checkpoint's two scenarios are independent hands. Choosing Dash fixes zero for that hand;
Next hand opens a different hand. No full auction, outcome, score, or progress
history is simulated. Feedback labels decision quality and explicitly says that
outcome is not simulated. Evidence is available under Why?.

## Ten-hand pack review (EC-033)

The first two hands above are unchanged. Eight more independent situations were
reviewed during implementation on 2026-09-07. The catalog now has 10 hands and 53
legal choices, all with authored feedback. These remain strategic judgments for
user testing, not owner-approved ratings or simulation results.

| ID suffix | Main lesson | Rating review |
| --- | --- | --- |
| training_003 | Low balanced hand | Dash and enter are both reasonable. Low cards across four suits support zero, but surviving cards may win later. Enter does not require an opening bid. |
| training_004 | Singleton King | Dash is risky because following Spades forces the King. Enter is reasonable without claiming the hand can open. The Ace can beat the King, so a win is not guaranteed. |
| training_005 | Seven low Clubs | Dash is risky despite no high honors: length can create late winners, particularly if Clubs become trump. Enter is reasonable, not a promise of seven tricks. |
| training_006 | Six Hearts headed by AKQJ | 5 Hearts is strong; 4 risks overtricks and 6 is reasonable with distribution risk. Sans gives up trump control; 4 is reasonable while 5/6 are risky because of weak Clubs and access. |
| training_007 | Five Diamonds headed by AKQ | 4 Diamonds is reasonable, 5 strong, 6 risky. Heart Ace supports the plan; Spade King is conditional. Sans 4 is reasonable, 5 risky, 6 weak without enough established extras. |
| training_008 | Raise 4 Sans with 5 Clubs | 5 Clubs is strong and 6 reasonable with six Clubs headed by AKQJ. Choosing Spades is weak at either target because 7-2 offers little trump control. Count outranks suit category. |
| training_009 | Three Aces and Club promotion | Facing 4 Hearts, 4 Sans is reasonable but 5 is risky and 6 weak. KQ Clubs face the missing Ace. Three-card Spades make 4 risky and 5/6 weak. East's existing Dash fixes zero and supplies no hidden card information. |
| training_010 | KQ doubleton versus AKQxx Hearts | 4 Hearts is reasonable, 5 strong, 6 risky. 4 Spades is risky and 5/6 weak: two high honors without the Ace do not replace trump length. |

Each new hand has 13 unique cards. Pre-bidding hands show no known trump; normal
hands offer no Dash. Normal histories either contain no prior action, a legal
4 Sans, or a legal 4 Hearts. Authored bounds are exercises, not every possible
bid in the game. Every legal choice within those bounds is evaluated. The three
extra pre-bidding hands have 2 choices each; the five normal hands have 6, 6, 4,
6, and 6 choices respectively (34 new choices plus the original 19).

Review checked each suit holding against the evidence, compared ratings across
counts and trumps, and kept conditional side honors distinct from top controls.
No numerical probability, scoring rule, auction termination rule, or fixed-trump
round was introduced. The authoring guide's old suggestion to Dash merely because
a hand cannot open was corrected: a zero-trick commitment is a separate judgment.

The application discovers these files without widget changes. Test coverage now
loads the complete bundled catalog, evaluates every authored choice, and walks
through all ten hands to session completion; earlier focused two-hand tests remain.

## First play pack review (EC-047)

Reviewed during implementation on 2026-09-08, then corrected during a
multi-agent safety audit the same day. Both scenarios live under
`content/scenarios/v1/play/` and are independent single-card decisions, not a
continuing hand. The authoritative trick-winner rule is the owner-confirmed
[game_rules_v1](GAME_RULES_V1.md#trick-winners): the player position in both
scenarios is the last of the four seats to act in the current trick, so the
outcome of that specific trick is fully decided by the visible cards once
their card is chosen — no hidden hand or future play affects it.

### `play_safe_probable_001` — A free trick with the ace of Hearts

**Teaches:** recognizing a trick that is already won if you take it, versus
giving it away for no visible reason. Hearts are led; the player holds the
ace and a low Heart and must follow suit, so the only choice is which Heart
to play.

**Ratings:** playing the ace is `strong` — no card already on the table beats
an ace, and since the player acts last nothing else can be added to the
trick. Playing the three is `weak` — it lets the eight of Hearts win the same,
already-decided trick instead, while the player's target still needs three of
the remaining four tricks.

**What makes this deterministic:** all four seats' contribution to the trick
is either already visible (`current_trick`) or about to be fixed by the
player's own choice (last to act); `trick_estimate` and `tricks_taken` are
authored facts from the scenario file, not inferred.

**Not claimed or simulated:** which card the player should keep for a
*different, later* trick is not evaluated — only this trick's outcome. The
feedback avoids saying the low card "costs nothing" or has "no benefit";
holding the ace back does not change how *this already-decided* trick
resolves, but the scenario does not simulate or rule out any hypothetical
value the held-back card might have in a future trick, since no later trick
is modeled. No opponent hidden cards, turn order beyond this trick, or
scoring are simulated.

### `play_safe_probable_002` — The last spade wins an open trick

**Teaches:** recognizing that a trump card wins an unclaimed trick outright
when acting last, regardless of the trump's rank — the same "already-decided,
last-to-act" pattern as `play_safe_probable_001`, applied to a void suit
instead of following suit. This scenario does **not** test tracking
previously played cards, deducing an opponent's void suit from earlier play,
or any other card-tracking skill — the player's own void is directly given by
their listed hand, not something they must infer from history. It was
originally tagged `card_tracking`; that label was corrected to
`safe_vs_probable` before this pack shipped, since presenting it under
`card_tracking` would have recorded misleading skill telemetry once EC-050
adds skill tracking. (See [D-017](DECISIONS.md).)

**Ratings:** the player holds no Diamonds (the led suit), so any card is
legal; playing the two of Spades (trump) is `strong` — per game_rules_v1, a
trump beats every non-trump card regardless of rank once no other trump is in
the trick, and the player acts last so nothing else can be added. Discarding
the seven of Clubs is `weak` — it lets the queen of Diamonds win the same
trick instead, while the target still needs one of the remaining two tricks.

**What makes this deterministic:** the situation states no trump has yet
appeared in `current_trick`; game_rules_v1 states a played trump always beats
a non-trump card. Combined with the player acting last, the trick's winner
follows directly from the rules for either legal choice.

**Not claimed or simulated:** the seven of Clubs point avoids asserting there is
"no benefit" to holding trump back, since the final trick (the only one left
after this) is not modeled — whether trump would still be needed or would
still win it is genuinely unknown from this scenario alone. The feedback only
states what follows from discarding specifically: the two of Spades then
becomes the player's sole remaining card, so it is what gets played into that
unresolved final trick. Playing the two of Spades now instead would leave the
seven of Clubs as that remaining card; the "sole remaining card" fact depends
on which card is chosen now, not on the decision being irrelevant.

### Runtime contract (play)

`PlayScenario.evaluate` mirrors the bidding evaluator: it returns the exact
authored entry for a legal card, null for a legal card without authored
feedback, and throws for an illegal card. `loadPlayScenarios` rejects an
incomplete pack before a session starts, the same as bidding. Neither
schema/domain validation nor these tests certify coaching quality — that is
this review. Every play scenario is a single-decision snapshot; no trick
winner is computed by the app, no outcome is simulated, and taken-trick
counts are not updated after a commit.

## Void-tracking pack review (EC-042)

Reviewed during implementation on 2026-09-08. All three scenarios live under
`content/scenarios/v1/play/` and add `observed_tricks`: prior tricks visible
to the player, from which void suits are *derived* (`lib/core/game_rules/
void_tracking.dart`), never authored as a flat fact. The derivation rests on
the already-confirmed [follow-suit rule](GAME_RULES.md#ec-021-following-suit):
a seat that could follow the led suit must, so an observed off-suit play
proves that seat held none of it. No new game rule is introduced by this
pack; `docs/GAME_RULES_V1.md#trick-winners` remains unimplemented and unused
here, same as the earlier pack.

### `play_void_tracking_001` — Save the king from a known void

**Teaches:** the flagship lesson — the correct choice *changes* once a known
void is accounted for. Diamonds are led; the player holds the king and a low
Diamond and must follow suit. The naive instinct ("play your best card") says
king; the void-aware read says three.

**Ratings:** playing the three is `strong` — East is already shown void in
Diamonds (an earlier trick: Diamonds led, East played a club) and is free to
trump this trick regardless of which Diamond is offered, so playing the king
would expose it to that known void for no gain; the ace of Diamonds is
already out, so the king is the highest Diamond left and keeps genuine
winning potential once it is not exposed here. Playing the king is `risky` —
not `weak`, because there is a genuine (if unlikely) chance East declines to
trump and the king wins outright; the avoidable risk is exposing the best
remaining card to a known void on a trick you do not control, when an
equally-losing, cost-free alternative (the three) is available. Neither
rating claims the retained king is *guaranteed* to win a future trick — only
that keeping it avoids a known, avoidable exposure.

**What makes this deterministic:** the observed trick shows East playing a
club when Diamonds were led — sound proof of void by the follow-suit rule,
not a guess. The ace being already played is a plain fact from the same
observed trick. Whether East *chooses* to trump is not claimed as certain —
only that East is *free* to. Whether the preserved king actually wins some
later trick is not claimed either; no future trick is modeled. East is the
seat that plays after South here (owner-confirmed rotation, leader North:
North → West → South → East).

**Confirmed non-decorative:** `test/scenarios/play_scenario_test.dart`
asserts that removing `observed_tricks` from this file leaves nothing in the
situation that reveals East's void, i.e. the authored rating's stated
rationale genuinely depends on the shown history. This is not an algorithmic
proof that the rating is the objectively optimal decision — ratings remain
authored judgment, the same as every other scenario in this project.

### `play_void_tracking_002` — No trump can save this trick

**Teaches:** in Sans, a known void is not merely risky for the void player —
it is a *guarantee* for everyone else, since game_rules_v1 states only the
led suit can win in Sans. East is shown void in Hearts; the player holds the
king and a low Heart, already ahead of North's and West's cards.

**Ratings:** the king is `strong` — East cannot add a Heart (confirmed void),
and in Sans a card that cannot follow suit can never win, so no card left in
this trick can beat the king. The two is `weak` — the king guarantees this
specific trick in Sans, and the target's exact estimate still requires both
of the two remaining tricks, so conceding a trick that is already certain
moves it into the harder, uncertain remainder for no offsetting benefit
identified in this situation.

**What makes this deterministic:** the observed trick's void evidence plus
the Sans-only-led-suit-wins rule combine to a closed case — no opponent
behavior needs to be predicted, unlike the trump-round scenarios.

### `play_void_tracking_003` — The same trap in a different suit

**Teaches:** a second, independent instance of `play_void_tracking_001`'s
"preserve your master card against a known void" pattern — same seat (East,
the seat that plays after South whenever North leads), different suit
(Clubs) and trump (Hearts) — reinforcing pattern recognition rather than one
memorized case. Ratings and reasoning mirror `_001` exactly, substituting
Clubs for Diamonds.

### Runtime contract (void tracking)

`knownVoidSuits` (`lib/core/game_rules/void_tracking.dart`) is pure and
independently tested from the parser/UI (`test/core/game_rules/
void_tracking_test.dart`): following suit never infers a void; an off-suit
play always does; repeated evidence for the same suit deduplicates; a player
can be void in several suits at once; an empty trick (leading) is skipped
safely; the in-progress current trick can reveal a void just as validly as an
earlier one; and loading the pre-existing `safe_vs_probable` scenarios (no
`observed_tricks`) still resolves to no known voids anywhere. `observed_tricks`
is an author-curated, visible *subset* of prior play — not a claim that it is
the most recent trick or the complete round history. Seat succession
*within* one trick is validated against the owner-confirmed rotation (see
[game_rules_v1](GAME_RULES_V1.md#play-direction--seat-rotation)), but no
attempt is made to validate leader succession *between* tricks, since that
would require a trick-winner resolver this project does not have.

## EC-043 — Exact-target checkpoint (2026-09-09)

Three scenarios and all six legal choices were reviewed against
`game_rules_v1`. These are authored local judgments, not statistical proof of
optimal full-hand play. Schema/domain checks validate structure and legality;
they do not prove the coaching ratings. No hidden cards, scoring or future
leader succession are assumed. All three place South last after East → North
→ West, so the current trick's winner is knowable from the shown cards.

### `play_target_protection_001` — One trick short of your target

South has three of an estimated four tricks. Hearts were led; KH and 3H are
the only legal cards. KH beats QH, 8H and 7H with no player left to respond.
Taking this guaranteed needed trick is strong; passing it with 3H is risky
because later opportunities are unknown, rather than declared certainly bad.
The retained king might win later. Taking the king now reaches four locally
but does not guarantee avoiding all three remaining tricks.

### `play_target_protection_002` — Four is enough

Identical cards, trump and turn position isolate the changed public count:
South already has four of four. Playing 3H is strong because QH wins and
South avoids an extra trick. KH is weak because it certainly takes a fifth
when a legal losing alternative exists. This is intentionally losing to
protect the exact target, not treating a trick win as automatically good.
Keeping KH may be dangerous later, but those tricks are unresolved; conceding
this trick preserves the possibility of an exact finish rather than promising it.

Both four-card snapshots have nine completed tricks in their taken maps.
No auction bid or full estimate set is needed or inferred.

### `play_target_protection_003` — Already past four

South has five of four, with two cards and eleven completed tricks. South is
void in Hearts, making both cards legal. Discarding 7C loses to QH; 2S is the
only trump and wins. Neither can undo the fifth trick already taken.
Both are reasonable: without scoring or another modeled objective, declaring
one a superior recovery would invent a preference the exact-target rule does
not provide. The club avoids additional excess but is not claimed to improve
points or restore exact success. This contrasts with _002, where avoiding the
trick still protects a reachable exact target.

### Contract and verification

No parser/schema extension or authored target flags. `classifyExactBid`
classifies the visible estimate/taken snapshot for the generic pre-play label;
the UI never updates that count on submission. Tests cover the reversed
preferred choice, all three labels, both submissions per scenario, unchanged
pre-play counts, and catalog loading/session completion. Future supported
scenarios require only portable content and review documentation.

## EC-043 — Final two scenarios / frozen checkpoint 1

Reviewed both new scenarios and all six legal choices against `game_rules_v1`.
The pack now has five exact-target scenarios and twelve evaluated choices.
No observed history is necessary: the current trick and hand contain the
evidence used. No flags, hidden hands or assumed future cards are authored.
South acts last in both (East → North → West → South); current-trick outcomes
below follow the confirmed rules but are not computed or progressed by the app.

### `play_target_protection_004` — A trump is already on the table

South is on target at four, with KS/2S/7C. Hearts were led, and North played JS
between East's 9H and West's QH. South has no Hearts, making all three choices
legal. North's off-suit play also reveals North's Heart void, though the actual
JS already on the table is sufficient evidence for this decision.

- **2S — strong:** undertrumps JS and certainly loses. This is an opportunity
  to shed trump while preserving the exact count for this trick.
- **KS — weak:** overtrumps JS and certainly takes an unwanted fifth trick.
- **7C — reasonable:** certainly loses too, but keeps both trumps. The preference
  for shedding 2S while covered is an authored local judgment, not proof that
  retaining KS/7C is always better than KS/2S through unknown future leads.

**Non-decorative evidence check:** replace North's JS with a legal low Heart
in a hypothetical alternative table. Then 2S would win as the only trump, while
7C would still lose. The target is unchanged, but the safe trump disposal is
gone: `Taken == Target` alone cannot select the right card. This hypothetical
explains the review, not an additional authored scenario or runtime variant.
No claim says the retained KS is guaranteed to lose later; higher trumps and
future leads are unknown. The ten taken tricks match a three-card hand.

### `play_target_protection_005` — One more trick in Sans

South is below target at three of four, with AH/QH/3H/2C in Sans. East's 8H,
North's JH and West's 9H make **both AH and QH certain current winners**.
The three Hearts are legal; 2C is locked by follow-suit.

- **AH — strong:** cash the highest Heart for the last needed trick. It avoids
  retaining an ace that cannot be beaten if Hearts are led later.
- **QH — reasonable:** also takes the needed trick, but preserves that ace just
  as further tricks become unwanted. The retained ace might be discarded on
  another suit later, so this is not graded as certain failure.
- **3H — risky:** passes up a needed certain trick and leaves both high Hearts
  to manage. Later success remains possible and is not simulated.

**Strategic distinction:** unlike _001's take-versus-pass choice, there are two
winning plays. Spending the ace rather than preserving it balances obtaining the
needed trick against managing future unwanted winners. The queen might lose to
KH if that card is still available, or might itself win; an unseen king is not
assumed to remain unplayed. No future lead is asserted. Strong versus reasonable
expresses reviewed judgment about this exposure, not an optimality proof over
unseen deals. The nine taken tricks match the four-card hand.

### Checkpoint verification boundary

Strict validation checks complete legal-choice coverage and public-state legality.
The existing catalog-driven session tests load and exercise new files without
test/UI registration changes. Coaching quality is supported by the explicit
review above, not inferred from passing automated checks. No rule or capability
extension was needed. Checkpoint 1 closes; checkpoints 2 and 3 remain unfinished,
so the Variety gate still earns zero and readiness stays 45%.

## EC-048 — Known auction bound correction (2026-09-09)

Reviewed all production play scenarios, the JSON contract fixture, and inline
play test setups against the confirmed estimate bound. The sole affected JSON
file was `play_safe_probable_001`: its winning auction bid was 4 Clubs while
South's estimate was 5. Corrected the auction bid to **5 Clubs**, retaining
the estimate of 5, South's two taken tricks, all cards, and all feedback.

Re-review: South still needs three of the four remaining tricks. Acting last,
AH wins the current all-Hearts trick; 3H concedes it. The strong/weak ratings
and their stated local rationale are unchanged. Raising the auction context
does not reveal caller identity, hidden cards, or future winners, and no
coaching depended on the former bid of four. Equal estimate/bid counts are
permitted for either the Caller or another player.

The inline domain test formerly accepting estimate 13 with bid 5 now uses
valid bounded values. Separate regressions preserve estimate 13 with bid 13
or without auction context. The contract JSON fixture (estimate 1, bid 4) and
all other production scenarios needed no correction. Strict catalog regression
restores the old 5-versus-4 mismatch in a temporary copy and verifies rejection
with a file/path diagnostic while the valid file continues to be checked.

## EC-055 — Checkpoint 3 coverage batch 1 (6 new base scenarios)

Reviewed all six new scenarios and every legal choice against `game_rules_v1`.
Each closes a gap identified by the checkpoint 3 coverage matrix
([MVP_STATUS.md](MVP_STATUS.md#checkpoint-3-coverage-matrix-ec-055)); none is
a suit/rank reskin of existing content. No schema, UI or variant-mechanism
change was needed for any of them.

### `bid_training_011` — Nothing above a six

Deterministic fact, directly checkable against the thirteen cards shown: no
Ace, King, Queen or Jack anywhere in the hand, and no card ranked above a
six. **Dash — strong**, the first Dash/Enter scenario where Dash itself
reaches Strong rather than Reasonable or Weak. **Enter — reasonable**,
consistent with every other Dash/Enter scenario: entering commits to
nothing yet, so it stays at least defensible regardless of hand strength.

**Non-decorative evidence check:** compare against `bid_training_003` ("Low
cards across four suits"), rated Dash-reasonable. That hand reaches 7s and
8s and a four-card Club suit; this hand never exceeds a six and no suit
exceeds four cards. The rating difference tracks a real difference in the
cards, not an arbitrary escalation.

### `bid_training_012` / `_013` — Bid sizing with a single trump offered

Both scenarios offer exactly one trump (`allowed_decisions.trumps` has one
entry), so every legal choice is a trick-count judgment on an already-fixed
trump, not a trump comparison — the trump_selection family (`_006`–`_010`,
`_014`) always offers two.

- `_012`: Ace-King-Queen-Jack of Spades is a deterministic four-honor trump
  base. **4S — reasonable** (safe, underuses the hand). **5S — strong**
  (matches the four honors plus one plausible side/length contribution).
  **6S — risky** (needs two conditional sources, not one). **7S — weak**
  (needs nearly everything conditional to land). The Queen of Diamonds and
  King of Hearts are explicitly flagged as conditional, never counted as
  certain.
- `_013`: King-Queen of Hearts (moderate, not solid, trump) plus the Ace of
  Spades and Ace of Diamonds (deterministic side controls) is a genuinely
  different profile from `_012`'s single overwhelming suit. **4H —
  reasonable**, **5H — strong** (three separate sources support it, not one
  suit stretching to cover it), **6H — risky** (needs a low Heart promoted
  by length on top of both Aces holding).

### `bid_training_014` — Two incomplete suits, no side support

Second Mixed/ambiguous bidding scenario (see `bid_training_009` for the
first, and the coverage matrix for why both keep `primary_skill:
trump_selection`). King-Queen of Spades and Ace-Jack of Hearts are
deterministically comparable in strength (two honors each, four-card
length each); Diamonds and Clubs are deterministically honor-free (nothing
above a nine). **4S/4H — reasonable**, explicitly stating the other is
"equally defensible" rather than implying a hidden preference. **5S/5H —
risky**, since neither candidate nor the side suits supports a fifth trick.
No evaluation in this scenario reaches Strong — an authored judgment that
this hand does not have a clearly correct answer, not an oversight.

### `play_safe_probable_003` — A likely trump winner, not a certain one

Deterministic facts: South is void in the led suit (holds no Diamonds), so
both cards are legal; the king of trump beats every card shown so far; East
has not yet acted. Unlike `_001`/`_002`, South does **not** act last here
(East does), so — unlike those two scenarios — this is the first
safe_vs_probable case where the feedback must explicitly decline to claim
certainty. **KH — strong**: reviewed as the better choice given the team is
below target, but the feedback states plainly that East holding the trump
ace is a real, unresolved possibility this scenario deliberately does not
rule out (no observed trick establishes a void for East here). **2C —
weak**: gives up a likely trick without reducing that same unresolved risk,
since the king is not "protected" by being held back — nothing about
discarding changes what East holds.

**Non-decorative evidence check:** if South instead held the trump ace, the
trick would be certain and this would collapse into the same shape as
`play_safe_probable_001`/`_002`. Using the king (not the ace) and leaving
East's holding genuinely unresolved is what keeps this a distinct
"probable, not certain" lesson rather than a third certain-win scenario.

### `play_void_tracking_004` — A known void that doesn't apply here

Deterministic facts: the current trick is Clubs; South acts last (East
leads, so the rotation is East → North → West → South); the king beats
every Club already played; the observed trick shows North void in
**Diamonds**, a different suit, in an earlier trick. **KC — strong**: the
king wins with certainty because South is last to act — no seat, void or
not, can respond after South's card this trick. **4C — weak**: gives away a
trick that was already certain, for no compensating safety, since the
shown void cannot affect a trick nobody can still respond to.

**Non-decorative evidence check:** this is the boundary-condition case the
`play_void_tracking_001`/`002` pattern needs to stay a real lesson rather
than a reflex ("void shown → always play the low card"). Replace the
leader with North (so East plays after South, as in `_001`/`_002`) and this
scenario's KC/4C choice would flip: KC would then risk being overtrumped by
a void East, and the Strong/Weak ratings would need to swap. The rating
here depends on South acting last, not on the mere presence of a shown
void; `play_void_tracking_003` (a suit reskin of `_001`, not a distinct
case — see the checkpoint 3 coverage matrix) never tested this boundary.

### Checkpoint verification boundary

Strict validation checks complete legal-choice coverage and public-state
legality for all 26 production files, unchanged from before this batch for
the existing 20. The existing catalog-driven session tests load and
exercise the six new files without test/UI registration changes; only the
hard-coded totals in `test/bidding_training_test.dart` (10→14 hands,
53→66 choices) needed updating, since those numbers describe the catalog's
size rather than any coaching behavior. Coaching quality is supported by the
explicit review above, not inferred from passing automated checks. No rule,
schema or capability extension was needed. Checkpoint 3 remains in progress:
25 of 32 base scenarios are authored, and the variant mechanism (D-023) is
still domain-tested only, so the Variety gate still earns zero and readiness
stays 45%.

## EC-055 — Checkpoint 3 coverage batch 2 (7 new base scenarios, matrix complete)

Reviewed all seven new scenarios and every legal choice against
`game_rules_v1`. Together they close every remaining gap in the checkpoint 3
coverage matrix ([MVP_STATUS.md](MVP_STATUS.md#checkpoint-3-coverage-matrix-ec-055)):
32/32. No schema, UI or variant-mechanism change was needed for any of them.

### `bid_training_015` — Seven Clubs, only one honor

Deterministic fact: seven Clubs, headed by a single Ace, no King/Queen/Jack
anywhere in the suit. **4C — reasonable** (safe, underuses the length).
**5C — strong**: the Ace plus exceptional length is a genuinely different
kind of support from a short, honor-dense suit — an authored judgment that
length alone, without concentration, still earns real credit. **6C —
risky**: needs the length to run two tricks past the Ace, not one.

**Non-decorative evidence check:** compare against `bid_training_012`
(Ace-King-Queen-Jack of Spades, six cards) — both reach Strong at five
tricks, but for structurally different reasons (concentrated honors vs. raw
length). If this hand's Clubs were only four cards instead of seven, the
length argument for a fifth trick would not hold, and 5C would need to drop
to at least Risky.

### `bid_training_016` — Length with a gap, or short and solid?

Third Mixed/ambiguous scenario. Deterministic facts: Spades is
Ace-Queen-Jack-nine-seven (five cards, King missing); Hearts is
Ace-King-six-four (four cards, no gap). **4S/4H — reasonable**, each
explicitly stating the other is "equally defensible." **5S/5H — risky**,
since neither the chosen suit nor the honor-free side suits supports a fifth
trick. No evaluation reaches Strong — an authored judgment that a
missing-honor suit with more length and a complete-but-shorter suit are a
genuine toss-up, not a hidden preference for one.

### `play_safe_probable_004` — Two unknowns instead of one

Deterministic facts: South is void in the led suit (holds no Diamonds), so
both cards are legal; the jack of trump beats every card shown so far; both
East and North have not yet acted (South acts second, not last). **JC —
strong**: reviewed as the best available choice given South is significantly
below target, but the feedback explicitly names that two seats, not one,
could still beat it — a real escalation of the unresolved risk in
`play_safe_probable_003` (one seat), stated plainly rather than treated the
same. **2H — weak**: cannot win regardless, gives up the strongest legal
card for no reduction in that same risk.

**Non-decorative evidence check:** if this hand were changed so South acts
last instead of second, the scenario would collapse into the same shape as
`play_safe_probable_001`/`_002` (a certain win). Keeping South second, with
two unresolved seats rather than one, is what keeps this a distinct
"degree of uncertainty" lesson rather than a fourth near-copy of `_003`.

### `play_void_tracking_005` — Leading around a known void

First void-tracking scenario where South leads (current trick empty) rather
than responds. Deterministic facts: the observed trick shows West void in
Clubs; from South leading, the rotation is South → East → North → West, so
West acts last in the new trick. **AC — risky**: leading the ace into the
suit where West is confirmed void offers West a free, already-evidenced
chance to trump it. **4D — strong**: avoids that one confirmed risk; the
feedback is explicit that this does not prove Diamonds are safe in every
sense, only that the one identified risk is avoided.

**Non-decorative evidence check:** this is a structurally new decision
point, not a reskinned response case — `play_void_tracking_001/002/004` are
all about which card to play into an already-started trick; here the
question is which suit to lead into, before any trick exists. The UI's
"You lead. Any card is legal." path (already built, previously untested by
any production scenario) is exercised for the first time.

### `play_target_protection_006` — Either trump wins — save the stronger one

Deterministic facts: East, North and West have all followed Clubs; no trump
has appeared yet; South is void in Clubs and holds two Diamonds (trump),
either of which currently wins since South acts last. **2D — strong**: wins
the needed trick while preserving the stronger trump. **9D — reasonable**:
also wins, but spends the better trump when the weaker one would have
sufficed — authored judgment about resource conservation, not a claim that
the nine is a mistake.

**Non-decorative evidence check:** distinct from `play_target_protection_004`
(which chooses between overtrumping, undertrumping, and discarding against
an opponent's *already-played* trump while exactly on target). Here no trump
has been played by anyone, South is below target and wants the trick, and
the choice is purely which of South's own two winning cards to spend.

### `play_mixed_tactical_001` — Below target, and a known void backs the play

First Mixed tactical reading scenario, combining two already-supported
signals without inventing a new one. Deterministic facts: East is confirmed
void in Spades (trump) from an observed trick; South acts before East in
this trick's remaining order; South is below target. **3S — strong**: the
feedback names the void as **decisive** (East cannot supply the one card
type that could beat a trump) and the below-target state as **supporting**
(why taking the trick, not just being safe to try, matters). **2C — weak**:
cannot win, gives away a trick the void makes unusually safe to attempt.

**Non-decorative evidence check:** remove the observed trick (no void
evidence) and this scenario collapses into the same shape as
`play_safe_probable_003`/`_004` — a merely probable trump play against an
unresolved responder. The void is what elevates it from probable to
effectively certain; the target state alone would not.

### `play_mixed_tactical_002` — The same visible trump, an opposite target

Second Mixed tactical reading scenario, deliberately reusing
`play_target_protection_004`'s exact mechanism (an opponent's trump already
visible in the current trick) with one variable flipped. Deterministic
fact: North has already played a low trump on this trick. **9C — strong**:
the feedback names South's below-target state as **decisive** (it is why
overtrumping, not avoiding, is correct here) and the visible trump as
**supporting** (it only establishes which card beats North's, not whether
winning is wanted). **2D — weak**: cannot beat the visible trump, gives away
an available and needed trick.

**Non-decorative evidence check:** swap this scenario's target state for
`play_target_protection_004`'s (exactly on target instead of below) and the
correct card would flip from overtrump to undertrump — proving the visible
trump alone does not determine the rating; the target state does, exactly
as the "decisive vs. supporting" split in the feedback claims.

### Fixture collision found and fixed during authoring

`play_mixed_tactical_001`'s original off-suit filler card, the ace of Clubs,
collided with `play_void_tracking_005`'s hand and broke an existing
cross-scenario test assertion in `play_training_test.dart`
(`scenarios.first.evaluate(scenarios.last.situation.legalChoices.first)`,
sensitive to alphabetical file order) once `play_mixed_tactical_001` began
sorting before `play_safe_probable_001`. Changed to the two of Clubs; the
card was never referenced by exact rank in that evaluation's own rating
(Weak, off-suit, cannot win), so only the feedback text needed rewording to
match. No rating or evaluated-choice content changed as a result.

### Checkpoint verification boundary

Strict validation checks complete legal-choice coverage and public-state
legality for all 33 production files, unchanged from before this batch for
the existing 26. The existing catalog-driven session tests load and exercise
the seven new files without test/UI registration changes; only the
hard-coded totals in `test/bidding_training_test.dart` (14→16 hands,
66→73 choices) needed updating. Coaching quality is supported by the
explicit review above, not inferred from passing automated checks. No rule,
schema or capability extension was needed — the two Mixed tactical reading
scenarios combine existing signals rather than introducing anything new.
The checkpoint 3 coverage matrix is now complete (32/32 base scenarios), but
checkpoint 3 itself remains in progress: deciding whether to wire the
domain-tested variant mechanism (D-023) into the product, and an owner
repeated-session review, are still open, so the Variety gate still earns
zero and readiness stays 45%.

## EC-055 — Owner review finding: `play_void_tracking_005` trick-winner inconsistency (D-025)

The owner's first checkpoint 3 repeated-session review pass found a real
game-state inconsistency, not a coaching-wording issue: the scenario's single
observed trick (East 7C, North 8C, West 5H, South 2C, trump Hearts) is won by
**West**, who trumped the led Club with 5H — not South. The scenario's
current, empty trick then authored `"leader": "south"`, contradicting the
standard rule that the winner of a trick leads the next one.

### Fix and re-review

Changed the observed trick's West and South plays only: West's discard is now
`3D` (off-suit, non-trump — still establishes the Club void this scenario
trains) instead of `5H` (a trump), and South's card is now `KC` (South's own
King of Clubs — not the Ace South still holds now) instead of `2C`. With no
trump played, South's King is the highest Club shown and legitimately wins,
making `"leader": "south"` correct.

Re-reviewed both evaluations against the new data:

- **AC — risky** (unchanged): the reasoning is entirely about the *current*
  trick South is about to lead, and West's Club void — both untouched by this
  fix. One point named the suit of West's historical discard ("a Heart");
  corrected to "a Diamond" to match. No other claim in this evaluation
  referenced the changed cards.
- **4D — strong** (unchanged): its central claim — that no void evidence
  exists for Diamonds — is, if anything, better supported now: West's
  historical discard being itself a Diamond is direct (if not conclusive)
  evidence West was not void in Diamonds at that point. Reworded one point to
  say so explicitly, without overclaiming that West still holds one now.

No rating changed. `author_notes` documents the correction in full, including
why the smallest possible change (two cards, not a redesign) preserves the
scenario's intended lesson: leading around a known void, still the first and
only leading (not responding) scenario in the pack.

### Audit and the resulting fix

Checked every production play scenario with `observed_tricks`
(`play_void_tracking_001/002/003/004/005`, `play_mixed_tactical_001`) for the
same class of bug: does the scenario's `leader` field assert something a
computed trick winner would contradict? `play_void_tracking_005` was the only
one with an empty current trick — the only situation where `leader` is
asserted with no other visible evidence (an already-shown first play) backing
it up. The other five were not touched: their current tricks are already in
progress with independently-visible leaders, and game_rules_v1's existing
"no claim of recency" principle for observed tricks means they never assert
their shown trick is the immediately preceding one.

Added `trickWinner` (`lib/core/game_rules/trick_winner.dart`, 9 tests)
implementing the already-confirmed game_rules_v1 rule for one
already-complete trick — but **not** a generic `PlaySituation` check
requiring every empty-current-trick leader to equal that helper's answer for
the last observed trick. `observed_tricks` is curated evidence, not
guaranteed contiguous with the current trick; a generic check would reject a
valid future scenario with an unshown trick between the last observed one
and the current empty one. Instead, `test/scenarios/play_scenario_test.dart`
gained one targeted regression test asserting this specific property for
`play_void_tracking_005` only, the one scenario whose own authored intent
(and title, "Leading around a known void") requires it. `SeatPlay` and
`ObservedTrick` moved to their own file, `lib/core/game_rules/seat_play.dart`,
so `trick_winner.dart` never imports `play_situation.dart` and no circular
dependency exists. Full rationale in [D-025](DECISIONS.md).

### Checkpoint verification boundary

324 tests pass. Analysis is clean, strict validation accepts all 33 content
files (unchanged count — this was a correction, not new content), and the web
build succeeds. This is a bounded correctness fix discovered during owner
review, not checkpoint 3 acceptance work: the coverage matrix stays 32/32,
readiness stays 45%, EC-055 is not marked DONE, and the owner's
repeated-session review continues.

## EC-055 — Owner review finding: `play_void_tracking_005`'s heuristic contradicted its own exact-target math (D-026)

The owner's review found a second, systemic issue: opponent estimates are
not shown at all (a genuine contract gap, scoped as its own follow-up PR —
see D-026), and — the correctness blocker fixed here — no check existed for
whether an authored rating was even *compatible* with the player's own
exact-target math for the current trick.

### The bug

South held 2 cards (2 tricks remain, including the pending decision), target
4, taken 2 — a `mustWinAll` state: both remaining tricks were required. The
scenario nonetheless rated **4D** Strong over **AC** Risky, purely because
4D avoided West's one known Club void. But 4D is a bare low card with **no
case for winning at all** — any reasonably-ranked Diamond from any of the
other three unknown hands beats it, independent of any void — while AC is
the Ace, unconditionally the highest possible card in its suit, beaten only
by the one specific, named risk (West trumping). Preferring the card with no
winning case over the guaranteed-winner-except-for-one-named-risk card, in a
state where losing this trick makes the target unreachable, was not a
defensible reading of the void evidence — the heuristic ("avoid the known
risk") was correct in isolation but wrong in scope, since it ignored that
avoiding one *named* risk by accepting a much larger *unnamed* one is not
actually safer when this specific trick cannot be spared.

### Audit

All 17 production play scenarios were classified by the new
`classifyTargetFeasibility` helper (taken vs. target vs. remaining tricks;
full table and rationale in [D-026](DECISIONS.md)). Six scenarios are
`mustWinAll`; five of the six already correctly recommend a card that wins.
`play_void_tracking_005` was the only exception. Separately, every
scenario's feedback text was checked for a claim requiring an *opponent's*
estimate specifically — none exist in current content, so no existing rating
is currently unjustified by that absence (the contract gap is real, but
hasn't yet produced a false claim).

### Fix and re-review

Rebalanced `tricks_taken`: South 2→3, North 3→2 (East and West unchanged;
sum stays 11, matching `13 - hand.length` for the unchanged 2-card hand). No
card, no void evidence, and no rating changed. This moves the scenario from
`mustWinAll` (need both of 2) to `slack` (need 1 of 2) — confirmed no
evaluation referenced North's specific taken count, so the rebalance is
strategically neutral.

- **AC — risky** (unchanged rating, strengthened reasoning): now explicitly
  states South needs only one more of the two remaining tricks, not both —
  losing this one shifts the requirement onto the final trick and the ace
  still in hand, rather than eliminating the target outright.
- **4D — strong** (unchanged rating, strengthened reasoning): same addition
  — the ace "remains available for the final trick" is now a true claim
  (there genuinely is one more trick to use it in), not a claim that was
  only true if this specific trick didn't matter.

This is the same shape `play_void_tracking_001` already uses successfully
(deliberately lose now, preserve the master card for the one trick still
needed) — the fix brings `_005` in line with that established, already-sound
pattern rather than inventing a new one.

### Regression coverage and its honest limit

`test/scenarios/play_target_feasibility_test.dart`: classifies all 17
scenarios against a reviewed table (a scenario added or edited without
updating it fails the test); proves `play_void_tracking_005` is now `slack`;
and, for the subset of `mustWinAll` scenarios where South acts last (so a
candidate's win/loss is mechanically provable via `trickWinner` from public
information alone — only `play_target_protection_006` currently qualifies),
asserts every Strong-rated card actually wins. The other four `mustWinAll`
scenarios cannot be checked this way without reimplementing the coaching's
own reasoning as a second, parallel engine (`play_void_tracking_002`
specifically depends on a derived void, not just visible cards) — that limit
is documented in the test file and here, not silently assumed away.

### Checkpoint verification boundary

338 tests pass (14 more than the prior batch: 10 `target_feasibility_test.dart`,
4 `play_target_feasibility_test.dart`). Analysis is clean, strict validation
accepts all 33 content files (unchanged count — a correction, not new
content), and the web build succeeds. Coverage matrix stays 32/32, readiness
stays 45%, EC-055 is not marked DONE, checkpoint 4 not started. The
owner's repeated-session review continues; the opponent-estimates contract
extension is scoped as a separate, non-optional follow-up PR (D-026),
starting only after this one is reviewed and merged.

## EC-055 — Owner review follow-up: public opponent estimates (D-027)

The follow-up scoped and queued by D-026 above, revised after owner review
rejected a first version that added the field but left every scenario empty.
All 17 bundled play scenarios now author a complete three-seat estimate set.
**No rating changed**; every evaluation was re-reviewed with the targets
visible, and this entry records that review.

### What changed

An `opponent_estimates` field (any seat except `player_position`), a matching
`PlaySituation.opponentEstimates` domain field enforcing three previously
unchecked game_rules_v1 estimate rules, and a `Target N · Taken M` label on
every opponent seat — including the seat that led, which previously showed
only `Led <suit>`. Contract details and the seat-generality and auction-bid
rules are in [D-027](DECISIONS.md).

### Authored sets, and why each is neutral

`R` is the remaining trick count (the player's hand size, including the
pending trick). "Needs" is `estimate - taken` for that seat.

| Scenario | Bid | R | N | E | W | S | Total | Opponent states |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| play_mixed_tactical_001 | 4 | 2 | 4 | 4 | 4 | 4 | 16 | all need 1 (forced) |
| play_mixed_tactical_002 | 4 | 2 | 4 | 3 | 4 | 4 | 15 | all need 1 |
| play_safe_probable_001 | 5 | 4 | 3 | 3 | 4 | 5 | 15 | all need 1 |
| play_safe_probable_002 | 4 | 2 | 4 | 4 | 3 | 4 | 15 | all need 1 |
| play_safe_probable_003 | 4 | 2 | 4 | 4 | 4 | 4 | 16 | all need 1 (forced) |
| play_safe_probable_004 | 4 | 2 | 4 | 4 | 4 | 4 | 16 | all need 1 (forced) |
| play_target_protection_001 | — | 4 | 4 | 3 | 3 | 4 | 14 | N needs 2, E/W need 1 |
| play_target_protection_002 | — | 4 | 4 | 3 | 3 | 4 | 14 | N needs 2, E needs 1, W needs 2 |
| play_target_protection_003 | — | 2 | 1 | 3 | 3 | 4 | 11 | **N already over**, E/W need 1 |
| play_target_protection_004 | — | 3 | 4 | 3 | 3 | 4 | 14 | N needs 2, E/W need 1 |
| play_target_protection_005 | — | 4 | 4 | 3 | 3 | 4 | 14 | N needs 2, E/W need 1 |
| play_target_protection_006 | 4 | 2 | 4 | 4 | 4 | 4 | 16 | all need 1 (forced) |
| play_void_tracking_001 | 4 | 2 | 4 | 4 | 3 | 4 | 15 | all need 1 |
| play_void_tracking_002 | 4 | 2 | 4 | 4 | 4 | 4 | 16 | all need 1 (forced) |
| play_void_tracking_003 | 4 | 2 | 4 | 3 | 4 | 4 | 15 | all need 1 |
| play_void_tracking_004 | 4 | 2 | 4 | 3 | 4 | 4 | 15 | all need 1 |
| play_void_tracking_005 | 4 | 2 | 3 | 4 | 4 | 4 | 15 | all need 1 |

Every set is rule-valid: no seat exceeds a supplied bid, every complete set
with a bid has some seat at exactly the bid (so a Caller is possible), no
total is 13, every set's maximum is at least 4 (the auction minimum, so a
Caller's bid exists even where `auction_bid` is absent), and no opponent is
authored at 0, which would be a Dash declaration this content cannot carry.

**No opponent is exactly on target in any scenario.** That is the one state
that would hand the player a reason to give a seat a trick specifically to
break it — opponent-punishing play this MVP does not teach. "Forced" above
marks seats on 3 taken under a 4-trick bid, where 4 is the only value that
keeps them below target at all; that is stated rather than resolved by
choosing an on-target value.

### Re-review with targets visible

**Twelve scenarios: no interaction with the decision.** In
`play_mixed_tactical_001/002`, `play_safe_probable_001/002/003/004`,
`play_target_protection_006` and `play_void_tracking_002/004`, the reviewed
line *takes* the trick. An opponent's target cannot change whether the
recommended card wins, and denying a below-target opponent aligns with the
existing Strong rating rather than competing with it. In
`play_void_tracking_004` South acts last with the winning card, so no
opponent state is even reachable by the decision.

**Three void-tracking scenarios: the targets reinforce the existing split.**
In `play_void_tracking_001`, `_003` and `_005`, the reviewed line concedes
the trick to protect a high card from a seat whose void is already confirmed.
That seat is now visibly below target, which makes it *more* evidently
motivated to trump — exactly the risk the Risky rating already cites. This
strengthens the authored reasoning without changing it; no feedback text was
edited, since the coaching already argues from the confirmed void rather than
from motive.

**Five target-protection scenarios: the estimates were chosen deliberately.**
These are the scenarios whose reviewed line concedes the current trick to
North, so North's target is the one state that could compete with the lesson:

- `play_target_protection_001` (take the needed trick), `_002` (deliberately
  lose at exactly four), `_004` (shed a trump under North's jack) and `_005`
  (spend the ace for the needed trick): North estimates 4 having taken 2, so
  it needs two more tricks. The trick North collects in the conceding line
  does **not** complete North's target, so no "am I finishing their contract?"
  question competes with South's own exact-target reasoning. In `_004` the
  choice under review is *which* losing card to play — both concede to the
  same seat, so opponent targets cannot separate them either way.
- `play_target_protection_003` (already past four, both choices Reasonable):
  North estimates 1 having taken 2, so North's exact target is already missed
  no matter what South does. With South also past four, neither choice can
  change any seat's exact-target outcome — which is precisely why both remain
  Reasonable, and the existing "no other objective or scoring rule is
  modeled" wording still carries. The four estimates total 11, so two tricks
  beyond the room's estimates must land somewhere; North's and South's
  overshoots are exactly that surplus, making the set internally coherent
  rather than arbitrary.

Each of these five choices is also recorded in its own file's
`author_notes`, so a future author editing `tricks_taken` sees why the
estimate was picked.

**Nothing was added to any coaching text about opponents' targets.** The
ratings are unchanged and still argue from the player's own exact target, the
cards on the table and derived voids. No scenario was found ambiguous enough
to need flagging for owner review.

### Regression coverage

`test/core/game_rules/estimate_totals_test.dart` (+2) covers
`includesCallerEstimate` directly: satisfied by any of the four seats or by
several at once ("With"), unsatisfied when nobody is at the bid, and
rejecting an incomplete set. `test/core/game_rules/play_situation_test.dart`
(+4) covers default empty, absent/partial/full acceptance, immutable
exposure, the excluded seat following `playerPosition` across all four
possible pending seats, the auction-bid bound (including no bound without a
bid), and both whole-set rules with proof that neither fires on a partial
set. `test/scenarios/play_scenario_test.dart` (+8) covers the schema/parser
round trip, no duplication of the pending player's seat, and rejections for
an unknown seat name, an out-of-range value, a fractional value, naming the
pending player's own seat, exceeding the bid, a complete set totalling 13,
and a complete set with no seat at the bid. `test/play_training_test.dart`
(+2) asserts every one of the 17 bundled scenarios renders a real
`Target · Taken` for all three opponents — including the leading seat, above
its `Led <suit>` line — with no `Target unknown` anywhere, and that a seat
whose estimate is removed falls back to the honest unknown label.

### Checkpoint verification boundary

358 tests pass (20 more than the prior batch). Analysis is clean, strict
validation accepts all 33 content files, and the web build succeeds. The
table was also checked in a browser at desktop and 375px widths, with no
overflow and no console errors. Coverage matrix stays 32/32 (these are edits
to existing scenarios, not new ones), readiness stays 45%, EC-055 is not
marked DONE, checkpoint 4 not started. The owner's repeated-session review
continues.

## EC-055 — Owner review: concise coaching by default (D-028)

A presentation change only. **No rating, no authored sentence and no
strategic meaning was altered**, and no scenario file was touched — this entry
records that, and the measurement behind the design.

### Why the suggested mapping was not used

The task proposed `summary` as the default one-liner with the first 1–2
`points` as compact default evidence. Measured over all 109 authored
evaluations:

| | summary chars (med/max) | multi-sentence summaries | first-point chars (med/max) |
| --- | --- | --- | --- |
| Bidding (73) | 97 / 176 | 14 of 73 | 92 / 156 |
| Play (36) | 153 / 250 | 20 of 36 | 92 / 156 |

That default would put roughly 350 characters of prose on screen — more than
the previous behaviour, and against the requirement that no long paragraph be
visible by default. The authored `title` is the field that already fits: 16–55
characters, and written as a self-contained verdict ("Take the free trick",
"Save the king; the ace is already gone", "A trump can be a losing card").

### What a player sees

Default: choice, rating, the authored `title`, the existing short factual
lines, then `More detail · N points`. Expanded: the full `summary` followed by
every `point`, verbatim. Nothing is truncated, split or paraphrased anywhere —
the full reviewed coaching remains one tap away for every evaluation in both
trainers, and the compact view is strictly shorter than what shipped before.

The one deliberate gap: no evidence point appears in the compact view, because
no authored field is short enough to promote without reintroducing paragraphs
(see [D-028](DECISIONS.md)). The action names the point count so the depth
behind it is still visible.
