import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovio/features/authentication/domain/entities/user_entity.dart';
import 'package:lovio/features/authentication/domain/repositories/auth_repository.dart';
import 'package:lovio/features/authentication/presentation/view_models/auth_view_model.dart';

class FakeAuthRepository implements AuthRepository {
  UserEntity? _currentUser;
  final StreamController<UserEntity?> _controller =
      StreamController<UserEntity?>.broadcast();

  @override
  Stream<UserEntity?> watchAuthState() => _controller.stream;

  @override
  Future<UserEntity?> getCurrentUser() async => _currentUser;

  @override
  Future<UserEntity> signInWithEmailPassword(
      String email, String password) async {
    final user = UserEntity(
      id: 'usr_1',
      email: email,
      displayName: 'Alexander',
      partnerName: 'Sophia',
      anniversaryDate: DateTime(2025, 1, 1),
      createdAt: DateTime.now(),
    );
    _currentUser = user;
    _controller.add(user);
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
    final user = UserEntity(
      id: 'usr_2',
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      partnerName: partnerName,
      anniversaryDate: anniversaryDate,
      createdAt: DateTime.now(),
    );
    _currentUser = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    final user = UserEntity(
      id: 'usr_google',
      email: 'alex@gmail.com',
      displayName: 'Alexander Google',
      provider: AuthProviderType.google,
      createdAt: DateTime.now(),
    );
    _currentUser = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<UserEntity> signInWithFacebook() async {
    final user = UserEntity(
      id: 'usr_fb',
      email: 'alex@fb.com',
      displayName: 'Alexander FB',
      provider: AuthProviderType.facebook,
      createdAt: DateTime.now(),
    );
    _currentUser = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<UserEntity> signInWithApple() async {
    final user = UserEntity(
      id: 'usr_apple',
      email: 'alex@apple.com',
      displayName: 'Alexander Apple',
      provider: AuthProviderType.apple,
      createdAt: DateTime.now(),
    );
    _currentUser = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<UserEntity> updateProfile({
    String? displayName,
    String? photoUrl,
    String? partnerName,
    DateTime? anniversaryDate,
    String? bio,
  }) async {
    if (_currentUser == null) throw Exception('No user');
    final updated = _currentUser!.copyWith(
      displayName: displayName,
      photoUrl: photoUrl,
      partnerName: partnerName,
      anniversaryDate: anniversaryDate,
      bio: bio,
    );
    _currentUser = updated;
    _controller.add(updated);
    return updated;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }
}

void main() {
  group('UserEntity & Authentication Unit Tests', () {
    test('UserEntity serializes and deserializes to/from JSON correctly', () {
      final anniversary = DateTime(2025, 2, 14);
      final user = UserEntity(
        id: 'usr_abc',
        email: 'alexander@love.com',
        displayName: 'Alexander',
        photoUrl: '/path/to/avatar.jpg',
        partnerName: 'Sophia',
        anniversaryDate: anniversary,
        provider: AuthProviderType.email,
        createdAt: DateTime(2026, 1, 1),
      );

      final json = user.toJson();
      expect(json['id'], 'usr_abc');
      expect(json['displayName'], 'Alexander');
      expect(json['partnerName'], 'Sophia');
      expect(json['provider'], 'email');

      final deserialized = UserEntity.fromJson(json);
      expect(deserialized.id, user.id);
      expect(deserialized.email, user.email);
      expect(deserialized.partnerName, 'Sophia');
      expect(deserialized.anniversaryDate, anniversary);
      expect(deserialized.daysTogether, isNotNull);
    });

    test('AuthNotifier registers and updates authenticated state with details',
        () async {
      final fakeRepo = FakeAuthRepository();
      final notifier = AuthNotifier(fakeRepo);

      final success = await notifier.signUpWithEmail(
        email: 'alex@love.com',
        password: 'password123',
        displayName: 'Alexander',
        partnerName: 'Sophia',
        anniversaryDate: DateTime(2024, 1, 1),
      );

      expect(success, true);
      expect(notifier.state.isAuthenticated, true);
      expect(notifier.state.user?.displayName, 'Alexander');
      expect(notifier.state.user?.partnerName, 'Sophia');
      expect(notifier.state.user?.daysTogether, isNotNull);

      // Sign Out
      await notifier.signOut();
      expect(notifier.state.isAuthenticated, false);
      expect(notifier.state.user, isNull);
    });

    test('AuthNotifier handles Google sign in hook cleanly', () async {
      final fakeRepo = FakeAuthRepository();
      final notifier = AuthNotifier(fakeRepo);

      final success = await notifier.signInWithGoogle();
      expect(success, true);
      expect(notifier.state.isAuthenticated, true);
      expect(notifier.state.user?.provider, AuthProviderType.google);
    });
  });
}

