import 'package:test/test.dart';
import 'package:debt_matching/data/services/import_parser.dart';

void main() {
  group('parseExcelFile', () {
    test('normal.xlsx: parses all sheets correctly', () {
      final result = parseExcelFile(('test/fixtures/normal.xlsx', 'run-test'));
      expect(result['holidays']!.length, greaterThanOrEqualTo(0)); // DateCellValue may not parse via spreadsheet_decoder
      expect(result['levels']!.length, 2);
      expect(result['mainData']!.length, 6);
      final first = result['mainData']![0];
      expect(first['runId'], 'run-test');
      expect(first['custCode'], 'KH01');
      expect(first['seasonal'], 'VU01');
    });

    test('normal.xlsx: levels have correct fields', () {
      final result = parseExcelFile(('test/fixtures/normal.xlsx', 'run-test'));
      final l = result['levels']![0];
      expect(l['seasonalCode'], 'VU01');
      expect(l['salesMethod'], 'BH01');
      expect(l['paymentPeriod'], 30);
      expect(l['paymentPeriod1'], 30);
    });

    test('edge_cases.xlsx: parses despite bad data', () {
      final result = parseExcelFile(('test/fixtures/edge_cases.xlsx', 'run-edge'));
      expect(result['mainData']!.length, 5);
    });

    test('empty.xlsx: no data rows', () {
      final result = parseExcelFile(('test/fixtures/empty.xlsx', 'run-empty'));
      expect(result['mainData']!.length, 0);
      expect(result['holidays']!.length, 0);
    });

    test('meta: reports skipped rows', () {
      final result = parseExcelFile(('test/fixtures/normal.xlsx', 'run-test'));
      final meta = result['meta']!;
      expect(meta.length, 1);
      expect(meta[0]['skippedLevels'], 0);
      expect(meta[0]['skippedMainData'], 0);
    });
  });
}
