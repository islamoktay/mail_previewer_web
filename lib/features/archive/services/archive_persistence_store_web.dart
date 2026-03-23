import 'package:idb_shim/idb_browser.dart';
import 'package:mail_previewer_web/features/archive/services/archive_persistence_store.dart';

const _databaseName = 'msg_archive_database';
const _databaseVersion = 1;
const _archiveItemsStoreName = 'archive_items';
const _metadataStoreName = 'archive_metadata';
const _selectedItemKey = 'selected_item_id';
const _hiddenSeedIdsKey = 'hidden_seed_item_ids';

class _IndexedDbArchivePersistenceStore implements ArchivePersistenceStore {
  Future<Database> get _database async {
    return idbFactoryBrowser.open(
      _databaseName,
      version: _databaseVersion,
      onUpgradeNeeded: (VersionChangeEvent event) {
        final database = event.database;
        if (!database.objectStoreNames.contains(_archiveItemsStoreName)) {
          database.createObjectStore(_archiveItemsStoreName, keyPath: 'id');
        }
        if (!database.objectStoreNames.contains(_metadataStoreName)) {
          database.createObjectStore(_metadataStoreName, keyPath: 'key');
        }
      },
    );
  }

  @override
  Future<List<Map<String, Object?>>> loadArchiveItems() async {
    final database = await _database;
    final transaction = database.transaction(
      _archiveItemsStoreName,
      idbModeReadOnly,
    );
    final store = transaction.objectStore(_archiveItemsStoreName);
    final items = await store.getAll();
    await transaction.completed;

    return items
        .whereType<Map>()
        .map((item) => item.cast<String, Object?>())
        .toList(growable: false);
  }

  @override
  Future<String?> loadSelectedItemId() async {
    final database = await _database;
    final transaction =
        database.transaction(_metadataStoreName, idbModeReadOnly);
    final store = transaction.objectStore(_metadataStoreName);
    final result = await store.getObject(_selectedItemKey);
    await transaction.completed;

    if (result is Map) {
      return result['value'] as String?;
    }

    return null;
  }

  @override
  Future<List<String>> loadHiddenSeedItemIds() async {
    final database = await _database;
    final transaction =
        database.transaction(_metadataStoreName, idbModeReadOnly);
    final store = transaction.objectStore(_metadataStoreName);
    final result = await store.getObject(_hiddenSeedIdsKey);
    await transaction.completed;

    if (result is Map && result['value'] is List) {
      return (result['value'] as List)
          .map((item) => item.toString())
          .toList(growable: false);
    }

    return const [];
  }

  @override
  Future<void> saveArchiveItems(List<Map<String, Object?>> items) async {
    final database = await _database;
    final transaction = database.transaction(
      _archiveItemsStoreName,
      idbModeReadWrite,
    );
    final store = transaction.objectStore(_archiveItemsStoreName);

    await store.clear();
    for (final item in items) {
      await store.put(item);
    }

    await transaction.completed;
  }

  @override
  Future<void> saveSelectedItemId(String? selectedItemId) async {
    final database = await _database;
    final transaction =
        database.transaction(_metadataStoreName, idbModeReadWrite);
    final store = transaction.objectStore(_metadataStoreName);
    await store.put({
      'key': _selectedItemKey,
      'value': selectedItemId,
    });
    await transaction.completed;
  }

  @override
  Future<void> saveHiddenSeedItemIds(List<String> hiddenSeedItemIds) async {
    final database = await _database;
    final transaction =
        database.transaction(_metadataStoreName, idbModeReadWrite);
    final store = transaction.objectStore(_metadataStoreName);
    await store.put({
      'key': _hiddenSeedIdsKey,
      'value': hiddenSeedItemIds,
    });
    await transaction.completed;
  }
}

ArchivePersistenceStore createArchivePersistenceStore() {
  return _IndexedDbArchivePersistenceStore();
}
