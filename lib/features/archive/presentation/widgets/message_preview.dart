import 'package:flutter/material.dart';
import 'package:mail_previewer_web/app/theme/app_colors.dart';
import 'package:mail_previewer_web/features/archive/models/msg_archive_item.dart';
import 'package:mail_previewer_web/features/archive/presentation/widgets/attachment_chip.dart';
import 'package:mail_previewer_web/features/archive/presentation/widgets/preview_metadata.dart';

class MessagePreview extends StatelessWidget {
  const MessagePreview({super.key, required this.item});

  final MsgArchiveItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth > 900 ? 56.0 : 36.0;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                horizontalPadding, 40, horizontalPadding, 56),
            child: Align(
              alignment: Alignment.topLeft,
              child: SelectionArea(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.summary.subject,
                        style: textTheme.headlineLarge?.copyWith(
                          fontSize: 42,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 32),
                      PreviewMetadata(
                        label: 'From',
                        child: PreviewSenderDetails(summary: item.summary),
                      ),
                      const SizedBox(height: 18),
                      PreviewMetadata(
                        label: 'To',
                        child: Text(
                          item.summary.recipientsLabel,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      PreviewMetadata(
                        label: 'Date',
                        child: Text(
                          item.summary.sentAtLabel,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      PreviewMetadata(
                        label: 'Attachments',
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: item.summary.attachmentNames
                              .map((attachment) =>
                                  AttachmentChip(attachment: attachment))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(0, 28, 0, 0),
                        child: DefaultTextStyle(
                          style: textTheme.bodyLarge?.copyWith(
                                color: AppColors.onSurfaceVariant,
                                height: 1.85,
                              ) ??
                              const TextStyle(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final paragraph
                                  in item.summary.bodyParagraphs) ...[
                                Text(paragraph),
                                const SizedBox(height: 18),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
