import 'package:drift/drift.dart';
import '../database/app_database.dart';
import 'calculate_fifo.dart';
import 'calculate_writer.dart';

/// Processes FIFO per group with crash recovery support.
/// Each group is committed independently — resume skips completed groups.
class ChunkedFifoService {
  final AppDatabase _db = AppDatabase.instance;

  /// Returns total bonus. Resumes from last incomplete group if crashed previously.
  Future<int> processChunked(
    String runId,
    List<Result> sortedResults,
    Map<String, MainData> dataMap,
    void Function(String) onLog,
    void Function(int) onSubStep,
  ) async {
    // Build groups
    final groups = _extractGroups(sortedResults, dataMap);
    onLog('FIFO: ${groups.length} nhóm');

    // Check for existing progress (resume support)
    final doneKeys = await _getCompletedGroups(runId);
    final pending = groups.entries.where((e) => !doneKeys.contains(e.key)).toList();

    if (doneKeys.isNotEmpty) {
      onLog('🔄 Resume: ${doneKeys.length} nhóm đã xong, còn ${pending.length} nhóm');
    }

    // Register pending groups
    if (doneKeys.isEmpty) {
      await _db.batch((b) {
        for (final key in groups.keys) {
          b.insert(_db.fifoProgress, FifoProgressCompanion.insert(runId: runId, groupKey: key));
        }
      });
    }

    int totalBonus = 0;
    for (int i = 0; i < pending.length; i++) {
      final entry = pending[i];
      final groupResults = entry.value;
      final bonus = await _processGroup(runId, groupResults, dataMap);
      totalBonus += bonus;
      // Mark done
      await (_db.update(_db.fifoProgress)
        ..where((t) => t.runId.equals(runId) & t.groupKey.equals(entry.key)))
        .write(const FifoProgressCompanion(status: Value('done')));

      if ((i + 1) % 50 == 0 || i == pending.length - 1) {
        onLog('FIFO: ${doneKeys.length + i + 1}/${groups.length} nhóm');
      }
    }

    // Add bonus from already-completed groups
    if (doneKeys.isNotEmpty) {
      totalBonus += await _sumCompletedBonus(runId, sortedResults, dataMap, doneKeys, groups);
    }

    // Cleanup progress
    await (_db.delete(_db.fifoProgress)..where((t) => t.runId.equals(runId))).go();
    return totalBonus;
  }

  Map<String, List<Result>> _extractGroups(List<Result> results, Map<String, MainData> dataMap) {
    final groups = <String, List<Result>>{};
    for (final r in results) {
      final d = dataMap[r.mainDataId];
      if (d == null) continue;
      final key = '${d.customerCode}|${d.branch}|${d.seasonalCode}';
      (groups[key] ??= []).add(r);
    }
    return groups;
  }

  Future<Set<String>> _getCompletedGroups(String runId) async {
    final rows = await (_db.select(_db.fifoProgress)
      ..where((t) => t.runId.equals(runId) & t.status.equals('done'))).get();
    return rows.map((r) => r.groupKey).toSet();
  }

  Future<int> _processGroup(String runId, List<Result> groupResults, Map<String, MainData> dataMap) async {
    // Serialize for computeFifo
    final sr = groupResults.map((r) => {
      'id': r.id, 'mainDataId': r.mainDataId, 'type': r.type,
      'bonusDecrease': r.bonusDecrease, 'nonBonusDecrease': r.nonBonusDecrease,
      'bonusIncrease': r.bonusIncrease, 'nonBonusIncrease': r.nonBonusIncrease,
      'paymentDueDate1': r.paymentDueDate1?.millisecondsSinceEpoch,
      'paymentDueDate2': r.paymentDueDate2?.millisecondsSinceEpoch,
      'paymentDueDate3': r.paymentDueDate3?.millisecondsSinceEpoch,
    }).toList();
    final sd = {for (final r in groupResults) r.mainDataId: {
      'customerCode': dataMap[r.mainDataId]!.customerCode,
      'branch': dataMap[r.mainDataId]!.branch,
      'seasonalCode': dataMap[r.mainDataId]!.seasonalCode,
      'documentNumber': dataMap[r.mainDataId]!.documentNumber,
      'documentDate': dataMap[r.mainDataId]!.documentDate?.millisecondsSinceEpoch,
    }};

    final fifo = computeFifo({'results': sr, 'dataMap': sd, 'runId': runId});

    // Write in single transaction per group
    await _db.transaction(() async {
      final writer = CalculateWriter(_db);
      await writer.writeFifoResults(fifo, runId);
    });

    return fifo.totalBonus;
  }

  Future<int> _sumCompletedBonus(String runId, List<Result> all, Map<String, MainData> dataMap,
      Set<String> doneKeys, Map<String, List<Result>> groups) async {
    // Sum bonus from DB for already-completed groups
    final doneResultIds = doneKeys.expand((k) => groups[k]?.map((r) => r.id) ?? <String>[]).toSet();
    final rows = await (_db.select(_db.results)
      ..where((t) => t.runId.equals(runId))).get();
    return rows.where((r) => doneResultIds.contains(r.id))
        .fold<int>(0, (s, r) => s + r.bonus1 + r.bonus2 + r.bonus3);
  }
}
