import 'package:test/test.dart';
import 'package:debt_matching/core/utils/error_utils.dart';

void main() {
  group('friendlyError', () {
    test('sheet-related error', () {
      final msg = friendlyError(Exception('Missing sheet "Data"'));
      expect(msg, contains('3 sheet'));
    });
    test('permission error', () {
      final msg = friendlyError(Exception('Access denied'));
      expect(msg, contains('quyền truy cập'));
    });
    test('file not found', () {
      final msg = friendlyError(Exception('No such file or directory'));
      expect(msg, contains('Không tìm thấy'));
    });
    test('unknown error shows detail', () {
      final msg = friendlyError(Exception('Something random'));
      expect(msg, contains('Lỗi không xác định'));
      expect(msg, contains('Something random'));
    });
    test('table keyword triggers sheet message', () {
      final msg = friendlyError(FormatException('table not found'));
      expect(msg, contains('3 sheet'));
    });
  });
}
