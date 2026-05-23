# Project Steering — Debt Matching

## Code Constraints

- **Max 150 LOC per file** — split into focused files if exceeding
- **Max 4 parameters** per function/constructor — use object/class if more
- **No file > 200 LOC** including imports and comments

## Architecture Pattern

```
lib/
├── main.dart              # Entry point only
├── app.dart               # MaterialApp setup
├── core/                  # Shared utilities, theme
│   ├── theme/
│   └── utils/
├── data/                  # Business logic + persistence
│   ├── database/          # Drift tables + DB singleton
│   └── services/          # One service per responsibility
└── presentation/          # UI layer
    └── dashboard/
        ├── widgets/       # Reusable widget components
        └── *.dart         # Screen + state views
```

### Design Rules

- **Services** are stateless classes, one responsibility each (import, calculate, export, validation)
- **Database** is singleton (`AppDatabase.instance`), accessed directly by services
- **State management**: local `StatefulWidget` + `setState`. Use Riverpod only for DI if needed
- **Heavy computation** runs in `Isolate.run()` — serialize to plain Maps before sending
- **Batch DB writes** in chunks of 100 rows within `db.transaction()`
- **All data scoped by `runId`** — never mix data across runs

## UI Conventions

- **Material 3** with `colorSchemeSeed: Colors.blue`, `useMaterial3: true`
- **Single-screen** layout — no navigation, state machine drives content
- **AppState enum** controls what's shown: `initial → processing → preview → exported → error`
- **Layout**: full-width main panel, collapsible console at bottom, run selector on top
- **Buttons**: `FilledButton` for primary action, `OutlinedButton` for secondary
- **Numbers**: always format with `NumberFormat('#,###')` from `intl`
- **Language**: UI text in Vietnamese, code/comments in English
- **Theme**: support both light and dark via `ThemeMode` toggle
- **Feedback**: real-time console log for all operations, progress indicator with step label during processing
- **Errors**: user-friendly Vietnamese messages, technical detail as fallback
- **Destructive actions**: always confirm with `AlertDialog`

## Naming

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Private: prefix `_`
- DB tables: `PascalCase` (Drift convention), columns `camelCase`

## Dependencies (pinned)

- State: `flutter_riverpod`
- DB: `drift` + `sqlite3_flutter_libs`
- Excel read: `spreadsheet_decoder`
- Excel write: `excel`
- File dialog: `file_picker`
- IDs: `uuid`
- Dates: `intl`
