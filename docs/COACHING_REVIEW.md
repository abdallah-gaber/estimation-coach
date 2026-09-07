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
