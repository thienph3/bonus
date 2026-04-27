import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';

const _uuid = Uuid();

class FifoResult {
  final int totalBonus;
  final int totalConsumed;
  final int totalRemaining;
  final int totalPushed;
  FifoResult({required this.totalBonus, required this.totalConsumed, required this.totalRemaining, required this.totalPushed});
}

/// FIFO stack bonus calculation logic
class CalculateFifo {
  final AppDatabase _db;
  CalculateFifo(this._db);

  Future<FifoResult> run(
    List<Result> results, Map<String, MainData> dataMap, void Function(String) onLog,
  ) async {
    String curCust = '', curBranch = '', curSeason = '';
    List<Map<String, dynamic>> stack = [];
    int totalBonus = 0, totalConsumed = 0, totalPushed = 0;
    var updates = <_BonusUpdate>[];
    var matchings = <MatchingDetailsCompanion>[];

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
        final amt = r.bonusDecrease > 0 ? r.bonusDecrease : r.nonBonusDecrease;
        stack.add({
          'sub_type': r.bonusDecrease > 0 ? 'bonus' : 'non_bonus',
          'amount': amt, 'date': data.documentDate, 'doc': data.documentNumber,
        });
        totalPushed += amt;
      } else if (r.type == 1) {
        int amount = r.bonusIncrease > 0 ? r.bonusIncrease : r.nonBonusIncrease;
        final isBonus = r.bonusIncrease > 0;
        while (amount > 0 && stack.isNotEmpty) {
          final first = stack[0];
          final mi = amount < (first['amount'] as int) ? amount : first['amount'] as int;
          amount -= mi;
          first['amount'] = (first['amount'] as int) - mi;
          totalConsumed += mi;
          String tier = 'none';

          if (isBonus && first['sub_type'] == 'bonus' && first['date'] != null) {
            final d = first['date'] as DateTime;
            if (r.paymentDueDate1 != null && !d.isAfter(r.paymentDueDate1!)) {
              b1 += mi; tier = 'bonus_1';
            } else if (r.paymentDueDate2 != null && !d.isAfter(r.paymentDueDate2!)) {
              b2 += mi; tier = 'bonus_2';
            } else if (r.paymentDueDate3 != null && !d.isAfter(r.paymentDueDate3!)) {
              b3 += mi; tier = 'bonus_3';
            }
          }

          matchings.add(MatchingDetailsCompanion.insert(
            id: _uuid.v4(), resultId: r.id,
            increaseDocNumber: Value(data.documentNumber ?? ''),
            decreaseDocNumber: Value(first['doc']?.toString() ?? ''),
            decreaseDate: Value(first['date'] as DateTime?),
            amountMatched: Value(mi), bonusTier: Value(tier),
          ));

          if ((first['amount'] as int) <= 0) stack.removeAt(0);
        }
      }

      totalBonus += b1 + b2 + b3;
      updates.add(_BonusUpdate(r.id, b1, b2, b3, beforeStr, stack.toString()));

      if (updates.length >= 100) {
        await _flush(updates, matchings);
        onLog('✅ Đã tính ${i + 1} dòng...');
        updates = [];
        matchings = [];
      }
    }
    if (updates.isNotEmpty) await _flush(updates, matchings);

    final totalRemaining = stack.fold<int>(0, (sum, item) => sum + (item['amount'] as int));
    return FifoResult(
      totalBonus: totalBonus, totalConsumed: totalConsumed,
      totalRemaining: totalRemaining, totalPushed: totalPushed,
    );
  }

  Future<void> _flush(List<_BonusUpdate> updates, List<MatchingDetailsCompanion> matchings) async {
    await _db.batch((batch) {
      for (final u in updates) {
        batch.update(_db.results,
          ResultsCompanion(bonus1: Value(u.b1), bonus2: Value(u.b2), bonus3: Value(u.b3),
              beforeRemain: Value(u.before), afterRemain: Value(u.after)),
          where: (r) => r.id.equals(u.id));
      }
      if (matchings.isNotEmpty) batch.insertAll(_db.matchingDetails, matchings);
    });
  }
}

class _BonusUpdate {
  final String id;
  final int b1, b2, b3;
  final String before, after;
  _BonusUpdate(this.id, this.b1, this.b2, this.b3, this.before, this.after);
}
