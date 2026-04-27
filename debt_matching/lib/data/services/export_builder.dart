import 'dart:typed_data';
import 'package:excel/excel.dart';

/// Pure function: build Excel bytes from raw data. Runs in isolate.
Uint8List? buildExcelBytes(Map<String, dynamic> input) {
  final results = input['results'] as List<Map<String, dynamic>>;
  final matchings = input['matchings'] as List<Map<String, dynamic>>;

  final excel = Excel.createExcel();
  _writeResults(excel, results);
  _writeMatchings(excel, matchings);
  if (excel.tables.containsKey('Sheet1')) excel.delete('Sheet1');
  return Uint8List.fromList(excel.save() ?? []);
}

void _writeResults(Excel excel, List<Map<String, dynamic>> results) {
  final sheet = excel['Result'];
  final headers = [
    'idx', 'document_date', 'document_number', 'description',
    'corresponding_account', 'increase', 'decrease', 'adjust_increase',
    'adjust_decrease', 'end_amount', 'seasonal_code', 'payment_period',
    'customer_code', 'customer_name', 'branch', 'code', 'sales_method',
    'type', 'payment_due_date', 'bonus_decrease', 'non_bonus_decrease',
    'bonus_increase', 'non_bonus_increase', 'payment_due_date_1',
    'payment_due_date_2', 'payment_due_date_3', 'bonus_1', 'bonus_2',
    'bonus_3', 'calculate_status', 'calculate_message',
  ];
  for (int c = 0; c < headers.length; c++) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0)).value = TextCellValue(headers[c]);
  }
  for (int i = 0; i < results.length; i++) {
    final r = results[i];
    int c = 0;
    for (final key in headers) {
      final val = r[key];
      CellValue? cellVal;
      if (val == null) {
        cellVal = null;
      } else if (val is int) {
        cellVal = IntCellValue(val);
      } else if (val is DateTime) {
        cellVal = DateCellValue(year: val.year, month: val.month, day: val.day);
      } else {
        cellVal = TextCellValue(val.toString());
      }
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: c++, rowIndex: i + 1)).value = cellVal;
    }
  }
}

void _writeMatchings(Excel excel, List<Map<String, dynamic>> matchings) {
  final sheet = excel['Matching Detail'];
  final headers = ['increase_doc', 'decrease_doc', 'decrease_date', 'amount', 'bonus_tier'];
  for (int c = 0; c < headers.length; c++) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0)).value = TextCellValue(headers[c]);
  }
  for (int i = 0; i < matchings.length; i++) {
    final m = matchings[i];
    int c = 0;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: c++, rowIndex: i + 1)).value = TextCellValue(m['increase_doc'] ?? '');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: c++, rowIndex: i + 1)).value = TextCellValue(m['decrease_doc'] ?? '');
    final dt = m['decrease_date'] as DateTime?;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: c++, rowIndex: i + 1)).value =
        dt != null ? DateCellValue(year: dt.year, month: dt.month, day: dt.day) : null;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: c++, rowIndex: i + 1)).value = IntCellValue(m['amount'] ?? 0);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: c++, rowIndex: i + 1)).value = TextCellValue(m['bonus_tier'] ?? '');
  }
}
