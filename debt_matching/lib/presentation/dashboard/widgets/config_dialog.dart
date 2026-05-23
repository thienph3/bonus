import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/database/app_database.dart';
import '../../../data/services/config_service.dart';

/// Dialog to manage level_config and holiday_config for a run.
class ConfigDialog extends StatefulWidget {
  final String runId;
  const ConfigDialog({super.key, required this.runId});
  @override
  State<ConfigDialog> createState() => _ConfigDialogState();
}

class _ConfigDialogState extends State<ConfigDialog> with SingleTickerProviderStateMixin {
  final _svc = ConfigService();
  late final TabController _tab = TabController(length: 2, vsync: this);
  List<LevelConfig> _levels = [];
  List<HolidayConfig> _holidays = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final l = await _svc.getLevels(widget.runId);
    final h = await _svc.getHolidays(widget.runId);
    setState(() { _levels = l; _holidays = h; });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700, maxHeight: 500),
      child: Column(children: [
        TabBar(controller: _tab, tabs: [
          Tab(text: 'Cấp độ (${_levels.length})'), Tab(text: 'Ngày lễ (${_holidays.length})'),
        ]),
        Expanded(child: TabBarView(controller: _tab, children: [_buildLevels(), _buildHolidays()])),
      ]),
    ));
  }

  Widget _buildLevels() {
    return Column(children: [
      Expanded(child: SingleChildScrollView(child: DataTable(columnSpacing: 8, columns: const [
        DataColumn(label: Text('Mã vụ')), DataColumn(label: Text('PTBH')),
        DataColumn(label: Text('Kỳ hạn')), DataColumn(label: Text('P1')),
        DataColumn(label: Text('P2')), DataColumn(label: Text('P3')), DataColumn(label: Text('')),
      ], rows: _levels.map((l) => DataRow(cells: [
        DataCell(Text(l.seasonalCode, style: const TextStyle(fontSize: 11))),
        DataCell(Text(l.salesMethod, style: const TextStyle(fontSize: 11))),
        DataCell(Text('${l.paymentPeriod}')), DataCell(Text('${l.paymentPeriod1}')),
        DataCell(Text('${l.paymentPeriod2}')), DataCell(Text('${l.paymentPeriod3}')),
        DataCell(IconButton(icon: const Icon(Icons.delete, size: 16), onPressed: () async {
          await _svc.deleteLevel(l.id); _load();
        })),
      ])).toList()))),
      Padding(padding: const EdgeInsets.all(8),
        child: OutlinedButton.icon(onPressed: _addLevel, icon: const Icon(Icons.add), label: const Text('Thêm'))),
    ]);
  }

  Widget _buildHolidays() {
    final fmt = DateFormat('dd/MM/yyyy');
    return Column(children: [
      Expanded(child: ListView.builder(itemCount: _holidays.length, itemBuilder: (_, i) {
        final h = _holidays[i];
        return ListTile(dense: true, title: Text(fmt.format(h.date)),
          trailing: IconButton(icon: const Icon(Icons.delete, size: 16), onPressed: () async {
            await _svc.deleteHoliday(h.id); _load();
          }));
      })),
      Padding(padding: const EdgeInsets.all(8),
        child: OutlinedButton.icon(onPressed: _addHoliday, icon: const Icon(Icons.add), label: const Text('Thêm ngày lễ'))),
    ]);
  }

  Future<void> _addLevel() async {
    final sc = TextEditingController(), sm = TextEditingController();
    final pp = TextEditingController(), p1 = TextEditingController(), p2 = TextEditingController(), p3 = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Thêm cấp độ'), content: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [Expanded(child: _f(sc, 'Mã vụ')), const SizedBox(width: 8), Expanded(child: _f(sm, 'PTBH'))]),
        const SizedBox(height: 8),
        Row(children: [Expanded(child: _f(pp, 'Kỳ hạn')), const SizedBox(width: 8),
          Expanded(child: _f(p1, 'P1')), const SizedBox(width: 8),
          Expanded(child: _f(p2, 'P2')), const SizedBox(width: 8), Expanded(child: _f(p3, 'P3'))]),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Thêm'))],
    ));
    if (ok == true) {
      await _svc.addLevel(widget.runId, seasonalCode: sc.text, salesMethod: sm.text,
        paymentPeriod: int.tryParse(pp.text) ?? 0, pp1: int.tryParse(p1.text) ?? 0,
        pp2: int.tryParse(p2.text) ?? 0, pp3: int.tryParse(p3.text) ?? 0);
      _load();
    }
  }

  Future<void> _addHoliday() async {
    final date = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2030));
    if (date != null) { await _svc.addHoliday(widget.runId, date); _load(); }
  }

  Widget _f(TextEditingController c, String l) => TextField(controller: c, decoration: InputDecoration(labelText: l, isDense: true, border: const OutlineInputBorder()));
}
