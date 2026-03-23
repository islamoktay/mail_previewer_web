import 'package:flutter/widgets.dart';
import 'package:mail_previewer_web/features/archive/presentation/widgets/upload_drop_region.dart';
import 'package:mail_previewer_web/features/archive/services/picked_archive_file.dart';

Widget buildUploadDropRegionImpl({
  required UploadDropRegionBuilder builder,
  required Future<void> Function(Iterable<PickedArchiveFile>) onFilesDropped,
  required ValueChanged<bool> onPageDragActiveChanged,
  required VoidCallback onDropError,
}) {
  return Builder(
    builder: (context) => builder(context, false),
  );
}
