# Implemented game rules

Canonical normal bidding rules are in [game_rules_v1](GAME_RULES_V1.md). They
take precedence over implementation and content. This page describes the
currently implemented follow-suit rule.

## EC-021: following suit

The rule in AGENTS.md and PROJECT_TRACKER.md is implemented by the pure Dart
functions in `lib/core/game_rules/legal_cards.dart`:

- `legalCards(hand, ledSuit: suit)` returns the cards allowed by following suit.
- `isLegalPlay(hand, card, ledSuit: suit)` also checks that the card is held.

Pass the suit of the **first** card in the trick as `ledSuit`. When leading a new
trick, pass null (the default).

| Situation | Allowed cards |
| --- | --- |
| Leading a new trick | Every card in the hand |
| Holding one or more cards of the led suit | Only cards of that suit |
| Void in the led suit | Every card in the hand |
| Empty hand | None |
| Candidate absent from the hand | Never allowed |

Rank does not affect following suit. No obligation to beat a previous card is
introduced. Returned lists preserve hand display order and cannot be modified;
evaluation does not change the hand.

```dart
final hand = Hand(['AS', '2H', 'KD'].map(GameCard.parse));
final allowed = legalCards(hand, ledSuit: Suit.hearts); // [2H]
final canDiscard = isLegalPlay(hand, GameCard.parse('KD'), ledSuit: Suit.hearts);
// false: a Heart is still held.
```

This is a card-selection rule, not a round engine. Callers must manage turn
order, derive the led suit from the current trick, and prevent actions after a
trick is complete. Trump winner resolution, bidding precedence, scoring and
coaching evaluation are not implemented here. Bidding ambiguity remains tracked
in EC-024. The visual preview still demonstrates an intentionally locked UI
specimen; it has no current trick and does not invoke this rule yet.

Run the rule tests:

```sh
flutter test test/core/game_rules/legal_cards_test.dart
```

Tests cover leading, following with low cards, voids, absent cards, empty and
single-card hands, immutable results, and all suit/rank combinations.
