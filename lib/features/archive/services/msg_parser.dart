import 'dart:typed_data';

import 'package:mail_previewer_web/features/archive/models/parsed_msg_summary.dart';

abstract class MsgParser {
  Future<ParsedMsgSummary> parse({
    required Uint8List rawFileBytes,
    required String fileName,
    required DateTime archivedAt,
  });
}
