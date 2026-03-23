import 'package:mail_previewer_web/features/archive/models/msg_archive_item.dart';

class ArchiveState {
  const ArchiveState({
    required this.allItems,
    required this.selectedItemId,
    required this.isInitializing,
    required this.isImporting,
    required this.isPageDragActive,
    required this.latestImportError,
    required this.searchQuery,
  });

  static const Object _selectedItemIdSentinel = Object();

  final List<MsgArchiveItem> allItems;
  final String? selectedItemId;
  final bool isInitializing;
  final bool isImporting;
  final bool isPageDragActive;
  final String? latestImportError;
  final String searchQuery;

  List<MsgArchiveItem> get items {
    final normalizedQuery = _normalizeSearchQuery(searchQuery);
    if (normalizedQuery.isEmpty) {
      return allItems;
    }

    return allItems
        .where((item) => item.searchableText.contains(normalizedQuery))
        .toList(growable: false);
  }

  bool get hasActiveSearch => _normalizeSearchQuery(searchQuery).isNotEmpty;
  bool get hasAnyItems => allItems.isNotEmpty;
  bool get hasSearchResults => items.isNotEmpty;

  MsgArchiveItem? get selectedItem {
    if (selectedItemId == null) {
      return null;
    }

    for (final item in items) {
      if (item.id == selectedItemId) {
        return item;
      }
    }

    return null;
  }

  ArchiveState copyWith({
    List<MsgArchiveItem>? allItems,
    Object? selectedItemId = _selectedItemIdSentinel,
    bool? isInitializing,
    bool? isImporting,
    bool? isPageDragActive,
    Object? latestImportError = _selectedItemIdSentinel,
    String? searchQuery,
  }) {
    return ArchiveState(
      allItems: allItems ?? this.allItems,
      selectedItemId:
          identical(selectedItemId, _selectedItemIdSentinel)
              ? this.selectedItemId
              : selectedItemId as String?,
      isInitializing: isInitializing ?? this.isInitializing,
      isImporting: isImporting ?? this.isImporting,
      isPageDragActive: isPageDragActive ?? this.isPageDragActive,
      latestImportError:
          identical(latestImportError, _selectedItemIdSentinel)
              ? this.latestImportError
              : latestImportError as String?,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  static String _normalizeSearchQuery(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
