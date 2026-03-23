import 'package:mail_previewer_web/features/archive/services/archive_persistence_store.dart';

class _StubArchivePersistenceStore implements ArchivePersistenceStore {
  @override
  Future<List<Map<String, Object?>>> loadArchiveItems() async => const [];

  @override
  Future<List<String>> loadHiddenSeedItemIds() async => const [];

  @override
  Future<String?> loadSelectedItemId() async => null;

  @override
  Future<void> saveArchiveItems(List<Map<String, Object?>> items) async {}

  @override
  Future<void> saveHiddenSeedItemIds(List<String> hiddenSeedItemIds) async {}

  @override
  Future<void> saveSelectedItemId(String? selectedItemId) async {}
}

ArchivePersistenceStore createArchivePersistenceStore() {
  return _StubArchivePersistenceStore();
}
