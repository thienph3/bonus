import 'package:drift/drift.dart';
import '../database/app_database.dart';
import 'calculate_validator.dart';
import 'calculate_result_builder.dart';
import 'calculate_writer.dart';
import 'chunked_fifo_service.dart';

class CalculateService {
  final AppDatabase _db = AppDatabase.instance;
  final _builder = CalculateResultBuilder();
  final _fifoService = ChunkedFifoService();

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

    // Phase 1: Prepare (single transaction)
    await _db.transaction(() async {
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
    });

    // Phase 2: FIFO per group (chunked, resumable)
    onSubStep(3);
    final dataMap = {for (final d in datas) d.id: d};
    final validResults = await _getSortedValidResults(datas, runId);
    final totalBonus = await _fifoService.processChunked(runId, validResults, dataMap, onLog, onSubStep);

    // Phase 3: Finalize
    final writer = CalculateWriter(_db);
    await writer.updateRunHistory(runId, totalBonus);
    onLog('✅ Hoàn tất. Tổng thưởng: $totalBonus');
    onSubStep(4);

    // Gather stats
    final pushed = validResults.where((r) => r.type == 0)
        .fold<int>(0, (s, r) => s + r.bonusDecrease + r.nonBonusDecrease);
    final results = await (_db.select(_db.results)..where((t) => t.runId.equals(runId))).get();
    final consumed = results.fold<int>(0, (s, r) => s + r.bonus1 + r.bonus2 + r.bonus3);

    return {
      'total_records': validResults.length, 'total_bonus': totalBonus,
      'total_pushed': pushed, 'total_consumed': consumed, 'total_remaining': pushed - consumed,
    };
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
