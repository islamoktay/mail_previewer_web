// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:mail_previewer_web/features/archive/services/picked_archive_file.dart';

Future<List<PickedArchiveFile>> readArchiveHtmlFiles(
    Iterable<html.File> files) async {
  final pickedFiles = <PickedArchiveFile>[];

  for (final file in files) {
    if (!_isMsgFile(file.name)) {
      continue;
    }

    pickedFiles.add(
      PickedArchiveFile(
        name: file.name,
        bytes: await _readBytes(file),
      ),
    );
  }

  return pickedFiles;
}

bool _isMsgFile(String fileName) {
  return fileName.toLowerCase().endsWith('.msg');
}

Future<Uint8List> _readBytes(html.File file) {
  final completer = Completer<Uint8List>();
  final reader = html.FileReader();

  reader.onLoadEnd.first.then((_) {
    final result = reader.result;
    if (result is Uint8List) {
      completer.complete(result);
      return;
    }
    if (result is List<int>) {
      completer.complete(Uint8List.fromList(result));
      return;
    }
    if (result is ByteBuffer) {
      completer.complete(result.asUint8List());
      return;
    }
    completer.complete(Uint8List(0));
  });

  reader.onError.first.then((_) {
    completer.completeError(reader.error ?? Exception('File read failed.'));
  });

  reader.readAsArrayBuffer(file);
  return completer.future;
}
