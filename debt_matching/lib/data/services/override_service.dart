import 'package:drift/drift.dart';
import '../database/app_database.dart';

/// Allows manual override of bonus values for individual results.
class OverrideService {
  final AppDatabase _db = AppDatabase.instance;

  /// Override bonus for a specific result. Stores original in calculateMessage.
  Future<void> overrideBonus(String resultId, {int? bonus1, int? bonus2, int? bonus3, String? reason}) async {
    final result = await (_db.select(_db.results)..where((t) => t.id.equals(resultId))).getSingle();
    final note = 'Override: ${reason ?? "manual"}. Original: b1=${result.bonus1}, b2=${result.bonus2}, b3=${result.bonus3}';
    final msg = result.calculateMessage.isEmpty ? note : '${result.calculateMessage}; $note';
    await (_db.update(_db.results)..where((t) => t.id.equals(resultId))).write(ResultsCompanion(
      bonus1: Value(bonus1 ?? result.bonus1),
      bonus2: Value(bonus2 ?? result.bonus2),
      bonus3: Value(bonus3 ?? result.bonus3),
      calculateMessage: Value(msg),
    ));
  }

  /// Get results for a run with customer info, for override UI.
  Future<List<Map<String, dynamic>>> getResultsForOverride(String runId) async {
    final rows = await _db.customSelect(
      'SELECT r.id, r.bonus1, r.bonus2, r.bonus3, r.calculate_message, '
      'm.customer_code, m.document_number '
      'FROM results r JOIN main_datas m ON r.main_data_id = m.id '
      'WHERE r.run_id = ? AND r.type = 1 AND (r.bonus1 > 0 OR r.bonus2 > 0 OR r.bonus3 > 0) '
      'ORDER BY (r.bonus1 + r.bonus2 + r.bonus3) DESC LIMIT 100',
      variables: [Variable.withString(runId)],
    ).get();
    return rows.map((r) => {
      'id': r.read<String>('id'),
      'customer': r.read<String>('customer_code'),
      'doc': r.read<String>('document_number'),
      'bonus1': r.read<int>('bonus1'),
      'bonus2': r.read<int>('bonus2'),
      'bonus3': r.read<int>('bonus3'),
      'message': r.read<String>('calculate_message'),
    }).toList();
  }
}
