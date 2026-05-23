import 'package:test/test.dart';
import 'package:debt_matching/data/services/calculate_fifo.dart';

Map<String, dynamic> _result(String id, String mainDataId, int type,
    {int bonusDec = 0, int nonBonusDec = 0, int bonusInc = 0, int nonBonusInc = 0,
    int? pdd1, int? pdd2, int? pdd3}) => {
  'id': id, 'mainDataId': mainDataId, 'type': type,
  'bonusDecrease': bonusDec, 'nonBonusDecrease': nonBonusDec,
  'bonusIncrease': bonusInc, 'nonBonusIncrease': nonBonusInc,
  'paymentDueDate1': pdd1, 'paymentDueDate2': pdd2, 'paymentDueDate3': pdd3,
};

Map<String, dynamic> _data(String cust, String doc, {int? date}) => {
  'customerCode': cust, 'branch': 'CN01', 'seasonalCode': 'VU01',
  'documentNumber': doc, 'documentDate': date,
};

void main() {
  group('computeFifo', () {
    test('basic FIFO: decrease then increase → bonus_1', () {
      final pdd1 = DateTime(2024, 3, 15).millisecondsSinceEpoch;
      final decDate = DateTime(2024, 2, 1).millisecondsSinceEpoch;
      final results = [
        _result('r1', 'd1', 0, bonusDec: 5000000),
        _result('r2', 'd2', 1, bonusInc: 5000000, pdd1: pdd1),
      ];
      final dataMap = {
        'd1': _data('KH01', 'CT001', date: decDate),
        'd2': _data('KH01', 'CT002'),
      };
      final fifo = computeFifo({'results': results, 'dataMap': dataMap});
      expect(fifo.totalBonus, 5000000);
      expect(fifo.totalPushed, 5000000);
      expect(fifo.totalConsumed, 5000000);
      expect(fifo.totalRemaining, 0);
      expect(fifo.matchingDetails.length, 1);
      expect(fifo.matchingDetails[0]['tier'], 'bonus_1');
    });

    test('partial consumption', () {
      final pdd1 = DateTime(2024, 3, 15).millisecondsSinceEpoch;
      final decDate = DateTime(2024, 2, 1).millisecondsSinceEpoch;
      final results = [
        _result('r1', 'd1', 0, bonusDec: 10000000),
        _result('r2', 'd2', 1, bonusInc: 3000000, pdd1: pdd1),
      ];
      final dataMap = {'d1': _data('KH01', 'CT001', date: decDate), 'd2': _data('KH01', 'CT002')};
      final fifo = computeFifo({'results': results, 'dataMap': dataMap});
      expect(fifo.totalConsumed, 3000000);
      expect(fifo.totalRemaining, 7000000);
      expect(fifo.totalBonus, 3000000);
    });

    test('tier 2: date exceeds pdd1 but within pdd2', () {
      final pdd1 = DateTime(2024, 2, 1).millisecondsSinceEpoch;
      final pdd2 = DateTime(2024, 3, 15).millisecondsSinceEpoch;
      final decDate = DateTime(2024, 2, 10).millisecondsSinceEpoch; // after pdd1
      final results = [
        _result('r1', 'd1', 0, bonusDec: 1000000),
        _result('r2', 'd2', 1, bonusInc: 1000000, pdd1: pdd1, pdd2: pdd2),
      ];
      final dataMap = {'d1': _data('KH01', 'CT001', date: decDate), 'd2': _data('KH01', 'CT002')};
      final fifo = computeFifo({'results': results, 'dataMap': dataMap});
      expect(fifo.matchingDetails[0]['tier'], 'bonus_2');
    });

    test('no bonus: date exceeds all tiers', () {
      final pdd1 = DateTime(2024, 1, 1).millisecondsSinceEpoch;
      final decDate = DateTime(2024, 6, 1).millisecondsSinceEpoch;
      final results = [
        _result('r1', 'd1', 0, bonusDec: 1000000),
        _result('r2', 'd2', 1, bonusInc: 1000000, pdd1: pdd1),
      ];
      final dataMap = {'d1': _data('KH01', 'CT001', date: decDate), 'd2': _data('KH01', 'CT002')};
      final fifo = computeFifo({'results': results, 'dataMap': dataMap});
      expect(fifo.totalBonus, 0);
      expect(fifo.matchingDetails[0]['tier'], 'none');
    });

    test('group reset: different customer gets fresh stack', () {
      final pdd1 = DateTime(2024, 3, 15).millisecondsSinceEpoch;
      final decDate = DateTime(2024, 2, 1).millisecondsSinceEpoch;
      final results = [
        _result('r1', 'd1', 0, bonusDec: 5000000),
        _result('r2', 'd2', 1, bonusInc: 5000000, pdd1: pdd1), // KH02 - no stack
      ];
      final dataMap = {
        'd1': _data('KH01', 'CT001', date: decDate),
        'd2': _data('KH02', 'CT002'), // different customer
      };
      final fifo = computeFifo({'results': results, 'dataMap': dataMap});
      expect(fifo.totalConsumed, 0); // KH02 has empty stack, nothing to consume
      expect(fifo.totalBonus, 0);
    });

    test('reconciliation: pushed = consumed + remaining', () {
      final pdd1 = DateTime(2024, 12, 31).millisecondsSinceEpoch;
      final decDate = DateTime(2024, 1, 1).millisecondsSinceEpoch;
      final results = [
        _result('r1', 'd1', 0, bonusDec: 10000000),
        _result('r2', 'd2', 0, bonusDec: 5000000),
        _result('r3', 'd3', 1, bonusInc: 8000000, pdd1: pdd1),
      ];
      final dataMap = {
        'd1': _data('KH01', 'CT001', date: decDate),
        'd2': _data('KH01', 'CT002', date: decDate),
        'd3': _data('KH01', 'CT003'),
      };
      final fifo = computeFifo({'results': results, 'dataMap': dataMap});
      expect(fifo.totalPushed, fifo.totalConsumed + fifo.totalRemaining);
    });

    test('non_bonus decrease: consumed but no bonus', () {
      final pdd1 = DateTime(2024, 12, 31).millisecondsSinceEpoch;
      final decDate = DateTime(2024, 1, 1).millisecondsSinceEpoch;
      final results = [
        _result('r1', 'd1', 0, nonBonusDec: 1000000), // non_bonus
        _result('r2', 'd2', 1, bonusInc: 1000000, pdd1: pdd1),
      ];
      final dataMap = {'d1': _data('KH01', 'CT001', date: decDate), 'd2': _data('KH01', 'CT002')};
      final fifo = computeFifo({'results': results, 'dataMap': dataMap});
      expect(fifo.totalConsumed, 1000000);
      expect(fifo.totalBonus, 0); // non_bonus stack item → no bonus
    });

    test('empty doc number skipped', () {
      final results = [_result('r1', 'd1', 0, bonusDec: 1000000)];
      final dataMap = {'d1': _data('KH01', '')};
      final fifo = computeFifo({'results': results, 'dataMap': dataMap});
      expect(fifo.totalPushed, 0);
    });
  });
}
