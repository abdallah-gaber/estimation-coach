# Application layout

- `main.dart`: Flutter entry point.
- `app/`: app shell, theme and minimal visual tokens.
- `core/cards/cards.dart`: pure Dart suit, rank, card, hand and deck types.
- `core/game_rules/legal_cards.dart`: follow-suit legality and card membership.
- `shared/widgets/playing_card.dart`: typed selectable/disabled card face.
- `shared/widgets/card_labels.dart`: UI labels and suit symbols/colors.
- `scenarios/bidding_scenario.dart`: immutable authored bidding content parser.
- `features/visual_preview/`: temporary interactive UI specimens and local state.

Create `core/coaching` when its implementation lands. Authored content remains under `content/scenarios/v1/` and
is not loaded or evaluated by this preview. See D-006 for the boundary between
UI specimens and training scenarios.

See D-007 for card identity, hand membership equality and strict content parsing.

See `docs/GAME_RULES.md` for the follow-suit contract and caller responsibilities.

`tool/validate_scenarios.dart` adds schema/file checks to the domain parser.
See the scenario authoring guide for its structural-validation limits.
