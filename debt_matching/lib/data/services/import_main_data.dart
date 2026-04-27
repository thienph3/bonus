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
    final dataStartRow = _findHeaderRow(sheet);
    if (dataStartRow == -1) {
      onLog('❌ Không tìm thấy header row trong sheet Data.');
      return 0;
    }

    int count = 0;
    var batch = <MainDatasCompanion>[];
    for (int i = dataStartRow; i < sheet.maxRows; i++) {
      final row = sheet.row(i);
      if (row.every((c) => c?.value == null || c!.value.toString().trim().isEmpty)) break;

      try {
        batch.add(MainDatasCompanion.insert(
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

        if (batch.length >= 100) {
          await _db.batch((b) => b.insertAll(_db.mainDatas, batch));
          count += batch.length;
          onLog('✅ Đã nhập $count dòng...');
          batch = [];
        }
      } catch (e) {
        onLog('⚠️ Row ${i + 1}: $e, skipping.');
      }
    }

    if (batch.isNotEmpty) {
      await _db.batch((b) => b.insertAll(_db.mainDatas, batch));
      count += batch.length;
    }
    onLog('✅ Đã nhập $count dòng dữ liệu.');
    return count;
  }

  int _findHeaderRow(Sheet sheet) {
    for (int i = 0; i < 30 && i < sheet.maxRows; i++) {
      final row = sheet.row(i);
      final nonEmpty = row.where((c) => c?.value != null && c!.value.toString().trim().isNotEmpty).length;
      if (nonEmpty >= 17) return i + 1;
    }
    return -1;
  }
}
