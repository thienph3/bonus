import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _nf = NumberFormat('#,###');

class PreviewPanel extends StatelessWidget {
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> topResults;
  final int invalidCount;
  final VoidCallback onExport;
  final VoidCallback onReset;
  final VoidCallback? onCompare;
  final VoidCallback? onOverride;

  const PreviewPanel({
    super.key,
    required this.stats,
    required this.topResults,
    required this.invalidCount,
    required this.onExport,
    required this.onReset,
    this.onCompare,
    this.onOverride,
  });

  @override
  Widget build(BuildContext context) {
    final recon = stats['total_pushed'] == stats['total_consumed'] + stats['total_remaining'];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
              const SizedBox(width: 12),
              if (onCompare != null) ...[
                OutlinedButton.icon(onPressed: onCompare, icon: const Icon(Icons.compare_arrows), label: const Text('So sánh')),
                const SizedBox(width: 12),
              ],
              if (onOverride != null) ...[
                OutlinedButton.icon(onPressed: onOverride, icon: const Icon(Icons.edit), label: const Text('Chỉnh sửa')),
                const SizedBox(width: 12),
              ],
              FilledButton.icon(onPressed: onExport, icon: const Icon(Icons.download), label: const Text('Xuất kết quả')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, bool recon) {
    return LayoutBuilder(builder: (context, constraints) {
      final cardWidth = ((constraints.maxWidth - 36) / 4).clamp(120.0, 180.0);
      return Wrap(
        spacing: 12, runSpacing: 12,
        children: [
          _card(context, 'Records', '${stats['total_records']}', Icons.list_alt, cardWidth),
          _card(context, 'Invalid', '$invalidCount', Icons.warning, cardWidth,
              color: invalidCount > 0 ? Theme.of(context).colorScheme.error : null),
          _card(context, 'Bonus 1', _nf.format(stats['bonus_1'] ?? 0), Icons.looks_one, cardWidth),
          _card(context, 'Bonus 2', _nf.format(stats['bonus_2'] ?? 0), Icons.looks_two, cardWidth),
          _card(context, 'Bonus 3', _nf.format(stats['bonus_3'] ?? 0), Icons.looks_3, cardWidth),
          _card(context, 'Tổng thưởng', _nf.format(stats['total_bonus']), Icons.monetization_on, cardWidth),
          _card(context, 'Reconciliation', recon ? 'OK' : 'MISMATCH', Icons.check_circle, cardWidth,
              color: recon ? Colors.green : Theme.of(context).colorScheme.error),
        ],
      );
    });
  }

  Widget _card(BuildContext context, String label, String value, IconData icon, double width, {Color? color}) {
    return SizedBox(
      width: width,
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
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('⚠️ Cảnh báo', style: TextStyle(
            fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onErrorContainer)),
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
                DataCell(Text(_nf.format(r['bonus_1']))),
                DataCell(Text(_nf.format(r['bonus_2']))),
                DataCell(Text(_nf.format(r['bonus_3']))),
              ])).toList(),
            ),
          ),
        ]),
      ),
    );
  }
}
