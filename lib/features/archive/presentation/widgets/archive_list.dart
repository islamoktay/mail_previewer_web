import 'package:flutter/material.dart';
import 'package:mail_previewer_web/app/theme/app_colors.dart';
import 'package:mail_previewer_web/features/archive/models/msg_archive_item.dart';
import 'package:mail_previewer_web/features/archive/presentation/widgets/archive_list_item.dart';

class ArchiveList extends StatelessWidget {
  const ArchiveList({
    super.key,
    required this.items,
    required this.selectedItemId,
    required this.onSelect,
    required this.onRemove,
    required this.hasActiveSearch,
  });

  final List<MsgArchiveItem> items;
  final String? selectedItemId;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onRemove;
  final bool hasActiveSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'RECENT ARCHIVES',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: items.isEmpty
              ? _ArchiveListEmptyState(hasActiveSearch: hasActiveSearch)
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ArchiveListItem(
                      item: item,
                      isSelected: item.id == selectedItemId,
                      onTap: () => onSelect(item.id),
                      onRemove: () => onRemove(item.id),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ArchiveListEmptyState extends StatelessWidget {
  const _ArchiveListEmptyState({required this.hasActiveSearch});

  final bool hasActiveSearch;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 20, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hasActiveSearch
                  ? 'No matching messages found'
                  : 'No archived messages yet',
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasActiveSearch
                  ? 'Try a different search term'
                  : 'Upload a .msg file to get started',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
