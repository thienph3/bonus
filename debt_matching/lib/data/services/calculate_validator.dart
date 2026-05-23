import '../database/app_database.dart';

class ValidatedData {
  final String dataId;
  final String? levelId;
  final LevelConfig? level;
  final String status;
  final String message;

  ValidatedData({
    required this.dataId,
    this.levelId,
    this.level,
    required this.status,
    required this.message,
  });
}

/// Validates main_data records and matches to level configs.
List<ValidatedData> validateAndMap(
  List<MainData> datas,
  List<LevelConfig> sortedLevels,
) {
  // Build duplicate doc set: (customerCode|branch|seasonalCode|docNumber)
  final docCounts = <String, int>{};
  for (final data in datas) {
    final doc = data.documentNumber?.trim() ?? '';
    if (doc.isEmpty) continue;
    final key = '${data.customerCode}|${data.branch}|${data.seasonalCode}|$doc';
    docCounts[key] = (docCounts[key] ?? 0) + 1;
  }
  final duplicateKeys = docCounts.entries.where((e) => e.value > 1).map((e) => e.key).toSet();

  final results = <ValidatedData>[];
  for (final data in datas) {
    String? levelId;
    LevelConfig? matchedLevel;
    String status = 'invalid';
    String message = '';

    final errors = <String>[];
    if (data.documentNumber == null || data.documentNumber!.trim().isEmpty) {
      errors.add('Document number is empty');
    }
    if (data.paymentPeriod == null) {
      errors.add('Payment period is null');
    } else if (data.paymentPeriod! < 0) {
      errors.add('Payment period must be >= 0');
    }
    if (data.seasonalCode.trim().isEmpty) errors.add('Missing seasonal_code');
    if (data.salesMethod.trim().isEmpty) errors.add('Missing sales_method');

    if (errors.isEmpty) {
      for (final level in sortedLevels) {
        if (data.seasonalCode.toLowerCase() == level.seasonalCode.toLowerCase() &&
            data.salesMethod.toLowerCase() == level.salesMethod.toLowerCase() &&
            (data.paymentPeriod ?? 0) >= level.paymentPeriod) {
          levelId = level.id;
          matchedLevel = level;
          status = 'valid';
          break;
        }
      }
      if (levelId == null) message = 'No matching level config';
      // Check duplicate documentNumber within same group
      final doc = data.documentNumber?.trim() ?? '';
      if (doc.isNotEmpty) {
        final key = '${data.customerCode}|${data.branch}|${data.seasonalCode}|$doc';
        if (duplicateKeys.contains(key)) {
          final warn = 'Duplicate documentNumber: $doc';
          message = message.isEmpty ? warn : '$message; $warn';
        }
      }
    } else {
      message = errors.join('; ');
    }

    results.add(ValidatedData(
      dataId: data.id,
      levelId: levelId,
      level: matchedLevel,
      status: status,
      message: message,
    ));
  }
  return results;
}
