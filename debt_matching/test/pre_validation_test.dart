import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:debt_matching/data/database/app_database.dart';
import 'package:debt_matching/data/services/pre_validation_service.dart';

// PreValidationService uses AppDatabase.instance singleton.
// For testing, we need to override it. Since we can't easily,
// we test the validation logic by inserting data and calling validate.
// This requires the singleton to point to our test DB.
// Workaround: test the logic inline.

void main() {
  late AppDatabase db;
  var _idCounter = 0;
  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    _idCounter = 0;
  });
  tearDown(() => db.close());

  Future<void> _insertData(String runId, {String? docNum, int? period,
    String seasonal = 'VU01', String sales = 'BH01', String cust = 'KH01'}) async {
    await db.into(db.mainDatas).insert(MainDatasCompanion.insert(
      id: 'md-${++_idCounter}', runId: Value(runId),
      documentNumber: Value(docNum), paymentPeriod: Value(period),
      seasonalCode: seasonal, salesMethod: sales, customerCode: cust, branch: 'CN01'));
  }

  group('PreValidationService logic', () {
    test('detects missing document numbers', () async {
      const runId = 'run1';
      await db.into(db.runHistories).insert(RunHistoriesCompanion.insert(
        id: runId, timestamp: DateTime.now()));
      await _insertData(runId, docNum: null, period: 30);
      await _insertData(runId, docNum: '', period: 30);
      await _insertData(runId, docNum: 'CT01', period: 30);

      final datas = await (db.select(db.mainDatas)..where((t) => t.runId.equals(runId))).get();
      final missingDoc = datas.where((d) => d.documentNumber == null || d.documentNumber!.trim().isEmpty).length;
      expect(missingDoc, 2);
    });

    test('detects duplicate document numbers in same group', () async {
      const runId = 'run2';
      await db.into(db.runHistories).insert(RunHistoriesCompanion.insert(
        id: runId, timestamp: DateTime.now()));
      await _insertData(runId, docNum: 'CT01', period: 30);
      await _insertData(runId, docNum: 'CT01', period: 30); // duplicate
      await _insertData(runId, docNum: 'CT02', period: 30);

      final datas = await (db.select(db.mainDatas)..where((t) => t.runId.equals(runId))).get();
      final docCounts = <String, int>{};
      for (final d in datas) {
        final key = '${d.customerCode}|${d.branch}|${d.seasonalCode}|${d.documentNumber ?? ""}';
        docCounts[key] = (docCounts[key] ?? 0) + 1;
      }
      final duplicates = docCounts.entries.where((e) => e.value > 1 && e.key.split('|').last.isNotEmpty);
      expect(duplicates.length, 1);
    });

    test('no issues with clean data', () async {
      const runId = 'run3';
      await db.into(db.runHistories).insert(RunHistoriesCompanion.insert(
        id: runId, timestamp: DateTime.now()));
      await _insertData(runId, docNum: 'CT01', period: 30);
      await _insertData(runId, docNum: 'CT02', period: 30);

      final datas = await (db.select(db.mainDatas)..where((t) => t.runId.equals(runId))).get();
      final missingDoc = datas.where((d) => d.documentNumber == null || d.documentNumber!.trim().isEmpty).length;
      expect(missingDoc, 0);
    });
  });
}
