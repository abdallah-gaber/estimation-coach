# Application layout

- `main.dart`: Flutter entry point.
- `app/`: app shell, theme and minimal visual tokens.
- `core/cards/cards.dart`: pure Dart suit, rank, card, hand and deck types.
- `shared/widgets/playing_card.dart`: typed selectable/disabled card face.
- `shared/widgets/card_labels.dart`: UI labels and suit symbols/colors.
- `features/visual_preview/`: temporary interactive UI specimens and local state.

Create `core/game_rules`, `core/coaching` and `scenarios` when their
implementations land. Authored content remains under `content/scenarios/v1/` and
is not loaded or evaluated by this preview. See D-006 for the boundary between
UI specimens and training scenarios.

See D-007 for card identity, hand membership equality and strict content parsing.
