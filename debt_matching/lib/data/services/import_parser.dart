import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/parse_utils.dart';

/// Pure function: parse Excel bytes into raw Maps. Runs in isolate.
Map<String, dynamic> parseExcelBytes(Uint8List bytes) {
  const uuid = Uuid();
  final excel = Excel.decodeBytes(bytes);

  return {
    'holidays': _parseHolidays(excel, uuid),
    'levels': _parseLevels(excel, uuid),
    'mainData': _parseMainData(excel, uuid),
  };
}

List<Map<String, dynamic>> _parseHolidays(Excel excel, Uuid uuid) {
  final sheet = excel.tables['holiday_config'];
  if (sheet == null) return [];
  final rows = <Map<String, dynamic>>[];
  for (int i = 1; i < sheet.maxRows; i++) {
    final row = sheet.row(i);
    if (row.isEmpty || row[0]?.value == null) continue;
    final date = parseDate(row[0]?.value);
    if (date == null) continue;
    rows.add({'id': uuid.v4(), 'date': date.millisecondsSinceEpoch});
  }
  return rows;
}

List<Map<String, dynamic>> _parseLevels(Excel excel, Uuid uuid) {
  final sheet = excel.tables['level_config'];
  if (sheet == null) return [];
  final rows = <Map<String, dynamic>>[];
  for (int i = 1; i < sheet.maxRows; i++) {
    final row = sheet.row(i);
    if (row.isEmpty || row[0]?.value == null) continue;
    try {
      rows.add({
        'id': uuid.v4(),
        'seasonalCode': row[0]?.value?.toString() ?? '',
        'salesMethod': row[1]?.value?.toString() ?? '',
        'paymentPeriod': parseNumber(row[2]?.value) ?? 0,
        'paymentPeriod1': parseNumber(row[3]?.value) ?? 0,
        'paymentPeriod2': parseNumber(row[4]?.value) ?? 0,
        'paymentPeriod3': parseNumber(row[5]?.value) ?? 0,
        'paymentDueDate1': parseDate(row[6]?.value)?.millisecondsSinceEpoch,
        'paymentDueDate2': parseDate(row[7]?.value)?.millisecondsSinceEpoch,
        'paymentDueDate3': parseDate(row[8]?.value)?.millisecondsSinceEpoch,
      });
    } catch (_) {}
  }
  return rows;
}

List<Map<String, dynamic>> _parseMainData(Excel excel, Uuid uuid) {
  final sheet = excel.tables['Data'];
  if (sheet == null) return [];

  int dataStartRow = -1;
  for (int i = 0; i < 30 && i < sheet.maxRows; i++) {
    final row = sheet.row(i);
    final nonEmpty = row.where((c) => c?.value != null && c!.value.toString().trim().isNotEmpty).length;
    if (nonEmpty >= 17) { dataStartRow = i + 1; break; }
  }
  if (dataStartRow == -1) return [];

  final rows = <Map<String, dynamic>>[];
  for (int i = dataStartRow; i < sheet.maxRows; i++) {
    final row = sheet.row(i);
    if (row.every((c) => c?.value == null || c!.value.toString().trim().isEmpty)) break;
    try {
      rows.add({
        'id': uuid.v4(),
        'idx': parseNumber(row[0]?.value),
        'documentDate': parseDate(row[1]?.value)?.millisecondsSinceEpoch,
        'documentNumber': row[2]?.value?.toString(),
        'description': row[3]?.value?.toString(),
        'correspondingAccount': row[4]?.value?.toString(),
        'increase': parseNumber(row[5]?.value),
        'decrease': parseNumber(row[6]?.value),
        'adjustIncrease': parseNumber(row[7]?.value),
        'adjustDecrease': parseNumber(row[8]?.value),
        'endAmount': parseNumber(row[9]?.value),
        'seasonalCode': row[10]?.value?.toString() ?? '',
        'paymentPeriod': parseNumber(row[11]?.value),
        'customerCode': row[12]?.value?.toString() ?? '',
        'customerName': row[13]?.value?.toString(),
        'branch': row[14]?.value?.toString() ?? '',
        'code': row[15]?.value?.toString(),
        'salesMethod': row[16]?.value?.toString() ?? '',
      });
    } catch (_) {}
  }
  return rows;
}
