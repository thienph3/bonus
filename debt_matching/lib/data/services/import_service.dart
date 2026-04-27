import 'dart:io';
import 'dart:isolate';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import 'import_parser.dart';

DateTime? _fromMs(int? ms) => ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;

class ImportService {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

  /// Returns the runId of the new import.
  Future<Map<String, dynamic>> importFromExcel(String filePath, void Function(String) onLog) async {
    final runId = _uuid.v4();

    // Create run history first
    await _db.into(_db.runHistories).insert(RunHistoriesCompanion.insert(
      id: runId, timestamp: DateTime.now(), filePath: Value(filePath), status: const Value('importing'),
    ));

    onLog('📥 Đọc file...');
    final bytes = await File(filePath).readAsBytes();

    onLog('📥 Parse Excel (background)...');
    final parsed = await Isolate.run(() => parseExcelBytes({'bytes': bytes, 'runId': runId}));

    final holidays = parsed['holidays'] as List;
    final levels = parsed['levels'] as List;
    final mainData = parsed['mainData'] as List;

    onLog('📥 Lưu ${holidays.length} ngày lễ...');
    if (holidays.isNotEmpty) {
      await _db.batch((b) => b.insertAll(_db.holidayConfigs, holidays.map((h) =>
        HolidayConfigsCompanion.insert(id: h['id'], date: DateTime.fromMillisecondsSinceEpoch(h['date']),
          runId: Value(h['runId']))).toList()));
    }

    onLog('📥 Lưu ${levels.length} cấp độ...');
    if (levels.isNotEmpty) {
      await _db.batch((b) => b.insertAll(_db.levelConfigs, levels.map((l) =>
        LevelConfigsCompanion.insert(
          id: l['id'], runId: Value(l['runId']),
          seasonalCode: l['seasonalCode'], salesMethod: l['salesMethod'],
          paymentPeriod: l['paymentPeriod'], paymentPeriod1: l['paymentPeriod1'],
          paymentPeriod2: l['paymentPeriod2'], paymentPeriod3: l['paymentPeriod3'],
          paymentDueDate1: Value(_fromMs(l['paymentDueDate1'])),
          paymentDueDate2: Value(_fromMs(l['paymentDueDate2'])),
          paymentDueDate3: Value(_fromMs(l['paymentDueDate3'])),
        )).toList()));
    }

    onLog('📥 Lưu ${mainData.length} dòng dữ liệu...');
    final mdList = mainData.map((m) => MainDatasCompanion.insert(
      id: m['id'], runId: Value(m['runId']),
      idx: Value(m['idx']), documentDate: Value(_fromMs(m['documentDate'])),
      documentNumber: Value(m['documentNumber']), description: Value(m['description']),
      correspondingAccount: Value(m['correspondingAccount']),
      increase: Value(m['increase']), decrease: Value(m['decrease']),
      adjustIncrease: Value(m['adjustIncrease']), adjustDecrease: Value(m['adjustDecrease']),
      endAmount: Value(m['endAmount']), seasonalCode: m['seasonalCode'],
      paymentPeriod: Value(m['paymentPeriod']), customerCode: m['customerCode'],
      customerName: Value(m['customerName']), branch: m['branch'],
      code: Value(m['code']), salesMethod: m['salesMethod'],
    )).toList();

    for (int i = 0; i < mdList.length; i += 100) {
      await _db.batch((b) => b.insertAll(_db.mainDatas, mdList.sublist(i, (i + 100).clamp(0, mdList.length))));
      onLog('✅ Đã nhập ${(i + 100).clamp(0, mdList.length)} dòng...');
    }

    await (_db.update(_db.runHistories)..where((t) => t.id.equals(runId))).write(
      RunHistoriesCompanion(recordCount: Value(mainData.length), levelCount: Value(levels.length),
        holidayCount: Value(holidays.length), status: const Value('imported')));

    onLog('✅ Hoàn tất import.');
    return {'runId': runId, 'holidays': holidays.length, 'levels': levels.length, 'records': mainData.length};
  }
}
