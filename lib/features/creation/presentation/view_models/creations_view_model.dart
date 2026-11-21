import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/config/app_config.dart';
import '../../data/data_sources/remote/creations_remote_data_source.dart';
import '../../data/data_sources/remote/firebase_creations_remote_data_source.dart';
import '../../data/data_sources/remote/rest_api_creations_remote_data_source.dart';
import '../../data/repositories/creations_repository_impl.dart';
import '../../domain/entities/creation_document.dart';
import '../../domain/entities/creation_item.dart';
import '../../domain/repositories/creations_repository.dart';

/// Remote Backend Provider (Firebase by default, or REST API server)
/// Easily swap backend implementations by setting AppConfig.backendType or overriding this provider!
final creationsRemoteDataSourceProvider =
    Provider<CreationsRemoteDataSource>((ref) {
  if (AppConfig.current.backendType == BackendType.restApi) {
    return RestApiCreationsRemoteDataSource();
  }
  return FirebaseCreationsRemoteDataSource();
});

final creationsRepositoryProvider = Provider<CreationsRepository>((ref) {
  final remoteDataSource = ref.watch(creationsRemoteDataSourceProvider);
  final repo = CreationsRepositoryImpl(remoteDataSource: remoteDataSource);
  ref.onDispose(repo.dispose);
  return repo;
});

class CreationsState {
  final List<CreationDocument> items;
  final bool isLoading;
  final String? errorMessage;

  const CreationsState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CreationsState copyWith({
    List<CreationDocument>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CreationsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class CreationsNotifier extends StateNotifier<CreationsState> {
  final CreationsRepository _repository;
  final Uuid _uuid = const Uuid();

  CreationsNotifier(this._repository) : super(const CreationsState()) {
    loadCreations();
    _repository.watchCreations().listen((items) {
      state = state.copyWith(items: items);
    });
  }

  Future<void> loadCreations() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await _repository.getCreations();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<CreationDocument> createNewCreation({
    required String title,
    required CreationType type,
    Map<String, dynamic> content = const {},
    String coverGradientKey = 'primary',
    int pageCount = 1,
    bool syncImmediately = false,
  }) async {
    final now = DateTime.now();
    final newDoc = CreationDocument(
      id: _uuid.v4(),
      title: title,
      type: type,
      content: content,
      createdAt: now,
      updatedAt: now,
      pageCount: pageCount,
      coverGradientKey: coverGradientKey,
      syncStatus: SyncStatus.localOnly,
    );

    // Save locally first
    final savedDoc = await _repository.saveCreationLocally(newDoc);

    // If requested, sync to cloud
    if (syncImmediately) {
      await uploadToCloud(savedDoc.id);
    }

    return savedDoc;
  }

  Future<void> uploadToCloud(String id) async {
    try {
      await _repository.syncToCloud(id);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Cloud upload failed: $e');
    }
  }

  Future<void> deleteCreation(String id) async {
    try {
      await _repository.deleteCreation(id);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Deletion failed: $e');
    }
  }
}

final creationsProvider =
    StateNotifierProvider<CreationsNotifier, CreationsState>((ref) {
  final repository = ref.watch(creationsRepositoryProvider);
  return CreationsNotifier(repository);
});
