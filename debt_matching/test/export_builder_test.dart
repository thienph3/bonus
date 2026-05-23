import 'package:test/test.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'package:debt_matching/data/services/export_builder.dart';

void main() {
  group('buildExcelBytes', () {
    test('produces valid Excel with 3 sheets', () {
      final bytes = buildExcelBytes({
        'results': [_sampleResult()],
        'matchings': [_sampleMatching()],
        'bonusRates': null,
      });
      expect(bytes, isNotNull);
      expect(bytes!.isNotEmpty, true);
      final dec = SpreadsheetDecoder.decodeBytes(bytes);
      expect(dec.tables.containsKey('Summary'), true);
      expect(dec.tables.containsKey('Result'), true);
      expect(dec.tables.containsKey('Matching Detail'), true);
    });

    test('Summary groups by customer_code', () {
      final bytes = buildExcelBytes({
        'results': [_sampleResult(), _sampleResult(cust: 'KH02', b1: 2000000)],
        'matchings': [], 'bonusRates': null,
      });
      final dec = SpreadsheetDecoder.decodeBytes(bytes!);
      final summary = dec.tables['Summary']!;
      expect(summary.rows.length, 3); // header + 2 customers
    });

    test('Summary includes final_bonus when rates provided', () {
      final bytes = buildExcelBytes({
        'results': [_sampleResult(b1: 10000000)],
        'matchings': [],
        'bonusRates': {'pct_1': 2.0, 'pct_2': 1.5, 'pct_3': 1.0},
      });
      final dec = SpreadsheetDecoder.decodeBytes(bytes!);
      final summary = dec.tables['Summary']!;
      final headers = summary.rows[0];
      expect(headers.contains('final_bonus_1'), true);
      // 10000000 * 2% = 200000
      final dataRow = summary.rows[1];
      expect(dataRow[7], 200000); // final_bonus_1
    });

    test('Result sheet has correct column count', () {
      final bytes = buildExcelBytes({'results': [_sampleResult()], 'matchings': [], 'bonusRates': null});
      final dec = SpreadsheetDecoder.decodeBytes(bytes!);
      final result = dec.tables['Result']!;
      expect(result.rows[0].length, 31); // 31 columns
    });

    test('empty results produces valid file', () {
      final bytes = buildExcelBytes({'results': [], 'matchings': [], 'bonusRates': null});
      expect(bytes, isNotNull);
      expect(bytes!.isNotEmpty, true);
    });
  });
}

Map<String, dynamic> _sampleResult({String cust = 'KH01', int b1 = 5000000}) => {
  'idx': 1, 'document_date': DateTime(2024, 1, 10), 'document_number': 'CT01',
  'description': 'Test', 'corresponding_account': '131',
  'increase': 5000000, 'decrease': 0, 'adjust_increase': 5000000, 'adjust_decrease': 0,
  'end_amount': 0, 'seasonal_code': 'VU01', 'payment_period': 30,
  'customer_code': cust, 'customer_name': 'Test', 'branch': 'CN01', 'code': '', 'sales_method': 'BH01',
  'type': 1, 'payment_due_date': DateTime(2024, 2, 9),
  'bonus_decrease': 0, 'non_bonus_decrease': 0, 'bonus_increase': 5000000, 'non_bonus_increase': 0,
  'payment_due_date_1': DateTime(2024, 2, 9), 'payment_due_date_2': null, 'payment_due_date_3': null,
  'bonus_1': b1, 'bonus_2': 0, 'bonus_3': 0,
  'calculate_status': 'valid', 'calculate_message': '',
};

Map<String, dynamic> _sampleMatching() => {
  'increase_doc': 'CT01', 'decrease_doc': 'CT02',
  'decrease_date': DateTime(2024, 2, 1), 'amount': 5000000, 'bonus_tier': 'bonus_1',
};
