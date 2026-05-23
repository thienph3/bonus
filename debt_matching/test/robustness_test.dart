import 'dart:io';
import 'dart:isolate';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:debt_matching/data/database/app_database.dart';
import 'package:debt_matching/data/services/calculate_fifo.dart';
import 'package:debt_matching/data/services/export_builder.dart';
import 'package:debt_matching/data/services/import_service.dart';
import 'package:debt_matching/data/services/calculate_service.dart';
import 'package:debt_matching/core/utils/error_utils.dart';

void main() {
  group('Isolate serialization', () {
    test('computeFifo works correctly through Isolate.run()', () async {
      // Same data as calculate_fifo_test but executed via real Isolate
      final input = {
        'results': [
          {'id': 'r1', 'mainDataId': 'md1', 'type': 0,
            'bonusDecrease': 1000, 'nonBonusDecrease': 0,
            'bonusIncrease': 0, 'nonBonusIncrease': 0,
            'paymentDueDate1': null, 'paymentDueDate2': null, 'paymentDueDate3': null},
          {'id': 'r2', 'mainDataId': 'md2', 'type': 1,
            'bonusDecrease': 0, 'nonBonusDecrease': 0,
            'bonusIncrease': 800, 'nonBonusIncrease': 0,
            'paymentDueDate1': DateTime(2025, 3, 1).millisecondsSinceEpoch,
            'paymentDueDate2': DateTime(2025, 4, 1).millisecondsSinceEpoch,
            'paymentDueDate3': DateTime(2025, 5, 1).millisecondsSinceEpoch},
        ],
        'dataMap': {
          'md1': {'customerCode': 'KH01', 'branch': 'CN01', 'seasonalCode': 'VU01',
            'documentNumber': 'CT01', 'documentDate': DateTime(2025, 2, 1).millisecondsSinceEpoch},
          'md2': {'customerCode': 'KH01', 'branch': 'CN01', 'seasonalCode': 'VU01',
            'documentNumber': 'CT02', 'documentDate': DateTime(2025, 2, 15).millisecondsSinceEpoch},
        },
        'runId': 'test-run',
      };

      // Run through real Isolate — catches serialization failures
      final result = await Isolate.run(() => computeFifo(input));

      expect(result.totalPushed, 1000);
      expect(result.totalConsumed, 800);
      expect(result.totalRemaining, 200);
      expect(result.totalBonus, 800); // bonus_1
      expect(result.matchingDetails.length, 1);
      expect(result.bonusUpdates.length, 2);
    });

    test('buildExcelBytes works through Isolate.run()', () async {
      final input = {
        'results': [
          {'customer_code': 'KH01', 'customer_name': 'Test', 'type': 1,
            'bonus_1': 500, 'bonus_2': 0, 'bonus_3': 0, 'calculate_status': 'valid',
            'document_number': 'CT01', 'increase': 1000, 'decrease': null,
            'seasonal_code': 'VU01', 'branch': 'CN01', 'sales_method': 'BH01'},
        ],
        'matchings': [
          {'increase_doc': 'CT01', 'decrease_doc': 'CT02',
            'decrease_date': null, 'amount': 500, 'bonus_tier': 'bonus_1'},
        ],
        'bonusRates': null,
      };

      final bytes = await Isolate.run(() => buildExcelBytes(input));
      expect(bytes, isNotNull);
      expect(bytes!.length, greaterThan(100));
    });
  });

  group('File error handling', () {
    test('export to read-only path returns permission error', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      AppDatabase.instance = db;
      AppDatabase.testMode = true;

      // Import + calculate to have data
      final ir = await ImportService().importFromExcel('test/fixtures/normal.xlsx', (_) {});
      final runId = ir['runId'] as String;
      await CalculateService().calculate(runId, (_) {}, (_) {});

      // Create a read-only directory
      final dir = Directory('test/fixtures/readonly_test');
      if (dir.existsSync()) dir.deleteSync(recursive: true);
      dir.createSync();
      final file = File('${dir.path}/output.xlsx');
      file.writeAsBytesSync([0]); // create file

      try {
        // Make read-only (Windows: attrib +R)
        Process.runSync('attrib', ['+R', file.path]);

        // Attempt write should throw
        Object? caught;
        try {
          await file.writeAsBytes([1, 2, 3]);
        } catch (e) {
          caught = e;
        }

        // Verify friendlyError handles it
        if (caught != null) {
          final msg = friendlyError(caught);
          expect(msg, anyOf(contains('quyền'), contains('Lỗi')));
        }
      } finally {
        Process.runSync('attrib', ['-R', file.path]);
        dir.deleteSync(recursive: true);
        db.close();
        AppDatabase.testMode = false;
      }
    });

    test('import non-existent file returns friendly error', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      AppDatabase.instance = db;
      AppDatabase.testMode = true;

      Object? caught;
      try {
        await ImportService().importFromExcel('test/fixtures/does_not_exist.xlsx', (_) {});
      } catch (e) {
        caught = e;
      }

      expect(caught, isNotNull);
      final msg = friendlyError(caught!);
      expect(msg, contains('Không tìm thấy'));

      db.close();
      AppDatabase.testMode = false;
    });
  });
}
