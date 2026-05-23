import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../../core/utils/parse_utils.dart';

class ValidatedData {
  final String dataId;
  final String? levelId;
  final LevelConfig? level;
  final String status;
  final String message;

  ValidatedData({
    required this.dataId,
    this.levelId,
    this.level,
    required this.status,
    required this.message,
  });
}

/// Validates main_data and builds result rows
class CalculateResultBuilder {
  final _uuid = const Uuid();

  /// Validate each main_data and find matching level
  List<ValidatedData> validateAndMap(
    List<MainData> datas,
    List<LevelConfig> sortedLevels,
  ) {
    // Build duplicate doc set: (customerCode|branch|seasonalCode|docNumber)
    final docCounts = <String, int>{};
    for (final data in datas) {
      final doc = data.documentNumber?.trim() ?? '';
      if (doc.isEmpty) continue;
      final key = '${data.customerCode}|${data.branch}|${data.seasonalCode}|$doc';
      docCounts[key] = (docCounts[key] ?? 0) + 1;
    }
    final duplicateKeys = docCounts.entries.where((e) => e.value > 1).map((e) => e.key).toSet();

    final results = <ValidatedData>[];
    for (final data in datas) {
      String? levelId;
      LevelConfig? matchedLevel;
      String status = 'invalid';
      String message = '';

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

      if (errors.isEmpty) {
        for (final level in sortedLevels) {
          if (data.seasonalCode.toLowerCase() == level.seasonalCode.toLowerCase() &&
              data.salesMethod.toLowerCase() == level.salesMethod.toLowerCase() &&
              (data.paymentPeriod ?? 0) >= level.paymentPeriod) {
            levelId = level.id;
            matchedLevel = level;
            status = 'valid';
            break;
          }
        }
        if (levelId == null) message = 'No matching level config';
        // Check duplicate documentNumber within same group
        final doc = data.documentNumber?.trim() ?? '';
        if (doc.isNotEmpty) {
          final key = '${data.customerCode}|${data.branch}|${data.seasonalCode}|$doc';
          if (duplicateKeys.contains(key)) {
            final warn = 'Duplicate documentNumber: $doc';
            message = message.isEmpty ? warn : '$message; $warn';
          }
        }
      } else {
        message = errors.join('; ');
      }

      results.add(ValidatedData(
        dataId: data.id,
        levelId: levelId,
        level: matchedLevel,
        status: status,
        message: message,
      ));
    }
    return results;
  }

  /// Build ResultsCompanion rows from validated data
  List<ResultsCompanion> buildResultRows(
    List<MainData> datas,
    List<ValidatedData> validated,
    Set<DateTime> holidaySet,
    String runId,
  ) {
    final rows = <ResultsCompanion>[];
    for (int idx = 0; idx < datas.length; idx++) {
      final data = datas[idx];
      final v = validated[idx];

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

      final docDate = data.documentDate;
      final paymentDueDate = docDate != null
          ? docDate.add(Duration(days: data.paymentPeriod ?? 0))
          : DateTime(1900, 1, 1);

      DateTime? pdd1, pdd2, pdd3;
      if (type == 1 && v.level != null) {
        final level = v.level!;
        pdd1 = level.paymentDueDate1 ??
            (docDate?.add(Duration(days: level.paymentPeriod1)) ?? DateTime(1900, 1, 1));
        pdd2 = level.paymentDueDate2 ??
            (docDate?.add(Duration(days: level.paymentPeriod2)) ?? DateTime(1900, 1, 1));
        pdd3 = level.paymentDueDate3 ??
            (docDate?.add(Duration(days: level.paymentPeriod3)) ?? DateTime(1900, 1, 1));
        pdd1 = changeDateByHolidays(pdd1, holidaySet);
        pdd2 = changeDateByHolidays(pdd2, holidaySet);
        pdd3 = changeDateByHolidays(pdd3, holidaySet);
      }

      rows.add(ResultsCompanion.insert(
        id: _uuid.v4(),
        mainDataId: data.id,
        runId: Value(runId),
        levelConfigId: Value(v.levelId),
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
        calculateStatus: Value(v.status),
        calculateMessage: Value(v.message),
      ));
    }
    return rows;
  }
}
