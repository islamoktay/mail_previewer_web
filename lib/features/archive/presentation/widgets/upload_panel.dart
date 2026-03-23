import 'package:flutter/material.dart';
import 'package:mail_previewer_web/app/theme/app_colors.dart';

class UploadPanel extends StatelessWidget {
  const UploadPanel({
    super.key,
    required this.onChooseFile,
    required this.isCompact,
    required this.isDragActive,
    required this.isImporting,
  });

  final Future<void> Function() onChooseFile;
  final bool isCompact;
  final bool isDragActive;
  final bool isImporting;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _CompactUploadPanel(
        onChooseFile: onChooseFile,
        isDragActive: isDragActive,
        isImporting: isImporting,
      );
    }

    return _ExpandedUploadPanel(
      onChooseFile: onChooseFile,
      isDragActive: isDragActive,
      isImporting: isImporting,
    );
  }
}

class _ExpandedUploadPanel extends StatelessWidget {
  const _ExpandedUploadPanel({
    required this.onChooseFile,
    required this.isDragActive,
    required this.isImporting,
  });

  final Future<void> Function() onChooseFile;
  final bool isDragActive;
  final bool isImporting;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 140),
      opacity: isImporting ? 0.66 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isDragActive
              ? const Color(0xFFF7FAFC)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x142A3439),
              blurRadius: 24,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.cloud_upload_rounded,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isDragActive
                  ? 'Drop .msg files to archive them'
                  : 'Drag and drop .msg files',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'or click to browse your local storage',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 22),
            _UploadButton(
              onChooseFile: onChooseFile,
              isImporting: isImporting,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactUploadPanel extends StatelessWidget {
  const _CompactUploadPanel({
    required this.onChooseFile,
    required this.isDragActive,
    required this.isImporting,
  });

  final Future<void> Function() onChooseFile;
  final bool isDragActive;
  final bool isImporting;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 140),
      opacity: isImporting ? 0.54 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isDragActive ? const Color(0xFFF7FAFC) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: isImporting ? null : onChooseFile,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 280;

                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _CompactUploadCopy(
                          isDragActive: isDragActive,
                          isImporting: isImporting,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isImporting ? 'Importing...' : 'Choose files',
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _CompactUploadCopy(
                          isDragActive: isDragActive,
                          isImporting: isImporting,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          isImporting ? 'Importing...' : 'Choose files',
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactUploadCopy extends StatelessWidget {
  const _CompactUploadCopy({
    required this.isDragActive,
    required this.isImporting,
  });

  final bool isDragActive;
  final bool isImporting;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isImporting
              ? 'Importing archived messages'
              : isDragActive
              ? 'Drop .msg files here'
              : 'Add another archived message',
          style: textTheme.titleSmall?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isImporting
              ? 'Please wait while the selected files are added'
              : 'Drag and drop or browse locally',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _UploadButton extends StatelessWidget {
  const _UploadButton({
    required this.onChooseFile,
    required this.isImporting,
  });

  final Future<void> Function() onChooseFile;
  final bool isImporting;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDim],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isImporting ? null : onChooseFile,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Text(
              isImporting ? 'Importing...' : 'Choose File',
              style: textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
