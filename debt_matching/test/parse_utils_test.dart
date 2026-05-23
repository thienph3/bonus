import 'package:test/test.dart';
import 'package:debt_matching/core/utils/parse_utils.dart';

void main() {
  group('parseNumber', () {
    test('null returns null', () => expect(parseNumber(null), isNull));
    test('int passthrough', () => expect(parseNumber(42), 42));
    test('double rounds', () => expect(parseNumber(3.7), 4));
    test('double rounds down', () => expect(parseNumber(3.2), 3));
    test('string int', () => expect(parseNumber('100'), 100));
    test('string double', () => expect(parseNumber('99.5'), 100));
    test('empty string', () => expect(parseNumber(''), isNull));
    test('non-numeric string', () => expect(parseNumber('abc'), isNull));
    test('whitespace string', () => expect(parseNumber('  '), isNull));
  });

  group('parseDate', () {
    test('null returns null', () => expect(parseDate(null), isNull));
    test('DateTime passthrough (normalized)', () {
      final dt = DateTime(2024, 3, 15, 10, 30);
      expect(parseDate(dt), DateTime(2024, 3, 15));
    });
    test('Excel serial number', () {
      // 45000 = 2023-03-15 (verified against Excel)
      expect(parseDate(45000), DateTime(2023, 3, 15));
    });
    test('string dd/MM/yyyy', () => expect(parseDate('15/03/2024'), DateTime(2024, 3, 15)));
    test('string yyyy-MM-dd', () => expect(parseDate('2024-03-15'), DateTime(2024, 3, 15)));
    test('empty string', () => expect(parseDate(''), isNull));
    test('invalid string', () => expect(parseDate('not-a-date'), isNull));
    test('zero serial', () => expect(parseDate(0), isNull));
  });

  group('changeDateByHolidays', () {
    test('null returns null', () => expect(changeDateByHolidays(null, {}), isNull));
    test('no holiday - unchanged', () {
      final date = DateTime(2024, 3, 15);
      expect(changeDateByHolidays(date, {}), date);
    });
    test('skips single holiday', () {
      final date = DateTime(2024, 1, 1);
      final holidays = {DateTime(2024, 1, 1)};
      expect(changeDateByHolidays(date, holidays), DateTime(2024, 1, 2));
    });
    test('skips consecutive holidays', () {
      final date = DateTime(2024, 1, 1);
      final holidays = {DateTime(2024, 1, 1), DateTime(2024, 1, 2), DateTime(2024, 1, 3)};
      expect(changeDateByHolidays(date, holidays), DateTime(2024, 1, 4));
    });
    test('date not in holidays - unchanged', () {
      final date = DateTime(2024, 3, 15);
      final holidays = {DateTime(2024, 1, 1)};
      expect(changeDateByHolidays(date, holidays), date);
    });
  });
}
