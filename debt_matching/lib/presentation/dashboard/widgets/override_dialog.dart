import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/services/override_service.dart';

final _nf = NumberFormat('#,###');

/// Dialog to view and override bonus values for individual results.
class OverrideDialog extends StatefulWidget {
  final String runId;
  const OverrideDialog({super.key, required this.runId});
  @override
  State<OverrideDialog> createState() => _OverrideDialogState();
}

class _OverrideDialogState extends State<OverrideDialog> {
  final _svc = OverrideService();
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final rows = await _svc.getResultsForOverride(widget.runId);
    setState(() { _rows = rows; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: (size.width - 48).clamp(0, 700), maxHeight: (size.height - 96).clamp(0, 500)),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        Text('Chỉnh sửa bonus', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const Text('Nhấn vào dòng để chỉnh sửa. Top 100 records có bonus.', style: TextStyle(fontSize: 12)),
        const Divider(),
        if (_loading) const Expanded(child: Center(child: CircularProgressIndicator())),
        if (!_loading) Expanded(child: SingleChildScrollView(child: DataTable(
          columnSpacing: 12,
          columns: const [
            DataColumn(label: Text('KH')), DataColumn(label: Text('CT')),
            DataColumn(label: Text('B1')), DataColumn(label: Text('B2')), DataColumn(label: Text('B3')),
          ],
          rows: _rows.map((r) => DataRow(
            onSelectChanged: (_) => _editRow(r),
            cells: [
              DataCell(Text(r['customer'], style: const TextStyle(fontSize: 12))),
              DataCell(Text(r['doc'], style: const TextStyle(fontSize: 12))),
              DataCell(Text(_nf.format(r['bonus1']))),
              DataCell(Text(_nf.format(r['bonus2']))),
              DataCell(Text(_nf.format(r['bonus3']))),
            ],
          )).toList(),
        ))),
      ])),
    ));
  }

  Future<void> _editRow(Map<String, dynamic> row) async {
    final c1 = TextEditingController(text: '${row['bonus1']}');
    final c2 = TextEditingController(text: '${row['bonus2']}');
    final c3 = TextEditingController(text: '${row['bonus3']}');
    final reason = TextEditingController();
    final saved = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text('${row['customer']} — ${row['doc']}'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _field(c1, 'Bonus 1'), const SizedBox(height: 8),
        _field(c2, 'Bonus 2'), const SizedBox(height: 8),
        _field(c3, 'Bonus 3'), const SizedBox(height: 8),
        _field(reason, 'Lý do'),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
        FilledButton(onPressed: () async {
          await _svc.overrideBonus(row['id'],
            bonus1: int.tryParse(c1.text), bonus2: int.tryParse(c2.text),
            bonus3: int.tryParse(c3.text), reason: reason.text.isEmpty ? null : reason.text);
          if (ctx.mounted) Navigator.pop(ctx, true);
        }, child: const Text('Lưu')),
      ],
    ));
    if (saved == true) { await _load(); }
  }

  Widget _field(TextEditingController c, String label) => TextField(controller: c,
    keyboardType: TextInputType.number, decoration: InputDecoration(labelText: label, isDense: true, border: const OutlineInputBorder()));
}
