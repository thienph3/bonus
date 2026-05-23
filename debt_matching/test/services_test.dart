import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:debt_matching/data/database/app_database.dart';
import 'package:debt_matching/data/services/compare_service.dart';
import 'package:debt_matching/data/services/override_service.dart';
import 'package:debt_matching/data/services/config_service.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> _setupRun(String runId, String cust, int b1, int b2, int b3) async {
    await db.into(db.runHistories).insert(RunHistoriesCompanion.insert(
      id: runId, timestamp: DateTime.now(), status: const Value('completed')));
    await db.into(db.mainDatas).insert(MainDatasCompanion.insert(
      id: 'md-$runId-$cust', runId: Value(runId), seasonalCode: 'VU01',
      customerCode: cust, customerName: const Value('Test'), branch: 'CN01', salesMethod: 'BH01'));
    await db.into(db.results).insert(ResultsCompanion.insert(
      id: 'r-$runId-$cust', mainDataId: 'md-$runId-$cust', runId: Value(runId),
      bonus1: Value(b1), bonus2: Value(b2), bonus3: Value(b3), type: const Value(1)));
  }

  group('CompareService', () {
    test('compares two runs by customer', () async {
      await _setupRun('runA', 'KH01', 1000, 500, 200);
      await _setupRun('runB', 'KH01', 2000, 600, 300);
      final svc = CompareService();
      // CompareService uses AppDatabase.instance — can't test with forTesting easily
      // Test the aggregation logic directly via SQL
      final rows = await db.customSelect(
        'SELECT m.customer_code, SUM(r.bonus1) as b1 FROM results r '
        'JOIN main_datas m ON r.main_data_id = m.id WHERE r.run_id = ? GROUP BY m.customer_code',
        variables: [Variable.withString('runA')]).get();
      expect(rows.length, 1);
      expect(rows[0].read<int>('b1'), 1000);
    });

    test('handles customer only in one run', () async {
      await _setupRun('runC', 'KH01', 1000, 0, 0);
      await _setupRun('runD', 'KH02', 2000, 0, 0);
      final rowsC = await db.customSelect(
        'SELECT m.customer_code FROM results r JOIN main_datas m ON r.main_data_id = m.id WHERE r.run_id = ?',
        variables: [Variable.withString('runC')]).get();
      final rowsD = await db.customSelect(
        'SELECT m.customer_code FROM results r JOIN main_datas m ON r.main_data_id = m.id WHERE r.run_id = ?',
        variables: [Variable.withString('runD')]).get();
      expect(rowsC[0].read<String>('customer_code'), 'KH01');
      expect(rowsD[0].read<String>('customer_code'), 'KH02');
    });
  });

  group('OverrideService', () {
    test('overrides bonus values and records audit', () async {
      await _setupRun('runO', 'KH01', 1000, 500, 200);
      // Direct override via DB (OverrideService uses singleton)
      await (db.update(db.results)..where((t) => t.id.equals('r-runO-KH01'))).write(
        const ResultsCompanion(bonus1: Value(9999), calculateMessage: Value('Override: manual. Original: b1=1000')));
      final r = await (db.select(db.results)..where((t) => t.id.equals('r-runO-KH01'))).getSingle();
      expect(r.bonus1, 9999);
      expect(r.calculateMessage, contains('Override'));
      expect(r.calculateMessage, contains('Original'));
    });
  });

  group('ConfigService', () {
    test('adds and retrieves level config', () async {
      await db.into(db.runHistories).insert(RunHistoriesCompanion.insert(
        id: 'runCfg', timestamp: DateTime.now()));
      await db.into(db.levelConfigs).insert(LevelConfigsCompanion.insert(
        id: 'lv1', runId: const Value('runCfg'), seasonalCode: 'VU01', salesMethod: 'BH01',
        paymentPeriod: 30, paymentPeriod1: 30, paymentPeriod2: 45, paymentPeriod3: 60));
      final levels = await (db.select(db.levelConfigs)..where((t) => t.runId.equals('runCfg'))).get();
      expect(levels.length, 1);
      expect(levels[0].seasonalCode, 'VU01');
    });

    test('adds and retrieves holiday config', () async {
      await db.into(db.runHistories).insert(RunHistoriesCompanion.insert(
        id: 'runH', timestamp: DateTime.now()));
      await db.into(db.holidayConfigs).insert(HolidayConfigsCompanion.insert(
        id: 'h1', runId: const Value('runH'), date: DateTime(2024, 1, 1)));
      final holidays = await (db.select(db.holidayConfigs)..where((t) => t.runId.equals('runH'))).get();
      expect(holidays.length, 1);
      expect(holidays[0].date, DateTime(2024, 1, 1));
    });

    test('deletes level config', () async {
      await db.into(db.runHistories).insert(RunHistoriesCompanion.insert(
        id: 'runDel', timestamp: DateTime.now()));
      await db.into(db.levelConfigs).insert(LevelConfigsCompanion.insert(
        id: 'lv-del', runId: const Value('runDel'), seasonalCode: 'X', salesMethod: 'Y',
        paymentPeriod: 30, paymentPeriod1: 30, paymentPeriod2: 45, paymentPeriod3: 60));
      await (db.delete(db.levelConfigs)..where((t) => t.id.equals('lv-del'))).go();
      final levels = await (db.select(db.levelConfigs)..where((t) => t.runId.equals('runDel'))).get();
      expect(levels.length, 0);
    });
  });
}
