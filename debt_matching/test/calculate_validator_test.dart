import 'package:test/test.dart';
import 'package:debt_matching/data/services/calculate_validator.dart';
import 'package:debt_matching/data/database/app_database.dart';

MainData _makeData({String? docNum, int? period, String seasonal = 'VU01', String sales = 'BH01',
  String cust = 'KH01', String branch = 'CN01'}) => MainData(
  id: 'test-${docNum ?? "x"}', runId: 'run1', idx: 1, documentDate: DateTime(2024, 1, 1),
  documentNumber: docNum, description: '', correspondingAccount: '131',
  increase: 1000000, decrease: 0, adjustIncrease: 1000000, adjustDecrease: 0, endAmount: 0,
  seasonalCode: seasonal, paymentPeriod: period, customerCode: cust, customerName: 'Test',
  branch: branch, code: '', salesMethod: sales);

LevelConfig _makeLevel({String seasonal = 'VU01', String sales = 'BH01', int period = 30}) => LevelConfig(
  id: 'lv1', runId: 'run1', seasonalCode: seasonal, salesMethod: sales,
  paymentPeriod: period, paymentPeriod1: 30, paymentPeriod2: 45, paymentPeriod3: 60,
  paymentDueDate1: null, paymentDueDate2: null, paymentDueDate3: null);

void main() {
  group('validateAndMap', () {
    test('valid record matches level', () {
      final datas = [_makeData(docNum: 'CT01', period: 30)];
      final levels = [_makeLevel()];
      final result = validateAndMap(datas, levels);
      expect(result[0].status, 'valid');
      expect(result[0].levelId, 'lv1');
    });

    test('missing document number → invalid', () {
      final result = validateAndMap([_makeData(docNum: null, period: 30)], [_makeLevel()]);
      expect(result[0].status, 'invalid');
      expect(result[0].message, contains('Document number is empty'));
    });

    test('empty document number → invalid', () {
      final result = validateAndMap([_makeData(docNum: '', period: 30)], [_makeLevel()]);
      expect(result[0].status, 'invalid');
    });

    test('null payment period → invalid', () {
      final result = validateAndMap([_makeData(docNum: 'CT01', period: null)], [_makeLevel()]);
      expect(result[0].status, 'invalid');
      expect(result[0].message, contains('Payment period is null'));
    });

    test('negative payment period → invalid', () {
      final result = validateAndMap([_makeData(docNum: 'CT01', period: -1)], [_makeLevel()]);
      expect(result[0].status, 'invalid');
      expect(result[0].message, contains('>= 0'));
    });

    test('no matching level → invalid with message', () {
      final datas = [_makeData(docNum: 'CT01', period: 30, seasonal: 'UNKNOWN')];
      final result = validateAndMap(datas, [_makeLevel()]);
      expect(result[0].status, 'invalid');
      expect(result[0].message, 'No matching level config');
    });

    test('duplicate documentNumber → warning in message', () {
      final datas = [
        _makeData(docNum: 'CT01', period: 30),
        _makeData(docNum: 'CT01', period: 30),
      ];
      final result = validateAndMap(datas, [_makeLevel()]);
      expect(result[0].status, 'valid');
      expect(result[0].message, contains('Duplicate'));
      expect(result[1].message, contains('Duplicate'));
    });

    test('case-insensitive level matching', () {
      final datas = [_makeData(docNum: 'CT01', period: 30, seasonal: 'vu01', sales: 'bh01')];
      final result = validateAndMap(datas, [_makeLevel()]);
      expect(result[0].status, 'valid');
    });
  });
}
