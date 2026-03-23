// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/widgets.dart';
import 'package:mail_previewer_web/features/archive/presentation/widgets/upload_drop_region.dart';
import 'package:mail_previewer_web/features/archive/services/archive_html_file_reader_web.dart';
import 'package:mail_previewer_web/features/archive/services/picked_archive_file.dart';

Widget buildUploadDropRegionImpl({
  required UploadDropRegionBuilder builder,
  required Future<void> Function(Iterable<PickedArchiveFile>) onFilesDropped,
  required ValueChanged<bool> onPageDragActiveChanged,
  required VoidCallback onDropError,
}) {
  return _WebUploadDropRegion(
    builder: builder,
    onFilesDropped: onFilesDropped,
    onPageDragActiveChanged: onPageDragActiveChanged,
    onDropError: onDropError,
  );
}

class _WebUploadDropRegion extends StatefulWidget {
  const _WebUploadDropRegion({
    required this.builder,
    required this.onFilesDropped,
    required this.onPageDragActiveChanged,
    required this.onDropError,
  });

  final UploadDropRegionBuilder builder;
  final Future<void> Function(Iterable<PickedArchiveFile>) onFilesDropped;
  final ValueChanged<bool> onPageDragActiveChanged;
  final VoidCallback onDropError;

  @override
  State<_WebUploadDropRegion> createState() => _WebUploadDropRegionState();
}

class _WebUploadDropRegionState extends State<_WebUploadDropRegion> {
  final GlobalKey _regionKey = GlobalKey();
  late final StreamSubscription<html.MouseEvent> _dragEnterSubscription;
  late final StreamSubscription<html.MouseEvent> _dragOverSubscription;
  late final StreamSubscription<html.MouseEvent> _dropSubscription;
  late final StreamSubscription<html.Event> _dragLeaveSubscription;
  int _pageDragDepth = 0;
  bool _isDragActive = false;

  @override
  void initState() {
    super.initState();
    _dragEnterSubscription = html.document.onDragEnter.listen(_handleDragEnter);
    _dragOverSubscription = html.document.onDragOver.listen(_handleDragOver);
    _dropSubscription = html.document.onDrop.listen(_handleDrop);
    _dragLeaveSubscription = html.document.onDragLeave.listen(_handleDragLeave);
  }

  @override
  void dispose() {
    widget.onPageDragActiveChanged(false);
    _dragEnterSubscription.cancel();
    _dragOverSubscription.cancel();
    _dropSubscription.cancel();
    _dragLeaveSubscription.cancel();
    super.dispose();
  }

  void _handleDragEnter(html.MouseEvent event) {
    if (!_containsFiles(event.dataTransfer)) {
      return;
    }

    event.preventDefault();
    _pageDragDepth += 1;
    _setPageDragActive(true);
    _updateDropRegionState(
      event.client.x.toDouble(),
      event.client.y.toDouble(),
    );
  }

  void _handleDragOver(html.MouseEvent event) {
    if (!_containsFiles(event.dataTransfer)) {
      return;
    }

    event.preventDefault();
    event.dataTransfer.dropEffect = 'copy';
    _setPageDragActive(true);
    _updateDropRegionState(
      event.client.x.toDouble(),
      event.client.y.toDouble(),
    );
  }

  Future<void> _handleDrop(html.MouseEvent event) async {
    if (!_containsFiles(event.dataTransfer)) {
      return;
    }

    event.preventDefault();
    _pageDragDepth = 0;
    _setPageDragActive(false);
    final isInside =
        _isPointerInside(event.client.x.toDouble(), event.client.y.toDouble());

    if (mounted && _isDragActive) {
      setState(() {
        _isDragActive = false;
      });
    }

    if (!isInside) {
      return;
    }

    final fileList = event.dataTransfer.files;
    if (fileList == null || fileList.isEmpty) {
      return;
    }

    try {
      final pickedFiles = await readArchiveHtmlFiles(fileList);
      if (pickedFiles.isEmpty) {
        return;
      }

      await widget.onFilesDropped(
        <PickedArchiveFile>[for (final file in pickedFiles) file],
      );
    } catch (_) {
      widget.onDropError();
    }
  }

  void _handleDragLeave(html.Event event) {
    if (_pageDragDepth > 0) {
      _pageDragDepth -= 1;
    }

    if (_pageDragDepth == 0) {
      _setPageDragActive(false);
      if (mounted && _isDragActive) {
        setState(() {
          _isDragActive = false;
        });
      }
    }
  }

  void _setPageDragActive(bool isActive) {
    widget.onPageDragActiveChanged(isActive);
  }

  void _updateDropRegionState(double clientX, double clientY) {
    final isInside = _isPointerInside(clientX, clientY);
    if (isInside != _isDragActive && mounted) {
      setState(() {
        _isDragActive = isInside;
      });
    }
  }

  bool _isPointerInside(double clientX, double clientY) {
    final renderObject = _regionKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return false;
    }

    final topLeft = renderObject.localToGlobal(Offset.zero);
    final rect = topLeft & renderObject.size;
    return rect.contains(Offset(clientX, clientY));
  }

  bool _containsFiles(html.DataTransfer? dataTransfer) {
    final types = dataTransfer?.types;
    if (types == null) {
      return false;
    }
    return types.contains('Files');
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _regionKey,
      child: widget.builder(context, _isDragActive),
    );
  }
}
