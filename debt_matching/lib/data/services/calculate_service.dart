import 'package:drift/drift.dart';
import '../database/app_database.dart';
import 'calculate_result_builder.dart';
import 'calculate_fifo.dart';

class CalculateService {
  final AppDatabase _db = AppDatabase.instance;
  final _builder = CalculateResultBuilder();

  Future<Map<String, dynamic>> calculate(
    void Function(String) onLog,
    void Function(int) onSubStep,
  ) async {
    onLog('Load dữ liệu...');
    final holidays = await _db.select(_db.holidayConfigs).get();
    final levels = await _db.select(_db.levelConfigs).get();
    final datas = await _db.select(_db.mainDatas).get();

    final holidaySet = holidays.map((h) => DateTime(h.date.year, h.date.month, h.date.day)).toSet();
    final sortedLevels = List<LevelConfig>.from(levels)
      ..sort((a, b) {
        int cmp = a.seasonalCode.compareTo(b.seasonalCode);
        if (cmp != 0) return cmp;
        cmp = a.salesMethod.compareTo(b.salesMethod);
        if (cmp != 0) return cmp;
        return b.paymentPeriod.compareTo(a.paymentPeriod);
      });

    return await _db.transaction(() async {
      onLog('Xóa kết quả cũ...');
      await _db.delete(_db.results).go();
      await _db.delete(_db.matchingDetails).go();

      onLog('Validate & tạo kết quả...');
      onSubStep(1);
      final validated = _builder.validateAndMap(datas, sortedLevels);
      final resultRows = _builder.buildResultRows(datas, validated, holidaySet);

      onLog('Lưu ${resultRows.length} kết quả...');
      await _db.batch((batch) => batch.insertAll(_db.results, resultRows));

      onLog('Sắp xếp...');
      onSubStep(2);
      final validResults = await _getSortedValidResults(datas);
      await _db.batch((batch) {
        for (int i = 0; i < validResults.length; i++) {
          batch.update(_db.results, ResultsCompanion(sortedIdx: Value(i)),
              where: (r) => r.id.equals(validResults[i].id));
        }
      });

      onLog('Tính toán FIFO...');
      onSubStep(3);
      final dataMap = {for (final d in datas) d.id: d};
      final fifo = CalculateFifo(_db);
      final fifoResult = await fifo.run(validResults, dataMap, onLog);

      // Reconciliation
      onLog('--- Reconciliation ---');
      onLog('Tổng pushed: ${fifoResult.totalPushed}');
      onLog('Tổng consumed: ${fifoResult.totalConsumed}');
      onLog('Tổng remaining: ${fifoResult.totalRemaining}');
      final diff = fifoResult.totalPushed - fifoResult.totalConsumed - fifoResult.totalRemaining;
      if (diff != 0) {
        onLog('⚠️ MISMATCH: $diff');
      } else {
        onLog('✅ Reconciliation OK');
      }

      // Update latest run_history
      final latestRun = await (_db.select(_db.runHistories)
            ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
            ..limit(1))
          .getSingleOrNull();
      if (latestRun != null) {
        await (_db.update(_db.runHistories)..where((t) => t.id.equals(latestRun.id)))
            .write(RunHistoriesCompanion(
                totalBonus: Value(fifoResult.totalBonus), status: const Value('completed')));
      }

      onLog('✅ Hoàn tất. Tổng thưởng: ${fifoResult.totalBonus}');
      onSubStep(4);
      return {
        'total_records': validResults.length,
        'total_bonus': fifoResult.totalBonus,
        'total_pushed': fifoResult.totalPushed,
        'total_consumed': fifoResult.totalConsumed,
        'total_remaining': fifoResult.totalRemaining,
      };
    });
  }

  Future<List<Result>> _getSortedValidResults(List<MainData> datas) async {
    final allResults = await (_db.select(_db.results)
          ..where((r) => r.calculateStatus.equals('valid') & r.type.isBiggerThanValue(-1)))
        .get();
    final dataMap = {for (final d in datas) d.id: d};
    final valid = allResults.where((r) => dataMap.containsKey(r.mainDataId)).toList();
    valid.sort((a, b) {
      final da = dataMap[a.mainDataId]!, db = dataMap[b.mainDataId]!;
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
