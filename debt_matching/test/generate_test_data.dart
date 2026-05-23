/// Generates test Excel files for unit testing.
/// Run: dart run test/generate_test_data.dart
import 'dart:io';
import 'package:excel/excel.dart';

void main() {
  final dir = Directory('test/fixtures');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  _generateNormal(dir);
  _generateEdgeCases(dir);
  _generateEmpty(dir);
  print('✅ Generated test fixtures in test/fixtures/');
}

void _generateNormal(Directory dir) {
  final excel = Excel.createExcel();

  // holiday_config sheet
  final holidays = excel['holiday_config'];
  holidays.appendRow([TextCellValue('date')]);
  holidays.appendRow([DateCellValue(year: 2024, month: 1, day: 1)]);
  holidays.appendRow([DateCellValue(year: 2024, month: 4, day: 30)]);

  // level_config sheet
  final levels = excel['level_config'];
  levels.appendRow([TextCellValue('seasonal'), TextCellValue('sales_method'),
    IntCellValue(30), IntCellValue(30), IntCellValue(45), IntCellValue(60)]);
  levels.appendRow([TextCellValue('VU01'), TextCellValue('BH01'),
    IntCellValue(30), IntCellValue(30), IntCellValue(45), IntCellValue(60)]);
  levels.appendRow([TextCellValue('VU01'), TextCellValue('BH01'),
    IntCellValue(60), IntCellValue(60), IntCellValue(75), IntCellValue(90)]);

  // Data sheet - 17 columns header + data rows
  final data = excel['Data'];
  data.appendRow(_header());
  // Decrease (payment) rows
  data.appendRow(_dataRow(1, DateTime(2024, 2, 1), 'CT001', null, 0, 5000000, 0, 0, 'VU01', 30, 'KH01', 'CN01', 'BH01'));
  data.appendRow(_dataRow(2, DateTime(2024, 2, 15), 'CT002', null, 0, 3000000, 0, 0, 'VU01', 30, 'KH01', 'CN01', 'BH01'));
  // Increase (invoice) rows
  data.appendRow(_dataRow(3, DateTime(2024, 1, 10), 'CT003', 4000000, 4000000, 0, 4000000, 0, 'VU01', 30, 'KH01', 'CN01', 'BH01'));
  data.appendRow(_dataRow(4, DateTime(2024, 1, 20), 'CT004', 6000000, 6000000, 0, 6000000, 0, 'VU01', 30, 'KH01', 'CN01', 'BH01'));
  // Second customer
  data.appendRow(_dataRow(5, DateTime(2024, 3, 1), 'CT005', null, 0, 2000000, 0, 0, 'VU01', 30, 'KH02', 'CN01', 'BH01'));
  data.appendRow(_dataRow(6, DateTime(2024, 2, 1), 'CT006', 2000000, 2000000, 0, 2000000, 0, 'VU01', 30, 'KH02', 'CN01', 'BH01'));

  if (excel.tables.containsKey('Sheet1')) excel.delete('Sheet1');
  File('${dir.path}/normal.xlsx').writeAsBytesSync(excel.save()!);
}

void _generateEdgeCases(Directory dir) {
  final excel = Excel.createExcel();
  final holidays = excel['holiday_config'];
  holidays.appendRow([TextCellValue('date')]);

  final levels = excel['level_config'];
  levels.appendRow([TextCellValue('seasonal'), TextCellValue('sales_method'),
    IntCellValue(30), IntCellValue(30), IntCellValue(45), IntCellValue(60)]);
  levels.appendRow([TextCellValue('VU01'), TextCellValue('BH01'),
    IntCellValue(30), IntCellValue(30), IntCellValue(45), IntCellValue(60)]);

  final data = excel['Data'];
  data.appendRow(_header());
  // Missing document number
  data.appendRow(_dataRow(1, DateTime(2024, 1, 1), '', 1000000, 1000000, 0, 1000000, 0, 'VU01', 30, 'KH01', 'CN01', 'BH01'));
  // Missing payment period
  data.appendRow(_dataRow(2, DateTime(2024, 1, 1), 'CT01', 1000000, 1000000, 0, 1000000, 0, 'VU01', null, 'KH01', 'CN01', 'BH01'));
  // Duplicate document number
  data.appendRow(_dataRow(3, DateTime(2024, 1, 1), 'CT02', null, 0, 500000, 0, 0, 'VU01', 30, 'KH01', 'CN01', 'BH01'));
  data.appendRow(_dataRow(4, DateTime(2024, 1, 5), 'CT02', 500000, 500000, 0, 500000, 0, 'VU01', 30, 'KH01', 'CN01', 'BH01'));
  // Zero amounts
  data.appendRow(_dataRow(5, DateTime(2024, 1, 1), 'CT03', 0, 0, 0, 0, 0, 'VU01', 30, 'KH01', 'CN01', 'BH01'));

  if (excel.tables.containsKey('Sheet1')) excel.delete('Sheet1');
  File('${dir.path}/edge_cases.xlsx').writeAsBytesSync(excel.save()!);
}

void _generateEmpty(Directory dir) {
  final excel = Excel.createExcel();
  excel['holiday_config'].appendRow([TextCellValue('date')]);
  excel['level_config'].appendRow([TextCellValue('seasonal'), TextCellValue('sales_method'),
    IntCellValue(30), IntCellValue(30), IntCellValue(45), IntCellValue(60)]);
  excel['Data'].appendRow(_header());
  if (excel.tables.containsKey('Sheet1')) excel.delete('Sheet1');
  File('${dir.path}/empty.xlsx').writeAsBytesSync(excel.save()!);
}

List<CellValue> _header() => [
  TextCellValue('STT'), TextCellValue('Ngày CT'), TextCellValue('Số CT'), TextCellValue('Diễn giải'),
  TextCellValue('TK đối ứng'), TextCellValue('PS tăng'), TextCellValue('PS giảm'),
  TextCellValue('ĐC tăng'), TextCellValue('ĐC giảm'), TextCellValue('Số dư'),
  TextCellValue('Mã vụ'), TextCellValue('Kỳ hạn'), TextCellValue('Mã KH'),
  TextCellValue('Tên KH'), TextCellValue('Chi nhánh'), TextCellValue('Mã'), TextCellValue('PTBH'),
];

List<CellValue?> _dataRow(int idx, DateTime date, String docNum, int? inc, int? adjInc,
    int? dec, int? adjDec, int? endAmt, String seasonal, int? period, String cust, String branch, String sales) => [
  IntCellValue(idx), DateCellValue(year: date.year, month: date.month, day: date.day),
  TextCellValue(docNum), TextCellValue('Test'), TextCellValue('131'),
  inc != null ? IntCellValue(inc) : null, dec != null ? IntCellValue(dec) : null,
  adjInc != null ? IntCellValue(adjInc) : null, adjDec != null ? IntCellValue(adjDec) : null,
  endAmt != null ? IntCellValue(endAmt) : null,
  TextCellValue(seasonal), period != null ? IntCellValue(period) : null,
  TextCellValue(cust), TextCellValue('Test Customer'), TextCellValue(branch),
  TextCellValue(''), TextCellValue(sales),
];
