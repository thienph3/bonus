import 'package:flutter/material.dart';

Widget buildInitialView(BuildContext context, VoidCallback onPickFile) {
  return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.upload_file, size: 64, color: Theme.of(context).colorScheme.primary),
    const SizedBox(height: 16),
    FilledButton.icon(onPressed: onPickFile, icon: const Icon(Icons.folder_open),
        label: const Text('Chọn file Excel')),
    const SizedBox(height: 12),
    Text('File cần 3 sheet: Data, level_config, holiday_config',
        style: TextStyle(color: Colors.grey[600], fontSize: 13)),
  ]));
}

Widget buildProcessingView() {
  return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    CircularProgressIndicator(),
    SizedBox(height: 16),
    Text('Đang xử lý...'),
  ]));
}

Widget buildExportedView(String path, VoidCallback onReset) {
  return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.check_circle, size: 64, color: Colors.green),
    const SizedBox(height: 16),
    const Text('Xuất file thành công!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    Text(path, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
    const SizedBox(height: 24),
    FilledButton.icon(onPressed: onReset, icon: const Icon(Icons.refresh), label: const Text('Bắt đầu lại')),
  ]));
}

Widget buildErrorView(String errorMsg, VoidCallback onRetry) {
  return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.error, size: 64, color: Colors.red),
    const SizedBox(height: 16),
    Text('Lỗi: $errorMsg', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
    const SizedBox(height: 24),
    FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Thử lại')),
  ]));
}
