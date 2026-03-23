import 'upload_drop_region_stub.dart'
    if (dart.library.html) 'upload_drop_region_web.dart';

import 'package:flutter/widgets.dart';
import 'package:mail_previewer_web/features/archive/services/picked_archive_file.dart';

typedef UploadDropRegionBuilder = Widget Function(
  BuildContext context,
  bool isDragActive,
);

Widget buildUploadDropRegion({
  required UploadDropRegionBuilder builder,
  required Future<void> Function(Iterable<PickedArchiveFile>) onFilesDropped,
  required ValueChanged<bool> onPageDragActiveChanged,
  required VoidCallback onDropError,
}) {
  return buildUploadDropRegionImpl(
    builder: builder,
    onFilesDropped: onFilesDropped,
    onPageDragActiveChanged: onPageDragActiveChanged,
    onDropError: onDropError,
  );
}
