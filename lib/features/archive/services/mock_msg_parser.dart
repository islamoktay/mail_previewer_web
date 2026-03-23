import 'dart:typed_data';

import 'package:mail_previewer_web/features/archive/models/parsed_msg_summary.dart';
import 'package:mail_previewer_web/features/archive/services/msg_parser.dart';

class MockMsgParser implements MsgParser {
  const MockMsgParser();

  @override
  Future<ParsedMsgSummary> parse({
    required Uint8List rawFileBytes,
    required String fileName,
    required DateTime archivedAt,
  }) {
    final baseName = _baseName(fileName);
    final displayTitle = _displayTitle(baseName);

    return Future.value(
      ParsedMsgSummary(
        subject: displayTitle,
        senderName: 'Mock Sender',
        senderEmail: 'mock.sender@local.archive',
        sentAtLabel: _formatSentAt(archivedAt),
        recipientsLabel: 'Local Preview',
        attachmentNames: const [],
        bodyPreview: 'Mock preview generated for $displayTitle.',
        bodyParagraphs: [
          'This is a mock preview for $displayTitle.',
          'The selected file has been loaded into the in-memory archive flow without attempting real .msg parsing.',
          'Raw file bytes are available in memory for future parsing and storage work.',
        ],
      ),
    );
  }

  String _baseName(String fileName) {
    final lowerName = fileName.toLowerCase();
    if (lowerName.endsWith('.msg')) {
      return fileName.substring(0, fileName.length - 4);
    }
    return fileName;
  }

  String _displayTitle(String value) {
    return value
        .replaceAll(RegExp(r'[_\-]+'), ' ')
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String _formatSentAt(DateTime dateTime) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final meridiem = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '${weekdays[dateTime.weekday - 1]}, ${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} at $hour:$minute $meridiem';
  }
}
