import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/creation_document.dart';

class LocalCreationsDataSource {
  Directory? _creationsDir;
  final Map<String, CreationDocument> _fallbackMemoryStorage = {};

  LocalCreationsDataSource({Directory? customDirectory})
      : _creationsDir = customDirectory;

  Future<Directory?> _getCreationsDirectory() async {
    if (_creationsDir != null) return _creationsDir!;
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final dir = Directory('${appDocDir.path}/lovio_creations');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      _creationsDir = dir;
      return dir;
    } catch (e) {
      debugPrint('Path provider unavailable (e.g. in test environment): $e');
      return null;
    }
  }

  Future<File?> _getFile(String id) async {
    final dir = await _getCreationsDirectory();
    if (dir == null) return null;
    return File('${dir.path}/$id.json');
  }

  Future<List<CreationDocument>> loadAll() async {
    try {
      final dir = await _getCreationsDirectory();
      if (dir == null) {
        final list = _fallbackMemoryStorage.values.toList();
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return list;
      }

      final files = dir.listSync().whereType<File>().where(
            (file) => file.path.endsWith('.json'),
          );

      final List<CreationDocument> list = [];
      for (final file in files) {
        try {
          final content = await file.readAsString();
          final jsonMap = jsonDecode(content) as Map<String, dynamic>;
          final doc = CreationDocument.fromJson(jsonMap).copyWith(
            localFilePath: file.path,
          );
          list.add(doc);
        } catch (e) {
          debugPrint('Error reading creation file ${file.path}: $e');
        }
      }

      // Sort by updatedAt descending
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return list;
    } catch (e) {
      debugPrint('Error accessing local creations directory: $e');
      final list = _fallbackMemoryStorage.values.toList();
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return list;
    }
  }

  Future<CreationDocument> save(CreationDocument doc) async {
    final file = await _getFile(doc.id);
    final docToSave = doc.copyWith(
      localFilePath: file?.path,
      updatedAt: DateTime.now(),
    );

    if (file != null) {
      final jsonString = jsonEncode(docToSave.toJson());
      await file.writeAsString(jsonString, flush: true);
    } else {
      _fallbackMemoryStorage[docToSave.id] = docToSave;
    }

    return docToSave;
  }

  Future<void> delete(String id) async {
    try {
      final file = await _getFile(id);
      if (file != null && await file.exists()) {
        await file.delete();
      }
      _fallbackMemoryStorage.remove(id);
    } catch (e) {
      debugPrint('Error deleting local creation file $id: $e');
      _fallbackMemoryStorage.remove(id);
    }
  }
}
