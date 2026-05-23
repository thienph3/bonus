import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/database/app_database.dart';
import '../../../data/services/compare_service.dart';

final _nf = NumberFormat('#,###');

/// Dialog to compare two runs side by side.
class CompareDialog extends StatefulWidget {
  final List<RunHistory> runs;
  final String currentRunId;
  const CompareDialog({super.key, required this.runs, required this.currentRunId});

  @override
  State<CompareDialog> createState() => _CompareDialogState();
}

class _CompareDialogState extends State<CompareDialog> {
  String? _compareRunId;
  CompareSummary? _result;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final otherRuns = widget.runs.where((r) => r.id != widget.currentRunId && r.status == 'completed').toList();
    final size = MediaQuery.of(context).size;
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: (size.width - 48).clamp(0, 700), maxHeight: (size.height - 96).clamp(0, 500)),
        child: Padding(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('So sánh kỳ', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          DropdownButton<String>(
            value: _compareRunId, isExpanded: true, hint: const Text('Chọn kỳ để so sánh'),
            items: otherRuns.map((r) => DropdownMenuItem(value: r.id,
              child: Text('${DateFormat('dd/MM/yyyy HH:mm').format(r.timestamp)} — ${r.recordCount} records'))).toList(),
            onChanged: (v) { setState(() => _compareRunId = v); _runCompare(); },
          ),
          const SizedBox(height: 12),
          if (_loading) const CircularProgressIndicator(),
          if (_result != null) Expanded(child: _buildResult()),
        ])),
      ),
    );
  }

  Future<void> _runCompare() async {
    if (_compareRunId == null) return;
    setState(() => _loading = true);
    final result = await CompareService().compare(_compareRunId!, widget.currentRunId);
    setState(() { _result = result; _loading = false; });
  }

  Widget _buildResult() {
    final r = _result!;
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _stat('Kỳ trước', _nf.format(r.totalA)),
        _stat('Kỳ này', _nf.format(r.totalB)),
        _stat('Chênh lệch', '${r.diff >= 0 ? "+" : ""}${_nf.format(r.diff)}'),
      ]),
      const SizedBox(height: 8),
      Text('KH chung: ${r.customersBoth} | Chỉ kỳ trước: ${r.customersOnlyA} | Chỉ kỳ này: ${r.customersOnlyB}',
          style: const TextStyle(fontSize: 12)),
      const Divider(),
      Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
        columnSpacing: 12,
        columns: const [
          DataColumn(label: Text('KH')), DataColumn(label: Text('Trước')),
          DataColumn(label: Text('Sau')), DataColumn(label: Text('±')),
        ],
        rows: r.rows.take(50).map((row) => DataRow(cells: [
          DataCell(Text(row.customerCode, style: const TextStyle(fontSize: 12))),
          DataCell(Text(_nf.format(row.totalA))),
          DataCell(Text(_nf.format(row.totalB))),
          DataCell(Text('${row.diff >= 0 ? "+" : ""}${_nf.format(row.diff)}',
              style: TextStyle(color: row.diff > 0 ? Colors.green : row.diff < 0 ? Colors.red : null))),
        ])).toList(),
      ))),
    ]);
  }

  Widget _stat(String label, String value) {
    return Column(children: [
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      Text(label, style: const TextStyle(fontSize: 11)),
    ]);
  }
}
