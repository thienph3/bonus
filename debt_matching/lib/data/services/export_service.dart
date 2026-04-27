import 'dart:io';
import 'package:excel/excel.dart';
import '../database/app_database.dart';

class ExportService {
  final AppDatabase _db = AppDatabase.instance;

  Future<void> exportToExcel(String filePath, void Function(String) onLog) async {
    onLog('📤 Đang lấy dữ liệu...');
    final results = await _db.select(_db.results).get();
    final mainDatas = await _db.select(_db.mainDatas).get();
    final matchings = await _db.select(_db.matchingDetails).get();
    final dataMap = {for (final d in mainDatas) d.id: d};

    results.sort((a, b) => a.originalIdx.compareTo(b.originalIdx));

    onLog('📤 Đang tạo file Excel...');
    final excel = Excel.createExcel();

    _writeResultSheet(excel, results, dataMap, onLog);
    _writeMatchingSheet(excel, matchings);

    if (excel.tables.containsKey('Sheet1')) excel.delete('Sheet1');

    onLog('📤 Đang lưu file...');
    final fileBytes = excel.save();
    if (fileBytes != null) File(filePath).writeAsBytesSync(fileBytes);
    onLog('✅ Đã xuất ${results.length} dòng + ${matchings.length} chi tiết đối trừ.');
  }

  void _writeResultSheet(Excel excel, List<Result> results, Map<String, MainData> dataMap, void Function(String) onLog) {
    final sheet = excel['Result'];
    final headers = [
      'idx', 'document_date', 'document_number', 'description',
      'corresponding_account', 'increase', 'decrease', 'adjust_increase',
      'adjust_decrease', 'end_amount', 'seasonal_code', 'payment_period',
      'customer_code', 'customer_name', 'branch', 'code', 'sales_method',
      'type', 'payment_due_date', 'bonus_decrease', 'non_bonus_decrease',
      'bonus_increase', 'non_bonus_increase', 'payment_due_date_1',
      'payment_due_date_2', 'payment_due_date_3', 'bonus_1', 'bonus_2',
      'bonus_3', 'calculate_status', 'calculate_message',
    ];
    for (int c = 0; c < headers.length; c++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0)).value = TextCellValue(headers[c]);
    }
    for (int i = 0; i < results.length; i++) {
      final r = results[i];
      final d = dataMap[r.mainDataId];
      if (d == null) continue;
      _writeResultRow(sheet, i + 1, r, d);
      if ((i + 1) % 100 == 0) onLog('📤 Đã ghi ${i + 1} dòng...');
    }
  }

  void _writeResultRow(Sheet sheet, int row, Result r, MainData d) {
    int c = 0;
    _cell(sheet, c++, row, d.idx != null ? IntCellValue(d.idx!) : null);
    _cell(sheet, c++, row, _dateVal(d.documentDate));
    _cell(sheet, c++, row, d.documentNumber != null ? TextCellValue(d.documentNumber!) : null);
    _cell(sheet, c++, row, d.description != null ? TextCellValue(d.description!) : null);
    _cell(sheet, c++, row, d.correspondingAccount != null ? TextCellValue(d.correspondingAccount!) : null);
    _cell(sheet, c++, row, d.increase != null ? IntCellValue(d.increase!) : null);
    _cell(sheet, c++, row, d.decrease != null ? IntCellValue(d.decrease!) : null);
    _cell(sheet, c++, row, d.adjustIncrease != null ? IntCellValue(d.adjustIncrease!) : null);
    _cell(sheet, c++, row, d.adjustDecrease != null ? IntCellValue(d.adjustDecrease!) : null);
    _cell(sheet, c++, row, d.endAmount != null ? IntCellValue(d.endAmount!) : null);
    _cell(sheet, c++, row, TextCellValue(d.seasonalCode));
    _cell(sheet, c++, row, d.paymentPeriod != null ? IntCellValue(d.paymentPeriod!) : null);
    _cell(sheet, c++, row, TextCellValue(d.customerCode));
    _cell(sheet, c++, row, d.customerName != null ? TextCellValue(d.customerName!) : null);
    _cell(sheet, c++, row, TextCellValue(d.branch));
    _cell(sheet, c++, row, d.code != null ? TextCellValue(d.code!) : null);
    _cell(sheet, c++, row, TextCellValue(d.salesMethod));
    _cell(sheet, c++, row, IntCellValue(r.type));
    _cell(sheet, c++, row, _dateVal(r.paymentDueDate));
    _cell(sheet, c++, row, IntCellValue(r.bonusDecrease));
    _cell(sheet, c++, row, IntCellValue(r.nonBonusDecrease));
    _cell(sheet, c++, row, IntCellValue(r.bonusIncrease));
    _cell(sheet, c++, row, IntCellValue(r.nonBonusIncrease));
    _cell(sheet, c++, row, _dateVal(r.paymentDueDate1));
    _cell(sheet, c++, row, _dateVal(r.paymentDueDate2));
    _cell(sheet, c++, row, _dateVal(r.paymentDueDate3));
    _cell(sheet, c++, row, IntCellValue(r.bonus1));
    _cell(sheet, c++, row, IntCellValue(r.bonus2));
    _cell(sheet, c++, row, IntCellValue(r.bonus3));
    _cell(sheet, c++, row, TextCellValue(r.calculateStatus));
    _cell(sheet, c++, row, TextCellValue(r.calculateMessage));
  }

  void _writeMatchingSheet(Excel excel, List<MatchingDetail> matchings) {
    final sheet = excel['Matching Detail'];
    final headers = ['increase_doc', 'decrease_doc', 'decrease_date', 'amount', 'bonus_tier'];
    for (int c = 0; c < headers.length; c++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0)).value = TextCellValue(headers[c]);
    }
    for (int i = 0; i < matchings.length; i++) {
      final m = matchings[i];
      int c = 0;
      _cell(sheet, c++, i + 1, TextCellValue(m.increaseDocNumber));
      _cell(sheet, c++, i + 1, TextCellValue(m.decreaseDocNumber));
      _cell(sheet, c++, i + 1, _dateVal(m.decreaseDate));
      _cell(sheet, c++, i + 1, IntCellValue(m.amountMatched));
      _cell(sheet, c++, i + 1, TextCellValue(m.bonusTier));
    }
  }

  void _cell(Sheet sheet, int col, int row, CellValue? value) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row)).value = value;
  }

  CellValue? _dateVal(DateTime? dt) {
    if (dt == null) return null;
    return DateCellValue(year: dt.year, month: dt.month, day: dt.day);
  }
}
