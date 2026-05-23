import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:debt_matching/data/database/app_database.dart';
import 'package:debt_matching/data/services/import_service.dart';
import 'package:debt_matching/data/services/calculate_service.dart';
import 'package:debt_matching/data/services/export_service.dart';
import 'package:debt_matching/data/services/pre_validation_service.dart';

void main() {
  late AppDatabase db;
  final logs = <String>[];
  void log(String msg) => logs.add(msg);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.instance = db;
    AppDatabase.testMode = true;
    logs.clear();
  });
  tearDown(() { db.close(); AppDatabase.testMode = false; });

  group('ImportService full pipeline', () {
    test('imports normal.xlsx and creates run with correct counts', () async {
      final svc = ImportService();
      final result = await svc.importFromExcel('test/fixtures/normal.xlsx', log);
      expect(result['runId'], isNotEmpty);
      expect(result['records'], 6);
      expect(result['levels'], 2);

      final run = await (db.select(db.runHistories)..where((t) => t.id.equals(result['runId'] as String))).getSingle();
      expect(run.status, 'imported');
      expect(run.recordCount, 6);
    });

    test('imports edge_cases.xlsx without crash', () async {
      final svc = ImportService();
      final result = await svc.importFromExcel('test/fixtures/edge_cases.xlsx', log);
      expect(result['records'], 5);
    });
  });

  group('CalculateService full pipeline', () {
    test('calculates bonus for normal data', () async {
      final importSvc = ImportService();
      final ir = await importSvc.importFromExcel('test/fixtures/normal.xlsx', log);
      final runId = ir['runId'] as String;

      final calcSvc = CalculateService();
      final stats = await calcSvc.calculate(runId, log, (_) {});

      expect(stats['total_records'], greaterThan(0));
      expect(stats['total_pushed'], greaterThanOrEqualTo(0));
      expect(stats['total_consumed'], greaterThanOrEqualTo(0));

      final run = await (db.select(db.runHistories)..where((t) => t.id.equals(runId))).getSingle();
      expect(run.status, 'completed');
    });

    test('cross-check logs warning if mismatch', () async {
      final importSvc = ImportService();
      final ir = await importSvc.importFromExcel('test/fixtures/normal.xlsx', log);
      final runId = ir['runId'] as String;

      final calcSvc = CalculateService();
      await calcSvc.calculate(runId, log, (_) {});

      // Verify reconciliation log exists
      expect(logs.any((l) => l.contains('Reconciliation') || l.contains('Pushed')), true);
    });

    test('handles edge cases without crash', () async {
      final importSvc = ImportService();
      final ir = await importSvc.importFromExcel('test/fixtures/edge_cases.xlsx', log);
      final runId = ir['runId'] as String;

      final calcSvc = CalculateService();
      final stats = await calcSvc.calculate(runId, log, (_) {});
      expect(stats['total_records'], greaterThan(0));
    });
  });

  group('PreValidationService', () {
    test('reports issues for edge case data', () async {
      final importSvc = ImportService();
      final ir = await importSvc.importFromExcel('test/fixtures/edge_cases.xlsx', log);
      final runId = ir['runId'] as String;

      final valSvc = PreValidationService();
      final report = await valSvc.validate(runId, log);
      expect(report.hasIssues, true);
      expect(report.missingDocNumber, greaterThan(0));
    });

    test('no issues for normal data', () async {
      final importSvc = ImportService();
      final ir = await importSvc.importFromExcel('test/fixtures/normal.xlsx', log);
      final runId = ir['runId'] as String;

      final valSvc = PreValidationService();
      final report = await valSvc.validate(runId, log);
      expect(report.missingDocNumber, 0);
      expect(report.missingSalesMethod, 0);
    });
  });

  group('ExportService', () {
    test('deleteRun removes all data atomically', () async {
      final importSvc = ImportService();
      final ir = await importSvc.importFromExcel('test/fixtures/normal.xlsx', log);
      final runId = ir['runId'] as String;
      await CalculateService().calculate(runId, log, (_) {});

      // Verify data exists
      final beforeResults = await (db.select(db.results)..where((t) => t.runId.equals(runId))).get();
      expect(beforeResults.length, greaterThan(0));

      // Delete
      await ExportService().deleteRun(runId);

      // Verify all gone
      final afterResults = await (db.select(db.results)..where((t) => t.runId.equals(runId))).get();
      final afterMain = await (db.select(db.mainDatas)..where((t) => t.runId.equals(runId))).get();
      final afterRun = await (db.select(db.runHistories)..where((t) => t.id.equals(runId))).get();
      expect(afterResults.length, 0);
      expect(afterMain.length, 0);
      expect(afterRun.length, 0);
    });
  });

  group('Multi-period isolation', () {
    test('two runs do not interfere with each other', () async {
      final importSvc = ImportService();
      final ir1 = await importSvc.importFromExcel('test/fixtures/normal.xlsx', log);
      final ir2 = await importSvc.importFromExcel('test/fixtures/normal.xlsx', log);
      final runId1 = ir1['runId'] as String;
      final runId2 = ir2['runId'] as String;

      await CalculateService().calculate(runId1, log, (_) {});
      await CalculateService().calculate(runId2, log, (_) {});

      final results1 = await (db.select(db.results)..where((t) => t.runId.equals(runId1))).get();
      final results2 = await (db.select(db.results)..where((t) => t.runId.equals(runId2))).get();
      expect(results1.length, results2.length);
      // Deleting run1 doesn't affect run2
      await ExportService().deleteRun(runId1);
      final afterDelete = await (db.select(db.results)..where((t) => t.runId.equals(runId2))).get();
      expect(afterDelete.length, results2.length);
    });
  });

  group('Retry stuck run', () {
    test('recalculate on imported status works', () async {
      final importSvc = ImportService();
      final ir = await importSvc.importFromExcel('test/fixtures/normal.xlsx', log);
      final runId = ir['runId'] as String;

      // Status should be 'imported'
      var run = await (db.select(db.runHistories)..where((t) => t.id.equals(runId))).getSingle();
      expect(run.status, 'imported');

      // Retry calculate
      await CalculateService().calculate(runId, log, (_) {});
      run = await (db.select(db.runHistories)..where((t) => t.id.equals(runId))).getSingle();
      expect(run.status, 'completed');
    });
  });
}
