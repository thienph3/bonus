import 'package:test/test.dart';
import 'package:debt_matching/data/services/calculate_result_builder.dart';
import 'package:debt_matching/data/services/calculate_validator.dart';
import 'package:debt_matching/data/database/app_database.dart';

MainData _make({int inc = 0, int dec = 0, int adjInc = 0, int adjDec = 0, int period = 30}) => MainData(
  id: 'md1', runId: 'run1', idx: 1, documentDate: DateTime(2024, 1, 10),
  documentNumber: 'CT01', description: '', correspondingAccount: '131',
  increase: inc, decrease: dec, adjustIncrease: adjInc, adjustDecrease: adjDec, endAmount: 0,
  seasonalCode: 'VU01', paymentPeriod: period, customerCode: 'KH01', customerName: 'Test',
  branch: 'CN01', code: '', salesMethod: 'BH01');

LevelConfig _level() => LevelConfig(id: 'lv1', runId: 'run1', seasonalCode: 'VU01', salesMethod: 'BH01',
  paymentPeriod: 30, paymentPeriod1: 30, paymentPeriod2: 45, paymentPeriod3: 60,
  paymentDueDate1: null, paymentDueDate2: null, paymentDueDate3: null);

void main() {
  final builder = CalculateResultBuilder();

  group('buildResultRows', () {
    test('increase row: type=1, bonusIncrease=adjustIncrease', () {
      final data = _make(inc: 5000000, adjInc: 5000000);
      final validated = [ValidatedData(dataId: 'md1', levelId: 'lv1', level: _level(), status: 'valid', message: '')];
      final rows = builder.buildResultRows([data], validated, {}, 'run1');
      expect(rows.length, 1);
      expect(rows[0].type.value, 1);
      expect(rows[0].bonusIncrease.value, 5000000);
      expect(rows[0].nonBonusIncrease.value, 0);
    });

    test('decrease row: type=0, bonusDecrease=decrease-adjustDecrease', () {
      final data = _make(dec: 3000000, adjDec: 0);
      final validated = [ValidatedData(dataId: 'md1', levelId: 'lv1', level: _level(), status: 'valid', message: '')];
      final rows = builder.buildResultRows([data], validated, {}, 'run1');
      expect(rows[0].type.value, 0);
      expect(rows[0].bonusDecrease.value, 3000000);
      expect(rows[0].nonBonusDecrease.value, 0);
    });

    test('zero amounts: type=-1', () {
      final data = _make(inc: 0, dec: 0);
      final validated = [ValidatedData(dataId: 'md1', levelId: 'lv1', level: _level(), status: 'valid', message: '')];
      final rows = builder.buildResultRows([data], validated, {}, 'run1');
      expect(rows[0].type.value, -1);
    });

    test('payment due dates calculated from docDate + period', () {
      final data = _make(inc: 1000000, adjInc: 1000000);
      final validated = [ValidatedData(dataId: 'md1', levelId: 'lv1', level: _level(), status: 'valid', message: '')];
      final rows = builder.buildResultRows([data], validated, {}, 'run1');
      // docDate=2024-01-10, period1=30 → 2024-02-09
      expect(rows[0].paymentDueDate1.value, DateTime(2024, 2, 9));
      expect(rows[0].paymentDueDate2.value, DateTime(2024, 2, 24)); // +45
      expect(rows[0].paymentDueDate3.value, DateTime(2024, 3, 10)); // +60
    });

    test('holiday adjustment shifts due date', () {
      final data = _make(inc: 1000000, adjInc: 1000000);
      final validated = [ValidatedData(dataId: 'md1', levelId: 'lv1', level: _level(), status: 'valid', message: '')];
      final holidays = {DateTime(2024, 2, 9)}; // pdd1 falls on holiday
      final rows = builder.buildResultRows([data], validated, holidays, 'run1');
      expect(rows[0].paymentDueDate1.value, DateTime(2024, 2, 10)); // shifted +1
    });
  });
}
