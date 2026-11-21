import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_preferences.dart';
import 'auth_remote_data_source.dart';

class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  FirebaseAuthRemoteDataSource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth,
        _firestore = firestore;

  FirebaseAuth? get auth {
    if (_auth != null) return _auth;
    if (Firebase.apps.isNotEmpty) {
      _auth = FirebaseAuth.instance;
      return _auth;
    }
    return null;
  }

  FirebaseFirestore? get firestore {
    if (_firestore != null) return _firestore;
    if (Firebase.apps.isNotEmpty) {
      _firestore = FirebaseFirestore.instance;
      return _firestore;
    }
    return null;
  }

  static const String usersCollection = 'users';
  static const String rtdbBaseUrl =
      'https://lovio-e5990-default-rtdb.firebaseio.com';

  Future<String?> _resolvePhotoPayload(String? photoUrl) async {
    if (photoUrl == null || photoUrl.isEmpty) return null;
    if (photoUrl.startsWith('http://') ||
        photoUrl.startsWith('https://') ||
        photoUrl.startsWith('data:image')) {
      return photoUrl;
    }
    try {
      final file = File(photoUrl);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        // Base64 encode for permanent cloud storage in RTDB & Firestore (max ~1.5MB)
        if (bytes.length <= 1500000) {
          final b64 = base64Encode(bytes);
          return 'data:image/jpeg;base64,$b64';
        }
      }
    } catch (e) {
      debugPrint('Warning: Could not encode avatar to base64: $e');
    }
    return photoUrl;
  }

  Future<bool> _writeToRealtimeDatabase({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      final currentUser = auth?.currentUser;
      String? token;
      if (currentUser != null) {
        try {
          token = await currentUser.getIdToken(true);
        } catch (_) {}
      }

      final queryParam =
          (token != null && token.isNotEmpty) ? '?auth=$token' : '';
      final url = Uri.parse('$rtdbBaseUrl/users/$uid.json$queryParam');

      final body = jsonEncode(data);
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      };

      final response = await http
          .put(
            url,
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint(
            'Successfully saved user profile to Firebase Realtime Database: $uid');
        return true;
      } else {
        debugPrint(
            'Realtime Database write response: ${response.statusCode} - ${response.body}');
        if (response.statusCode == 401 || response.statusCode == 403) {
          debugPrint(
              'RTDB Rules Notice: Please set Realtime Database Rules to allow read/write in Firebase Console.');
        }
        // Fallback write without auth param (works if test mode rules are active)
        final fallbackUrl = Uri.parse('$rtdbBaseUrl/users/$uid.json');
        final fbResponse = await http
            .put(
              fallbackUrl,
              headers: {'Content-Type': 'application/json'},
              body: body,
            )
            .timeout(const Duration(seconds: 8));
        return (fbResponse.statusCode >= 200 && fbResponse.statusCode < 300);
      }
    } catch (e) {
      debugPrint('Warning: Realtime Database write error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> _readFromRealtimeDatabase(String uid) async {
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
      final url = Uri.parse('$rtdbBaseUrl/users/$uid.json$queryParam');

      final headers = <String, String>{
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      };

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 &&
          response.body.isNotEmpty &&
          response.body != 'null') {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
    } catch (e) {
      debugPrint('Warning: Realtime Database read error: $e');
    }
    return null;
  }

  UserEntity _mapFirebaseUserToEntity(
    User user, {
    Map<String, dynamic>? firestoreData,
    String? partnerName,
    DateTime? anniversaryDate,
  }) {
    final extraData = firestoreData ?? {};
    final partner = partnerName ?? extraData['partnerName'] as String?;
    final anniversary = anniversaryDate ??
        (extraData['anniversaryDate'] != null
            ? DateTime.tryParse(extraData['anniversaryDate'] as String)
            : null);

    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      displayName:
          user.displayName ?? extraData['displayName'] as String? ?? 'Beloved',
      photoUrl: extraData['photoUrl'] as String? ?? user.photoURL,
      partnerName: partner,
      anniversaryDate: anniversary,
      bio: extraData['bio'] as String?,
      provider: AuthProviderType.email,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      isEmailVerified: user.emailVerified,
    );
  }

  @override
  Stream<UserEntity?> watchAuthState() {
    final fa = auth;
    if (fa == null) return Stream.value(null);

    return fa.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return await _fetchFullUser(user);
    });
  }

  Future<UserEntity> _fetchFullUser(User user) async {
    // 1. Immediately return local cache if fresh
    final cached = await AuthPreferences.getCachedUser();
    if (cached != null && cached.id == user.uid) {
      _syncUserInBackground(user, cached);
      return cached;
    }

    // 2. Fetch from Realtime Database first
    Map<String, dynamic>? remoteData =
        await _readFromRealtimeDatabase(user.uid);

    // 3. Fallback to Cloud Firestore
    if (remoteData == null) {
      final db = firestore;
      if (db != null) {
        try {
          final doc = await db
              .collection(usersCollection)
              .doc(user.uid)
              .get()
              .timeout(const Duration(seconds: 4));
          if (doc.exists) {
            remoteData = doc.data();
          }
        } catch (e) {
          debugPrint('Warning: Could not fetch Firestore user profile: $e');
        }
      }
    }

    final entity = _mapFirebaseUserToEntity(user, firestoreData: remoteData);
    await AuthPreferences.saveCachedUser(entity);

    // If remote did not have user profile, sync local cached data up to cloud
    if (remoteData == null) {
      _syncUserInBackground(user, entity);
    }

    return entity;
  }

  void _syncUserInBackground(User user, [UserEntity? existing]) async {
    try {
      var data = await _readFromRealtimeDatabase(user.uid);
      if (data == null && firestore != null) {
        final doc = await firestore!
            .collection(usersCollection)
            .doc(user.uid)
            .get()
            .timeout(const Duration(seconds: 4));
        if (doc.exists) data = doc.data();
      }

      // If cloud is empty but we have local user data, upload to Realtime Database & Firestore!
      if (data == null && existing != null) {
        final photoPayload = await _resolvePhotoPayload(existing.photoUrl);
        final payload = <String, dynamic>{
          'id': existing.id,
          'email': existing.email,
          'displayName': existing.displayName,
          'photoUrl': photoPayload,
          'partnerName': existing.partnerName,
          'anniversaryDate': existing.anniversaryDate?.toIso8601String(),
          'createdAt': existing.createdAt.toIso8601String(),
        };
        await _writeToRealtimeDatabase(uid: user.uid, data: payload);
        if (firestore != null) {
          try {
            await firestore!
                .collection(usersCollection)
                .doc(user.uid)
                .set(payload, SetOptions(merge: true));
          } catch (_) {}
        }
        data = payload;
      }

      if (data != null) {
        final entity = _mapFirebaseUserToEntity(user, firestoreData: data);
        await AuthPreferences.saveCachedUser(entity);
      }
    } catch (_) {}
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final fa = auth;
    if (fa == null || fa.currentUser == null) return null;
    return await _fetchFullUser(fa.currentUser!);
  }

  @override
  Future<UserEntity> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    final fa = auth;
    if (fa == null) {
      throw const AuthFailure(
          'Firebase is not initialized in this environment.');
    }

    try {
      final credential = await fa.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthFailure('Sign in failed: no user returned.');
      }

      return await _fetchFullUser(user);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseError(e.code, e.message), code: e.code);
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<UserEntity> signUpWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
    String? photoUrl,
    String? partnerName,
    DateTime? anniversaryDate,
  }) async {
    final fa = auth;
    if (fa == null) {
      throw const AuthFailure(
          'Firebase is not initialized in this environment.');
    }

    try {
      final credential = await fa.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthFailure('Sign up failed: no user created.');
      }

      // Update Firebase Auth profile safely (ignore invalid photo url on local paths)
      if (displayName.isNotEmpty) {
        try {
          await user.updateDisplayName(displayName);
        } catch (_) {}
      }
      if (photoUrl != null &&
          photoUrl.isNotEmpty &&
          (photoUrl.startsWith('http://') || photoUrl.startsWith('https://'))) {
        try {
          await user.updatePhotoURL(photoUrl);
        } catch (_) {}
      }

      final photoPayload = await _resolvePhotoPayload(photoUrl);

      final payload = <String, dynamic>{
        'id': user.uid,
        'email': email.trim(),
        'displayName': displayName,
        'photoUrl': photoPayload,
        'partnerName': partnerName,
        'anniversaryDate': anniversaryDate?.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      // 1. Persist to Firebase Realtime Database
      await _writeToRealtimeDatabase(
        uid: user.uid,
        data: payload,
      );

      // 2. Persist extended user details to Cloud Firestore
      final db = firestore;
      if (db != null) {
        try {
          await db.collection(usersCollection).doc(user.uid).set({
            ...payload,
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint('Error storing user profile in Firestore: $e');
        }
      }

      final entity = _mapFirebaseUserToEntity(
        user,
        firestoreData: payload,
        partnerName: partnerName,
        anniversaryDate: anniversaryDate,
      );

      // 3. Cache locally immediately for 0ms loading
      await AuthPreferences.saveCachedUser(entity);

      return entity;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseError(e.code, e.message), code: e.code);
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    // Modular hook: Ready to integrate google_sign_in package with OAuthCredential
    throw const AuthFailure(
      'Google Sign-In hook ready. Configure Google OAuth client ID in google-services.json to activate.',
    );
  }

  @override
  Future<UserEntity> signInWithFacebook() async {
    // Modular hook: Ready to integrate flutter_facebook_auth package
    throw const AuthFailure(
      'Facebook Sign-In hook ready. Configure Facebook App ID in AndroidManifest to activate.',
    );
  }

  @override
  Future<UserEntity> signInWithApple() async {
    // Modular hook: Ready to integrate sign_in_with_apple package
    throw const AuthFailure(
      'Apple Sign-In hook ready. Configure Apple Developer Team ID to activate.',
    );
  }

  @override
  Future<UserEntity> updateProfile({
    String? displayName,
    String? photoUrl,
    String? partnerName,
    DateTime? anniversaryDate,
    String? bio,
  }) async {
    final fa = auth;
    if (fa == null || fa.currentUser == null) {
      throw const AuthFailure('User not authenticated.');
    }

    final user = fa.currentUser!;

    if (displayName != null && displayName.isNotEmpty) {
      try {
        await user.updateDisplayName(displayName);
      } catch (_) {}
    }
    if (photoUrl != null &&
        photoUrl.isNotEmpty &&
        (photoUrl.startsWith('http://') || photoUrl.startsWith('https://'))) {
      try {
        await user.updatePhotoURL(photoUrl);
      } catch (_) {}
    }

    final Map<String, dynamic> updateData = {
      'updatedAt': DateTime.now().toIso8601String(),
    };
    if (displayName != null) updateData['displayName'] = displayName;
    if (photoUrl != null) {
      final photoPayload = await _resolvePhotoPayload(photoUrl);
      if (photoPayload != null) updateData['photoUrl'] = photoPayload;
    }
    if (partnerName != null) updateData['partnerName'] = partnerName;
    if (anniversaryDate != null) {
      updateData['anniversaryDate'] = anniversaryDate.toIso8601String();
    }
    if (bio != null) updateData['bio'] = bio;

    // 1. Write to Realtime Database
    await _writeToRealtimeDatabase(
      uid: user.uid,
      data: updateData,
    );

    // 2. Write to Firestore
    final db = firestore;
    if (db != null && updateData.isNotEmpty) {
      try {
        await db.collection(usersCollection).doc(user.uid).set(
              updateData,
              SetOptions(merge: true),
            );
      } catch (e) {
        debugPrint('Error updating Firestore profile: $e');
      }
    }

    final updated = await _fetchFullUser(user);
    await AuthPreferences.saveCachedUser(updated);
    return updated;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final fa = auth;
    if (fa == null || fa.currentUser == null || fa.currentUser!.email == null) {
      throw const AuthFailure('User not authenticated.');
    }
    try {
      final user = fa.currentUser!;
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseError(e.code, e.message), code: e.code);
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final fa = auth;
    if (fa == null) {
      throw const AuthFailure(
          'Firebase is not initialized in this environment.');
    }
    try {
      await fa.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseError(e.code, e.message), code: e.code);
    }
  }

  @override
  Future<void> signOut() async {
    final fa = auth;
    if (fa != null) {
      await fa.signOut();
    }
  }

  String _mapFirebaseError(String code, String? defaultMessage) {
    switch (code) {
      case 'user-not-found':
        return 'No account found for this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return defaultMessage ?? 'An authentication error occurred.';
    }
  }
}
