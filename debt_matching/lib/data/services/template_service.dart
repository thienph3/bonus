import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

/// Copies bundled template.xlsx to user-chosen location.
/// Returns saved path or null if cancelled/not found.
Future<String?> downloadTemplate(void Function(String) onLog) async {
  final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Lưu file mẫu', fileName: 'template.xlsx',
      type: FileType.custom, allowedExtensions: ['xlsx']);
  if (savePath == null) return null;
  final src = File(p.join(p.dirname(Platform.resolvedExecutable), 'data', 'flutter_assets', 'assets', 'template.xlsx'));
  if (await src.exists()) { await src.copy(savePath); onLog('✅ Đã lưu file mẫu: $savePath'); return savePath; }
  onLog('⚠️ Không tìm thấy file mẫu.');
  return null;
}
