import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class FifoResult {
  final int totalBonus, totalConsumed, totalRemaining, totalPushed;
  final List<Map<String, dynamic>> bonusUpdates;
  final List<Map<String, dynamic>> matchingDetails;
  FifoResult({required this.totalBonus, required this.totalConsumed,
    required this.totalRemaining, required this.totalPushed,
    required this.bonusUpdates, required this.matchingDetails});
}

/// Pure FIFO computation. Input/output are plain Maps — isolate-safe.
FifoResult computeFifo(Map<String, dynamic> input) {
  final results = input['results'] as List<Map<String, dynamic>>;
  final dataMap = input['dataMap'] as Map<String, Map<String, dynamic>>;

  String curCust = '', curBranch = '', curSeason = '';
  List<Map<String, dynamic>> stack = [];
  int totalBonus = 0, totalConsumed = 0, totalPushed = 0;
  final bonusUpdates = <Map<String, dynamic>>[];
  final matchings = <Map<String, dynamic>>[];

  for (final r in results) {
    final data = dataMap[r['mainDataId']]!;
    final custCode = data['customerCode'] as String;
    final branch = data['branch'] as String;
    final seasonal = data['seasonalCode'] as String;

    if (curCust != custCode || curBranch != branch || curSeason != seasonal) {
      curCust = custCode; curBranch = branch; curSeason = seasonal; stack = [];
    }

    final docNum = data['documentNumber'] as String?;
    if (docNum == null || docNum.isEmpty) continue;

    final beforeStr = stack.toString();
    int b1 = 0, b2 = 0, b3 = 0;
    final type = r['type'] as int;
    final bonusDec = r['bonusDecrease'] as int;
    final nonBonusDec = r['nonBonusDecrease'] as int;
    final bonusInc = r['bonusIncrease'] as int;
    final nonBonusInc = r['nonBonusIncrease'] as int;

    if (type == 0) {
      final amt = bonusDec > 0 ? bonusDec : nonBonusDec;
      stack.add({'sub_type': bonusDec > 0 ? 'bonus' : 'non_bonus',
        'amount': amt, 'date': data['documentDate'], 'doc': docNum});
      totalPushed += amt;
    } else if (type == 1) {
      int amount = bonusInc > 0 ? bonusInc : nonBonusInc;
      final isBonus = bonusInc > 0;
      while (amount > 0 && stack.isNotEmpty) {
        final first = stack[0];
        final mi = amount < (first['amount'] as int) ? amount : first['amount'] as int;
        amount -= mi;
        first['amount'] = (first['amount'] as int) - mi;
        totalConsumed += mi;
        String tier = 'none';

        if (isBonus && first['sub_type'] == 'bonus' && first['date'] != null) {
          final d = first['date'] as int;
          final pdd1 = r['paymentDueDate1'] as int?;
          final pdd2 = r['paymentDueDate2'] as int?;
          final pdd3 = r['paymentDueDate3'] as int?;
          if (pdd1 != null && d <= pdd1) { b1 += mi; tier = 'bonus_1'; }
          else if (pdd2 != null && d <= pdd2) { b2 += mi; tier = 'bonus_2'; }
          else if (pdd3 != null && d <= pdd3) { b3 += mi; tier = 'bonus_3'; }
        }

        matchings.add({'id': _uuid.v4(), 'resultId': r['id'],
          'increaseDoc': docNum, 'decreaseDoc': first['doc'] ?? '',
          'decreaseDate': first['date'], 'amount': mi, 'tier': tier});

        if ((first['amount'] as int) <= 0) stack.removeAt(0);
      }
    }

    totalBonus += b1 + b2 + b3;
    bonusUpdates.add({'id': r['id'], 'b1': b1, 'b2': b2, 'b3': b3,
      'before': beforeStr, 'after': stack.toString()});
  }

  final totalRemaining = stack.fold<int>(0, (s, item) => s + (item['amount'] as int));
  return FifoResult(totalBonus: totalBonus, totalConsumed: totalConsumed,
    totalRemaining: totalRemaining, totalPushed: totalPushed,
    bonusUpdates: bonusUpdates, matchingDetails: matchings);
}
