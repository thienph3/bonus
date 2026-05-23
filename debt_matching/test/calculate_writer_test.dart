import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:debt_matching/data/database/app_database.dart';
import 'package:debt_matching/data/services/calculate_fifo.dart';
import 'package:debt_matching/data/services/calculate_writer.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('CalculateWriter', () {
    test('writeFifoResults writes bonus and matchings', () async {
      // Setup: insert a run + result
      await db.into(db.runHistories).insert(RunHistoriesCompanion.insert(
        id: 'run1', timestamp: DateTime.now(), status: const Value('imported')));
      await db.into(db.mainDatas).insert(MainDatasCompanion.insert(
        id: 'md1', runId: const Value('run1'), seasonalCode: 'VU01',
        customerCode: 'KH01', branch: 'CN01', salesMethod: 'BH01'));
      await db.into(db.results).insert(ResultsCompanion.insert(
        id: 'r1', mainDataId: 'md1', runId: const Value('run1')));

      final fifo = FifoResult(
        totalBonus: 1000, totalConsumed: 1000, totalRemaining: 0, totalPushed: 1000,
        bonusUpdates: [{'id': 'r1', 'b1': 500, 'b2': 300, 'b3': 200, 'before': '[]', 'after': '[]'}],
        matchingDetails: [{'id': 'm1', 'resultId': 'r1', 'increaseDoc': 'CT01',
          'decreaseDoc': 'CT02', 'decreaseDate': DateTime(2024, 1, 1).millisecondsSinceEpoch,
          'amount': 1000, 'tier': 'bonus_1'}],
      );

      final writer = CalculateWriter(db);
      await writer.writeFifoResults(fifo, 'run1');

      final result = await (db.select(db.results)..where((t) => t.id.equals('r1'))).getSingle();
      expect(result.bonus1, 500);
      expect(result.bonus2, 300);
      expect(result.bonus3, 200);

      final matchings = await db.select(db.matchingDetails).get();
      expect(matchings.length, 1);
      expect(matchings[0].amountMatched, 1000);
      expect(matchings[0].bonusTier, 'bonus_1');
    });

    test('updateRunHistory sets status and totalBonus', () async {
      await db.into(db.runHistories).insert(RunHistoriesCompanion.insert(
        id: 'run1', timestamp: DateTime.now(), status: const Value('imported')));

      final writer = CalculateWriter(db);
      await writer.updateRunHistory('run1', 5000000);

      final run = await (db.select(db.runHistories)..where((t) => t.id.equals('run1'))).getSingle();
      expect(run.status, 'completed');
      expect(run.totalBonus, 5000000);
    });
  });
}
