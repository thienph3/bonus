import '../../data/database/app_database.dart';

class PreviewData {
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> topResults;
  final int invalidCount;
  PreviewData({required this.stats, required this.topResults, required this.invalidCount});
}

Future<PreviewData> loadPreviewData(String runId, Map<String, dynamic>? calcStats) async {
  final db = AppDatabase.instance;
  final results = await (db.select(db.results)..where((t) => t.runId.equals(runId))).get();
  final mainDatas = await (db.select(db.mainDatas)..where((t) => t.runId.equals(runId))).get();
  final dataMap = {for (final d in mainDatas) d.id: d};

  final invalidCount = results.where((r) => r.calculateStatus != 'valid').length;
  final bonusResults = results.where((r) => r.bonus1 > 0 || r.bonus2 > 0 || r.bonus3 > 0).toList()
    ..sort((a, b) => (b.bonus1 + b.bonus2 + b.bonus3).compareTo(a.bonus1 + a.bonus2 + a.bonus3));

  final topResults = bonusResults.take(20).map((r) {
    final d = dataMap[r.mainDataId];
    return {'customer': d?.customerCode ?? '', 'doc': d?.documentNumber ?? '',
      'bonus_1': r.bonus1, 'bonus_2': r.bonus2, 'bonus_3': r.bonus3};
  }).toList();

  final stats = Map<String, dynamic>.from(calcStats ?? {});
  stats['total_records'] = results.length;
  stats['total_bonus'] = results.fold<int>(0, (s, r) => s + r.bonus1 + r.bonus2 + r.bonus3);
  stats['bonus_1'] = results.fold<int>(0, (s, r) => s + r.bonus1);
  stats['bonus_2'] = results.fold<int>(0, (s, r) => s + r.bonus2);
  stats['bonus_3'] = results.fold<int>(0, (s, r) => s + r.bonus3);
  stats['total_pushed'] ??= 0;
  stats['total_consumed'] ??= 0;
  stats['total_remaining'] ??= 0;

  return PreviewData(stats: stats, topResults: topResults, invalidCount: invalidCount);
}
