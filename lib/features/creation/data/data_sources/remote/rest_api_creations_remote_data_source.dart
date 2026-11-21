import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../domain/entities/creation_document.dart';
import 'creations_remote_data_source.dart';

/// REST API Server Implementation of [CreationsRemoteDataSource]
/// Ready for any standard REST backend (Node.js, Go, Python, Spring, etc.)
class RestApiCreationsRemoteDataSource implements CreationsRemoteDataSource {
  final ApiClient _apiClient;

  RestApiCreationsRemoteDataSource({ApiClient? apiClient})
      : _apiClient = apiClient ?? HttpApiClient();

  @override
  Future<Map<String, dynamic>> uploadCreation(CreationDocument doc) async {
    final response = await _apiClient.post(
      ApiEndpoints.creations,
      body: doc.toJson(),
    );

    return {
      'cloudDocId':
          response != null && response is Map && response.containsKey('id')
              ? response['id'].toString()
              : doc.id,
      'lastSyncedAt': DateTime.now(),
    };
  }

  @override
  Future<List<CreationDocument>> fetchAllCreations() async {
    final response = await _apiClient.get(ApiEndpoints.creations);
    if (response is List) {
      return response
          .map((item) =>
              CreationDocument.fromJson(item as Map<String, dynamic>).copyWith(
                syncStatus: SyncStatus.synced,
              ))
          .toList();
    }
    return [];
  }

  @override
  Future<CreationDocument?> fetchCreationById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.creationById(id));
    if (response is Map<String, dynamic>) {
      return CreationDocument.fromJson(response).copyWith(
        syncStatus: SyncStatus.synced,
      );
    }
    return null;
  }

  @override
  Future<void> deleteFromCloud(String id) async {
    await _apiClient.delete(ApiEndpoints.creationById(id));
  }
}
