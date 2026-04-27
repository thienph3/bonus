import 'package:drift/drift.dart';
import 'package:excel/excel.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../../core/utils/parse_utils.dart';

/// Handles importing main_data sheet with dynamic header detection
class ImportMainData {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

  Future<int> import(Excel excel, void Function(String) onLog) async {
    final sheet = excel.tables['Data'];
    if (sheet == null) {
      onLog('⚠️ Sheet "Data" không tồn tại.');
      return 0;
    }

    onLog('📥 Importing main_data...');

    // Dynamic header detection
    int dataStartRow = -1;
    for (int i = 0; i < 30 && i < sheet.maxRows; i++) {
      final row = sheet.row(i);
      final nonEmpty = row
          .where((c) => c?.value != null && c!.value.toString().trim().isNotEmpty)
          .length;
      if (nonEmpty >= 17) {
        dataStartRow = i + 1;
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
      final allEmpty = row.every(
          (c) => c?.value == null || c!.value.toString().trim().isEmpty);
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
