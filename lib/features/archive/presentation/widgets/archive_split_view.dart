import 'package:flutter/material.dart';
import 'package:mail_previewer_web/app/theme/app_colors.dart';
import 'package:mail_previewer_web/features/archive/presentation/widgets/archive_list.dart';
import 'package:mail_previewer_web/features/archive/presentation/widgets/empty_preview.dart';
import 'package:mail_previewer_web/features/archive/presentation/widgets/message_preview.dart';
import 'package:mail_previewer_web/features/archive/presentation/widgets/upload_panel.dart';
import 'package:mail_previewer_web/features/archive/state/archive_controller.dart';

class ArchiveSplitView extends StatelessWidget {
  const ArchiveSplitView({
    super.key,
    required this.controller,
    required this.onPickFiles,
    required this.isDragActive,
  });

  final ArchiveController controller;
  final Future<void> Function() onPickFiles;
  final bool isDragActive;

  @override
  Widget build(BuildContext context) {
    final selectedItem = controller.selectedItem;
    final hasFilteredNoResults =
        controller.state.hasActiveSearch && controller.items.isEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 2,
          child: _SidebarContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UploadPanel(
                  onChooseFile: onPickFiles,
                  isCompact: controller.state.hasAnyItems,
                  isDragActive: isDragActive,
                  isImporting: controller.isImporting,
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: ArchiveList(
                    items: controller.items,
                    selectedItemId: controller.selectedItemId,
                    hasActiveSearch: controller.state.hasActiveSearch,
                    onSelect: controller.selectItem,
                    onRemove: (itemId) {
                      controller.removeItem(itemId);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 3,
          child: selectedItem == null
              ? EmptyPreview(
                  title: hasFilteredNoResults
                      ? 'No message matches your search'
                      : 'No message selected',
                  subtitle: hasFilteredNoResults
                      ? 'Try a different search term to preview a message'
                      : 'Select a message to preview',
                )
              : MessagePreview(item: selectedItem),
        ),
      ],
    );
  }
}

class _SidebarContainer extends StatelessWidget {
  const _SidebarContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: child,
    );
  }
}
