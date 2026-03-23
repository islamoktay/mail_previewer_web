class ParsedMsgSummary {
  const ParsedMsgSummary({
    required this.subject,
    required this.senderName,
    required this.senderEmail,
    required this.sentAtLabel,
    required this.recipientsLabel,
    required this.attachmentNames,
    required this.bodyPreview,
    required this.bodyParagraphs,
  });

  final String subject;
  final String senderName;
  final String senderEmail;
  final String sentAtLabel;
  final String recipientsLabel;
  final List<String> attachmentNames;
  final String bodyPreview;
  final List<String> bodyParagraphs;

  Map<String, Object?> toMap() {
    return {
      'subject': subject,
      'senderName': senderName,
      'senderEmail': senderEmail,
      'sentAtLabel': sentAtLabel,
      'recipientsLabel': recipientsLabel,
      'attachmentNames': attachmentNames,
      'bodyPreview': bodyPreview,
      'bodyParagraphs': bodyParagraphs,
    };
  }

  factory ParsedMsgSummary.fromMap(Map<String, Object?> map) {
    return ParsedMsgSummary(
      subject: map['subject'] as String? ?? '',
      senderName: map['senderName'] as String? ?? '',
      senderEmail: map['senderEmail'] as String? ?? '',
      sentAtLabel: map['sentAtLabel'] as String? ?? '',
      recipientsLabel: map['recipientsLabel'] as String? ?? '',
      attachmentNames: _toStringList(map['attachmentNames']),
      bodyPreview: map['bodyPreview'] as String? ?? '',
      bodyParagraphs: _toStringList(map['bodyParagraphs']),
    );
  }

  String get senderInitials {
    final parts =
        senderName.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) {
      return '';
    }
    if (parts.length == 1) {
      final first = parts.first;
      return first.substring(0, first.length >= 2 ? 2 : 1).toUpperCase();
    }

    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  static List<String> _toStringList(Object? value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList(growable: false);
    }

    return const [];
  }
}
