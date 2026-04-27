import 'package:flutter/material.dart';

class PreviewPanel extends StatelessWidget {
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> topResults;
  final int invalidCount;
  final VoidCallback onExport;
  final VoidCallback onReset;

  const PreviewPanel({
    super.key,
    required this.stats,
    required this.topResults,
    required this.invalidCount,
    required this.onExport,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final recon = stats['total_pushed'] == stats['total_consumed'] + stats['total_remaining'];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Kết quả tính toán', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          _buildSummaryCards(context, recon),
          if (invalidCount > 0 || !recon) ...[
            const SizedBox(height: 16),
            _buildWarnings(context, recon),
          ],
          const SizedBox(height: 16),
          _buildPreviewTable(context),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(onPressed: onReset, icon: const Icon(Icons.refresh), label: const Text('Chọn file khác')),
              const SizedBox(width: 16),
              FilledButton.icon(onPressed: onExport, icon: const Icon(Icons.download), label: const Text('Xuất kết quả')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, bool recon) {
    return Wrap(
      spacing: 12, runSpacing: 12,
      children: [
        _card(context, 'Records', '${stats['total_records']}', Icons.list_alt),
        _card(context, 'Invalid', '$invalidCount', Icons.warning, color: invalidCount > 0 ? Colors.orange : null),
        _card(context, 'Bonus 1', '${stats['bonus_1'] ?? 0}', Icons.looks_one),
        _card(context, 'Bonus 2', '${stats['bonus_2'] ?? 0}', Icons.looks_two),
        _card(context, 'Bonus 3', '${stats['bonus_3'] ?? 0}', Icons.looks_3),
        _card(context, 'Tổng thưởng', '${stats['total_bonus']}', Icons.monetization_on),
        _card(context, 'Reconciliation', recon ? 'OK' : 'MISMATCH', Icons.check_circle,
            color: recon ? Colors.green : Colors.red),
      ],
    );
  }

  Widget _card(BuildContext context, String label, String value, IconData icon, {Color? color}) {
    return SizedBox(
      width: 150,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ]),
        ),
      ),
    );
  }

  Widget _buildWarnings(BuildContext context, bool recon) {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('⚠️ Cảnh báo', style: TextStyle(fontWeight: FontWeight.bold)),
          if (invalidCount > 0) Text('• $invalidCount records không hợp lệ (thiếu data hoặc không match level)'),
          if (!recon) const Text('• Reconciliation MISMATCH — kiểm tra lại dữ liệu'),
        ]),
      ),
    );
  }

  Widget _buildPreviewTable(BuildContext context) {
    if (topResults.isEmpty) return const Text('Không có records có bonus.');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Top ${topResults.length} records có bonus', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16,
              columns: const [
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Doc#')),
                DataColumn(label: Text('Bonus 1', style: TextStyle(fontSize: 12))),
                DataColumn(label: Text('Bonus 2', style: TextStyle(fontSize: 12))),
                DataColumn(label: Text('Bonus 3', style: TextStyle(fontSize: 12))),
              ],
              rows: topResults.map((r) => DataRow(cells: [
                DataCell(Text(r['customer'] ?? '')),
                DataCell(Text(r['doc'] ?? '')),
                DataCell(Text('${r['bonus_1']}')),
                DataCell(Text('${r['bonus_2']}')),
                DataCell(Text('${r['bonus_3']}')),
              ])).toList(),
            ),
          ),
        ]),
      ),
    );
  }
}
