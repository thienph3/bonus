import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/database/app_database.dart';

class RunSelector extends StatelessWidget {
  final List<RunHistory> runs;
  final String? selectedRunId;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onDelete;

  const RunSelector({
    super.key,
    required this.runs,
    required this.selectedRunId,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (runs.isEmpty) return const SizedBox.shrink();
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.history, size: 20),
            const SizedBox(width: 8),
            const Text('Kỳ: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: DropdownButton<String>(
                value: selectedRunId,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                items: runs.map((r) {
                  final label = '${fmt.format(r.timestamp)} — ${r.recordCount} records (${r.status})';
                  return DropdownMenuItem(value: r.id, child: Text(label, overflow: TextOverflow.ellipsis));
                }).toList(),
                onChanged: (v) { if (v != null) onSelect(v); },
              ),
            ),
            if (selectedRunId != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                tooltip: 'Xóa kỳ này',
                onPressed: () => _confirmDelete(context, selectedRunId!),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String runId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa kỳ?'),
        content: const Text('Toàn bộ data của kỳ này sẽ bị xóa vĩnh viễn.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          FilledButton(onPressed: () { Navigator.pop(ctx); onDelete(runId); }, child: const Text('Xóa')),
        ],
      ),
    );
  }
}
