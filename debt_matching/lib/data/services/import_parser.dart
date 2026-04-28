import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/parse_utils.dart';

/// Runs in isolate. Input: (Uint8List bytes, String runId)
/// All CellValues are converted to primitives before returning.
Map<String, List<Map<String, Object?>>> parseExcel((Uint8List, String) args) {
  final (bytes, runId) = args;
  const uuid = Uuid();
  final excel = Excel.decodeBytes(bytes);
  return {
    'holidays': _parseHolidays(excel, uuid, runId),
    'levels': _parseLevels(excel, uuid, runId),
    'mainData': _parseMainData(excel, uuid, runId),
  };
}

Object? _cellVal(Data? cell) {
  if (cell == null || cell.value == null) return null;
  final v = cell.value;
  if (v is IntCellValue) return v.value;
  if (v is DoubleCellValue) return v.value;
  if (v is TextCellValue) return v.value.toString();
  if (v is DateCellValue) {
    return DateTime(v.year, v.month, v.day).millisecondsSinceEpoch;
  }
  if (v is DateTimeCellValue) {
    return DateTime(v.year, v.month, v.day, v.hour, v.minute, v.second)
        .millisecondsSinceEpoch;
  }
  if (v is TimeCellValue) return null;
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
    final raw = _cellVal(row[0]);
    final date = parseDate(raw);
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
    if (row.isEmpty || _cellVal(row[0]) == null) continue;
    try {
      rows.add({
        'id': uuid.v4(), 'runId': runId,
        'seasonalCode': _cellVal(row[0])?.toString() ?? '',
        'salesMethod': _cellVal(row[1])?.toString() ?? '',
        'paymentPeriod': parseNumber(_cellVal(row[2])) ?? 0,
        'paymentPeriod1': parseNumber(_cellVal(row[3])) ?? 0,
        'paymentPeriod2': parseNumber(_cellVal(row[4])) ?? 0,
        'paymentPeriod3': parseNumber(_cellVal(row[5])) ?? 0,
        'pdd1': parseDate(_cellVal(row[6]))?.millisecondsSinceEpoch,
        'pdd2': parseDate(_cellVal(row[7]))?.millisecondsSinceEpoch,
        'pdd3': parseDate(_cellVal(row[8]))?.millisecondsSinceEpoch,
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
    if (row.where((c) => _cellVal(c) != null).length >= 17) { startRow = i + 1; break; }
  }
  if (startRow == -1) return [];

  final rows = <Map<String, Object?>>[];
  for (int i = startRow; i < sheet.maxRows; i++) {
    final row = sheet.row(i);
    if (row.every((c) => _cellVal(c) == null)) break;
    try {
      rows.add({
        'id': uuid.v4(), 'runId': runId,
        'idx': parseNumber(_cellVal(row[0])),
        'docDate': parseDate(_cellVal(row[1]))?.millisecondsSinceEpoch,
        'docNum': _cellVal(row[2])?.toString(),
        'desc': _cellVal(row[3])?.toString(),
        'corrAcc': _cellVal(row[4])?.toString(),
        'inc': parseNumber(_cellVal(row[5])),
        'dec': parseNumber(_cellVal(row[6])),
        'adjInc': parseNumber(_cellVal(row[7])),
        'adjDec': parseNumber(_cellVal(row[8])),
        'endAmt': parseNumber(_cellVal(row[9])),
        'seasonal': _cellVal(row[10])?.toString() ?? '',
        'payPeriod': parseNumber(_cellVal(row[11])),
        'custCode': _cellVal(row[12])?.toString() ?? '',
        'custName': _cellVal(row[13])?.toString(),
        'branch': _cellVal(row[14])?.toString() ?? '',
        'code': _cellVal(row[15])?.toString(),
        'salesMethod': _cellVal(row[16])?.toString() ?? '',
      });
    } catch (_) {}
  }
  return rows;
}
