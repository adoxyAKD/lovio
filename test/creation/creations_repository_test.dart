import 'package:flutter_test/flutter_test.dart';
import 'package:lovio/features/creation/domain/entities/creation_document.dart';
import 'package:lovio/features/creation/domain/entities/creation_item.dart';
import 'package:lovio/features/creation/domain/repositories/creations_repository.dart';
import 'package:lovio/features/creation/presentation/view_models/creations_view_model.dart';

class FakeCreationsRepository implements CreationsRepository {
  final List<CreationDocument> _storage = [];

  @override
  Future<List<CreationDocument>> getCreations() async {
    return List.unmodifiable(_storage);
  }

  @override
  Future<CreationDocument> saveCreationLocally(CreationDocument doc) async {
    final index = _storage.indexWhere((e) => e.id == doc.id);
    if (index >= 0) {
      _storage[index] = doc;
    } else {
      _storage.insert(0, doc);
    }
    return doc;
  }

  @override
  Future<CreationDocument> syncToCloud(String id) async {
    final index = _storage.indexWhere((e) => e.id == id);
    if (index < 0) throw Exception('Not found');
    final synced = _storage[index].copyWith(
      syncStatus: SyncStatus.synced,
      cloudDocId: 'firestore_$id',
      lastSyncedAt: DateTime.now(),
    );
    _storage[index] = synced;
    return synced;
  }

  @override
  Future<void> deleteCreation(String id) async {
    _storage.removeWhere((e) => e.id == id);
  }

  @override
  Stream<List<CreationDocument>> watchCreations() {
    return Stream.value(List.unmodifiable(_storage));
  }
}

void main() {
  group('CreationDocument & Sync Storage Tests', () {
    test('CreationDocument serializes and deserializes to/from JSON correctly',
        () {
      final now = DateTime.now();
      final doc = CreationDocument(
        id: 'test-123',
        title: 'Anniversary Memory Book',
        type: CreationType.shortBook,
        createdAt: now,
        updatedAt: now,
        isFavorite: true,
        pageCount: 10,
        syncStatus: SyncStatus.localOnly,
        coverGradientKey: 'sunset',
      );

      final json = doc.toJson();
      expect(json['id'], 'test-123');
      expect(json['title'], 'Anniversary Memory Book');
      expect(json['type'], 'shortBook');
      expect(json['syncStatus'], 'localOnly');

      final deserialized = CreationDocument.fromJson(json);
      expect(deserialized.id, doc.id);
      expect(deserialized.title, doc.title);
      expect(deserialized.type, CreationType.shortBook);
      expect(deserialized.isFavorite, true);
      expect(deserialized.syncStatus, SyncStatus.localOnly);
    });

    test('CreationsNotifier saves locally first with localOnly status',
        () async {
      final fakeRepo = FakeCreationsRepository();
      final notifier = CreationsNotifier(fakeRepo);

      final created = await notifier.createNewCreation(
        title: 'My First Love Letter',
        type: CreationType.loveLetter,
        syncImmediately: false,
      );

      expect(created.title, 'My First Love Letter');
      expect(created.syncStatus, SyncStatus.localOnly);
      expect(created.isLocalOnly, true);
      expect(created.isSynced, false);

      final stored = await fakeRepo.getCreations();
      expect(stored.length, 1);
      expect(stored.first.id, created.id);
    });

    test('CreationsNotifier uploads to cloud on demand and updates syncStatus',
        () async {
      final fakeRepo = FakeCreationsRepository();
      final notifier = CreationsNotifier(fakeRepo);

      final created = await notifier.createNewCreation(
        title: 'Greeting Card for Sophia',
        type: CreationType.card,
        syncImmediately: false,
      );

      expect(created.syncStatus, SyncStatus.localOnly);

      // Perform cloud sync
      await notifier.uploadToCloud(created.id);

      final stored = await fakeRepo.getCreations();
      expect(stored.first.syncStatus, SyncStatus.synced);
      expect(stored.first.isSynced, true);
      expect(stored.first.cloudDocId, isNotNull);
    });
  });
}
