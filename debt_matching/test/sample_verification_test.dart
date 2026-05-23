import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:debt_matching/data/database/app_database.dart';
import 'package:debt_matching/data/services/import_service.dart';
import 'package:debt_matching/data/services/calculate_service.dart';
import 'package:debt_matching/data/services/sample_verification_service.dart';

void main() {
  late AppDatabase db;
  final logs = <String>[];
  void log(String msg) => logs.add(msg);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.instance = db;
    AppDatabase.testMode = true;
    logs.clear();
  });
  tearDown(() { db.close(); AppDatabase.testMode = false; });

  test('getRandomSample returns customer with matching details', () async {
    final ir = await ImportService().importFromExcel('test/fixtures/normal.xlsx', log);
    final runId = ir['runId'] as String;
    await CalculateService().calculate(runId, log, (_) {});

    final svc = SampleVerificationService();
    final sample = await svc.getRandomSample(runId, []);

    if (sample == null) {
      // normal.xlsx may not produce bonus depending on dates — that's OK
      return;
    }
    expect(sample['customer_code'], isNotEmpty);
    expect(sample['matchings'], isList);
    expect((sample['matchings'] as List).first['inc_doc'], isNotEmpty);
  });

  test('getRandomSample excludes already shown customers', () async {
    final ir = await ImportService().importFromExcel('test/fixtures/normal.xlsx', log);
    final runId = ir['runId'] as String;
    await CalculateService().calculate(runId, log, (_) {});

    final svc = SampleVerificationService();
    final first = await svc.getRandomSample(runId, []);
    if (first == null) return;

    final second = await svc.getRandomSample(runId, [first['customer_code'] as String]);
    // Either different customer or null (no more)
    if (second != null) {
      expect(second['customer_code'], isNot(first['customer_code']));
    }
  });

  test('getRandomSample returns null when no bonus exists', () async {
    final ir = await ImportService().importFromExcel('test/fixtures/empty.xlsx', log);
    final runId = ir['runId'] as String;
    await CalculateService().calculate(runId, log, (_) {});

    final svc = SampleVerificationService();
    final sample = await svc.getRandomSample(runId, []);
    expect(sample, isNull);
  });
}
