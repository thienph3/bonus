import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

/// Copies bundled template.xlsx to user-chosen location.
Future<String?> downloadTemplate(void Function(String) onLog) async {
  final savePath = await FilePicker.saveFile(
      dialogTitle: 'Lưu file mẫu', fileName: 'template.xlsx',
      type: FileType.custom, allowedExtensions: ['xlsx']);
  if (savePath == null) return null;

  try {
    final data = await rootBundle.load('assets/template.xlsx');
    await File(savePath).writeAsBytes(data.buffer.asUint8List());
    onLog('✅ Đã lưu file mẫu: $savePath');
    return savePath;
  } catch (e) {
    onLog('⚠️ Không tìm thấy file mẫu: $e');
    return null;
  }
}
