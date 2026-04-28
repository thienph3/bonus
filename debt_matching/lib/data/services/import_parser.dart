import 'dart:io';
import 'package:excel/excel.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/parse_utils.dart';

/// Runs in isolate. Input: (String filePath, String runId)
/// Reads file, parses Excel, returns only primitives.
Map<String, List<Map<String, Object?>>> parseExcelFile((String, String) args) {
  final (filePath, runId) = args;
  const uuid = Uuid();
  final bytes = File(filePath).readAsBytesSync();
  final excel = Excel.decodeBytes(bytes);
  return {
    'holidays': _parseHolidays(excel, uuid, runId),
    'levels': _parseLevels(excel, uuid, runId),
    'mainData': _parseMainData(excel, uuid, runId),
  };
}

Object? _val(Data? cell) {
  if (cell == null || cell.value == null) return null;
  final v = cell.value;
  if (v is IntCellValue) return v.value;
  if (v is DoubleCellValue) return v.value;
  if (v is TextCellValue) return v.value.toString();
  if (v is DateCellValue) return DateTime(v.year, v.month, v.day).millisecondsSinceEpoch;
  if (v is DateTimeCellValue) {
    return DateTime(v.year, v.month, v.day, v.hour, v.minute, v.second).millisecondsSinceEpoch;
  }
  if (v is BoolCellValue) return v.value ? 1 : 0;
  if (v is FormulaCellValue) return v.formula.toString();
  return v.toString();
}

List<Map<String, Object?>> _parseHolidays(Excel excel, Uuid uuid, String runId) {
  final sheet = excel.tables['holiday_config'];
  if (sheet == null) return [];
  final rows = <Map<String, Object?>>[];
  for (int i = 1; i < sheet.maxRows; i++) {
    final row = sheet.row(i);
    if (row.isEmpty) continue;
    final date = parseDate(_val(row[0]));
    if (date == null) continue;
    rows.add({'id': uuid.v4(), 'runId': runId, 'date': date.millisecondsSinceEpoch});
  }
  return rows;
}

List<Map<String, Object?>> _parseLevels(Excel excel, Uuid uuid, String runId) {
  final sheet = excel.tables['level_config'];
  if (sheet == null) return [];
  final rows = <Map<String, Object?>>[];
  for (int i = 1; i < sheet.maxRows; i++) {
    final row = sheet.row(i);
    if (row.isEmpty || _val(row[0]) == null) continue;
    try {
      rows.add({
        'id': uuid.v4(), 'runId': runId,
        'seasonalCode': _val(row[0])?.toString() ?? '',
        'salesMethod': _val(row[1])?.toString() ?? '',
        'paymentPeriod': parseNumber(_val(row[2])) ?? 0,
        'paymentPeriod1': parseNumber(_val(row[3])) ?? 0,
        'paymentPeriod2': parseNumber(_val(row[4])) ?? 0,
        'paymentPeriod3': parseNumber(_val(row[5])) ?? 0,
        'pdd1': parseDate(_val(row[6]))?.millisecondsSinceEpoch,
        'pdd2': parseDate(_val(row[7]))?.millisecondsSinceEpoch,
        'pdd3': parseDate(_val(row[8]))?.millisecondsSinceEpoch,
      });
    } catch (_) {}
  }
  return rows;
}

List<Map<String, Object?>> _parseMainData(Excel excel, Uuid uuid, String runId) {
  final sheet = excel.tables['Data'];
  if (sheet == null) return [];
  int startRow = -1;
  for (int i = 0; i < 30 && i < sheet.maxRows; i++) {
    final row = sheet.row(i);
    if (row.where((c) => _val(c) != null).length >= 17) { startRow = i + 1; break; }
  }
  if (startRow == -1) return [];

  final rows = <Map<String, Object?>>[];
  for (int i = startRow; i < sheet.maxRows; i++) {
    final row = sheet.row(i);
    if (row.every((c) => _val(c) == null)) break;
    try {
      rows.add({
        'id': uuid.v4(), 'runId': runId,
        'idx': parseNumber(_val(row[0])),
        'docDate': parseDate(_val(row[1]))?.millisecondsSinceEpoch,
        'docNum': _val(row[2])?.toString(),
        'desc': _val(row[3])?.toString(),
        'corrAcc': _val(row[4])?.toString(),
        'inc': parseNumber(_val(row[5])),
        'dec': parseNumber(_val(row[6])),
        'adjInc': parseNumber(_val(row[7])),
        'adjDec': parseNumber(_val(row[8])),
        'endAmt': parseNumber(_val(row[9])),
        'seasonal': _val(row[10])?.toString() ?? '',
        'payPeriod': parseNumber(_val(row[11])),
        'custCode': _val(row[12])?.toString() ?? '',
        'custName': _val(row[13])?.toString(),
        'branch': _val(row[14])?.toString() ?? '',
        'code': _val(row[15])?.toString(),
        'salesMethod': _val(row[16])?.toString() ?? '',
      });
    } catch (_) {}
  }
  return rows;
}
