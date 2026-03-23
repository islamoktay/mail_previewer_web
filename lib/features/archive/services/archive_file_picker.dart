import 'archive_file_picker_stub.dart'
    if (dart.library.html) 'archive_file_picker_web.dart'
    as archive_file_picker;
import 'package:mail_previewer_web/features/archive/services/picked_archive_file.dart';

export 'package:mail_previewer_web/features/archive/services/picked_archive_file.dart';

Future<List<PickedArchiveFile>> pickArchiveFiles() {
  return archive_file_picker.pickArchiveFiles();
}
