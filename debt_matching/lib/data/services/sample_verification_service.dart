import 'dart:math';
import 'package:drift/drift.dart';
import '../database/app_database.dart';

class SampleVerificationService {
  final _db = AppDatabase.instance;

  /// Get a random customer with bonus > 0, excluding [exclude] list.
  Future<Map<String, dynamic>?> getRandomSample(String runId, List<String> exclude) async {
    // Get distinct customers with bonus
    var query = 'SELECT DISTINCT m.customer_code, m.customer_name, m.branch, m.seasonal_code '
        'FROM results r JOIN main_datas m ON r.main_data_id = m.id '
        'WHERE r.run_id = ? AND (r.bonus1 > 0 OR r.bonus2 > 0 OR r.bonus3 > 0)';
    if (exclude.isNotEmpty) {
      query += ' AND m.customer_code NOT IN (${exclude.map((_) => '?').join(',')})';
    }
    final vars = [Variable.withString(runId), ...exclude.map(Variable.withString)];
    final customers = await _db.customSelect(query, variables: vars).get();
    if (customers.isEmpty) return null;

    final pick = customers[Random().nextInt(customers.length)];
    final custCode = pick.read<String>('customer_code');
    final custName = pick.readNullable<String>('customer_name') ?? '';
    final branch = pick.read<String>('branch');
    final seasonal = pick.read<String>('seasonal_code');

    // Get matching details for this customer group
    final matchings = await _db.customSelect(
      'SELECT md.increase_doc_number, md.decrease_doc_number, md.decrease_date, '
      'md.amount_matched, md.bonus_tier, '
      'r.payment_due_date1, r.payment_due_date2, r.payment_due_date3 '
      'FROM matching_details md '
      'JOIN results r ON md.result_id = r.id '
      'JOIN main_datas m ON r.main_data_id = m.id '
      'WHERE md.run_id = ? AND m.customer_code = ? AND m.branch = ? AND m.seasonal_code = ? '
      'ORDER BY md.rowid',
      variables: [Variable.withString(runId), Variable.withString(custCode),
                  Variable.withString(branch), Variable.withString(seasonal)],
    ).get();

    // Get totals
    final totals = await _db.customSelect(
      'SELECT SUM(r.bonus1) as b1, SUM(r.bonus2) as b2, SUM(r.bonus3) as b3 '
      'FROM results r JOIN main_datas m ON r.main_data_id = m.id '
      'WHERE r.run_id = ? AND m.customer_code = ? AND m.branch = ? AND m.seasonal_code = ?',
      variables: [Variable.withString(runId), Variable.withString(custCode),
                  Variable.withString(branch), Variable.withString(seasonal)],
    ).getSingle();

    return {
      'customer_code': custCode,
      'customer_name': custName,
      'branch': branch,
      'seasonal': seasonal,
      'bonus_1': totals.read<int>('b1'),
      'bonus_2': totals.read<int>('b2'),
      'bonus_3': totals.read<int>('b3'),
      'matchings': matchings.map((m) => {
        'inc_doc': m.read<String>('increase_doc_number'),
        'dec_doc': m.read<String>('decrease_doc_number'),
        'dec_date': m.readNullable<DateTime>('decrease_date'),
        'amount': m.read<int>('amount_matched'),
        'tier': m.read<String>('bonus_tier'),
        'pdd1': m.readNullable<DateTime>('payment_due_date1'),
        'pdd2': m.readNullable<DateTime>('payment_due_date2'),
        'pdd3': m.readNullable<DateTime>('payment_due_date3'),
      }).toList(),
    };
  }
}
