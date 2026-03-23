import 'dart:typed_data';

class PickedArchiveFile {
  const PickedArchiveFile({
    required this.name,
    required this.bytes,
  });

  final String name;
  final Uint8List bytes;
}
