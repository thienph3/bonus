import 'dart:io';
import 'package:drift/drift.dart';
import 'package:excel/excel.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../../core/utils/parse_utils.dart';

class ImportService {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

  Future<Map<String, dynamic>> importFromExcel(String filePath, void Function(String) onLog) async {
    final runId = _uuid.v4();
    await _db.into(_db.runHistories).insert(RunHistoriesCompanion.insert(
      id: runId, timestamp: DateTime.now(), filePath: Value(filePath), status: const Value('importing'),
    ));

    onLog('📥 Đọc file...');
    final bytes = await File(filePath).readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    final holidayCount = await _importHolidays(excel, runId, onLog);
    final levelCount = await _importLevels(excel, runId, onLog);
    final recordCount = await _importMainData(excel, runId, onLog);

    await (_db.update(_db.runHistories)..where((t) => t.id.equals(runId))).write(
      RunHistoriesCompanion(recordCount: Value(recordCount), levelCount: Value(levelCount),
        holidayCount: Value(holidayCount), status: const Value('imported')));

    onLog('✅ Hoàn tất import.');
    return {'runId': runId, 'holidays': holidayCount, 'levels': levelCount, 'records': recordCount};
  }

  Future<int> _importHolidays(Excel excel, String runId, void Function(String) onLog) async {
    final sheet = excel.tables['holiday_config'];
    if (sheet == null) { onLog('⚠️ Sheet "holiday_config" không tồn tại.'); return 0; }
    onLog('📥 Importing holiday_config...');
    final batch = <HolidayConfigsCompanion>[];
    for (int i = 1; i < sheet.maxRows; i++) {
      final row = sheet.row(i);
      if (row.isEmpty || row[0]?.value == null) continue;
      final date = parseDate(row[0]?.value);
      if (date == null) continue;
      batch.add(HolidayConfigsCompanion.insert(id: _uuid.v4(), date: date, runId: Value(runId)));
    }
    if (batch.isNotEmpty) await _db.batch((b) => b.insertAll(_db.holidayConfigs, batch));
    onLog('✅ Đã nhập ${batch.length} ngày lễ.');
    return batch.length;
  }

  Future<int> _importLevels(Excel excel, String runId, void Function(String) onLog) async {
    final sheet = excel.tables['level_config'];
    if (sheet == null) { onLog('⚠️ Sheet "level_config" không tồn tại.'); return 0; }
    onLog('📥 Importing level_config...');
    final batch = <LevelConfigsCompanion>[];
    for (int i = 1; i < sheet.maxRows; i++) {
      final row = sheet.row(i);
      if (row.isEmpty || row[0]?.value == null) continue;
      try {
        batch.add(LevelConfigsCompanion.insert(
          id: _uuid.v4(), runId: Value(runId),
          seasonalCode: row[0]?.value?.toString() ?? '', salesMethod: row[1]?.value?.toString() ?? '',
          paymentPeriod: parseNumber(row[2]?.value) ?? 0, paymentPeriod1: parseNumber(row[3]?.value) ?? 0,
          paymentPeriod2: parseNumber(row[4]?.value) ?? 0, paymentPeriod3: parseNumber(row[5]?.value) ?? 0,
          paymentDueDate1: Value(parseDate(row[6]?.value)),
          paymentDueDate2: Value(parseDate(row[7]?.value)),
          paymentDueDate3: Value(parseDate(row[8]?.value)),
        ));
      } catch (e) { onLog('⚠️ Row ${i + 1}: $e'); }
    }
    if (batch.isNotEmpty) await _db.batch((b) => b.insertAll(_db.levelConfigs, batch));
    onLog('✅ Đã nhập ${batch.length} cấp độ.');
    return batch.length;
  }

  Future<int> _importMainData(Excel excel, String runId, void Function(String) onLog) async {
    final sheet = excel.tables['Data'];
    if (sheet == null) { onLog('⚠️ Sheet "Data" không tồn tại.'); return 0; }
    onLog('📥 Importing main_data...');
    int startRow = -1;
    for (int i = 0; i < 30 && i < sheet.maxRows; i++) {
      final row = sheet.row(i);
      if (row.where((c) => c?.value != null && c!.value.toString().trim().isNotEmpty).length >= 17) {
        startRow = i + 1; break;
      }
    }
    if (startRow == -1) { onLog('❌ Header not found.'); return 0; }

    int count = 0;
    var batch = <MainDatasCompanion>[];
    for (int i = startRow; i < sheet.maxRows; i++) {
      final row = sheet.row(i);
      if (row.every((c) => c?.value == null || c!.value.toString().trim().isEmpty)) break;
      try {
        batch.add(MainDatasCompanion.insert(
          id: _uuid.v4(), runId: Value(runId),
          idx: Value(parseNumber(row[0]?.value)), documentDate: Value(parseDate(row[1]?.value)),
          documentNumber: Value(row[2]?.value?.toString()), description: Value(row[3]?.value?.toString()),
          correspondingAccount: Value(row[4]?.value?.toString()),
          increase: Value(parseNumber(row[5]?.value)), decrease: Value(parseNumber(row[6]?.value)),
          adjustIncrease: Value(parseNumber(row[7]?.value)), adjustDecrease: Value(parseNumber(row[8]?.value)),
          endAmount: Value(parseNumber(row[9]?.value)), seasonalCode: row[10]?.value?.toString() ?? '',
          paymentPeriod: Value(parseNumber(row[11]?.value)), customerCode: row[12]?.value?.toString() ?? '',
          customerName: Value(row[13]?.value?.toString()), branch: row[14]?.value?.toString() ?? '',
          code: Value(row[15]?.value?.toString()), salesMethod: row[16]?.value?.toString() ?? '',
        ));
        if (batch.length >= 100) {
          await _db.batch((b) => b.insertAll(_db.mainDatas, batch));
          count += batch.length; batch = [];
          onLog('✅ Đã nhập $count dòng...');
        }
      } catch (e) { onLog('⚠️ Row ${i + 1}: $e'); }
    }
    if (batch.isNotEmpty) { await _db.batch((b) => b.insertAll(_db.mainDatas, batch)); count += batch.length; }
    onLog('✅ Đã nhập $count dòng dữ liệu.');
    return count;
  }
}
