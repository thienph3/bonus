import 'dart:io';
import 'package:test/test.dart';
import '../lib/data/services/import_parser.dart';

void main() {
  test('parseExcelFile should parse input.xlsx without error', () {
    // Use the real input file from data folder
    final filePath = _findInputFile();
    if (filePath == null) {
      print('⚠️ data/input.xlsx not found, skipping test');
      return;
    }

    print('Testing with: $filePath');
    final result = parseExcelFile((filePath, 'test-run-id'));

    final holidays = result['holidays']!;
    final levels = result['levels']!;
    final mainData = result['mainData']!;

    print('Holidays: ${holidays.length}');
    print('Levels: ${levels.length}');
    print('MainData: ${mainData.length}');

    expect(holidays, isA<List>());
    expect(levels, isA<List>());
    expect(mainData, isA<List>());

    // Verify all values are primitives (sendable via isolate)
    for (final h in holidays) {
      for (final v in h.values) {
        expect(v == null || v is int || v is String || v is double || v is bool, isTrue,
            reason: 'Holiday value $v (${v.runtimeType}) is not a primitive');
      }
    }
    for (final l in levels) {
      for (final v in l.values) {
        expect(v == null || v is int || v is String || v is double || v is bool, isTrue,
            reason: 'Level value $v (${v.runtimeType}) is not a primitive');
      }
    }
    for (final m in mainData) {
      for (final entry in m.entries) {
        final v = entry.value;
        expect(v == null || v is int || v is String || v is double || v is bool, isTrue,
            reason: 'MainData key=${entry.key} value=$v (${v.runtimeType}) is not a primitive');
      }
    }

    print('✅ All values are primitives — isolate safe!');

    // Print first record for inspection
    if (mainData.isNotEmpty) {
      print('\nFirst main_data record:');
      mainData.first.forEach((k, v) => print('  $k: $v (${v.runtimeType})'));
    }
    if (levels.isNotEmpty) {
      print('\nFirst level record:');
      levels.first.forEach((k, v) => print('  $k: $v (${v.runtimeType})'));
    }
  });
}

String? _findInputFile() {
  // Try relative paths from different working directories
  for (final path in [
    'data/input.xlsx',
    '../data/input.xlsx',
    '../../data/input.xlsx',
  ]) {
    if (File(path).existsSync()) return File(path).absolute.path;
  }
  return null;
}
