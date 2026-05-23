// ignore_for_file: avoid_print
import 'dart:io';
import 'package:image/image.dart' as img;

/// Compresses PNG images by resizing to max dimensions and re-encoding.
/// Output: same name with _compressed suffix.
void main() {
  const maxWidth = 400;
  const assets = [
    'assets/initial_state.png',
    'assets/export_success.png',
    'assets/error_state.png',
  ];

  for (final path in assets) {
    final file = File(path);
    if (!file.existsSync()) {
      print('⚠️ Not found: $path');
      continue;
    }

    final bytes = file.readAsBytesSync();
    final original = img.decodePng(bytes);
    if (original == null) {
      print('⚠️ Cannot decode: $path');
      continue;
    }

    final resized = original.width > maxWidth
        ? img.copyResize(original, width: maxWidth)
        : original;

    final compressed = img.encodePng(resized, level: 9);
    final outPath = path.replaceAll('.png', '_compressed.png');
    File(outPath).writeAsBytesSync(compressed);

    final ratio = (compressed.length / bytes.length * 100).toStringAsFixed(1);
    print('✅ $path: ${_kb(bytes.length)} → ${_kb(compressed.length)} ($ratio%)');
  }
}

String _kb(int bytes) => '${(bytes / 1024).toStringAsFixed(0)}KB';
