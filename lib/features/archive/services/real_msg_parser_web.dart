import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:mail_previewer_web/features/archive/models/parsed_msg_summary.dart';
import 'package:mail_previewer_web/features/archive/services/msg_parser.dart';

MsgParser createPlatformMsgParser() {
  return const RealMsgParserWeb();
}

class RealMsgParserWeb implements MsgParser {
  const RealMsgParserWeb();

  @override
  Future<ParsedMsgSummary> parse({
    required Uint8List rawFileBytes,
    required String fileName,
    required DateTime archivedAt,
  }) async {
    final parsedMap = await _parseArchiveSummary(rawFileBytes);
    final bodyText = _normalizeBodyText(parsedMap['bodyText'] as String?);
    final bodyParagraphs = _buildBodyParagraphs(bodyText);

    return ParsedMsgSummary(
      subject: _normalizeSubject(parsedMap['subject'] as String?, fileName),
      senderName: _normalizeSenderName(
        senderName: parsedMap['senderName'] as String?,
        senderEmail: parsedMap['senderEmail'] as String?,
      ),
      senderEmail: _normalizeSenderEmail(
        senderName: parsedMap['senderName'] as String?,
        senderEmail: parsedMap['senderEmail'] as String?,
      ),
      sentAtLabel: _normalizeSentAtLabel(
        parsedSentAt: parsedMap['sentAt'] as String?,
        archivedAt: archivedAt,
      ),
      recipientsLabel: _normalizeRecipients(
        parsedMap['recipients'] as String?,
      ),
      attachmentNames: _normalizeAttachmentNames(
        parsedMap['attachmentNames'],
      ),
      bodyPreview: _buildBodyPreview(bodyParagraphs),
      bodyParagraphs: bodyParagraphs,
    );
  }

  Future<Map<String, Object?>> _parseArchiveSummary(
    Uint8List rawFileBytes,
  ) async {
    final parserFunction = globalContext['parseMsgArchiveSummary'];
    if (parserFunction == null || !parserFunction.isA<JSFunction>()) {
      throw StateError('MSG parser bridge is unavailable.');
    }

    final result = await (parserFunction as JSFunction)
        .callAsFunction(
          globalContext,
          rawFileBytes.toJS,
        )
        .asJSPromise<JSAny?>()
        .toDart;
    final dartified = result.dartify();
    if (dartified is Map<Object?, Object?>) {
      return dartified.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    throw StateError('MSG parser returned an invalid result.');
  }

  String _normalizeSubject(String? subject, String fileName) {
    final normalized = _normalizeWhitespace(subject);
    if (normalized.isNotEmpty) {
      return normalized;
    }
    return _baseName(fileName);
  }

  String _normalizeSenderName({
    required String? senderName,
    required String? senderEmail,
  }) {
    final normalizedName = _normalizeWhitespace(senderName);
    final normalizedEmail = _normalizeWhitespace(senderEmail);

    if (normalizedName.isNotEmpty) {
      return normalizedName;
    }
    if (normalizedEmail.isNotEmpty) {
      return normalizedEmail;
    }
    return 'Unknown sender';
  }

  String _normalizeSenderEmail({
    required String? senderName,
    required String? senderEmail,
  }) {
    final normalizedName = _normalizeWhitespace(senderName);
    final normalizedEmail = _normalizeWhitespace(senderEmail);

    if (normalizedName.isNotEmpty && normalizedEmail.isNotEmpty) {
      return normalizedEmail;
    }
    return '';
  }

  String _normalizeRecipients(String? recipients) {
    return _normalizeWhitespace(recipients);
  }

  String _normalizeSentAtLabel({
    required String? parsedSentAt,
    required DateTime archivedAt,
  }) {
    final normalized = _normalizeWhitespace(parsedSentAt);
    final parsedDate = normalized.isEmpty ? null : DateTime.tryParse(normalized);
    if (parsedDate != null) {
      return _formatSentAt(parsedDate.toLocal());
    }
    if (normalized.isNotEmpty) {
      return normalized;
    }
    return _formatSentAt(archivedAt);
  }

  List<String> _normalizeAttachmentNames(Object? value) {
    if (value is! List) {
      return const [];
    }

    final seen = <String>{};
    final names = <String>[];
    for (final item in value) {
      final normalized = _normalizeWhitespace(item?.toString());
      if (normalized.isEmpty || !seen.add(normalized)) {
        continue;
      }
      names.add(normalized);
    }
    return List<String>.unmodifiable(names);
  }

  String _normalizeBodyText(String? bodyText) {
    final normalized = bodyText
            ?.replaceAll('\u0000', '')
            .replaceAll('\r\n', '\n')
            .replaceAll('\r', '\n')
            .trim() ??
        '';
    if (normalized.isNotEmpty) {
      return normalized;
    }
    return 'No message body available.';
  }

  List<String> _buildBodyParagraphs(String bodyText) {
    final paragraphs = bodyText
        .split(RegExp(r'\n\s*\n'))
        .map(
          (paragraph) => paragraph
              .split('\n')
              .map((line) => line.trim())
              .where((line) => line.isNotEmpty)
              .join(' '),
        )
        .where((paragraph) => paragraph.isNotEmpty)
        .toList(growable: false);

    if (paragraphs.isNotEmpty) {
      return paragraphs;
    }
    return const ['No message body available.'];
  }

  String _buildBodyPreview(List<String> bodyParagraphs) {
    final firstParagraph = bodyParagraphs.isEmpty ? '' : bodyParagraphs.first;
    if (firstParagraph.length <= 160) {
      return firstParagraph;
    }
    return '${firstParagraph.substring(0, 160).trimRight()}...';
  }

  String _normalizeWhitespace(String? value) {
    return value?.replaceAll(RegExp(r'\s+'), ' ').trim() ?? '';
  }

  String _baseName(String fileName) {
    final lowerName = fileName.toLowerCase();
    if (lowerName.endsWith('.msg')) {
      return fileName.substring(0, fileName.length - 4);
    }
    return fileName;
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

extension on JSAny? {
  JSPromise<T> asJSPromise<T extends JSAny?>() {
    return this! as JSPromise<T>;
  }
}
