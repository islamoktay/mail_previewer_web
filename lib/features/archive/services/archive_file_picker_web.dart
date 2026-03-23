// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;

import 'package:mail_previewer_web/features/archive/services/archive_html_file_reader_web.dart';
import 'package:mail_previewer_web/features/archive/services/picked_archive_file.dart';

Future<List<PickedArchiveFile>> pickArchiveFiles() {
  final completer = Completer<List<PickedArchiveFile>>();
  final input = html.FileUploadInputElement()
    ..accept = '.msg'
    ..multiple = true;

  input.onChange.first.then((_) async {
    final files = input.files;
    if (files == null || files.isEmpty) {
      completer.complete(const []);
      return;
    }

    completer.complete(readArchiveHtmlFiles(files));
  });

  input.click();
  return completer.future;
}
