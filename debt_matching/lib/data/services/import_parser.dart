import 'dart:io';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/parse_utils.dart';

/// Runs in isolate. Input: (String filePath, String runId)
/// Returns only primitives (int, String, double, null).
Map<String, List<Map<String, Object?>>> parseExcelFile((String, String) args) {
  final (filePath, runId) = args;
  const uuid = Uuid();
  final bytes = File(filePath).readAsBytesSync();
  final decoder = SpreadsheetDecoder.decodeBytes(bytes);
  return {
    'holidays': _parseHolidays(decoder, uuid, runId),
    'levels': _parseLevels(decoder, uuid, runId),
    'mainData': _parseMainData(decoder, uuid, runId),
  };
}

List<Map<String, Object?>> _parseHolidays(SpreadsheetDecoder dec, Uuid uuid, String runId) {
  final table = dec.tables['holiday_config'];
  if (table == null) return [];
  final rows = <Map<String, Object?>>[];
  for (int i = 1; i < table.rows.length; i++) {
    final row = table.rows[i];
    if (row.isEmpty || row[0] == null) continue;
    final date = parseDate(row[0]);
    if (date == null) continue;
    rows.add({'id': uuid.v4(), 'runId': runId, 'date': date.millisecondsSinceEpoch});
  }
  return rows;
}

List<Map<String, Object?>> _parseLevels(SpreadsheetDecoder dec, Uuid uuid, String runId) {
  final table = dec.tables['level_config'];
  if (table == null) return [];
  final rows = <Map<String, Object?>>[];
  for (int i = 1; i < table.rows.length; i++) {
    final row = table.rows[i];
    if (row.isEmpty || row[0] == null) continue;
    try {
      rows.add({
        'id': uuid.v4(), 'runId': runId,
        'seasonalCode': row[0]?.toString() ?? '',
        'salesMethod': row[1]?.toString() ?? '',
        'paymentPeriod': parseNumber(row[2]) ?? 0,
        'paymentPeriod1': parseNumber(row[3]) ?? 0,
        'paymentPeriod2': parseNumber(row[4]) ?? 0,
        'paymentPeriod3': parseNumber(row[5]) ?? 0,
        'pdd1': parseDate(row.length > 6 ? row[6] : null)?.millisecondsSinceEpoch,
        'pdd2': parseDate(row.length > 7 ? row[7] : null)?.millisecondsSinceEpoch,
        'pdd3': parseDate(row.length > 8 ? row[8] : null)?.millisecondsSinceEpoch,
      });
    } catch (_) {}
  }
  return rows;
}

List<Map<String, Object?>> _parseMainData(SpreadsheetDecoder dec, Uuid uuid, String runId) {
  final table = dec.tables['Data'];
  if (table == null) return [];
  int startRow = -1;
  for (int i = 0; i < 30 && i < table.rows.length; i++) {
    final nonEmpty = table.rows[i].where((c) => c != null && c.toString().trim().isNotEmpty).length;
    if (nonEmpty >= 17) { startRow = i + 1; break; }
  }
  if (startRow == -1) return [];

  final rows = <Map<String, Object?>>[];
  for (int i = startRow; i < table.rows.length; i++) {
    final row = table.rows[i];
    if (row.every((c) => c == null || c.toString().trim().isEmpty)) break;
    try {
      rows.add({
        'id': uuid.v4(), 'runId': runId,
        'idx': parseNumber(row[0]),
        'docDate': parseDate(row[1])?.millisecondsSinceEpoch,
        'docNum': row[2]?.toString(),
        'desc': row[3]?.toString(),
        'corrAcc': row[4]?.toString(),
        'inc': parseNumber(row[5]),
        'dec': parseNumber(row[6]),
        'adjInc': parseNumber(row[7]),
        'adjDec': parseNumber(row[8]),
        'endAmt': parseNumber(row[9]),
        'seasonal': row[10]?.toString() ?? '',
        'payPeriod': parseNumber(row[11]),
        'custCode': row[12]?.toString() ?? '',
        'custName': row[13]?.toString(),
        'branch': row[14]?.toString() ?? '',
        'code': row[15]?.toString(),
        'salesMethod': row[16]?.toString() ?? '',
      });
    } catch (_) {}
  }
  return rows;
}
