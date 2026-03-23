import 'dart:math';

import 'package:mail_previewer_web/features/archive/models/msg_archive_item.dart';
import 'package:mail_previewer_web/features/archive/services/archive_file_picker.dart';
import 'package:mail_previewer_web/features/archive/services/archive_persistence_store.dart';
import 'package:mail_previewer_web/features/archive/services/msg_parser.dart';
import 'package:mail_previewer_web/features/archive/services/real_msg_parser.dart';

class ArchiveStorageService {
  ArchiveStorageService({
    MsgParser? parser,
    ArchivePersistenceStore? persistenceStore,
  })  : _parser = parser ?? createMsgParser(),
        _persistenceStore = persistenceStore ?? createArchivePersistenceStore();

  final MsgParser _parser;
  final ArchivePersistenceStore _persistenceStore;
  late final List<MsgArchiveItem> _seedItems = _buildSeedItems();
  final List<MsgArchiveItem> _persistedItems = [];
  final Set<String> _hiddenSeedItemIds = <String>{};

  List<MsgArchiveItem> loadItems() {
    final visibleSeedItems = _seedItems
        .where((item) => !_hiddenSeedItemIds.contains(item.id))
        .toList(growable: false);
    final items = [
      ...visibleSeedItems,
      ..._persistedItems,
    ]..sort((a, b) {
        final archivedComparison = b.archivedAt.compareTo(a.archivedAt);
        if (archivedComparison != 0) {
          return archivedComparison;
        }
        return b.id.compareTo(a.id);
      });

    return List.unmodifiable(items);
  }

  Future<String?> restorePersistedItems() async {
    final persistedMaps = await _persistenceStore.loadArchiveItems();
    final hiddenSeedItemIds = await _persistenceStore.loadHiddenSeedItemIds();
    _hiddenSeedItemIds
      ..clear()
      ..addAll(hiddenSeedItemIds);
    _persistedItems
      ..clear()
      ..addAll(
        persistedMaps
            .map(MsgArchiveItem.fromMap)
            .where((item) => item.id.isNotEmpty),
      );
    return _persistenceStore.loadSelectedItemId();
  }

  Future<List<MsgArchiveItem>> addPickedFiles(
      Iterable<PickedArchiveFile> files) async {
    final createdItems = <MsgArchiveItem>[];
    for (final file in files) {
      createdItems.add(await _createItemFromPickedFile(file));
    }
    _persistedItems.addAll(createdItems);
    await _persistArchiveItems();
    return createdItems;
  }

  Future<void> removeItem(String itemId) async {
    final persistedLengthBefore = _persistedItems.length;
    _persistedItems.removeWhere((item) => item.id == itemId);
    final persistedItemRemoved =
        _persistedItems.length != persistedLengthBefore;
    if (persistedItemRemoved) {
      await _persistArchiveItems();
      return;
    }

    if (_seedItems.any((item) => item.id == itemId)) {
      _hiddenSeedItemIds.add(itemId);
      await _persistHiddenSeedItemIds();
    }
  }

  Future<void> saveSelectedItemId(String? selectedItemId) {
    return _persistenceStore.saveSelectedItemId(selectedItemId);
  }

  List<MsgArchiveItem> _buildSeedItems() {
    return const [];
  }

  Future<MsgArchiveItem> _createItemFromPickedFile(PickedArchiveFile file) async {
    final normalizedBaseName = _baseName(file.name);
    final now = DateTime.now();
    final fileSizeLabel = _formatFileSize(file.bytes.length);
    final summary = await _parser.parse(
      rawFileBytes: file.bytes,
      fileName: file.name,
      archivedAt: now,
    );

    return MsgArchiveItem(
      id: '${normalizedBaseName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}-${now.microsecondsSinceEpoch}-${Random().nextInt(9999)}',
      rawFileBytes: file.bytes,
      fileName: file.name,
      fileSizeBytes: file.bytes.length,
      fileSizeLabel: fileSizeLabel,
      archivedAt: now,
      archivedAtLabel: 'Archived ${_formatArchiveDate(now)}',
      summary: summary,
    );
  }

  Future<void> _persistArchiveItems() {
    return _persistenceStore.saveArchiveItems(
      _persistedItems.map((item) => item.toMap()).toList(growable: false),
    );
  }

  Future<void> _persistHiddenSeedItemIds() {
    return _persistenceStore.saveHiddenSeedItemIds(
      _hiddenSeedItemIds.toList(growable: false),
    );
  }

  String _baseName(String fileName) {
    final lowerName = fileName.toLowerCase();
    if (lowerName.endsWith('.msg')) {
      return fileName.substring(0, fileName.length - 4);
    }
    return fileName;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(bytes < 10 * 1024 ? 1 : 0)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatArchiveDate(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

}
