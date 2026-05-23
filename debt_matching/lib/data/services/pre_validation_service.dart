import '../database/app_database.dart';

class ValidationReport {
  final int totalRecords;
  final int missingDocNumber;
  final int missingPaymentPeriod;
  final int missingSeasonalCode;
  final int missingSalesMethod;
  final int duplicateDocNumbers;
  final List<String> duplicateDocs;

  ValidationReport({
    required this.totalRecords,
    required this.missingDocNumber,
    required this.missingPaymentPeriod,
    required this.missingSeasonalCode,
    required this.missingSalesMethod,
    required this.duplicateDocNumbers,
    required this.duplicateDocs,
  });

  bool get hasIssues =>
      missingDocNumber > 0 || missingPaymentPeriod > 0 ||
      missingSeasonalCode > 0 || missingSalesMethod > 0 ||
      duplicateDocNumbers > 0;

  int get totalIssues =>
      missingDocNumber + missingPaymentPeriod +
      missingSeasonalCode + missingSalesMethod + duplicateDocNumbers;
}

/// Validates imported data before calculate, reports issues via onLog.
class PreValidationService {
  final AppDatabase _db = AppDatabase.instance;

  Future<ValidationReport> validate(String runId, void Function(String) onLog) async {
    onLog('🔍 Kiểm tra dữ liệu...');
    final datas = await (_db.select(_db.mainDatas)..where((t) => t.runId.equals(runId))).get();

    int missingDoc = 0, missingPeriod = 0, missingSeasonal = 0, missingSales = 0;
    final docCounts = <String, int>{};

    for (final d in datas) {
      if (d.documentNumber == null || d.documentNumber!.trim().isEmpty) missingDoc++;
      if (d.paymentPeriod == null) missingPeriod++;
      if (d.seasonalCode.trim().isEmpty) missingSeasonal++;
      if (d.salesMethod.trim().isEmpty) missingSales++;

      final key = '${d.customerCode}|${d.branch}|${d.seasonalCode}|${d.documentNumber ?? ""}';
      docCounts[key] = (docCounts[key] ?? 0) + 1;
    }

    final duplicates = docCounts.entries.where((e) => e.value > 1 && e.key.split('|').last.isNotEmpty).toList();
    final dupDocs = duplicates.map((e) => e.key.split('|').last).toSet().toList();

    final report = ValidationReport(
      totalRecords: datas.length,
      missingDocNumber: missingDoc,
      missingPaymentPeriod: missingPeriod,
      missingSeasonalCode: missingSeasonal,
      missingSalesMethod: missingSales,
      duplicateDocNumbers: duplicates.fold(0, (s, e) => s + e.value - 1),
      duplicateDocs: dupDocs.take(5).toList(),
    );

    if (report.hasIssues) {
      onLog('⚠️ Phát hiện ${report.totalIssues} vấn đề:');
      if (missingDoc > 0) onLog('   • $missingDoc dòng thiếu số chứng từ');
      if (missingPeriod > 0) onLog('   • $missingPeriod dòng thiếu kỳ hạn thanh toán');
      if (missingSeasonal > 0) onLog('   • $missingSeasonal dòng thiếu mã vụ việc');
      if (missingSales > 0) onLog('   • $missingSales dòng thiếu phương thức bán hàng');
      if (duplicates.isNotEmpty) {
        onLog('   • ${report.duplicateDocNumbers} chứng từ trùng lặp (${dupDocs.take(3).join(", ")}${dupDocs.length > 3 ? "..." : ""})');
      }
      onLog('⚠️ Các dòng lỗi sẽ bị đánh dấu invalid khi tính toán.');
    } else {
      onLog('✅ Dữ liệu hợp lệ (${datas.length} dòng).');
    }

    return report;
  }
}
