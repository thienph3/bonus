import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';

const _uuid = Uuid();

/// CRUD operations for level_config and holiday_config within a run.
class ConfigService {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<LevelConfig>> getLevels(String runId) =>
      (_db.select(_db.levelConfigs)..where((t) => t.runId.equals(runId))).get();

  Future<List<HolidayConfig>> getHolidays(String runId) =>
      (_db.select(_db.holidayConfigs)..where((t) => t.runId.equals(runId))).get();

  Future<void> addLevel(String runId, {required String seasonalCode, required String salesMethod,
    required int paymentPeriod, required int pp1, required int pp2, required int pp3}) async {
    await _db.into(_db.levelConfigs).insert(LevelConfigsCompanion.insert(
      id: _uuid.v4(), runId: Value(runId), seasonalCode: seasonalCode, salesMethod: salesMethod,
      paymentPeriod: paymentPeriod, paymentPeriod1: pp1, paymentPeriod2: pp2, paymentPeriod3: pp3));
  }

  Future<void> deleteLevel(String id) =>
      (_db.delete(_db.levelConfigs)..where((t) => t.id.equals(id))).go();

  Future<void> addHoliday(String runId, DateTime date) async {
    await _db.into(_db.holidayConfigs).insert(HolidayConfigsCompanion.insert(
      id: _uuid.v4(), runId: Value(runId), date: date));
  }

  Future<void> deleteHoliday(String id) =>
      (_db.delete(_db.holidayConfigs)..where((t) => t.id.equals(id))).go();
}
