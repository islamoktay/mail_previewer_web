import 'package:mail_previewer_web/features/archive/services/msg_parser.dart';
import 'package:mail_previewer_web/features/archive/services/real_msg_parser_stub.dart'
    if (dart.library.html) 'package:mail_previewer_web/features/archive/services/real_msg_parser_web.dart'
    as real_msg_parser;

MsgParser createMsgParser() {
  return real_msg_parser.createPlatformMsgParser();
}
