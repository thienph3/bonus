import 'package:drift/drift.dart';
import '../database/app_database.dart';
import 'calculate_fifo.dart';

/// Writes FIFO results back to database in batches.
class CalculateWriter {
  final AppDatabase _db;
  CalculateWriter(this._db);

  Future<void> writeFifoResults(FifoResult fifo, String runId) async {
    // Pre-group matchingDetails by resultId → O(n) lookup
    final matchingsByResult = <String, List<Map<String, dynamic>>>{};
    for (final m in fifo.matchingDetails) {
      (matchingsByResult[m['resultId']] ??= []).add(m);
    }

    for (int i = 0; i < fifo.bonusUpdates.length; i += 100) {
      final chunk = fifo.bonusUpdates.sublist(i, (i + 100).clamp(0, fifo.bonusUpdates.length));
      await _db.batch((b) {
        for (final u in chunk) {
          b.update(_db.results, ResultsCompanion(
            bonus1: Value(u['b1']), bonus2: Value(u['b2']), bonus3: Value(u['b3']),
            beforeRemain: Value(u['before']), afterRemain: Value(u['after'])),
            where: (r) => r.id.equals(u['id']));
          final mList = matchingsByResult[u['id']];
          if (mList != null) {
            b.insertAll(_db.matchingDetails, [for (final m in mList) MatchingDetailsCompanion.insert(
              id: m['id'], resultId: m['resultId'], runId: Value(runId),
              increaseDocNumber: Value(m['increaseDoc']),
              decreaseDocNumber: Value(m['decreaseDoc']),
              decreaseDate: Value(m['decreaseDate'] != null
                  ? DateTime.fromMillisecondsSinceEpoch(m['decreaseDate']) : null),
              amountMatched: Value(m['amount']), bonusTier: Value(m['tier']),
            )]);
          }
        }
      });
    }
  }

  Future<void> updateRunHistory(String runId, int totalBonus) async {
    await (_db.update(_db.runHistories)..where((t) => t.id.equals(runId)))
        .write(RunHistoriesCompanion(totalBonus: Value(totalBonus), status: const Value('completed')));
  }
}
