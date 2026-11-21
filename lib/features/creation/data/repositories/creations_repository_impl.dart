import 'dart:async';
import '../../domain/entities/creation_document.dart';
import '../../domain/repositories/creations_repository.dart';
import '../data_sources/local_creations_data_source.dart';
import '../data_sources/remote/creations_remote_data_source.dart';
import '../data_sources/remote/firebase_creations_remote_data_source.dart';

class CreationsRepositoryImpl implements CreationsRepository {
  final LocalCreationsDataSource _localDataSource;
  final CreationsRemoteDataSource _remoteDataSource;

  final StreamController<List<CreationDocument>> _creationsStreamController =
      StreamController<List<CreationDocument>>.broadcast();

  List<CreationDocument> _cachedCreations = [];

  CreationsRepositoryImpl({
    LocalCreationsDataSource? localDataSource,
    CreationsRemoteDataSource? remoteDataSource,
  })  : _localDataSource = localDataSource ?? LocalCreationsDataSource(),
        _remoteDataSource =
            remoteDataSource ?? FirebaseCreationsRemoteDataSource();

  @override
  Stream<List<CreationDocument>> watchCreations() {
    return _creationsStreamController.stream;
  }

  @override
  Future<List<CreationDocument>> getCreations() async {
    final list = await _localDataSource.loadAll();
    _cachedCreations = list;
    _creationsStreamController.add(List.unmodifiable(_cachedCreations));
    return list;
  }

  @override
  Future<CreationDocument> saveCreationLocally(CreationDocument doc) async {
    // Save to local device first
    final savedDoc = await _localDataSource.save(doc);

    // Update in-memory cache
    final index = _cachedCreations.indexWhere((item) => item.id == doc.id);
    if (index >= 0) {
      _cachedCreations[index] = savedDoc;
    } else {
      _cachedCreations.insert(0, savedDoc);
    }

    _creationsStreamController.add(List.unmodifiable(_cachedCreations));
    return savedDoc;
  }

  @override
  Future<CreationDocument> syncToCloud(String id) async {
    final index = _cachedCreations.indexWhere((item) => item.id == id);
    if (index < 0) {
      throw Exception('Creation not found locally for ID: $id');
    }

    final currentDoc = _cachedCreations[index];

    // Optimistically update status to syncing
    final syncingDoc = currentDoc.copyWith(syncStatus: SyncStatus.syncing);
    _cachedCreations[index] = syncingDoc;
    _creationsStreamController.add(List.unmodifiable(_cachedCreations));

    try {
      final uploadResult = await _remoteDataSource.uploadCreation(currentDoc);

      final syncedDoc = currentDoc.copyWith(
        syncStatus: SyncStatus.synced,
        cloudDocId: uploadResult['cloudDocId'] as String?,
        lastSyncedAt: uploadResult['lastSyncedAt'] as DateTime?,
      );

      // Persist the updated sync status locally to disk
      await _localDataSource.save(syncedDoc);

      _cachedCreations[index] = syncedDoc;
      _creationsStreamController.add(List.unmodifiable(_cachedCreations));
      return syncedDoc;
    } catch (e) {
      final failedDoc = currentDoc.copyWith(syncStatus: SyncStatus.syncFailed);
      await _localDataSource.save(failedDoc);
      _cachedCreations[index] = failedDoc;
      _creationsStreamController.add(List.unmodifiable(_cachedCreations));
      rethrow;
    }
  }

  @override
  Future<void> deleteCreation(String id) async {
    final index = _cachedCreations.indexWhere((item) => item.id == id);
    if (index >= 0) {
      final doc = _cachedCreations[index];
      await _localDataSource.delete(id);
      if (doc.cloudDocId != null) {
        await _remoteDataSource.deleteFromCloud(id);
      }
      _cachedCreations.removeAt(index);
      _creationsStreamController.add(List.unmodifiable(_cachedCreations));
    }
  }

  void dispose() {
    _creationsStreamController.close();
  }
}
