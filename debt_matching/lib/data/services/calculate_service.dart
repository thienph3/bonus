import 'dart:isolate';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import 'calculate_validator.dart';
import 'calculate_result_builder.dart';
import 'calculate_fifo.dart';
import 'calculate_writer.dart';

class CalculateService {
  final AppDatabase _db = AppDatabase.instance;
  final _builder = CalculateResultBuilder();

  Future<Map<String, dynamic>> calculate(
    String runId, void Function(String) onLog, void Function(int) onSubStep,
  ) async {
    onLog('Load dữ liệu (run: $runId)...');
    final holidays = await (_db.select(_db.holidayConfigs)..where((t) => t.runId.equals(runId))).get();
    final levels = await (_db.select(_db.levelConfigs)..where((t) => t.runId.equals(runId))).get();
    final datas = await (_db.select(_db.mainDatas)..where((t) => t.runId.equals(runId))).get();

    final holidaySet = holidays.map((h) => DateTime(h.date.year, h.date.month, h.date.day)).toSet();
    final sortedLevels = List<LevelConfig>.from(levels)
      ..sort((a, b) {
        int c = a.seasonalCode.compareTo(b.seasonalCode);
        if (c != 0) return c;
        c = a.salesMethod.compareTo(b.salesMethod);
        return c != 0 ? c : b.paymentPeriod.compareTo(a.paymentPeriod);
      });

    return await _db.transaction(() async {
      onLog('Xóa kết quả cũ của run...');
      await (_db.delete(_db.matchingDetails)..where((t) => t.runId.equals(runId))).go();
      await (_db.delete(_db.results)..where((t) => t.runId.equals(runId))).go();

      onLog('Validate & tạo kết quả...');
      onSubStep(1);
      final validated = validateAndMap(datas, sortedLevels);
      final resultRows = _builder.buildResultRows(datas, validated, holidaySet, runId);
      await _db.batch((b) => b.insertAll(_db.results, resultRows));

      onLog('Sắp xếp...');
      onSubStep(2);
      final validResults = await _getSortedValidResults(datas, runId);
      await _db.batch((b) {
        for (int i = 0; i < validResults.length; i++) {
          b.update(_db.results, ResultsCompanion(sortedIdx: Value(i)),
              where: (r) => r.id.equals(validResults[i].id));
        }
      });

      onLog('Tính toán FIFO (background)...');
      onSubStep(3);
      final dataMap = {for (final d in datas) d.id: d};
      final fifo = await _runFifoInIsolate(validResults, dataMap, runId);

      onLog('Lưu kết quả FIFO...');
      final writer = CalculateWriter(_db);
      await writer.writeFifoResults(fifo, runId);

      onLog('Pushed: ${fifo.totalPushed}, Consumed: ${fifo.totalConsumed}, Remaining: ${fifo.totalRemaining}');
      final diff = fifo.totalPushed - fifo.totalConsumed - fifo.totalRemaining;
      onLog(diff != 0 ? '⚠️ MISMATCH: $diff' : '✅ Reconciliation OK');

      // Cross-check: tổng decrease trên sổ vs totalPushed
      final sumDecrease = validResults.where((r) => r.type == 0)
          .fold<int>(0, (s, r) => s + r.bonusDecrease + r.nonBonusDecrease);
      final crossDiff = sumDecrease - fifo.totalPushed;
      if (crossDiff != 0) {
        onLog('⚠️ Cross-check: tổng decrease sổ ($sumDecrease) ≠ totalPushed (${fifo.totalPushed}), chênh lệch: $crossDiff');
      }

      await writer.updateRunHistory(runId, fifo.totalBonus);
      onLog('✅ Hoàn tất. Tổng thưởng: ${fifo.totalBonus}');
      onSubStep(4);
      return {
        'total_records': validResults.length, 'total_bonus': fifo.totalBonus,
        'total_pushed': fifo.totalPushed, 'total_consumed': fifo.totalConsumed,
        'total_remaining': fifo.totalRemaining,
      };
    });
  }

  Future<FifoResult> _runFifoInIsolate(List<Result> results, Map<String, MainData> dataMap, String runId) {
    final sr = results.map((r) => {
      'id': r.id, 'mainDataId': r.mainDataId, 'type': r.type,
      'bonusDecrease': r.bonusDecrease, 'nonBonusDecrease': r.nonBonusDecrease,
      'bonusIncrease': r.bonusIncrease, 'nonBonusIncrease': r.nonBonusIncrease,
      'paymentDueDate1': r.paymentDueDate1?.millisecondsSinceEpoch,
      'paymentDueDate2': r.paymentDueDate2?.millisecondsSinceEpoch,
      'paymentDueDate3': r.paymentDueDate3?.millisecondsSinceEpoch,
    }).toList();
    final sd = dataMap.map((k, d) => MapEntry(k, {
      'customerCode': d.customerCode, 'branch': d.branch, 'seasonalCode': d.seasonalCode,
      'documentNumber': d.documentNumber, 'documentDate': d.documentDate?.millisecondsSinceEpoch,
    }));
    return Isolate.run(() => computeFifo({'results': sr, 'dataMap': sd, 'runId': runId}));
  }

  Future<List<Result>> _getSortedValidResults(List<MainData> datas, String runId) async {
    final all = await (_db.select(_db.results)
          ..where((r) => r.runId.equals(runId) & r.calculateStatus.equals('valid') & r.type.isBiggerThanValue(-1))).get();
    final dm = {for (final d in datas) d.id: d};
    final valid = all.where((r) => dm.containsKey(r.mainDataId)).toList();
    valid.sort((a, b) {
      final da = dm[a.mainDataId]!, db = dm[b.mainDataId]!;
      int c = da.customerCode.compareTo(db.customerCode);
      if (c != 0) return c;
      c = da.branch.compareTo(db.branch);
      if (c != 0) return c;
      c = da.seasonalCode.compareTo(db.seasonalCode);
      if (c != 0) return c;
      c = a.type.compareTo(b.type);
      if (c != 0) return c;
      c = (a.paymentDueDate ?? DateTime(1900)).compareTo(b.paymentDueDate ?? DateTime(1900));
      if (c != 0) return c;
      c = b.bonusDecrease.compareTo(a.bonusDecrease);
      if (c != 0) return c;
      c = b.nonBonusDecrease.compareTo(a.nonBonusDecrease);
      if (c != 0) return c;
      c = b.bonusIncrease.compareTo(a.bonusIncrease);
      return c != 0 ? c : b.nonBonusIncrease.compareTo(a.nonBonusIncrease);
    });
    return valid;
  }
}
