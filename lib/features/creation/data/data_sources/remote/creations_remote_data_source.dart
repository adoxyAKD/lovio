import '../../../domain/entities/creation_document.dart';

/// Contract interface for any remote backend service (Firebase, REST API, GraphQL, Supabase, etc.)
/// Following Clean Architecture Port & Adapter (Hexagonal) pattern.
abstract class CreationsRemoteDataSource {
  /// Upload or sync a creation to the remote backend
  Future<Map<String, dynamic>> uploadCreation(CreationDocument doc);

  /// Fetch all creations stored on the remote backend
  Future<List<CreationDocument>> fetchAllCreations();

  /// Fetch a single creation by ID
  Future<CreationDocument?> fetchCreationById(String id);

  /// Delete a creation from the remote backend
  Future<void> deleteFromCloud(String id);
}
