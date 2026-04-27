import 'dart:io';
import 'package:drift/drift.dart';
import 'package:excel/excel.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../../core/utils/parse_utils.dart';

class ImportService {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

  Future<Map<String, int>> importFromExcel(
    String filePath,
    void Function(String) onLog,
  ) async {
    final bytes = File(filePath).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    onLog('🗑️ Xóa dữ liệu cũ...');
    await _db.delete(_db.results).go();
    await _db.delete(_db.mainDatas).go();
    await _db.delete(_db.levelConfigs).go();
    await _db.delete(_db.holidayConfigs).go();

    final holidayCount = await _importHolidayConfig(excel, onLog);
    final levelCount = await _importLevelConfig(excel, onLog);
    final mainDataCount = await _importMainData(excel, onLog);

    return {
      'holidays': holidayCount,
      'levels': levelCount,
      'records': mainDataCount,
    };
  }

  Future<int> _importHolidayConfig(Excel excel, void Function(String) onLog) async {
    final sheet = excel.tables['holiday_config'];
    if (sheet == null) {
      onLog('⚠️ Sheet "holiday_config" không tồn tại.');
      return 0;
    }

    onLog('📥 Importing holiday_config...');
    int count = 0;
    for (int i = 1; i < sheet.maxRows; i++) {
      final row = sheet.row(i);
      if (row.isEmpty || row[0]?.value == null) continue;

      final date = parseDate(row[0]?.value);
      if (date == null) {
        onLog('⚠️ Row ${i + 1}: invalid date, skipping.');
        continue;
      }

      await _db.into(_db.holidayConfigs).insert(HolidayConfigsCompanion.insert(
        id: _uuid.v4(),
        date: date,
      ));
      count++;
    }
    onLog('✅ Đã nhập $count ngày lễ.');
    return count;
  }

  Future<int> _importLevelConfig(Excel excel, void Function(String) onLog) async {
    final sheet = excel.tables['level_config'];
    if (sheet == null) {
      onLog('⚠️ Sheet "level_config" không tồn tại.');
      return 0;
    }

    onLog('📥 Importing level_config...');
    int count = 0;
    for (int i = 1; i < sheet.maxRows; i++) {
      final row = sheet.row(i);
      if (row.isEmpty || row[0]?.value == null) continue;

      try {
        await _db.into(_db.levelConfigs).insert(LevelConfigsCompanion.insert(
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
        count++;
      } catch (e) {
        onLog('⚠️ Row ${i + 1}: $e, skipping.');
      }
    }
    onLog('✅ Đã nhập $count cấp độ.');
    return count;
  }

  Future<int> _importMainData(Excel excel, void Function(String) onLog) async {
    final sheet = excel.tables['Data'];
    if (sheet == null) {
      onLog('⚠️ Sheet "Data" không tồn tại.');
      return 0;
    }

    onLog('📥 Importing main_data...');

    // Dynamic header detection: find first row with >= 17 non-empty cells
    int dataStartRow = -1;
    for (int i = 0; i < 30 && i < sheet.maxRows; i++) {
      final row = sheet.row(i);
      final nonEmpty = row.where((c) => c?.value != null && c!.value.toString().trim().isNotEmpty).length;
      if (nonEmpty >= 17) {
        dataStartRow = i + 1; // Data starts after header
        break;
      }
    }

    if (dataStartRow == -1) {
      onLog('❌ Không tìm thấy header row trong sheet Data.');
      return 0;
    }

    int count = 0;
    for (int i = dataStartRow; i < sheet.maxRows; i++) {
      final row = sheet.row(i);

      // Stop at empty row
      final allEmpty = row.every((c) => c?.value == null || c!.value.toString().trim().isEmpty);
      if (allEmpty) break;

      try {
        await _db.into(_db.mainDatas).insert(MainDatasCompanion.insert(
          id: _uuid.v4(),
          idx: Value(parseNumber(row[0]?.value)),
          documentDate: Value(parseDate(row[1]?.value)),
          documentNumber: Value(row[2]?.value?.toString()),
          description: Value(row[3]?.value?.toString()),
          correspondingAccount: Value(row[4]?.value?.toString()),
          increase: Value(parseNumber(row[5]?.value)),
          decrease: Value(parseNumber(row[6]?.value)),
          adjustIncrease: Value(parseNumber(row[7]?.value)),
          adjustDecrease: Value(parseNumber(row[8]?.value)),
          endAmount: Value(parseNumber(row[9]?.value)),
          seasonalCode: row[10]?.value?.toString() ?? '',
          paymentPeriod: Value(parseNumber(row[11]?.value)),
          customerCode: row[12]?.value?.toString() ?? '',
          customerName: Value(row[13]?.value?.toString()),
          branch: row[14]?.value?.toString() ?? '',
          code: Value(row[15]?.value?.toString()),
          salesMethod: row[16]?.value?.toString() ?? '',
        ));
        count++;
        if (count % 100 == 0) onLog('✅ Đã nhập $count dòng...');
      } catch (e) {
        onLog('⚠️ Row ${i + 1}: $e, skipping.');
      }
    }
    onLog('✅ Đã nhập $count dòng dữ liệu.');
    return count;
  }
}
