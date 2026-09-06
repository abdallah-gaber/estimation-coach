# Application layout

- `main.dart`: Flutter entry point.
- `app/`: app shell, theme and minimal visual tokens.
- `shared/widgets/playing_card.dart`: reusable selectable/disabled card face.
- `features/visual_preview/`: temporary interactive UI specimens and local state.

Create `core/cards`, `core/game_rules`, `core/coaching` and `scenarios` when their
implementations land. Authored content remains under `content/scenarios/v1/` and
is not loaded or evaluated by this preview. See D-006 for the boundary between
UI specimens and training scenarios.
