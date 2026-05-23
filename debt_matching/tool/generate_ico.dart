// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Converts app_icon.png to app_icon.ico (multi-resolution: 16, 32, 48, 256)
void main() {
  final src = File('../assets/app_icon.png');
  if (!src.existsSync()) {
    print('⚠️ ../assets/app_icon.png not found');
    return;
  }

  final original = img.decodePng(src.readAsBytesSync())!;
  const sizes = [16, 32, 48, 256];
  final pngEntries = <Uint8List>[];

  for (final size in sizes) {
    final resized = img.copyResize(original, width: size, height: size);
    pngEntries.add(Uint8List.fromList(img.encodePng(resized)));
  }

  // Build ICO file
  final ico = _buildIco(pngEntries, sizes);
  final out = File('windows/runner/resources/app_icon.ico');
  out.writeAsBytesSync(ico);
  print('✅ Generated ${out.path} (${(ico.length / 1024).toStringAsFixed(1)}KB) with sizes: $sizes');
}

Uint8List _buildIco(List<Uint8List> pngEntries, List<int> sizes) {
  // ICO header: 6 bytes
  // Each entry: 16 bytes
  // Then PNG data
  final headerSize = 6 + 16 * pngEntries.length;
  var offset = headerSize;

  final buffer = BytesBuilder();
  // Header
  buffer.add([0, 0]); // reserved
  buffer.add([1, 0]); // type: ICO
  buffer.add([pngEntries.length & 0xFF, (pngEntries.length >> 8) & 0xFF]); // count

  // Directory entries
  for (int i = 0; i < pngEntries.length; i++) {
    final size = sizes[i];
    final data = pngEntries[i];
    buffer.addByte(size == 256 ? 0 : size); // width (0 = 256)
    buffer.addByte(size == 256 ? 0 : size); // height
    buffer.addByte(0); // color palette
    buffer.addByte(0); // reserved
    buffer.add([1, 0]); // color planes
    buffer.add([32, 0]); // bits per pixel
    // data size (4 bytes LE)
    buffer.add([data.length & 0xFF, (data.length >> 8) & 0xFF,
                (data.length >> 16) & 0xFF, (data.length >> 24) & 0xFF]);
    // offset (4 bytes LE)
    buffer.add([offset & 0xFF, (offset >> 8) & 0xFF,
                (offset >> 16) & 0xFF, (offset >> 24) & 0xFF]);
    offset += data.length;
  }

  // PNG data
  for (final data in pngEntries) {
    buffer.add(data);
  }

  return buffer.toBytes();
}
