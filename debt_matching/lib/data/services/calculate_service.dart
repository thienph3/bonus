import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../../core/utils/parse_utils.dart';

class CalculateService {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

  Future<Map<String, dynamic>> calculate(
    void Function(String) onLog,
    void Function(int) onSubStep,
  ) async {
    onLog('Load dữ liệu...');
    final holidays = await _db.select(_db.holidayConfigs).get();
    final levels = await _db.select(_db.levelConfigs).get();
    final datas = await _db.select(_db.mainDatas).get();

    final holidaySet = holidays.map((h) => _dateOnly(h.date)).toSet();

    // Sort levels
    final sortedLevels = List<LevelConfig>.from(levels)
      ..sort((a, b) {
        int cmp = a.seasonalCode.compareTo(b.seasonalCode);
        if (cmp != 0) return cmp;
        cmp = a.salesMethod.compareTo(b.salesMethod);
        if (cmp != 0) return cmp;
        return b.paymentPeriod.compareTo(a.paymentPeriod); // DESC
      });

    // Delete old results
    onLog('Xóa kết quả cũ...');
    await _db.delete(_db.results).go();

    // Step 1: Validate & map level
    onLog('Validate & mapping level...');
    onSubStep(1);

    final resultRows = <ResultsCompanion>[];
    for (int idx = 0; idx < datas.length; idx++) {
      final data = datas[idx];
      String? levelId;
      String calcStatus = 'invalid';
      String calcMessage = '';

      // Validate
      final errors = <String>[];
      if (data.documentNumber == null || data.documentNumber!.trim().isEmpty) {
        errors.add('Document number is empty');
      }
      if (data.paymentPeriod == null) {
        errors.add('Payment period is null');
      } else if (data.paymentPeriod! < 0) {
        errors.add('Payment period must be >= 0');
      }
      if (data.seasonalCode.trim().isEmpty) errors.add('Missing seasonal_code');
      if (data.salesMethod.trim().isEmpty) errors.add('Missing sales_method');

      LevelConfig? matchedLevel;
      if (errors.isEmpty) {
        for (final level in sortedLevels) {
          if (data.seasonalCode.toLowerCase() == level.seasonalCode.toLowerCase() &&
              data.salesMethod.toLowerCase() == level.salesMethod.toLowerCase() &&
              (data.paymentPeriod ?? 0) >= level.paymentPeriod) {
            levelId = level.id;
            matchedLevel = level;
            calcStatus = 'valid';
            break;
          }
        }
        if (levelId == null) {
          calcMessage = 'No matching level config';
        }
      } else {
        calcMessage = errors.join('; ');
      }

      // Calculate amounts
      final increase = data.increase ?? 0;
      final decrease = data.decrease ?? 0;
      final adjustIncrease = data.adjustIncrease ?? 0;
      final adjustDecrease = data.adjustDecrease ?? 0;

      final bonusIncrease = adjustIncrease;
      final nonBonusIncrease = increase - adjustIncrease;
      final bonusDecrease = decrease - adjustDecrease;
      final nonBonusDecrease = adjustDecrease;

      int type;
      if (bonusDecrease > 0 || nonBonusDecrease > 0) {
        type = 0;
      } else if (bonusIncrease > 0 || nonBonusIncrease > 0) {
        type = 1;
      } else {
        type = -1;
      }

      // Payment due dates
      final docDate = data.documentDate;
      final paymentDueDate = docDate != null
          ? docDate.add(Duration(days: data.paymentPeriod ?? 0))
          : DateTime(1900, 1, 1);

      DateTime? pdd1, pdd2, pdd3;
      if (type == 1 && matchedLevel != null) {
        pdd1 = matchedLevel.paymentDueDate1 ??
            (docDate?.add(Duration(days: matchedLevel.paymentPeriod1)) ??
                DateTime(1900, 1, 1));
        pdd2 = matchedLevel.paymentDueDate2 ??
            (docDate?.add(Duration(days: matchedLevel.paymentPeriod2)) ??
                DateTime(1900, 1, 1));
        pdd3 = matchedLevel.paymentDueDate3 ??
            (docDate?.add(Duration(days: matchedLevel.paymentPeriod3)) ??
                DateTime(1900, 1, 1));

        pdd1 = changeDateByHolidays(pdd1, holidaySet);
        pdd2 = changeDateByHolidays(pdd2, holidaySet);
        pdd3 = changeDateByHolidays(pdd3, holidaySet);
      }

      resultRows.add(ResultsCompanion.insert(
        id: _uuid.v4(),
        mainDataId: data.id,
        levelConfigId: Value(levelId),
        sortedIdx: Value(0),
        originalIdx: Value(idx),
        type: Value(type),
        paymentDueDate: Value(paymentDueDate),
        bonusIncrease: Value(bonusIncrease),
        nonBonusIncrease: Value(nonBonusIncrease),
        bonusDecrease: Value(bonusDecrease),
        nonBonusDecrease: Value(nonBonusDecrease),
        paymentDueDate1: Value(pdd1),
        paymentDueDate2: Value(pdd2),
        paymentDueDate3: Value(pdd3),
        calculateStatus: Value(calcStatus),
        calculateMessage: Value(calcMessage),
      ));

      if (resultRows.length % 100 == 0) {
        onLog('✅ Đã xử lý ${resultRows.length} dòng...');
      }
    }

    // Batch insert results
    onLog('Lưu ${resultRows.length} kết quả...');
    await _db.batch((batch) {
      batch.insertAll(_db.results, resultRows);
    });

    // Step 2: Sort valid results
    onLog('Sắp xếp kết quả...');
    onSubStep(2);

    final allResults = await (_db.select(_db.results)
          ..where((r) => r.calculateStatus.equals('valid') & r.type.isBiggerThanValue(-1)))
        .get();

    // Need main_data for sorting
    final dataMap = {for (final d in datas) d.id: d};

    final validResults = allResults.where((r) => dataMap.containsKey(r.mainDataId)).toList();
    validResults.sort((a, b) {
      final da = dataMap[a.mainDataId]!;
      final db2 = dataMap[b.mainDataId]!;
      int cmp = da.customerCode.compareTo(db2.customerCode);
      if (cmp != 0) return cmp;
      cmp = da.branch.compareTo(db2.branch);
      if (cmp != 0) return cmp;
      cmp = da.seasonalCode.compareTo(db2.seasonalCode);
      if (cmp != 0) return cmp;
      cmp = a.type.compareTo(b.type);
      if (cmp != 0) return cmp;
      cmp = (a.paymentDueDate ?? DateTime(1900)).compareTo(b.paymentDueDate ?? DateTime(1900));
      if (cmp != 0) return cmp;
      cmp = b.bonusDecrease.compareTo(a.bonusDecrease);
      if (cmp != 0) return cmp;
      cmp = b.nonBonusDecrease.compareTo(a.nonBonusDecrease);
      if (cmp != 0) return cmp;
      cmp = b.bonusIncrease.compareTo(a.bonusIncrease);
      if (cmp != 0) return cmp;
      return b.nonBonusIncrease.compareTo(a.nonBonusIncrease);
    });

    // Update sorted_idx
    await _db.batch((batch) {
      for (int i = 0; i < validResults.length; i++) {
        batch.update(
          _db.results,
          ResultsCompanion(sortedIdx: Value(i)),
          where: (r) => r.id.equals(validResults[i].id),
        );
      }
    });

    // Step 3: FIFO bonus calculation
    onLog('Tính toán thưởng FIFO...');
    onSubStep(3);

    String currentCustomer = '', currentBranch = '', currentSeasonal = '';
    List<Map<String, dynamic>> beforeRemain = [];
    int totalBonus = 0;

    for (int i = 0; i < validResults.length; i++) {
      final result = validResults[i];
      final data = dataMap[result.mainDataId]!;

      // Reset stack on group change
      if (currentCustomer != data.customerCode ||
          currentBranch != data.branch ||
          currentSeasonal != data.seasonalCode) {
        currentCustomer = data.customerCode;
        currentBranch = data.branch;
        currentSeasonal = data.seasonalCode;
        beforeRemain = [];
      }

      // Skip empty document numbers
      if (data.documentNumber == null || data.documentNumber!.isEmpty) continue;

      final beforeStr = beforeRemain.toString();
      int bonus1 = 0, bonus2 = 0, bonus3 = 0;

      if (result.type == 0) {
        // Decrease → push to stack
        if (result.bonusDecrease > 0) {
          beforeRemain.add({
            'type': 'decrease',
            'sub_type': 'bonus',
            'amount': result.bonusDecrease,
            'date': data.documentDate,
          });
        } else {
          beforeRemain.add({
            'type': 'decrease',
            'sub_type': 'non_bonus',
            'amount': result.nonBonusDecrease,
            'date': data.documentDate,
          });
        }
      } else if (result.type == 1) {
        // Increase → consume stack
        if (result.bonusIncrease > 0) {
          int amount = result.bonusIncrease;
          while (amount > 0 && beforeRemain.isNotEmpty) {
            final first = beforeRemain[0];
            final mi = amount < (first['amount'] as int) ? amount : first['amount'] as int;
            amount -= mi;
            first['amount'] = (first['amount'] as int) - mi;

            if (first['sub_type'] == 'bonus' && first['date'] != null) {
              final decreaseDate = first['date'] as DateTime;
              if (result.paymentDueDate1 != null && !decreaseDate.isAfter(result.paymentDueDate1!)) {
                bonus1 += mi;
              } else if (result.paymentDueDate2 != null && !decreaseDate.isAfter(result.paymentDueDate2!)) {
                bonus2 += mi;
              } else if (result.paymentDueDate3 != null && !decreaseDate.isAfter(result.paymentDueDate3!)) {
                bonus3 += mi;
              }
            }

            if ((first['amount'] as int) <= 0) {
              beforeRemain.removeAt(0);
            }
          }
        } else {
          // non_bonus increase: consume stack without bonus
          int amount = result.nonBonusIncrease;
          while (amount > 0 && beforeRemain.isNotEmpty) {
            final first = beforeRemain[0];
            final mi = amount < (first['amount'] as int) ? amount : first['amount'] as int;
            amount -= mi;
            first['amount'] = (first['amount'] as int) - mi;
            if ((first['amount'] as int) <= 0) {
              beforeRemain.removeAt(0);
            }
          }
        }
      }

      totalBonus += bonus1 + bonus2 + bonus3;

      // Update result
      await (_db.update(_db.results)..where((r) => r.id.equals(result.id))).write(
        ResultsCompanion(
          bonus1: Value(bonus1),
          bonus2: Value(bonus2),
          bonus3: Value(bonus3),
          beforeRemain: Value(beforeStr),
          afterRemain: Value(beforeRemain.toString()),
        ),
      );

      if ((i + 1) % 100 == 0) onLog('✅ Đã tính toán ${i + 1} dòng...');
    }

    onLog('✅ Hoàn tất. Tổng thưởng: $totalBonus');
    onSubStep(4);

    return {
      'total_records': validResults.length,
      'total_bonus': totalBonus,
    };
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
