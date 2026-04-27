import 'package:drift/drift.dart';
import '../database/app_database.dart';
import 'calculate_result_builder.dart';

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
      final totalBonus = await _calculateFifo(validResults, dataMap, onLog);

      onLog('✅ Hoàn tất. Tổng thưởng: $totalBonus');
      onSubStep(4);
      return {'total_records': validResults.length, 'total_bonus': totalBonus};
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

  Future<int> _calculateFifo(
    List<Result> results, Map<String, MainData> dataMap, void Function(String) onLog,
  ) async {
    String curCust = '', curBranch = '', curSeason = '';
    List<Map<String, dynamic>> stack = [];
    int totalBonus = 0;
    var updates = <_BonusUpdate>[];

    for (int i = 0; i < results.length; i++) {
      final r = results[i];
      final data = dataMap[r.mainDataId]!;

      if (curCust != data.customerCode || curBranch != data.branch || curSeason != data.seasonalCode) {
        curCust = data.customerCode;
        curBranch = data.branch;
        curSeason = data.seasonalCode;
        stack = [];
      }
      if (data.documentNumber == null || data.documentNumber!.isEmpty) continue;

      final beforeStr = stack.toString();
      int b1 = 0, b2 = 0, b3 = 0;

      if (r.type == 0) {
        stack.add({
          'sub_type': r.bonusDecrease > 0 ? 'bonus' : 'non_bonus',
          'amount': r.bonusDecrease > 0 ? r.bonusDecrease : r.nonBonusDecrease,
          'date': data.documentDate,
        });
      } else if (r.type == 1) {
        int amount = r.bonusIncrease > 0 ? r.bonusIncrease : r.nonBonusIncrease;
        final isBonus = r.bonusIncrease > 0;
        while (amount > 0 && stack.isNotEmpty) {
          final first = stack[0];
          final mi = amount < (first['amount'] as int) ? amount : first['amount'] as int;
          amount -= mi;
          first['amount'] = (first['amount'] as int) - mi;
          if (isBonus && first['sub_type'] == 'bonus' && first['date'] != null) {
            final d = first['date'] as DateTime;
            if (r.paymentDueDate1 != null && !d.isAfter(r.paymentDueDate1!)) {
              b1 += mi;
            } else if (r.paymentDueDate2 != null && !d.isAfter(r.paymentDueDate2!)) {
              b2 += mi;
            } else if (r.paymentDueDate3 != null && !d.isAfter(r.paymentDueDate3!)) {
              b3 += mi;
            }
          }
          if ((first['amount'] as int) <= 0) stack.removeAt(0);
        }
      }

      totalBonus += b1 + b2 + b3;
      updates.add(_BonusUpdate(r.id, b1, b2, b3, beforeStr, stack.toString()));

      if (updates.length >= 100) {
        await _flushUpdates(updates);
        onLog('✅ Đã tính ${i + 1} dòng...');
        updates = [];
      }
    }
    if (updates.isNotEmpty) await _flushUpdates(updates);
    return totalBonus;
  }

  Future<void> _flushUpdates(List<_BonusUpdate> updates) async {
    await _db.batch((batch) {
      for (final u in updates) {
        batch.update(_db.results,
          ResultsCompanion(bonus1: Value(u.b1), bonus2: Value(u.b2), bonus3: Value(u.b3),
              beforeRemain: Value(u.before), afterRemain: Value(u.after)),
          where: (r) => r.id.equals(u.id));
      }
    });
  }
}

class _BonusUpdate {
  final String id;
  final int b1, b2, b3;
  final String before, after;
  _BonusUpdate(this.id, this.b1, this.b2, this.b3, this.before, this.after);
}
