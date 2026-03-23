import 'package:flutter/material.dart';
import 'package:mail_previewer_web/app/theme/app_colors.dart';
import 'package:mail_previewer_web/features/archive/presentation/widgets/archive_activity_overlay.dart';
import 'package:mail_previewer_web/features/archive/presentation/widgets/archive_split_view.dart';
import 'package:mail_previewer_web/features/archive/presentation/widgets/archive_top_bar.dart';
import 'package:mail_previewer_web/features/archive/presentation/widgets/upload_drop_region.dart';
import 'package:mail_previewer_web/features/archive/services/archive_file_picker.dart';
import 'package:mail_previewer_web/features/archive/state/archive_controller.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  late final ArchiveController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ArchiveController()..addListener(_handleControllerChanged);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    setState(() {});
  }

  Future<void> _handlePickFiles() async {
    if (_controller.isImporting) {
      return;
    }

    try {
      final files = await pickArchiveFiles();
      if (!mounted || files.isEmpty) {
        return;
      }

      await _controller.addPickedFiles(files);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _controller.setImportError();
    }
  }

  Future<void> _handleImportFiles(Iterable<PickedArchiveFile> files) {
    return _controller.addPickedFiles(
      <PickedArchiveFile>[for (final file in files) file],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ColoredBox(
              color: AppColors.surface,
              child: AbsorbPointer(
                absorbing: _controller.isInitializing || _controller.isImporting,
                child: Column(
                  children: [
                    ArchiveTopBar(
                      searchQuery: _controller.state.searchQuery,
                      onSearchChanged: _controller.updateSearchQuery,
                    ),
                    Expanded(
                      child: buildUploadDropRegion(
                        onFilesDropped: _handleImportFiles,
                        onPageDragActiveChanged: _controller.setPageDragActive,
                        onDropError: _controller.setImportError,
                        builder: (context, isDragActive) => Padding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                          child: ArchiveSplitView(
                            controller: _controller,
                            onPickFiles: _handlePickFiles,
                            isDragActive: isDragActive,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_controller.isPageDragActive && !_controller.isImporting)
              const ArchiveActivityOverlay(
                title: 'Drop .msg files to archive them',
                subtitle:
                    'Release the files to add them to your local message archive.',
              ),
            if (_controller.isInitializing)
              const ArchiveActivityOverlay(
                title: 'Loading archived messages',
                subtitle:
                    'Restoring your local archive from this browser.',
                showProgress: true,
                absorbPointer: true,
              ),
            if (_controller.isImporting)
              const ArchiveActivityOverlay(
                title: 'Importing archived messages',
                subtitle:
                    'Your selected files are being added to the local archive.',
                showProgress: true,
                absorbPointer: true,
              ),
            if (_controller.latestImportError != null && !_controller.isImporting)
              ArchiveActivityNotice(
                message: _controller.latestImportError!,
              ),
          ],
        ),
      ),
    );
  }
}
