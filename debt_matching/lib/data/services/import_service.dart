import 'dart:io';
import 'package:drift/drift.dart';
import 'package:excel/excel.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../../core/utils/parse_utils.dart';
import 'import_main_data.dart';

class ImportService {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();
  final _mainDataImporter = ImportMainData();

  Future<Map<String, int>> importFromExcel(
    String filePath,
    void Function(String) onLog,
  ) async {
    final bytes = await File(filePath).readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    onLog('🗑️ Xóa dữ liệu cũ...');
    await _db.delete(_db.results).go();
    await _db.delete(_db.mainDatas).go();
    await _db.delete(_db.levelConfigs).go();
    await _db.delete(_db.holidayConfigs).go();

    final holidayCount = await _importHolidayConfig(excel, onLog);
    final levelCount = await _importLevelConfig(excel, onLog);
    final mainDataCount = await _mainDataImporter.import(excel, onLog);

    return {'holidays': holidayCount, 'levels': levelCount, 'records': mainDataCount};
  }

  Future<int> _importHolidayConfig(Excel excel, void Function(String) onLog) async {
    final sheet = excel.tables['holiday_config'];
    if (sheet == null) {
      onLog('⚠️ Sheet "holiday_config" không tồn tại.');
      return 0;
    }
    onLog('📥 Importing holiday_config...');
    final batch = <HolidayConfigsCompanion>[];
    for (int i = 1; i < sheet.maxRows; i++) {
      final row = sheet.row(i);
      if (row.isEmpty || row[0]?.value == null) continue;
      final date = parseDate(row[0]?.value);
      if (date == null) continue;
      batch.add(HolidayConfigsCompanion.insert(id: _uuid.v4(), date: date));
    }
    if (batch.isNotEmpty) {
      await _db.batch((b) => b.insertAll(_db.holidayConfigs, batch));
    }
    onLog('✅ Đã nhập ${batch.length} ngày lễ.');
    return batch.length;
  }

  Future<int> _importLevelConfig(Excel excel, void Function(String) onLog) async {
    final sheet = excel.tables['level_config'];
    if (sheet == null) {
      onLog('⚠️ Sheet "level_config" không tồn tại.');
      return 0;
    }
    onLog('📥 Importing level_config...');
    final batch = <LevelConfigsCompanion>[];
    for (int i = 1; i < sheet.maxRows; i++) {
      final row = sheet.row(i);
      if (row.isEmpty || row[0]?.value == null) continue;
      try {
        batch.add(LevelConfigsCompanion.insert(
          id: _uuid.v4(),
          seasonalCode: row[0]?.value?.toString() ?? '',
          salesMethod: row[1]?.value?.toString() ?? '',
          paymentPeriod: parseNumber(row[2]?.value) ?? 0,
          paymentPeriod1: parseNumber(row[3]?.value) ?? 0,
          paymentPeriod2: parseNumber(row[4]?.value) ?? 0,
          paymentPeriod3: parseNumber(row[5]?.value) ?? 0,
          paymentDueDate1: Value(parseDate(row[6]?.value)),
          paymentDueDate2: Value(parseDate(row[7]?.value)),
          paymentDueDate3: Value(parseDate(row[8]?.value)),
        ));
      } catch (e) {
        onLog('⚠️ Row ${i + 1}: $e, skipping.');
      }
    }
    if (batch.isNotEmpty) {
      await _db.batch((b) => b.insertAll(_db.levelConfigs, batch));
    }
    onLog('✅ Đã nhập ${batch.length} cấp độ.');
    return batch.length;
  }
}
