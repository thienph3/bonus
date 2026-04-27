import 'dart:io';
import 'package:excel/excel.dart';
import '../database/app_database.dart';

class ExportService {
  final AppDatabase _db = AppDatabase.instance;

  Future<void> exportToExcel(
    String filePath,
    void Function(String) onLog,
  ) async {
    onLog('📤 Đang lấy dữ liệu...');
    final results = await _db.select(_db.results).get();
    final mainDatas = await _db.select(_db.mainDatas).get();
    final dataMap = {for (final d in mainDatas) d.id: d};

    // Sort by originalIdx
    results.sort((a, b) => a.originalIdx.compareTo(b.originalIdx));

    onLog('📤 Đang tạo file Excel...');
    final excel = Excel.createExcel();
    final sheet = excel['Result'];

    // Headers
    final headers = [
      'idx', 'document_date', 'document_number', 'description',
      'corresponding_account', 'increase', 'decrease',
      'adjust_increase', 'adjust_decrease', 'end_amount',
      'seasonal_code', 'payment_period', 'customer_code',
      'customer_name', 'branch', 'code', 'sales_method',
      'type', 'payment_due_date', 'bonus_decrease', 'non_bonus_decrease',
      'bonus_increase', 'non_bonus_increase',
      'payment_due_date_1', 'payment_due_date_2', 'payment_due_date_3',
      'bonus_1', 'bonus_2', 'bonus_3',
      'calculate_status', 'calculate_message',
    ];

    for (int col = 0; col < headers.length; col++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0)).value =
          TextCellValue(headers[col]);
    }

    // Data rows
    for (int i = 0; i < results.length; i++) {
      final r = results[i];
      final d = dataMap[r.mainDataId];
      if (d == null) continue;

      final row = i + 1;
      int col = 0;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          d.idx != null ? IntCellValue(d.idx!) : null;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          d.documentDate != null ? DateCellValue(year: d.documentDate!.year, month: d.documentDate!.month, day: d.documentDate!.day) : null;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          d.documentNumber != null ? TextCellValue(d.documentNumber!) : null;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          d.description != null ? TextCellValue(d.description!) : null;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          d.correspondingAccount != null ? TextCellValue(d.correspondingAccount!) : null;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          d.increase != null ? IntCellValue(d.increase!) : null;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          d.decrease != null ? IntCellValue(d.decrease!) : null;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          d.adjustIncrease != null ? IntCellValue(d.adjustIncrease!) : null;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          d.adjustDecrease != null ? IntCellValue(d.adjustDecrease!) : null;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          d.endAmount != null ? IntCellValue(d.endAmount!) : null;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          TextCellValue(d.seasonalCode);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          d.paymentPeriod != null ? IntCellValue(d.paymentPeriod!) : null;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          TextCellValue(d.customerCode);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          d.customerName != null ? TextCellValue(d.customerName!) : null;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          TextCellValue(d.branch);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          d.code != null ? TextCellValue(d.code!) : null;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          TextCellValue(d.salesMethod);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          IntCellValue(r.type);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          r.paymentDueDate != null ? DateCellValue(year: r.paymentDueDate!.year, month: r.paymentDueDate!.month, day: r.paymentDueDate!.day) : null;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          IntCellValue(r.bonusDecrease);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          IntCellValue(r.nonBonusDecrease);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          IntCellValue(r.bonusIncrease);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          IntCellValue(r.nonBonusIncrease);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          r.paymentDueDate1 != null ? DateCellValue(year: r.paymentDueDate1!.year, month: r.paymentDueDate1!.month, day: r.paymentDueDate1!.day) : null;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          r.paymentDueDate2 != null ? DateCellValue(year: r.paymentDueDate2!.year, month: r.paymentDueDate2!.month, day: r.paymentDueDate2!.day) : null;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          r.paymentDueDate3 != null ? DateCellValue(year: r.paymentDueDate3!.year, month: r.paymentDueDate3!.month, day: r.paymentDueDate3!.day) : null;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          IntCellValue(r.bonus1);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          IntCellValue(r.bonus2);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          IntCellValue(r.bonus3);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          TextCellValue(r.calculateStatus);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value =
          TextCellValue(r.calculateMessage);

      if ((i + 1) % 100 == 0) onLog('📤 Đã ghi ${i + 1} dòng...');
    }

    // Remove default Sheet1
    if (excel.tables.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    onLog('📤 Đang lưu file...');
    final fileBytes = excel.save();
    if (fileBytes != null) {
      File(filePath).writeAsBytesSync(fileBytes);
    }
    onLog('✅ Đã xuất ${results.length} dòng.');
  }
}
