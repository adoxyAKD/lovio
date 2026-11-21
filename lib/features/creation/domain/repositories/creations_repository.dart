import '../entities/creation_document.dart';

abstract class CreationsRepository {
  Future<List<CreationDocument>> getCreations();
  Future<CreationDocument> saveCreationLocally(CreationDocument doc);
  Future<CreationDocument> syncToCloud(String id);
  Future<void> deleteCreation(String id);
  Stream<List<CreationDocument>> watchCreations();
}
