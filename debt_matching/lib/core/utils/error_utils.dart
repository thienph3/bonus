/// Maps exceptions to user-friendly Vietnamese messages.
String friendlyError(Object e) {
  final msg = e.toString();
  if (msg.contains('sheet') || msg.contains('Sheet') || msg.contains('table')) {
    return 'File Excel không đúng format. Cần có 3 sheet: Data, level_config, holiday_config.';
  }
  if (msg.contains('permission') || msg.contains('denied') || msg.contains('access')) {
    return 'Không có quyền truy cập file. Vui lòng kiểm tra lại.';
  }
  if (msg.contains('No such file') || msg.contains('FileSystemException')) {
    return 'Không tìm thấy file. Vui lòng chọn lại.';
  }
  return 'Lỗi không xác định. Vui lòng liên hệ IT.\n\nChi tiết: $msg';
}
