import 'dart:typed_data';
import 'package:excel/excel.dart';

/// Pure function: build Excel bytes from raw data. Runs in isolate.
Uint8List? buildExcelBytes(Map<String, dynamic> input) {
  final results = input['results'] as List<Map<String, dynamic>>;
  final matchings = input['matchings'] as List<Map<String, dynamic>>;
  final bonusRates = input['bonusRates'] as Map<String, double>?;

  final excel = Excel.createExcel();
  _writeSummary(excel, results, bonusRates);
  _writeResults(excel, results);
  _writeMatchings(excel, matchings);
  if (excel.tables.containsKey('Sheet1')) excel.delete('Sheet1');
  return Uint8List.fromList(excel.save() ?? []);
}

void _writeSummary(Excel excel, List<Map<String, dynamic>> results, Map<String, double>? rates) {
  final sheet = excel['Summary'];
  final hasRates = rates != null && rates.isNotEmpty;
  final headers = ['customer_code', 'customer_name', 'records', 'bonus_1', 'bonus_2', 'bonus_3', 'total_bonus',
    if (hasRates) ...['final_bonus_1', 'final_bonus_2', 'final_bonus_3', 'final_total']];
  for (int c = 0; c < headers.length; c++) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0)).value = TextCellValue(headers[c]);
  }
  final r1 = rates?['pct_1'] ?? 0, r2 = rates?['pct_2'] ?? 0, r3 = rates?['pct_3'] ?? 0;
  // Group by customer_code
  final grouped = <String, Map<String, dynamic>>{};
  for (final r in results) {
    final code = (r['customer_code'] ?? '') as String;
    final g = grouped.putIfAbsent(code, () => {'name': r['customer_name'] ?? '', 'cnt': 0, 'b1': 0, 'b2': 0, 'b3': 0});
    g['cnt'] = (g['cnt'] as int) + 1;
    g['b1'] = (g['b1'] as int) + ((r['bonus_1'] ?? 0) as int);
    g['b2'] = (g['b2'] as int) + ((r['bonus_2'] ?? 0) as int);
    g['b3'] = (g['b3'] as int) + ((r['bonus_3'] ?? 0) as int);
  }
  final sorted = grouped.entries.toList()..sort((a, b) {
    final ta = (a.value['b1'] as int) + (a.value['b2'] as int) + (a.value['b3'] as int);
    final tb = (b.value['b1'] as int) + (b.value['b2'] as int) + (b.value['b3'] as int);
    return tb.compareTo(ta);
  });
  for (int i = 0; i < sorted.length; i++) {
    final e = sorted[i];
    final g = e.value;
    final total = (g['b1'] as int) + (g['b2'] as int) + (g['b3'] as int);
    int c = 0;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: c++, rowIndex: i + 1)).value = TextCellValue(e.key);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: c++, rowIndex: i + 1)).value = TextCellValue(g['name'] as String);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: c++, rowIndex: i + 1)).value = IntCellValue(g['cnt'] as int);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: c++, rowIndex: i + 1)).value = IntCellValue(g['b1'] as int);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: c++, rowIndex: i + 1)).value = IntCellValue(g['b2'] as int);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: c++, rowIndex: i + 1)).value = IntCellValue(g['b3'] as int);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: c++, rowIndex: i + 1)).value = IntCellValue(total);
    if (hasRates) {
      final fb1 = ((g['b1'] as int) * r1 / 100).round();
      final fb2 = ((g['b2'] as int) * r2 / 100).round();
      final fb3 = ((g['b3'] as int) * r3 / 100).round();
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: c++, rowIndex: i + 1)).value = IntCellValue(fb1);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: c++, rowIndex: i + 1)).value = IntCellValue(fb2);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: c++, rowIndex: i + 1)).value = IntCellValue(fb3);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: c++, rowIndex: i + 1)).value = IntCellValue(fb1 + fb2 + fb3);
    }
  }
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
