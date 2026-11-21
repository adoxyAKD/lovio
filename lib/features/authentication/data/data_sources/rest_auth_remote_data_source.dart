import 'dart:async';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_remote_data_source.dart';

/// REST API Server Implementation of [AuthRemoteDataSource]
/// Ready for custom backend APIs (Node.js, Go, Python, Laravel, etc.)
class RestAuthRemoteDataSource implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  final StreamController<UserEntity?> _authController =
      StreamController<UserEntity?>.broadcast();
  UserEntity? _currentUser;

  RestAuthRemoteDataSource({ApiClient? apiClient})
      : _apiClient = apiClient ?? HttpApiClient();

  @override
  Stream<UserEntity?> watchAuthState() => _authController.stream;

  @override
  Future<UserEntity?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    try {
      final response = await _apiClient.get('/auth/me');
      if (response != null && response is Map<String, dynamic>) {
        _currentUser = UserEntity.fromJson(response);
        _authController.add(_currentUser);
        return _currentUser;
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<UserEntity> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    final response = await _apiClient.post('/auth/login', body: {
      'email': email.trim(),
      'password': password,
    });

    final user = UserEntity.fromJson(response['user'] as Map<String, dynamic>);
    _currentUser = user;
    _authController.add(user);
    return user;
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
    final response = await _apiClient.post('/auth/register', body: {
      'email': email.trim(),
      'password': password,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'partnerName': partnerName,
      'anniversaryDate': anniversaryDate?.toIso8601String(),
    });

    final user = UserEntity.fromJson(response['user'] as Map<String, dynamic>);
    _currentUser = user;
    _authController.add(user);
    return user;
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    throw UnimplementedError(
        'Configure custom backend Google OAuth endpoint /auth/google');
  }

  @override
  Future<UserEntity> signInWithFacebook() async {
    throw UnimplementedError(
        'Configure custom backend Facebook OAuth endpoint /auth/facebook');
  }

  @override
  Future<UserEntity> signInWithApple() async {
    throw UnimplementedError(
        'Configure custom backend Apple OAuth endpoint /auth/apple');
  }

  @override
  Future<UserEntity> updateProfile({
    String? displayName,
    String? photoUrl,
    String? partnerName,
    DateTime? anniversaryDate,
    String? bio,
  }) async {
    final response = await _apiClient.put('/auth/profile', body: {
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (partnerName != null) 'partnerName': partnerName,
      if (anniversaryDate != null)
        'anniversaryDate': anniversaryDate.toIso8601String(),
      if (bio != null) 'bio': bio,
    });

    final user = UserEntity.fromJson(response['user'] as Map<String, dynamic>);
    _currentUser = user;
    _authController.add(user);
    return user;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.post('/auth/change-password', body: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _apiClient
        .post('/auth/forgot-password', body: {'email': email.trim()});
  }

  @override
  Future<void> signOut() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (_) {}
    _currentUser = null;
    _authController.add(null);
  }
}
