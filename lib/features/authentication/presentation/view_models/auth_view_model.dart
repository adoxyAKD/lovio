import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/config/app_config.dart';
import '../../data/data_sources/auth_preferences.dart';
import '../../data/data_sources/auth_remote_data_source.dart';
import '../../data/data_sources/firebase_auth_remote_data_source.dart';
import '../../data/data_sources/rest_auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Active Remote Authentication Provider (Firebase or REST API)
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  if (AppConfig.current.backendType == BackendType.restApi) {
    return RestAuthRemoteDataSource();
  }
  return FirebaseAuthRemoteDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource: remote);
});

class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final bool isFirstTime;
  final String? errorMessage;
  final String? successMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isFirstTime = false,
    this.errorMessage,
    this.successMessage,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserEntity? user,
    bool clearUser = false,
    bool? isLoading,
    bool? isFirstTime,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      isFirstTime: isFirstTime ?? this.isFirstTime,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  StreamSubscription<UserEntity?>? _authSubscription;

  AuthNotifier(this._repository) : super(const AuthState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    // 1. Load cached user profile immediately with 0ms delay
    final cachedUser = await AuthPreferences.getCachedUser();
    final hasSeen = await AuthPreferences.hasSeenSignUp();
    if (cachedUser != null && mounted) {
      state = state.copyWith(
        user: cachedUser,
        isLoading: false,
        isFirstTime: false,
      );
    }

    // 2. Fetch latest user from repository (Firebase / REST)
    try {
      final initialUser = await _repository.getCurrentUser();
      if (initialUser != null) {
        await AuthPreferences.saveCachedUser(initialUser);
      }
      if (!mounted) return;
      state = state.copyWith(
        user: initialUser ?? cachedUser,
        isLoading: false,
        isFirstTime: !hasSeen,
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false);
    }

    _authSubscription = _repository.watchAuthState().listen((user) async {
      if (!mounted) return;
      if (user != null) {
        await AuthPreferences.saveCachedUser(user);
      }
      state = state.copyWith(
        user: user,
        clearUser: user == null,
        isLoading: false,
      );
    });
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  Future<void> markFirstTimeComplete() async {
    await AuthPreferences.markSignUpSeen();
    state = state.copyWith(isFirstTime: false);
  }

  Future<bool> signInWithEmail(String email, String password) async {
    state =
        state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final user = await _repository.signInWithEmailPassword(email, password);
      await AuthPreferences.saveCachedUser(user);
      state = state.copyWith(
        user: user,
        isLoading: false,
        successMessage: 'Welcome back, ${user.displayName}! 💕',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    String? photoUrl,
    String? partnerName,
    DateTime? anniversaryDate,
  }) async {
    state =
        state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final user = await _repository.signUpWithEmailPassword(
        email: email,
        password: password,
        displayName: displayName,
        photoUrl: photoUrl,
        partnerName: partnerName,
        anniversaryDate: anniversaryDate,
      );
      await AuthPreferences.markSignUpSeen();
      await AuthPreferences.saveCachedUser(user);
      state = state.copyWith(
        user: user,
        isFirstTime: false,
        isLoading: false,
        successMessage: 'Account created! Welcome to Lovio ✨',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.signInWithGoogle();
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> signInWithFacebook() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.signInWithFacebook();
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> signInWithApple() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.signInWithApple();
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateProfile({
    String? displayName,
    String? photoUrl,
    String? partnerName,
    DateTime? anniversaryDate,
    String? bio,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updated = await _repository.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
        partnerName: partnerName,
        anniversaryDate: anniversaryDate,
        bio: bio,
      );
      await AuthPreferences.saveCachedUser(updated);
      state = state.copyWith(
        user: updated,
        isLoading: false,
        successMessage: 'Profile updated successfully ✨',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Password updated successfully! 🔒',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.signOut();
      await AuthPreferences.clearCachedUser();
      state = state.copyWith(clearUser: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
