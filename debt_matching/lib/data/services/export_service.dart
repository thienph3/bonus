import 'dart:io';
import 'dart:isolate';
import '../database/app_database.dart';
import 'export_builder.dart';

class ExportService {
  final AppDatabase _db = AppDatabase.instance;

  Future<void> exportToExcel(String runId, String filePath, void Function(String) onLog,
      {Map<String, double>? bonusRates}) async {
    onLog('📤 Đang lấy dữ liệu...');
    final results = await (_db.select(_db.results)..where((t) => t.runId.equals(runId))).get();
    final mainDatas = await (_db.select(_db.mainDatas)..where((t) => t.runId.equals(runId))).get();
    final matchings = await (_db.select(_db.matchingDetails)..where((t) => t.runId.equals(runId))).get();
    final dataMap = {for (final d in mainDatas) d.id: d};

    results.sort((a, b) => a.originalIdx.compareTo(b.originalIdx));

    final serialResults = results.map((r) {
      final d = dataMap[r.mainDataId];
      return {
        'idx': d?.idx, 'document_date': d?.documentDate, 'document_number': d?.documentNumber,
        'description': d?.description, 'corresponding_account': d?.correspondingAccount,
        'increase': d?.increase, 'decrease': d?.decrease,
        'adjust_increase': d?.adjustIncrease, 'adjust_decrease': d?.adjustDecrease,
        'end_amount': d?.endAmount, 'seasonal_code': d?.seasonalCode ?? '',
        'payment_period': d?.paymentPeriod, 'customer_code': d?.customerCode ?? '',
        'customer_name': d?.customerName, 'branch': d?.branch ?? '',
        'code': d?.code, 'sales_method': d?.salesMethod ?? '',
        'type': r.type, 'payment_due_date': r.paymentDueDate,
        'bonus_decrease': r.bonusDecrease, 'non_bonus_decrease': r.nonBonusDecrease,
        'bonus_increase': r.bonusIncrease, 'non_bonus_increase': r.nonBonusIncrease,
        'payment_due_date_1': r.paymentDueDate1, 'payment_due_date_2': r.paymentDueDate2,
        'payment_due_date_3': r.paymentDueDate3,
        'bonus_1': r.bonus1, 'bonus_2': r.bonus2, 'bonus_3': r.bonus3,
        'calculate_status': r.calculateStatus, 'calculate_message': r.calculateMessage,
      };
    }).toList();

    final serialMatchings = matchings.map((m) => {
      'increase_doc': m.increaseDocNumber, 'decrease_doc': m.decreaseDocNumber,
      'decrease_date': m.decreaseDate, 'amount': m.amountMatched, 'bonus_tier': m.bonusTier,
    }).toList();

    onLog('📤 Tạo Excel (background)...');
    final bytes = await Isolate.run(() => buildExcelBytes({
      'results': serialResults, 'matchings': serialMatchings, 'bonusRates': bonusRates,
    }));

    onLog('📤 Lưu file...');
    if (bytes != null && bytes.isNotEmpty) await File(filePath).writeAsBytes(bytes);
    onLog('✅ Đã xuất ${results.length} dòng + ${matchings.length} chi tiết đối trừ.');
  }

  /// Delete a run and all its data
  Future<void> deleteRun(String runId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.matchingDetails)..where((t) => t.runId.equals(runId))).go();
      await (_db.delete(_db.results)..where((t) => t.runId.equals(runId))).go();
      await (_db.delete(_db.mainDatas)..where((t) => t.runId.equals(runId))).go();
      await (_db.delete(_db.levelConfigs)..where((t) => t.runId.equals(runId))).go();
      await (_db.delete(_db.holidayConfigs)..where((t) => t.runId.equals(runId))).go();
      await (_db.delete(_db.runHistories)..where((t) => t.id.equals(runId))).go();
    });
  }
}
