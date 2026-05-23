import 'package:flutter/material.dart';

/// Shows dialog to input optional bonus percentages.
/// Returns null if cancelled, empty map if skipped, or rates if entered.
Future<Map<String, double>?> showBonusRatesDialog(BuildContext context) async {
  final c1 = TextEditingController(), c2 = TextEditingController(), c3 = TextEditingController();
  return showDialog<Map<String, double>?>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Nhập % chiết khấu (tùy chọn)'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Bỏ trống nếu không cần tính tiền thưởng cuối.', style: TextStyle(fontSize: 12)),
        const SizedBox(height: 12),
        _field(c1, 'Tier 1 (%)'), const SizedBox(height: 8),
        _field(c2, 'Tier 2 (%)'), const SizedBox(height: 8),
        _field(c3, 'Tier 3 (%)'),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
        OutlinedButton(onPressed: () => Navigator.pop(ctx, <String, double>{}), child: const Text('Bỏ qua')),
        FilledButton(onPressed: () {
          final r = <String, double>{};
          final v1 = double.tryParse(c1.text), v2 = double.tryParse(c2.text), v3 = double.tryParse(c3.text);
          if (v1 != null) r['pct_1'] = v1;
          if (v2 != null) r['pct_2'] = v2;
          if (v3 != null) r['pct_3'] = v3;
          Navigator.pop(ctx, r);
        }, child: const Text('Áp dụng')),
      ],
    ),
  );
}

Widget _field(TextEditingController c, String label) {
  return TextField(controller: c, keyboardType: TextInputType.number,
    decoration: InputDecoration(labelText: label, isDense: true, border: const OutlineInputBorder()));
}
