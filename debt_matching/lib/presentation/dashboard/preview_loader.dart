import 'package:drift/drift.dart';
import '../../data/database/app_database.dart';

class PreviewData {
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> topResults;
  final int invalidCount;
  final Map<String, int> invalidReasons;
  PreviewData({required this.stats, required this.topResults, required this.invalidCount, this.invalidReasons = const {}});
}

Future<PreviewData> loadPreviewData(String runId, Map<String, dynamic>? calcStats) async {
  final db = AppDatabase.instance;

  // Aggregate counts and sums in one query
  final agg = await db.customSelect(
    'SELECT COUNT(*) as cnt, '
    'SUM(CASE WHEN calculate_status != \'valid\' THEN 1 ELSE 0 END) as invalid, '
    'SUM(bonus1) as b1, SUM(bonus2) as b2, SUM(bonus3) as b3 '
    'FROM results WHERE run_id = ?',
    variables: [Variable.withString(runId)],
  ).getSingle();

  final custCount = await db.customSelect(
    'SELECT COUNT(DISTINCT customer_code) as cnt FROM main_datas WHERE run_id = ?',
    variables: [Variable.withString(runId)],
  ).getSingle();

  final totalRecords = agg.read<int>('cnt');
  final invalidCount = agg.read<int>('invalid');
  final totalCustomers = custCount.read<int>('cnt');
  final b1 = agg.read<int>('b1');
  final b2 = agg.read<int>('b2');
  final b3 = agg.read<int>('b3');

  // Top 20 bonus results with JOIN (avoids loading all records)
  final topRows = await db.customSelect(
    'SELECT m.customer_code, m.document_number, r.bonus1, r.bonus2, r.bonus3 '
    'FROM results r JOIN main_datas m ON r.main_data_id = m.id '
    'WHERE r.run_id = ? AND (r.bonus1 > 0 OR r.bonus2 > 0 OR r.bonus3 > 0) '
    'ORDER BY (r.bonus1 + r.bonus2 + r.bonus3) DESC LIMIT 20',
    variables: [Variable.withString(runId)],
  ).get();

  final topResults = topRows.map((r) => {
    'customer': r.read<String>('customer_code'),
    'doc': r.read<String>('document_number'),
    'bonus_1': r.read<int>('bonus1'),
    'bonus_2': r.read<int>('bonus2'),
    'bonus_3': r.read<int>('bonus3'),
  }).toList();

  final stats = Map<String, dynamic>.from(calcStats ?? {});
  stats['total_records'] = totalRecords;
  stats['total_customers'] = totalCustomers;
  stats['total_bonus'] = b1 + b2 + b3;
  stats['bonus_1'] = b1;
  stats['bonus_2'] = b2;
  stats['bonus_3'] = b3;
  stats['total_pushed'] ??= 0;
  stats['total_consumed'] ??= 0;
  stats['total_remaining'] ??= 0;

  // Breakdown of invalid reasons
  final invalidReasons = <String, int>{};
  if (invalidCount > 0) {
    final rows = await db.customSelect(
      'SELECT calculate_message, COUNT(*) as cnt FROM results '
      'WHERE run_id = ? AND calculate_status != \'valid\' AND calculate_message != \'\' '
      'GROUP BY calculate_message ORDER BY cnt DESC',
      variables: [Variable.withString(runId)],
    ).get();
    for (final r in rows) {
      invalidReasons[r.read<String>('calculate_message')] = r.read<int>('cnt');
    }
  }

  return PreviewData(stats: stats, topResults: topResults, invalidCount: invalidCount, invalidReasons: invalidReasons);
}
