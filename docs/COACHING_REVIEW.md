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
