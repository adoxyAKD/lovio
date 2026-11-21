import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovio/app/app.dart';
import 'package:lovio/features/authentication/domain/entities/user_entity.dart';
import 'package:lovio/features/authentication/domain/repositories/auth_repository.dart';
import 'package:lovio/features/authentication/presentation/view_models/auth_view_model.dart';
import 'package:lovio/features/navigation/presentation/widgets/dashboard_top_actions.dart';
import 'package:lovio/features/navigation/presentation/widgets/lovio_bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthRepository implements AuthRepository {
  final UserEntity? _user;
  final StreamController<UserEntity?> _controller =
      StreamController<UserEntity?>.broadcast();

  _FakeAuthRepository([this._user]);

  @override
  Stream<UserEntity?> watchAuthState() => _controller.stream;

  @override
  Future<UserEntity?> getCurrentUser() async => _user;

  @override
  Future<UserEntity> signInWithEmailPassword(
          String email, String password) async =>
      _user!;

  @override
  Future<UserEntity> signUpWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
    String? photoUrl,
    String? partnerName,
    DateTime? anniversaryDate,
  }) async =>
      _user!;

  @override
  Future<UserEntity> signInWithGoogle() async => _user!;

  @override
  Future<UserEntity> signInWithFacebook() async => _user!;

  @override
  Future<UserEntity> signInWithApple() async => _user!;

  @override
  Future<UserEntity> updateProfile({
    String? displayName,
    String? photoUrl,
    String? partnerName,
    DateTime? anniversaryDate,
    String? bio,
  }) async =>
      _user!;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> signOut() async {
    _controller.add(null);
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final testUser = UserEntity(
    id: 'usr_test_1',
    email: 'alexander@lovio.app',
    displayName: 'Alexander',
    partnerName: 'Sophia',
    anniversaryDate: DateTime(2025, 1, 1),
    createdAt: DateTime(2025, 1, 1),
  );

  testWidgets('LovioApp renders with 5-tab dashboard navigation shell smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider
              .overrideWithValue(_FakeAuthRepository(testUser)),
        ],
        child: const LovioApp(),
      ),
    );

    // Initial pump
    await tester.pumpAndSettle();

    // Verify Lovio app title, bottom navigation bar, and Top-Right Actions
    expect(find.byType(LovioBottomNavBar), findsOneWidget);
    expect(find.byType(DashboardTopActions), findsOneWidget);
    expect(find.text('Lovio'), findsOneWidget);
    expect(find.text('Share Love & Cherished Stories ✨'), findsOneWidget);

    // Verify all tabs exist in bottom navigation: Home, Explore, (+), Library, Inbox
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(
        find.descendant(
          of: find.byType(LovioBottomNavBar),
          matching: find.byIcon(Icons.add_rounded),
        ),
        findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);

    // Tap Library tab
    await tester.tap(find.text('Library'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Library Screen is visible
    expect(find.text('My Library'), findsOneWidget);

    // Tap Explore tab
    await tester.tap(find.text('Explore'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap Create (+) Center Button
    await tester.tap(
      find.descendant(
        of: find.byType(LovioBottomNavBar),
        matching: find.byIcon(Icons.add_rounded),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Create Hub Screen is visible with creation options
    expect(find.text('Express Your Heart'), findsOneWidget);
    expect(find.text('Create Short Book'), findsOneWidget);

    // Scroll down to check Saved Content section
    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Saved Content & Drafts'), findsOneWidget);
  });

  testWidgets(
      'First-time unauthenticated user is guarded and redirected to Sign In (Login) screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository(null)),
        ],
        child: const LovioApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Verify redirection to Sign In (Login) screen as default landing page
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In to Lovio'), findsOneWidget);
    expect(find.text("Don't have an account? "), findsOneWidget);
  });
}
