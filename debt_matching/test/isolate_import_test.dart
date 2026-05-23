import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:debt_matching/data/database/app_database.dart';
import 'package:debt_matching/data/services/import_service.dart';

/// Regression test: ImportService must work with real Isolate.run()
/// (not testMode) to catch unsendable object errors.
void main() {
  late AppDatabase db;
  final logs = <String>[];
  void log(String msg) => logs.add(msg);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.instance = db;
    AppDatabase.testMode = false; // Force real Isolate
    logs.clear();
  });
  tearDown(() => db.close());

  test('importFromExcel via real Isolate with input.xlsx', () async {
    final result = await ImportService().importFromExcel('../data/input.xlsx', log);
    expect(result['records'], greaterThan(0));
    final run = await (db.select(db.runHistories)
          ..where((t) => t.id.equals(result['runId'] as String)))
        .getSingle();
    expect(run.status, 'imported');
  });

  test('importFromExcel via real Isolate with template.xlsx', () async {
    final result = await ImportService().importFromExcel('../data/template.xlsx', log);
    expect(result['levels'], greaterThan(0));
    final run = await (db.select(db.runHistories)
          ..where((t) => t.id.equals(result['runId'] as String)))
        .getSingle();
    expect(run.status, 'imported');
  });
}
