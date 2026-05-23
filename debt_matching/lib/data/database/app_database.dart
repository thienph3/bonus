import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  HolidayConfigs,
  LevelConfigs,
  MainDatas,
  Results,
  RunHistories,
  MatchingDetails,
  FifoProgress,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  static AppDatabase? _instance;
  static AppDatabase get instance => _instance ??= AppDatabase._();

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await customStatement('ALTER TABLE holiday_configs ADD COLUMN run_id TEXT');
        await customStatement('ALTER TABLE level_configs ADD COLUMN run_id TEXT');
        await customStatement('ALTER TABLE main_datas ADD COLUMN run_id TEXT');
        await customStatement('ALTER TABLE results ADD COLUMN run_id TEXT');
        await customStatement('ALTER TABLE matching_details ADD COLUMN run_id TEXT');
      }
      if (from < 3) {
        await customStatement('CREATE INDEX IF NOT EXISTS idx_holiday_configs_run_id ON holiday_configs(run_id)');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_level_configs_run_id ON level_configs(run_id)');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_main_datas_run_id ON main_datas(run_id)');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_results_run_id ON results(run_id)');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_matching_details_run_id ON matching_details(run_id)');
      }
      if (from < 4) {
        await customStatement('CREATE TABLE IF NOT EXISTS fifo_progress ('
            'run_id TEXT NOT NULL, group_key TEXT NOT NULL, status TEXT NOT NULL DEFAULT \'pending\', '
            'PRIMARY KEY (run_id, group_key))');
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'debt_matching.db'));
    return NativeDatabase.createInBackground(file);
  });
}

/// Riverpod provider for DI / testing
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase.instance);
