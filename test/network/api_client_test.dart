import 'package:flutter_test/flutter_test.dart';
import 'package:lovio/core/network/api_client.dart';
import 'package:lovio/features/creation/data/data_sources/remote/rest_api_creations_remote_data_source.dart';
import 'package:lovio/features/creation/domain/entities/creation_document.dart';
import 'package:lovio/features/creation/domain/entities/creation_item.dart';

class MockApiClient implements ApiClient {
  dynamic postResponse;
  dynamic getResponse;
  String? lastRequestedEndpoint;
  dynamic lastRequestBody;

  @override
  Future<dynamic> post(String endpoint,
      {dynamic body, Map<String, String>? headers}) async {
    lastRequestedEndpoint = endpoint;
    lastRequestBody = body;
    return postResponse;
  }

  @override
  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    lastRequestedEndpoint = endpoint;
    return getResponse;
  }

  @override
  Future<dynamic> put(String endpoint,
      {dynamic body, Map<String, String>? headers}) async {
    lastRequestedEndpoint = endpoint;
    return postResponse;
  }

  @override
  Future<dynamic> delete(String endpoint,
      {Map<String, String>? headers}) async {
    lastRequestedEndpoint = endpoint;
    return null;
  }
}

void main() {
  group('Backend-Agnostic REST API Remote Data Source Tests', () {
    late MockApiClient mockApiClient;
    late RestApiCreationsRemoteDataSource remoteDataSource;

    setUp(() {
      mockApiClient = MockApiClient();
      remoteDataSource =
          RestApiCreationsRemoteDataSource(apiClient: mockApiClient);
    });

    test('uploadCreation sends document JSON to REST API endpoint', () async {
      final doc = CreationDocument(
        id: 'book-999',
        title: 'REST API Storybook',
        type: CreationType.shortBook,
        createdAt: DateTime(2026, 11, 13),
        updatedAt: DateTime(2026, 11, 13),
      );

      mockApiClient.postResponse = {'id': 'server_assigned_id_123'};

      final result = await remoteDataSource.uploadCreation(doc);

      expect(mockApiClient.lastRequestedEndpoint, '/creations');
      expect(mockApiClient.lastRequestBody['title'], 'REST API Storybook');
      expect(result['cloudDocId'], 'server_assigned_id_123');
      expect(result['lastSyncedAt'], isNotNull);
    });

    test('fetchAllCreations parses server array response', () async {
      mockApiClient.getResponse = [
        {
          'id': 'book-1',
          'title': 'Server Book 1',
          'type': 'shortBook',
          'createdAt': '2026-11-13T10:00:00.000',
          'updatedAt': '2026-11-13T10:00:00.000',
        },
        {
          'id': 'card-2',
          'title': 'Server Card 2',
          'type': 'card',
          'createdAt': '2026-11-13T10:00:00.000',
          'updatedAt': '2026-11-13T10:00:00.000',
        }
      ];

      final items = await remoteDataSource.fetchAllCreations();

      expect(mockApiClient.lastRequestedEndpoint, '/creations');
      expect(items.length, 2);
      expect(items.first.title, 'Server Book 1');
      expect(items.first.syncStatus, SyncStatus.synced);
      expect(items.last.title, 'Server Card 2');
    });

    test('deleteFromCloud calls DELETE on REST API endpoint', () async {
      await remoteDataSource.deleteFromCloud('book-999');
      expect(mockApiClient.lastRequestedEndpoint, '/creations/book-999');
    });
  });
}
