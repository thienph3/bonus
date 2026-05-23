import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/services/sample_verification_service.dart';

final _nf = NumberFormat('#,###');
final _df = DateFormat('dd/MM/yyyy');

class SampleVerificationDialog extends StatefulWidget {
  final String runId;
  const SampleVerificationDialog({super.key, required this.runId});
  @override
  State<SampleVerificationDialog> createState() => _SampleVerificationDialogState();
}

class _SampleVerificationDialogState extends State<SampleVerificationDialog> {
  final _svc = SampleVerificationService();
  final _shown = <String>[];
  Map<String, dynamic>? _sample;
  bool _loading = true;
  String? _noMore;

  @override
  void initState() { super.initState(); _loadSample(); }

  Future<void> _loadSample() async {
    setState(() { _loading = true; _noMore = null; });
    final result = await _svc.getRandomSample(widget.runId, _shown);
    if (result == null) {
      setState(() { _loading = false; _noMore = 'Đã xem hết tất cả khách hàng có bonus.'; });
    } else {
      _shown.add(result['customer_code'] as String);
      setState(() { _sample = result; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: (size.width - 48).clamp(0, 750), maxHeight: (size.height - 64).clamp(0, 600)),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        Row(children: [
          const Expanded(child: Text('Kiểm tra mẫu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ]),
        const Divider(),
        if (_loading) const Expanded(child: Center(child: CircularProgressIndicator())),
        if (_noMore != null) Expanded(child: Center(child: Text(_noMore!))),
        if (!_loading && _sample != null) Expanded(child: _buildContent()),
        const SizedBox(height: 8),
        FilledButton.icon(onPressed: _loading ? null : _loadSample,
            icon: const Icon(Icons.shuffle), label: const Text('Mẫu khác')),
      ])),
    ));
  }

  Widget _buildContent() {
    final s = _sample!;
    final matchings = s['matchings'] as List<Map<String, dynamic>>;
    return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${s['customer_code']} — ${s['customer_name']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      Text('Chi nhánh: ${s['branch']} | Vụ: ${s['seasonal']}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      const SizedBox(height: 12),
      Text('ĐỐI TRỪ (${matchings.length} cặp)', style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      ...matchings.take(30).map(_buildMatchRow),
      if (matchings.length > 30) Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text('... và ${matchings.length - 30} cặp khác', style: TextStyle(color: Colors.grey[600])),
      ),
      const Divider(height: 24),
      _buildTotals(s),
    ]));
  }

  Widget _buildMatchRow(Map<String, dynamic> m) {
    final tier = m['tier'] as String;
    final decDate = m['dec_date'] as DateTime?;
    final amount = m['amount'] as int;
    final tierLabel = switch (tier) { 'bonus_1' => 'B1 ✓', 'bonus_2' => 'B2 ✓', 'bonus_3' => 'B3 ✓', _ => '—' };
    final tierColor = tier.startsWith('bonus') ? Colors.green : Colors.grey;
    final explanation = _explain(m);

    return Card(child: Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text('${m['inc_doc']} ← ${m['dec_doc']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: tierColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
          child: Text(tierLabel, style: TextStyle(fontSize: 11, color: tierColor, fontWeight: FontWeight.bold))),
      ]),
      const SizedBox(height: 4),
      Text('Số tiền: ${_nf.format(amount)} | Ngày TT: ${decDate != null ? _df.format(decDate) : "—"}',
          style: const TextStyle(fontSize: 12)),
      if (explanation.isNotEmpty) Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(explanation, style: TextStyle(fontSize: 11, color: Colors.grey[700], fontStyle: FontStyle.italic)),
      ),
    ])));
  }

  String _explain(Map<String, dynamic> m) {
    final tier = m['tier'] as String;
    final decDate = m['dec_date'] as DateTime?;
    if (decDate == null) return '';
    final dateStr = _df.format(decDate);
    if (tier == 'bonus_1' && m['pdd1'] != null) {
      return '→ Ngày TT $dateStr ≤ Hạn tier1 ${_df.format(m['pdd1'])} → Bonus 1';
    } else if (tier == 'bonus_2' && m['pdd2'] != null) {
      return '→ Ngày TT $dateStr ≤ Hạn tier2 ${_df.format(m['pdd2'])} → Bonus 2';
    } else if (tier == 'bonus_3' && m['pdd3'] != null) {
      return '→ Ngày TT $dateStr ≤ Hạn tier3 ${_df.format(m['pdd3'])} → Bonus 3';
    } else if (tier == 'none') {
      final pdd3 = m['pdd3'] as DateTime?;
      return pdd3 != null ? '→ Ngày TT $dateStr > Hạn tier3 ${_df.format(pdd3)} → Không thưởng' : '→ Không thưởng';
    }
    return '';
  }

  Widget _buildTotals(Map<String, dynamic> s) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      _total('Bonus 1', s['bonus_1'] as int),
      _total('Bonus 2', s['bonus_2'] as int),
      _total('Bonus 3', s['bonus_3'] as int),
    ]);
  }

  Widget _total(String label, int value) => Column(children: [
    Text(_nf.format(value), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: value > 0 ? Colors.green : null)),
    Text(label, style: const TextStyle(fontSize: 11)),
  ]);
}
