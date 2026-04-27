# Design: Flutter Desktop Bonus Calculator

## Tech Stack

| Layer | Công nghệ |
|-------|-----------|
| UI Framework | Flutter 3.x (Desktop) |
| State Management | Riverpod |
| Database | SQLite via drift (ORM) |
| Excel Read | excel package (dart) |
| Excel Write | excel package hoặc custom xlsxwriter-like |
| Architecture | Clean Architecture (Presentation / Domain / Data) |

## Cấu trúc project

```
debt_matching/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── theme/              # Light/Dark theme
│   │   ├── utils/              # parse_date, parse_number
│   │   └── constants.dart
│   ├── data/
│   │   ├── database/
│   │   │   ├── app_database.dart       # Drift database definition
│   │   │   ├── tables/                 # Table definitions
│   │   │   └── daos/                   # Data Access Objects
│   │   ├── repositories/              # Repository implementations
│   │   └── services/
│   │       ├── import_service.dart
│   │       ├── calculate_service.dart
│   │       └── export_service.dart
│   ├── domain/
│   │   ├── models/                    # Domain entities
│   │   └── repositories/             # Repository interfaces
│   └── presentation/
│       ├── dashboard/                 # Dashboard screen (3 steps)
│       ├── data_view/                 # View/edit data screens
│       ├── widgets/                   # Shared widgets
│       └── console/                   # Log console panel
├── assets/
│   └── icons/
├── test/
└── pubspec.yaml
```

## Database (Drift)

4 tables giữ nguyên schema:

```dart
class HolidayConfigs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get name => text().nullable()();
  TextColumn get desc => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LevelConfigs extends Table {
  TextColumn get id => text()();
  TextColumn get seasonalCode => text()();
  TextColumn get salesMethod => text()();
  IntColumn get paymentPeriod => integer()();
  IntColumn get paymentPeriod1 => integer()();
  IntColumn get paymentPeriod2 => integer()();
  IntColumn get paymentPeriod3 => integer()();
  DateTimeColumn get paymentDueDate1 => dateTime().nullable()();
  DateTimeColumn get paymentDueDate2 => dateTime().nullable()();
  DateTimeColumn get paymentDueDate3 => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class MainDatas extends Table {
  TextColumn get id => text()();
  IntColumn get idx => integer().nullable()();
  DateTimeColumn get documentDate => dateTime().nullable()();
  TextColumn get documentNumber => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get correspondingAccount => text().nullable()();
  IntColumn get increase => integer().nullable()();
  IntColumn get decrease => integer().nullable()();
  IntColumn get adjustIncrease => integer().nullable()();
  IntColumn get adjustDecrease => integer().nullable()();
  IntColumn get endAmount => integer().nullable()();
  TextColumn get seasonalCode => text()();
  IntColumn get paymentPeriod => integer().nullable()();
  TextColumn get customerCode => text()();
  TextColumn get customerName => text().nullable()();
  TextColumn get branch => text()();
  TextColumn get code => text().nullable()();
  TextColumn get salesMethod => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Results extends Table {
  TextColumn get id => text()();
  TextColumn get mainDataId => text().references(MainDatas, #id)();
  TextColumn get levelConfigId => text().nullable().references(LevelConfigs, #id)();
  IntColumn get sortedIdx => integer().withDefault(const Constant(0))();
  IntColumn get originalIdx => integer().withDefault(const Constant(0))();
  IntColumn get type => integer().withDefault(const Constant(0))();
  DateTimeColumn get paymentDueDate => dateTime().nullable()();
  IntColumn get bonusIncrease => integer().withDefault(const Constant(0))();
  IntColumn get nonBonusIncrease => integer().withDefault(const Constant(0))();
  IntColumn get bonusDecrease => integer().withDefault(const Constant(0))();
  IntColumn get nonBonusDecrease => integer().withDefault(const Constant(0))();
  DateTimeColumn get paymentDueDate1 => dateTime().nullable()();
  DateTimeColumn get paymentDueDate2 => dateTime().nullable()();
  DateTimeColumn get paymentDueDate3 => dateTime().nullable()();
  IntColumn get bonus1 => integer().withDefault(const Constant(0))();
  IntColumn get bonus2 => integer().withDefault(const Constant(0))();
  IntColumn get bonus3 => integer().withDefault(const Constant(0))();
  TextColumn get beforeRemain => text().withDefault(const Constant(''))();
  TextColumn get afterRemain => text().withDefault(const Constant(''))();
  TextColumn get calculateStatus => text().withDefault(const Constant('valid'))();
  TextColumn get calculateMessage => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
```

## Services Design

### ImportService
- `importFromExcel(String filePath, Function(String) onLog)` → Future<ImportStats>
- Dynamic header detection (scan 30 rows, tìm row >= 17 non-empty cells)
- Parse date: hỗ trợ Excel serial number, dd/mm/yyyy, yyyy-mm-dd, etc.
- Batch insert 100 rows/lần
- Chạy trong Isolate để không block UI

### CalculateService
- `calculate(Function(String) onLog, Function(int) onSubStep)` → Future<CalculateStats>
- Port 1:1 logic từ Python (xem docs/LOGIC_CALCULATE.md)
- Fix known bugs: idx stale, exception handling, null date validation
- Chạy trong Isolate

### ExportService
- `exportToExcel(String filePath, Function(String) onLog)` → Future<void>
- Sort theo originalIdx
- Date → Excel serial number
- Column formatting (date, number, auto-width)
- Chạy trong Isolate

## UI Design

### Layout
```
┌─────────────────────────────────────────────┐
│ AppBar (title + theme toggle)               │
├────────────────────────┬────────────────────┤
│                        │                    │
│   Main Content Area    │   Console Log      │
│   (Dashboard / Views)  │   Panel            │
│                        │                    │
├────────────────────────┴────────────────────┤
│ Navigation Rail (left) hoặc Bottom Nav      │
└─────────────────────────────────────────────┘
```

### Screens
1. **Dashboard** — 3 step cards (Import → Calculate → Export) với status/progress
2. **Holiday Config** — List + Add/Edit/Delete
3. **Level Config** — List + Add/Edit/Delete
4. **Main Data** — Paginated table (read-only hoặc editable)
5. **Result** — Paginated table (read-only)

## Fixes cho Known Issues khi rewrite

| Issue | Fix trong Flutter |
|-------|-------------------|
| #1 idx stale | Dùng enumerate trong loop |
| #2 Exception bị nuốt | try/catch + rethrow, Isolate error handling |
| #3 Null date crash | Validate document_date != null trước khi push stack |
| #9 Recursive overflow | Dùng while loop thay vì recursion cho holiday adjustment |
| #10 No shared transaction | Drift hỗ trợ transaction() wrapper cho toàn bộ operation |
