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

The two scenarios are independent hands. Choosing Dash fixes zero for that hand;
Next hand opens a different hand. No full auction, outcome, score, or progress
history is simulated. Feedback labels decision quality and explicitly says that
outcome is not simulated. Evidence is available under Why?.
