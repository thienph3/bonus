import 'dart:io';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:debt_matching/data/database/app_database.dart';
import 'package:debt_matching/data/services/import_service.dart';
import 'package:debt_matching/data/services/calculate_service.dart';
import 'package:debt_matching/data/services/export_builder.dart';

/// End-to-end: import → calculate → export → verify output file.
/// This catches serialization issues, data flow bugs, and ensures
/// the full pipeline produces a valid, non-empty Excel.
void main() {
  late AppDatabase db;
  final logs = <String>[];

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.instance = db;
    AppDatabase.testMode = true;
    logs.clear();
  });
  tearDown(() {
    db.close();
    AppDatabase.testMode = false;
  });

  group('E2E pipeline', () {
    test('import → calculate → export produces valid 3-sheet Excel', () async {
      // 1. Import
      final ir = await ImportService().importFromExcel('test/fixtures/normal.xlsx', logs.add);
      final runId = ir['runId'] as String;
      expect(ir['records'], greaterThan(0));

      // 2. Calculate
      final stats = await CalculateService().calculate(runId, logs.add, (_) {});
      expect(stats['total_records'], greaterThan(0));

      // 3. Export (build bytes directly, no Isolate boundary in test)
      final results = await (db.select(db.results)..where((t) => t.runId.equals(runId))).get();
      final mainDatas = await (db.select(db.mainDatas)..where((t) => t.runId.equals(runId))).get();
      final matchings = await (db.select(db.matchingDetails)..where((t) => t.runId.equals(runId))).get();
      final dataMap = {for (final d in mainDatas) d.id: d};
      results.sort((a, b) => a.originalIdx.compareTo(b.originalIdx));

      final serialResults = results.map((r) {
        final d = dataMap[r.mainDataId];
        return {
          'idx': d?.idx, 'document_date': d?.documentDate,
          'document_number': d?.documentNumber, 'description': d?.description,
          'corresponding_account': d?.correspondingAccount,
          'increase': d?.increase, 'decrease': d?.decrease,
          'adjust_increase': d?.adjustIncrease, 'adjust_decrease': d?.adjustDecrease,
          'end_amount': d?.endAmount, 'seasonal_code': d?.seasonalCode ?? '',
          'payment_period': d?.paymentPeriod, 'customer_code': d?.customerCode ?? '',
          'customer_name': d?.customerName, 'branch': d?.branch ?? '',
          'code': d?.code, 'sales_method': d?.salesMethod ?? '',
          'type': r.type, 'payment_due_date': r.paymentDueDate,
          'bonus_decrease': r.bonusDecrease, 'non_bonus_decrease': r.nonBonusDecrease,
          'bonus_increase': r.bonusIncrease, 'non_bonus_increase': r.nonBonusIncrease,
          'payment_due_date_1': r.paymentDueDate1, 'payment_due_date_2': r.paymentDueDate2,
          'payment_due_date_3': r.paymentDueDate3,
          'bonus_1': r.bonus1, 'bonus_2': r.bonus2, 'bonus_3': r.bonus3,
          'calculate_status': r.calculateStatus, 'calculate_message': r.calculateMessage,
        };
      }).toList();
      final serialMatchings = matchings.map((m) => {
        'increase_doc': m.increaseDocNumber, 'decrease_doc': m.decreaseDocNumber,
        'decrease_date': m.decreaseDate, 'amount': m.amountMatched, 'bonus_tier': m.bonusTier,
      }).toList();

      final bytes = buildExcelBytes({'results': serialResults, 'matchings': serialMatchings, 'bonusRates': null});
      expect(bytes, isNotNull);
      expect(bytes!.length, greaterThan(100));

      // 4. Verify Excel structure
      final excel = Excel.decodeBytes(bytes);
      expect(excel.tables.keys, containsAll(['Summary', 'Result', 'Matching Detail']));
      expect(excel.tables['Result']!.rows.length, greaterThan(1)); // header + data
      expect(excel.tables['Summary']!.rows.length, greaterThan(1));
    });

    test('import → calculate → export with bonus rates includes final_bonus', () async {
      final ir = await ImportService().importFromExcel('test/fixtures/normal.xlsx', logs.add);
      final runId = ir['runId'] as String;
      await CalculateService().calculate(runId, logs.add, (_) {});

      final results = await (db.select(db.results)..where((t) => t.runId.equals(runId))).get();
      final mainDatas = await (db.select(db.mainDatas)..where((t) => t.runId.equals(runId))).get();
      final matchings = await (db.select(db.matchingDetails)..where((t) => t.runId.equals(runId))).get();
      final dataMap = {for (final d in mainDatas) d.id: d};

      final serialResults = results.map((r) {
        final d = dataMap[r.mainDataId];
        return {
          'customer_code': d?.customerCode ?? '', 'customer_name': d?.customerName,
          'bonus_1': r.bonus1, 'bonus_2': r.bonus2, 'bonus_3': r.bonus3,
          'type': r.type, 'calculate_status': r.calculateStatus,
        };
      }).toList();
      final serialMatchings = matchings.map((m) => {
        'increase_doc': m.increaseDocNumber, 'decrease_doc': m.decreaseDocNumber,
        'decrease_date': m.decreaseDate, 'amount': m.amountMatched, 'bonus_tier': m.bonusTier,
      }).toList();

      final bytes = buildExcelBytes({
        'results': serialResults, 'matchings': serialMatchings,
        'bonusRates': {'pct_1': 3.0, 'pct_2': 2.0, 'pct_3': 1.0},
      });
      final excel = Excel.decodeBytes(bytes!);
      final summaryHeaders = excel.tables['Summary']!.rows.first.map((c) => c?.value.toString()).toList();
      expect(summaryHeaders, contains('final_total'));
    });

    test('reconciliation: pushed == consumed + remaining', () async {
      final ir = await ImportService().importFromExcel('test/fixtures/normal.xlsx', logs.add);
      final runId = ir['runId'] as String;
      final stats = await CalculateService().calculate(runId, logs.add, (_) {});

      final pushed = stats['total_pushed'] as int;
      final consumed = stats['total_consumed'] as int;
      final remaining = stats['total_remaining'] as int;
      expect(pushed, consumed + remaining);
    });

    test('edge case data completes without exception', () async {
      final ir = await ImportService().importFromExcel('test/fixtures/edge_cases.xlsx', logs.add);
      final runId = ir['runId'] as String;
      final stats = await CalculateService().calculate(runId, logs.add, (_) {});

      final run = await (db.select(db.runHistories)..where((t) => t.id.equals(runId))).getSingle();
      expect(run.status, 'completed');
      expect(stats['total_records'], greaterThan(0));
    });

    test('empty file import produces zero results gracefully', () async {
      final ir = await ImportService().importFromExcel('test/fixtures/empty.xlsx', logs.add);
      final runId = ir['runId'] as String;
      expect(ir['records'], 0);

      final stats = await CalculateService().calculate(runId, logs.add, (_) {});
      expect(stats['total_records'], 0);
      expect(stats['total_bonus'], 0);
    });
  });
}
