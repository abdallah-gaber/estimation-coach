# Egyptian Arabic — مصري

Owner-confirmed glossary, 2026-09-08. This is the source for player-facing
Egyptian terminology in EC-060. The language switch is planned, not implemented.
Use natural Egyptian phrasing in controls and coaching, not literal formal-Arabic
translations. Keep domain identifiers and portable rule codes in English.

| Concept | Player-facing term |
| --- | --- |
| Spades ♠ | سبيد |
| Hearts ♥ | هارت |
| Diamonds ♦ | كارو |
| Clubs ♣ | تريفل |
| Trick | لَمّة |
| Bidding call / winning auction bid | الكول |
| Trump | القاطوع |
| No trump | صنز |
| Dash | داش |

Owner-provided examples:

- `الكول 5 سبيد`
- `القاطوع هارت`
- `طالب 4 لمّات`
- `أخد الكول`
- `عمل داش`

## Auction bid and trick estimate are distinct

Do not translate every player's trick estimate as الكول. That term usually
refers to the winning auction bid; after trump is fixed, use phrasing such as
`طالب كام؟` or `قال كام لمة` for a player's estimate.

The domain must preserve the distinction between `auctionBid` (count and trump
in the auction) and `trickEstimate` (a player's exact-trick target). The existing
`Bid` class implements the former under game_rules_v1; its 4-trick opening
minimum must not be reused as an estimate validation rule. The preview's target
is a display fixture, not a new estimate model. Future play data must expose the
separate concepts before supporting post-auction estimates.

This terminology does not define any new rule for setting estimates, auction
termination, turn order, or scoring. Those rules still require documentation
before implementation depends on them.

## Localization acceptance

EC-060 covers the switch, saved preference, RTL layout, translated UI and
portable authored coaching, accessibility, and Arabic glyph verification.
Changing language must not move a player's physical seat, reverse card-play
order, change card identity, or alter evaluations. Keep IDs such as `spades`,
`hearts`, `diamonds`, `clubs`, `trick`, `bid`, and `trump` stable.

Rank names and other unlisted terms remain to be reviewed during localization;
the confirmed terms above must not be silently replaced with alternatives.
