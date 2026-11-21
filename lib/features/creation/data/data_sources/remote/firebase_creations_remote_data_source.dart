import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../../core/errors/failures.dart';
import '../../../domain/entities/creation_document.dart';
import 'creations_remote_data_source.dart';

class FirebaseCreationsRemoteDataSource implements CreationsRemoteDataSource {
  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;

  static const String rtdbBaseUrl =
      'https://lovio-e5990-default-rtdb.firebaseio.com';

  FirebaseCreationsRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore,
        _auth = auth;

  FirebaseFirestore? get firestore {
    if (_firestore != null) return _firestore!;
    if (Firebase.apps.isNotEmpty) {
      _firestore = FirebaseFirestore.instance;
      return _firestore;
    }
    return null;
  }

  FirebaseAuth? get auth {
    if (_auth != null) return _auth;
    if (Firebase.apps.isNotEmpty) {
      _auth = FirebaseAuth.instance;
      return _auth;
    }
    return null;
  }

  static const String collectionName = 'creations';

  Future<void> _writeCreationToRealtimeDatabase(CreationDocument doc) async {
    try {
      final currentUser = auth?.currentUser;
      String? token;
      if (currentUser != null) {
        try {
          token = await currentUser.getIdToken();
        } catch (_) {}
      }

      final queryParam =
          (token != null && token.isNotEmpty) ? '?auth=$token' : '';
      final url =
          Uri.parse('$rtdbBaseUrl/creations/${doc.id}.json$queryParam');

      final rtdbPayload = {
        'id': doc.id,
        'title': doc.title,
        'type': doc.type.name,
        'content': doc.content,
        'createdAt': doc.createdAt.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'isFavorite': doc.isFavorite,
        'pageCount': doc.pageCount,
        'coverGradientKey': doc.coverGradientKey,
        'authorUid': currentUser?.uid,
      };

      final body = jsonEncode(rtdbPayload);
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      };

      final response = await http
          .put(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint(
            'Successfully saved creation to Firebase Realtime Database: ${doc.id}');
      } else {
        // Fallback write without auth parameter
        final fallbackUrl =
            Uri.parse('$rtdbBaseUrl/creations/${doc.id}.json');
        await http
            .put(fallbackUrl,
                headers: {'Content-Type': 'application/json'}, body: body)
            .timeout(const Duration(seconds: 6));
      }
    } catch (e) {
      debugPrint('Warning: Realtime Database creation write error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> uploadCreation(CreationDocument doc) async {
    try {
      // 1. Write to Realtime Database
      await _writeCreationToRealtimeDatabase(doc);

      // 2. Write to Cloud Firestore
      final db = firestore;
      if (db != null) {
        final docRef = db.collection(collectionName).doc(doc.id);
        final payload = {
          'id': doc.id,
          'title': doc.title,
          'type': doc.type.name,
          'content': doc.content,
          'createdAt': Timestamp.fromDate(doc.createdAt),
          'updatedAt': FieldValue.serverTimestamp(),
          'isFavorite': doc.isFavorite,
          'pageCount': doc.pageCount,
          'coverGradientKey': doc.coverGradientKey,
        };

        await docRef.set(payload, SetOptions(merge: true));

        return {
          'cloudDocId': docRef.id,
          'lastSyncedAt': DateTime.now(),
        };
      }

      return {
        'cloudDocId': doc.id,
        'lastSyncedAt': DateTime.now(),
      };
    } catch (e) {
      debugPrint('Firebase upload error: $e');
      throw ServerFailure('Failed to sync creation to cloud: $e');
    }
  }

  @override
  Future<List<CreationDocument>> fetchAllCreations() async {
    try {
      final db = firestore;
      if (db == null) return [];
      final querySnapshot = await db.collection(collectionName).get();
      return querySnapshot.docs.map((snapshot) {
        final data = snapshot.data();
        data['id'] = snapshot.id;
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] =
              (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        if (data['updatedAt'] is Timestamp) {
          data['updatedAt'] =
              (data['updatedAt'] as Timestamp).toDate().toIso8601String();
        }
        data['syncStatus'] = SyncStatus.synced.name;
        data['cloudDocId'] = snapshot.id;
        return CreationDocument.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Firebase fetchAllCreations error: $e');
      throw ServerFailure('Failed to fetch creations from cloud: $e');
    }
  }

  @override
  Future<CreationDocument?> fetchCreationById(String id) async {
    try {
      final db = firestore;
      if (db == null) return null;
      final docSnapshot = await db.collection(collectionName).doc(id).get();
      if (!docSnapshot.exists || docSnapshot.data() == null) return null;
      final data = docSnapshot.data()!;
      data['id'] = docSnapshot.id;
      if (data['createdAt'] is Timestamp) {
        data['createdAt'] =
            (data['createdAt'] as Timestamp).toDate().toIso8601String();
      }
      if (data['updatedAt'] is Timestamp) {
        data['updatedAt'] =
            (data['updatedAt'] as Timestamp).toDate().toIso8601String();
      }
      data['syncStatus'] = SyncStatus.synced.name;
      data['cloudDocId'] = docSnapshot.id;
      return CreationDocument.fromJson(data);
    } catch (e) {
      debugPrint('Firebase fetchCreationById error: $e');
      throw ServerFailure('Failed to fetch creation from cloud: $e');
    }
  }

  @override
  Future<void> deleteFromCloud(String id) async {
    try {
      final db = firestore;
      if (db == null) return;
      await db.collection(collectionName).doc(id).delete();
    } catch (e) {
      debugPrint('Firebase delete error: $e');
    }
  }
}
