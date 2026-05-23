import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../../core/utils/parse_utils.dart';
import 'calculate_validator.dart';

/// Builds ResultsCompanion rows from validated data.
class CalculateResultBuilder {
  final _uuid = const Uuid();

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
      String calcStatus = v.status;
      String calcMessage = v.message;
      if (bonusDecrease > 0 || nonBonusDecrease > 0) {
        type = 0;
      } else if (bonusIncrease > 0 || nonBonusIncrease > 0) {
        type = 1;
      } else {
        type = -1;
        if (calcStatus == 'valid') {
          final isOpening = (data.documentDate != null && data.documentDate!.year <= 1900)
              || (data.description?.toLowerCase().contains('dư đầu kỳ') ?? false);
          calcStatus = isOpening ? 'opening_balance' : 'invalid';
          calcMessage = isOpening ? 'Số dư đầu kỳ' : 'Không có phát sinh';
        }
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
        calculateStatus: Value(calcStatus),
        calculateMessage: Value(calcMessage),
      ));
    }
    return rows;
  }
}
