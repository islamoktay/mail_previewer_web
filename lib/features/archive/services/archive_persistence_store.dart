import 'archive_persistence_store_stub.dart'
    if (dart.library.indexed_db) 'archive_persistence_store_web.dart'
    as archive_persistence_store;

abstract class ArchivePersistenceStore {
  Future<List<Map<String, Object?>>> loadArchiveItems();

  Future<void> saveArchiveItems(List<Map<String, Object?>> items);

  Future<String?> loadSelectedItemId();

  Future<void> saveSelectedItemId(String? selectedItemId);

  Future<List<String>> loadHiddenSeedItemIds();

  Future<void> saveHiddenSeedItemIds(List<String> hiddenSeedItemIds);
}

ArchivePersistenceStore createArchivePersistenceStore() {
  return archive_persistence_store.createArchivePersistenceStore();
}
