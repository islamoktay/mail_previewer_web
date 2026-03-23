import 'dart:typed_data';

import 'package:mail_previewer_web/features/archive/models/parsed_msg_summary.dart';

class MsgArchiveItem {
  const MsgArchiveItem({
    required this.id,
    required this.rawFileBytes,
    required this.fileName,
    required this.fileSizeBytes,
    required this.fileSizeLabel,
    required this.archivedAt,
    required this.archivedAtLabel,
    required this.summary,
  });

  final String id;
  final Uint8List rawFileBytes;
  final String fileName;
  final int fileSizeBytes;
  final String fileSizeLabel;
  final DateTime archivedAt;
  final String archivedAtLabel;
  final ParsedMsgSummary summary;

  String get searchableText {
    return _normalizeSearchValue([
      fileName,
      summary.subject,
      summary.senderName,
      summary.senderEmail,
      summary.recipientsLabel,
      summary.bodyPreview,
      ...summary.attachmentNames,
      ...summary.bodyParagraphs,
    ].join(' '));
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'rawFileBytes': rawFileBytes.toList(growable: false),
      'fileName': fileName,
      'fileSizeBytes': fileSizeBytes,
      'fileSizeLabel': fileSizeLabel,
      'archivedAt': archivedAt.toIso8601String(),
      'archivedAtLabel': archivedAtLabel,
      'summary': summary.toMap(),
    };
  }

  factory MsgArchiveItem.fromMap(Map<String, Object?> map) {
    return MsgArchiveItem(
      id: map['id'] as String? ?? '',
      rawFileBytes: _toBytes(map['rawFileBytes']),
      fileName: map['fileName'] as String? ?? '',
      fileSizeBytes: map['fileSizeBytes'] as int? ?? 0,
      fileSizeLabel: map['fileSizeLabel'] as String? ?? '',
      archivedAt: DateTime.tryParse(map['archivedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      archivedAtLabel: map['archivedAtLabel'] as String? ?? '',
      summary: ParsedMsgSummary.fromMap(
        (map['summary'] as Map?)?.cast<String, Object?>() ?? const {},
      ),
    );
  }

  static Uint8List _toBytes(Object? value) {
    if (value is Uint8List) {
      return value;
    }
    if (value is List<int>) {
      return Uint8List.fromList(value);
    }
    if (value is List) {
      return Uint8List.fromList(
        value.map((item) => (item as num).toInt()).toList(growable: false),
      );
    }

    return Uint8List(0);
  }

  static String _normalizeSearchValue(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
