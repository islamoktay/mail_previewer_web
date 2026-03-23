import 'package:flutter/material.dart';
import 'package:mail_previewer_web/app/theme/app_colors.dart';

class AttachmentChip extends StatelessWidget {
  const AttachmentChip({super.key, required this.attachment});

  final String attachment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.description_outlined,
            size: 16,
            color: AppColors.onSurface,
          ),
          const SizedBox(width: 8),
          Text(
            attachment,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
