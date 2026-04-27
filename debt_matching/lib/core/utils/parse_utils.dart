import 'package:intl/intl.dart';

/// Parse number from dynamic value (String, double, int, null)
int? parseNumber(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  final str = value.toString().trim();
  if (str.isEmpty) return null;
  final d = double.tryParse(str);
  if (d != null) return d.toInt();
  return null;
}

/// Parse date from dynamic value (Excel serial, String, DateTime, null)
DateTime? parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;

  // Excel serial number
  if (value is double || value is int) {
    final serial = value is int ? value : (value as double).toInt();
    if (serial <= 0) return null;
    // Excel bug: 1900 is not a leap year, skip day 60
    final base = DateTime(1899, 12, 30);
    return base.add(Duration(days: serial > 59 ? serial : serial + 1));
  }

  final str = value.toString().trim();
  if (str.isEmpty) return null;

  final formats = [
    'dd/MM/yyyy',
    'yyyy-MM-dd',
    'yyyy-MM-dd HH:mm:ss',
    'dd-MM-yyyy',
    'MM/dd/yyyy',
  ];

  for (final fmt in formats) {
    try {
      return DateFormat(fmt).parseStrict(str);
    } catch (_) {}
  }

  return null;
}

/// Adjust date to skip holidays (iterative, not recursive)
DateTime? changeDateByHolidays(DateTime? date, Set<DateTime> holidaySet) {
  if (date == null) return null;
  var current = date;
  int maxIterations = 1000;
  while (holidaySet.contains(current) && maxIterations > 0) {
    current = current.add(const Duration(days: 1));
    maxIterations--;
  }
  return current;
}
