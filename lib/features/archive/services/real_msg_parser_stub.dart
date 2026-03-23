import 'package:mail_previewer_web/features/archive/services/mock_msg_parser.dart';
import 'package:mail_previewer_web/features/archive/services/msg_parser.dart';

MsgParser createPlatformMsgParser() {
  return const MockMsgParser();
}
