import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mail_previewer_web/features/archive/services/archive_file_picker.dart';
import 'package:mail_previewer_web/features/archive/services/archive_storage_service.dart';
import 'package:mail_previewer_web/features/archive/models/msg_archive_item.dart';
import 'package:mail_previewer_web/features/archive/state/archive_state.dart';

class ArchiveController extends ChangeNotifier {
  ArchiveController({ArchiveStorageService? storageService})
      : _storageService = storageService ?? ArchiveStorageService() {
    final items = _storageService.loadItems();
    _state = ArchiveState(
      allItems: items,
      selectedItemId: items.isEmpty ? null : items.first.id,
      isInitializing: true,
      isImporting: false,
      isPageDragActive: false,
      latestImportError: null,
      searchQuery: '',
    );
  }

  final ArchiveStorageService _storageService;
  late ArchiveState _state;

  ArchiveState get state => _state;
  List<MsgArchiveItem> get items => _state.items;
  String? get selectedItemId => _state.selectedItemId;
  MsgArchiveItem? get selectedItem => _state.selectedItem;
  bool get isInitializing => _state.isInitializing;
  bool get isImporting => _state.isImporting;
  bool get isPageDragActive => _state.isPageDragActive;
  String? get latestImportError => _state.latestImportError;

  Future<void> initialize() async {
    final restoredSelectedItemId =
        await _storageService.restorePersistedItems();
    final restoredItems = _storageService.loadItems();

    _state = _state.copyWith(
      allItems: restoredItems,
      selectedItemId: _resolvedVisibleSelection(
        allItems: restoredItems,
        preferredItemId: restoredSelectedItemId,
        searchQuery: _state.searchQuery,
      ),
      isInitializing: false,
    );
    notifyListeners();
  }

  Future<void> addPickedFiles(Iterable<PickedArchiveFile> files) async {
    if (_state.isImporting) {
      return;
    }

    final normalizedFiles = <PickedArchiveFile>[for (final file in files) file];
    if (normalizedFiles.isEmpty) {
      return;
    }

    _state = _state.copyWith(
      isImporting: true,
      isPageDragActive: false,
      latestImportError: null,
    );
    notifyListeners();

    try {
      final newItems = await _storageService.addPickedFiles(normalizedFiles);
      if (newItems.isEmpty) {
        _state = _state.copyWith(isImporting: false);
        notifyListeners();
        return;
      }

      final updatedItems = _storageService.loadItems();
      final nextSelectedItemId = _resolvedVisibleSelection(
        allItems: updatedItems,
        preferredItemId: newItems.last.id,
        searchQuery: _state.searchQuery,
      );

      _state = _state.copyWith(
        allItems: updatedItems,
        selectedItemId: nextSelectedItemId,
        isImporting: false,
        latestImportError: null,
      );
      await _storageService.saveSelectedItemId(nextSelectedItemId);
      notifyListeners();
    } catch (_) {
      _state = _state.copyWith(
        isImporting: false,
        latestImportError: _defaultImportError,
      );
      notifyListeners();
    }
  }

  void selectItem(String itemId) {
    if (itemId == _state.selectedItemId) {
      return;
    }

    _state = _state.copyWith(selectedItemId: itemId);
    unawaited(_storageService.saveSelectedItemId(itemId));
    notifyListeners();
  }

  Future<void> removeItem(String itemId) async {
    final currentItems = _state.items;
    final removedIndex = currentItems.indexWhere((item) => item.id == itemId);
    if (removedIndex == -1) {
      return;
    }

    final wasSelected = _state.selectedItemId == itemId;
    await _storageService.removeItem(itemId);
    final updatedItems = _storageService.loadItems();
    final visibleUpdatedItems = _filterItems(
      items: updatedItems,
      searchQuery: _state.searchQuery,
    );
    final nextSelectedItemId = wasSelected
        ? _nextSelectedItemIdAfterRemoval(
            previousItems: currentItems,
            updatedItems: visibleUpdatedItems,
            removedIndex: removedIndex,
          )
        : _resolvedVisibleSelection(
            allItems: updatedItems,
            preferredItemId: _state.selectedItemId,
            searchQuery: _state.searchQuery,
          );

    _state = _state.copyWith(
      allItems: updatedItems,
      selectedItemId: nextSelectedItemId,
    );
    await _storageService.saveSelectedItemId(nextSelectedItemId);
    notifyListeners();
  }

  void setPageDragActive(bool isActive) {
    if (_state.isPageDragActive == isActive) {
      return;
    }

    _state = _state.copyWith(isPageDragActive: isActive);
    notifyListeners();
  }

  void setImportError([String? message]) {
    final nextMessage = message ?? _defaultImportError;
    if (_state.latestImportError == nextMessage) {
      return;
    }

    _state = _state.copyWith(latestImportError: nextMessage);
    notifyListeners();
  }

  void clearImportError() {
    if (_state.latestImportError == null) {
      return;
    }

    _state = _state.copyWith(latestImportError: null);
    notifyListeners();
  }

  static const String _defaultImportError =
      'Could not import file. Please try again with a valid .msg file.';

  void updateSearchQuery(String value) {
    if (value == _state.searchQuery) {
      return;
    }

    _state = _state.copyWith(
      searchQuery: value,
      selectedItemId: _resolvedVisibleSelection(
        allItems: _state.allItems,
        preferredItemId: _state.selectedItemId,
        searchQuery: value,
      ),
    );
    notifyListeners();
  }

  String? _resolvedVisibleSelection({
    required List<MsgArchiveItem> allItems,
    required String? preferredItemId,
    required String searchQuery,
  }) {
    final visibleItems = _filterItems(
      items: allItems,
      searchQuery: searchQuery,
    );
    if (visibleItems.isEmpty) {
      return null;
    }

    if (preferredItemId != null &&
        visibleItems.any((item) => item.id == preferredItemId)) {
      return preferredItemId;
    }
    return visibleItems.first.id;
  }

  String? _nextSelectedItemIdAfterRemoval({
    required List<MsgArchiveItem> previousItems,
    required List<MsgArchiveItem> updatedItems,
    required int removedIndex,
  }) {
    if (updatedItems.isEmpty) {
      return null;
    }

    if (removedIndex < previousItems.length - 1) {
      final nextItemId = previousItems[removedIndex + 1].id;
      if (updatedItems.any((item) => item.id == nextItemId)) {
        return nextItemId;
      }
    }

    return null;
  }

  List<MsgArchiveItem> _filterItems({
    required List<MsgArchiveItem> items,
    required String searchQuery,
  }) {
    final normalizedQuery = _normalizeSearchQuery(searchQuery);
    if (normalizedQuery.isEmpty) {
      return items;
    }

    return items
        .where((item) => item.searchableText.contains(normalizedQuery))
        .toList(growable: false);
  }

  String _normalizeSearchQuery(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
