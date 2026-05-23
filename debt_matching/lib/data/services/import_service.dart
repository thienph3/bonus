import 'dart:isolate';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import 'import_parser.dart';

DateTime? _ms(Object? v) => v is int ? DateTime.fromMillisecondsSinceEpoch(v) : null;

class ImportService {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

  Future<Map<String, dynamic>> importFromExcel(String filePath, void Function(String) onLog) async {
    final runId = _uuid.v4();
    await _db.into(_db.runHistories).insert(RunHistoriesCompanion.insert(
      id: runId, timestamp: DateTime.now(), filePath: Value(filePath), status: const Value('importing'),
    ));

    onLog('📥 Parse Excel (background)...');
    final parsed = AppDatabase.testMode
        ? parseExcelFile((filePath, runId))
        : await Isolate.run(() => parseExcelFile((filePath, runId)));

    final holidays = parsed['holidays']!;
    final levels = parsed['levels']!;
    final mainData = parsed['mainData']!;
    final meta = parsed['meta']!;
    final skippedLevels = (meta.isNotEmpty ? meta[0]['skippedLevels'] : 0) as int? ?? 0;
    final skippedMainData = (meta.isNotEmpty ? meta[0]['skippedMainData'] : 0) as int? ?? 0;
    if (skippedLevels > 0) onLog('⚠️ $skippedLevels dòng level_config bị bỏ qua (parse lỗi)');
    if (skippedMainData > 0) onLog('⚠️ $skippedMainData dòng Data bị bỏ qua (parse lỗi)');

    onLog('📥 Lưu ${holidays.length} ngày lễ...');
    if (holidays.isNotEmpty) {
      await _db.batch((b) => b.insertAll(_db.holidayConfigs, holidays.map((h) =>
        HolidayConfigsCompanion.insert(id: h['id'] as String, runId: Value(h['runId'] as String?),
          date: DateTime.fromMillisecondsSinceEpoch(h['date'] as int))).toList()));
    }

    onLog('📥 Lưu ${levels.length} cấp độ...');
    if (levels.isNotEmpty) {
      await _db.batch((b) => b.insertAll(_db.levelConfigs, levels.map((l) =>
        LevelConfigsCompanion.insert(
          id: l['id'] as String, runId: Value(l['runId'] as String?),
          seasonalCode: l['seasonalCode'] as String, salesMethod: l['salesMethod'] as String,
          paymentPeriod: l['paymentPeriod'] as int, paymentPeriod1: l['paymentPeriod1'] as int,
          paymentPeriod2: l['paymentPeriod2'] as int, paymentPeriod3: l['paymentPeriod3'] as int,
          paymentDueDate1: Value(_ms(l['pdd1'])), paymentDueDate2: Value(_ms(l['pdd2'])),
          paymentDueDate3: Value(_ms(l['pdd3'])),
        )).toList()));
    }

    onLog('📥 Lưu ${mainData.length} dòng...');
    final mdList = mainData.map((m) => MainDatasCompanion.insert(
      id: m['id'] as String, runId: Value(m['runId'] as String?),
      idx: Value(m['idx'] as int?), documentDate: Value(_ms(m['docDate'])),
      documentNumber: Value(m['docNum'] as String?), description: Value(m['desc'] as String?),
      correspondingAccount: Value(m['corrAcc'] as String?),
      increase: Value(m['inc'] as int?), decrease: Value(m['dec'] as int?),
      adjustIncrease: Value(m['adjInc'] as int?), adjustDecrease: Value(m['adjDec'] as int?),
      endAmount: Value(m['endAmt'] as int?), seasonalCode: m['seasonal'] as String,
      paymentPeriod: Value(m['payPeriod'] as int?), customerCode: m['custCode'] as String,
      customerName: Value(m['custName'] as String?), branch: m['branch'] as String,
      code: Value(m['code'] as String?), salesMethod: m['salesMethod'] as String,
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
