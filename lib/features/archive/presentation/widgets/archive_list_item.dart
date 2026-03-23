import 'package:flutter/material.dart';
import 'package:mail_previewer_web/app/theme/app_colors.dart';
import 'package:mail_previewer_web/features/archive/models/msg_archive_item.dart';

class ArchiveListItem extends StatefulWidget {
  const ArchiveListItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.onRemove,
  });

  final MsgArchiveItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  State<ArchiveListItem> createState() => _ArchiveListItemState();
}

class _ArchiveListItemState extends State<ArchiveListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final backgroundColor = widget.isSelected
        ? AppColors.surfaceContainerLowest
        : const Color(0xFFF4F7F9);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: widget.onTap,
          child: Ink(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: widget.isSelected
                  ? const [
                      BoxShadow(
                        color: Color(0x122A3439),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.item.summary.subject,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: widget.isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        if (widget.item.summary.attachmentNames.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.attach_file_rounded,
                            size: 18,
                            color: widget.isSelected
                                ? AppColors.primary
                                : AppColors.onSurfaceVariant.withValues(
                                    alpha: 0.6,
                                  ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.item.summary.senderName,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.item.summary.sentAtLabel,
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            widget.item.fileSizeLabel,
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: IgnorePointer(
                    ignoring: !_isHovered,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 140),
                      opacity: _isHovered ? 1 : 0,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: widget.onRemove,
                          child: Ink(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
