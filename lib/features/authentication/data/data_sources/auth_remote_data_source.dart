import '../../domain/entities/user_entity.dart';

/// Contract interface for any authentication service (Firebase, REST API, OAuth, etc.)
abstract class AuthRemoteDataSource {
  Stream<UserEntity?> watchAuthState();
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> signInWithEmailPassword(String email, String password);
  Future<UserEntity> signUpWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
    String? photoUrl,
    String? partnerName,
    DateTime? anniversaryDate,
  });
  Future<UserEntity> signInWithGoogle();
  Future<UserEntity> signInWithFacebook();
  Future<UserEntity> signInWithApple();
  Future<UserEntity> updateProfile({
    String? displayName,
    String? photoUrl,
    String? partnerName,
    DateTime? anniversaryDate,
    String? bio,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
}

