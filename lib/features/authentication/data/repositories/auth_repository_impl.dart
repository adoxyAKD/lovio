import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';
import '../data_sources/firebase_auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({AuthRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? FirebaseAuthRemoteDataSource();

  @override
  Stream<UserEntity?> watchAuthState() => _remoteDataSource.watchAuthState();

  @override
  Future<UserEntity?> getCurrentUser() => _remoteDataSource.getCurrentUser();

  @override
  Future<UserEntity> signInWithEmailPassword(String email, String password) =>
      _remoteDataSource.signInWithEmailPassword(email, password);

  @override
  Future<UserEntity> signUpWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
    String? photoUrl,
    String? partnerName,
    DateTime? anniversaryDate,
  }) =>
      _remoteDataSource.signUpWithEmailPassword(
        email: email,
        password: password,
        displayName: displayName,
        photoUrl: photoUrl,
        partnerName: partnerName,
        anniversaryDate: anniversaryDate,
      );

  @override
  Future<UserEntity> signInWithGoogle() => _remoteDataSource.signInWithGoogle();

  @override
  Future<UserEntity> signInWithFacebook() =>
      _remoteDataSource.signInWithFacebook();

  @override
  Future<UserEntity> signInWithApple() => _remoteDataSource.signInWithApple();

  @override
  Future<UserEntity> updateProfile({
    String? displayName,
    String? photoUrl,
    String? partnerName,
    DateTime? anniversaryDate,
    String? bio,
  }) =>
      _remoteDataSource.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
        partnerName: partnerName,
        anniversaryDate: anniversaryDate,
        bio: bio,
      );

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _remoteDataSource.sendPasswordResetEmail(email);

  @override
  Future<void> signOut() => _remoteDataSource.signOut();
}
