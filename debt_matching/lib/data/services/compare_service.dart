import 'package:drift/drift.dart';
import '../database/app_database.dart';

class CompareRow {
  final String customerCode;
  final String customerName;
  final int bonus1A, bonus2A, bonus3A;
  final int bonus1B, bonus2B, bonus3B;
  int get totalA => bonus1A + bonus2A + bonus3A;
  int get totalB => bonus1B + bonus2B + bonus3B;
  int get diff => totalB - totalA;
  CompareRow({required this.customerCode, required this.customerName,
    required this.bonus1A, required this.bonus2A, required this.bonus3A,
    required this.bonus1B, required this.bonus2B, required this.bonus3B});
}

class CompareSummary {
  final int totalA, totalB;
  final int customersOnlyA, customersOnlyB, customersBoth;
  final List<CompareRow> rows;
  int get diff => totalB - totalA;
  CompareSummary({required this.totalA, required this.totalB,
    required this.customersOnlyA, required this.customersOnlyB,
    required this.customersBoth, required this.rows});
}

/// Compares bonus results between two runs.
class CompareService {
  final AppDatabase _db = AppDatabase.instance;

  Future<CompareSummary> compare(String runIdA, String runIdB) async {
    final aggA = await _aggregateByCustomer(runIdA);
    final aggB = await _aggregateByCustomer(runIdB);
    final allKeys = {...aggA.keys, ...aggB.keys};

    final rows = <CompareRow>[];
    int totalA = 0, totalB = 0, onlyA = 0, onlyB = 0, both = 0;
    for (final key in allKeys) {
      final a = aggA[key], b = aggB[key];
      final row = CompareRow(
        customerCode: key,
        customerName: a?['name'] as String? ?? b?['name'] as String? ?? '',
        bonus1A: a?['b1'] as int? ?? 0, bonus2A: a?['b2'] as int? ?? 0, bonus3A: a?['b3'] as int? ?? 0,
        bonus1B: b?['b1'] as int? ?? 0, bonus2B: b?['b2'] as int? ?? 0, bonus3B: b?['b3'] as int? ?? 0,
      );
      rows.add(row);
      totalA += row.totalA; totalB += row.totalB;
      if (a == null) { onlyB++; } else if (b == null) { onlyA++; } else { both++; }
    }
    rows.sort((a, b) => b.diff.abs().compareTo(a.diff.abs()));
    return CompareSummary(totalA: totalA, totalB: totalB,
      customersOnlyA: onlyA, customersOnlyB: onlyB, customersBoth: both, rows: rows);
  }

  Future<Map<String, Map<String, dynamic>>> _aggregateByCustomer(String runId) async {
    final rows = await _db.customSelect(
      'SELECT m.customer_code, m.customer_name, '
      'SUM(r.bonus1) as b1, SUM(r.bonus2) as b2, SUM(r.bonus3) as b3 '
      'FROM results r JOIN main_datas m ON r.main_data_id = m.id '
      'WHERE r.run_id = ? GROUP BY m.customer_code',
      variables: [Variable.withString(runId)],
    ).get();
    return {for (final r in rows) r.read<String>('customer_code'): {
      'name': r.read<String>('customer_name'),
      'b1': r.read<int>('b1'), 'b2': r.read<int>('b2'), 'b3': r.read<int>('b3'),
    }};
  }
}
