import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
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
])
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());

  static AppDatabase? _instance;
  static AppDatabase get instance => _instance ??= AppDatabase._();

  @override
  int get schemaVersion => 2;

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
