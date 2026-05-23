import 'package:flutter/material.dart';

void showColumnGuideDialog(BuildContext context) {
  showDialog(context: context, builder: (_) => const ColumnGuideDialog());
}

class ColumnGuideDialog extends StatelessWidget {
  const ColumnGuideDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(child: Text('Hướng dẫn cấu trúc file Excel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ]),
            const SizedBox(height: 8),
            const Text('File cần 3 sheet. Cột được nhận diện theo vị trí (A, B, C...), không theo tên.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Expanded(child: DefaultTabController(length: 3, child: Column(children: [
              const TabBar(tabs: [Tab(text: 'Data'), Tab(text: 'level_config'), Tab(text: 'holiday_config')]),
              const SizedBox(height: 8),
              Expanded(child: TabBarView(children: [_dataSheet(), _levelSheet(), _holidaySheet()])),
            ]))),
          ]),
        ),
      ),
    );
  }

  Widget _dataSheet() => _buildTable([
    ['A', 'STT', 'Số', 'Số thứ tự'],
    ['B', 'Ngày chứng từ', 'Ngày', 'Bắt buộc — dùng tính hạn thưởng'],
    ['C', 'Số chứng từ', 'Text', 'Bắt buộc — ID đối trừ'],
    ['D', 'Diễn giải', 'Text', ''],
    ['E', 'TK đối ứng', 'Text', ''],
    ['F', 'Phát sinh tăng', 'Số', 'Nợ TK 131 (bán hàng)'],
    ['G', 'Phát sinh giảm', 'Số', 'Có TK 131 (thanh toán)'],
    ['H', 'Điều chỉnh tăng', 'Số', 'Phần đủ ĐK thưởng của PS tăng'],
    ['I', 'Điều chỉnh giảm', 'Số', 'Phần không ĐK thưởng của PS giảm'],
    ['J', 'Số dư cuối kỳ', 'Số', ''],
    ['K', 'Mã vụ việc', 'Text', 'Bắt buộc — dùng match level'],
    ['L', 'Hạn thanh toán', 'Số', 'Bắt buộc — số ngày, dùng match level'],
    ['M', 'Mã khách hàng', 'Text', 'Bắt buộc — nhóm đối trừ'],
    ['N', 'Tên khách hàng', 'Text', ''],
    ['O', 'Mã chi nhánh', 'Text', 'Bắt buộc — nhóm đối trừ'],
    ['P', 'Mã', 'Text', ''],
    ['Q', 'Hình thức bán', 'Text', 'Bắt buộc — dùng match level'],
  ]);

  Widget _levelSheet() => _buildTable([
    ['A', 'Mã vụ việc', 'Text', 'Match với cột K sheet Data'],
    ['B', 'Hình thức bán', 'Text', 'Match với cột Q sheet Data'],
    ['C', 'Kỳ hạn TT', 'Số', 'Match với cột L sheet Data'],
    ['D', 'Kỳ hạn thưởng 1', 'Số', 'Số ngày tier 1'],
    ['E', 'Kỳ hạn thưởng 2', 'Số', 'Số ngày tier 2'],
    ['F', 'Kỳ hạn thưởng 3', 'Số', 'Số ngày tier 3'],
    ['G', 'Ngày CĐ tier 1', 'Ngày', 'Tùy chọn — ưu tiên hơn kỳ hạn'],
    ['H', 'Ngày CĐ tier 2', 'Ngày', 'Tùy chọn'],
    ['I', 'Ngày CĐ tier 3', 'Ngày', 'Tùy chọn'],
  ]);

  Widget _holidaySheet() => _buildTable([
    ['A', 'Ngày nghỉ', 'Ngày', 'Ngày lễ — dời hạn thưởng sang ngày kế'],
  ]);

  Widget _buildTable(List<List<String>> rows) {
    return SingleChildScrollView(child: DataTable(
      columnSpacing: 12,
      headingRowHeight: 36,
      dataRowMinHeight: 32,
      dataRowMaxHeight: 48,
      columns: const [
        DataColumn(label: Text('Cột', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Tên', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Loại', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Ghi chú', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: rows.map((r) => DataRow(cells: [
        DataCell(Text(r[0], style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'))),
        DataCell(Text(r[1])),
        DataCell(Text(r[2], style: TextStyle(color: r[2] == 'Ngày' ? Colors.blue : r[2] == 'Số' ? Colors.green : null))),
        DataCell(Text(r[3], style: const TextStyle(fontSize: 12))),
      ])).toList(),
    ));
  }
}
