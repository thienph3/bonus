import 'package:flutter/material.dart';

Widget buildInitialView(BuildContext context, VoidCallback onPickFile, {VoidCallback? onDownloadTemplate}) {
  return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Image.asset('assets/initial_state.png', width: 240, height: 200,
        errorBuilder: (_, __, ___) => Icon(Icons.upload_file, size: 64, color: Theme.of(context).colorScheme.primary)),
    const SizedBox(height: 16),
    FilledButton.icon(onPressed: onPickFile, icon: const Icon(Icons.folder_open),
        label: const Text('Chọn file Excel')),
    const SizedBox(height: 12),
    Text('File cần 3 sheet: Data, level_config, holiday_config',
        style: TextStyle(color: Colors.grey[600], fontSize: 13)),
    if (onDownloadTemplate != null) ...[
      const SizedBox(height: 16),
      OutlinedButton.icon(onPressed: onDownloadTemplate, icon: const Icon(Icons.description),
          label: const Text('Tải file mẫu')),
    ],
  ]));
}

Widget buildProcessingView(int subStep, {String? importProgress}) {
  const steps = ['Import & Validate', 'Tạo kết quả', 'Sắp xếp', 'FIFO', 'Hoàn tất'];
  final String label;
  if (subStep > 0 && subStep <= steps.length) {
    label = 'Bước $subStep/${steps.length - 1}: ${steps[subStep]}';
  } else if (importProgress != null) {
    label = importProgress;
  } else {
    label = 'Đang xử lý...';
  }
  return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const CircularProgressIndicator(),
    const SizedBox(height: 16),
    Text(label),
    if (subStep > 0) Padding(
      padding: const EdgeInsets.only(top: 8),
      child: LinearProgressIndicator(value: subStep / 4),
    ),
  ]));
}

Widget buildExportedView(String path, VoidCallback onBack) {
  return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Image.asset('assets/export_success.png', width: 200, height: 160,
        errorBuilder: (_, __, ___) => const Icon(Icons.check_circle, size: 64, color: Colors.green)),
    const SizedBox(height: 16),
    const Text('Xuất file thành công!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    Text(path, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
    const SizedBox(height: 24),
    FilledButton.icon(onPressed: onBack, icon: const Icon(Icons.arrow_back), label: const Text('Quay lại')),
  ]));
}

Widget buildErrorView(String errorMsg, VoidCallback onRetry) {
  return Center(child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Image.asset('assets/error_state.png', width: 200, height: 160,
          errorBuilder: (_, __, ___) => const Icon(Icons.error, size: 64, color: Colors.red)),
      const SizedBox(height: 16),
      ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 120),
        child: SingleChildScrollView(
          child: Text('Lỗi: $errorMsg', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
        ),
      ),
      const SizedBox(height: 24),
      FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Thử lại')),
    ]),
  ));
}
