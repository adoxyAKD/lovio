import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/deep_link_service.dart';
import '../../features/authentication/presentation/screens/sign_in_screen.dart';
import '../../features/authentication/presentation/screens/sign_up_screen.dart';
import '../../features/authentication/presentation/view_models/auth_view_model.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/creation/presentation/screens/create_hub_screen.dart';
import '../../features/creation/presentation/screens/page_content_write_screen.dart';
import '../../features/creation/presentation/screens/page_editor_screen.dart';
import '../../features/creation/presentation/screens/page_preview_screen.dart';
import '../../features/creation/presentation/screens/shared_card_viewer_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/inbox/presentation/screens/inbox_screen.dart';
import '../../features/library/presentation/screens/library_screen.dart';
import '../../features/moments/presentation/screens/moments_screen.dart';
import '../../features/navigation/presentation/screens/main_navigation_shell.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/account_settings_screen.dart';
import '../../features/profile/presentation/screens/app_settings_screen.dart';
import '../../features/profile/presentation/screens/appearance_settings_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/theme_settings_screen.dart';
import 'routes.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNav');
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'homeNav');
final _exploreNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'exploreNav');
final _momentsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'momentsNav');
final _inboxNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'inboxNav');

class AuthRouterListenable extends ChangeNotifier {
  final Ref ref;

  AuthRouterListenable(this.ref) {
    ref.listen<AuthState>(authProvider, (_, __) {
      notifyListeners();
    });
  }
}

final authRouterListenableProvider = Provider<AuthRouterListenable>((ref) {
  return AuthRouterListenable(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final authListenable = ref.watch(authRouterListenableProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable:
        Listenable.merge([authListenable, DeepLinkService.instance]),
    debugLogDiagnostics: false,
    redirect: (context, state) {
      // 1. Highest Priority: Pending Deep Link token from MethodChannel or warm/cold start
      final pendingToken = DeepLinkService.instance.consumePendingToken();
      if (pendingToken != null && pendingToken.isNotEmpty) {
        DeepLinkService.instance.dismissAllModals();
        return '/p/$pendingToken';
      }

      // 2. Direct URI Parsing for Custom Schemes (lovio://) and Universal Web Links
      final uri = state.uri;
      if (uri.scheme == 'lovio' ||
          uri.host.contains('lovio') ||
          uri.host.contains('web.app') ||
          uri.path.startsWith('/p/') ||
          uri.path.startsWith('/card/') ||
          uri.path.startsWith('/page/')) {
        final extractedToken =
            DeepLinkService.instance.extractToken(state.uri.toString());
        if (extractedToken != null &&
            extractedToken.isNotEmpty &&
            state.matchedLocation != '/p/$extractedToken') {
          DeepLinkService.instance.dismissAllModals();
          return '/p/$extractedToken';
        }
      }

      final authState = ref.read(authProvider);

      // If still loading initial auth state, don't interrupt
      if (authState.isLoading) {
        return null;
      }

      final matchedLocation = state.matchedLocation;

      // Allow Splash Screen to complete its branded transition
      if (matchedLocation == AppRoutes.splash) {
        return null;
      }

      final isAuthenticated = authState.isAuthenticated;
      final isAuthRoute = matchedLocation == AppRoutes.signIn ||
          matchedLocation == AppRoutes.signUp;
      final isSharedRoute = matchedLocation.startsWith('/p/') ||
          matchedLocation.startsWith('/page/') ||
          matchedLocation.startsWith('/card/');

      // 3. Unauthenticated users cannot access protected screens (except shared cards & splash)
      if (!isAuthenticated) {
        if (isSharedRoute) {
          return null; // Publicly accessible without login
        }
        if (!isAuthRoute) {
          // Direct by default to Login (Sign In) page
          return AppRoutes.signIn;
        }
        return null;
      }

      // 4. Authenticated users should not see sign-in / sign-up screens
      if (isAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // Top-level Splash Screen Route
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => const MaterialPage(
          child: SplashScreen(),
        ),
      ),
      // Top-level Authentication Routes
      GoRoute(
        path: AppRoutes.signIn,
        name: 'signIn',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => const MaterialPage(
          child: SignInScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        name: 'signUp',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => const MaterialPage(
          child: SignUpScreen(),
        ),
      ),

      // Top-level Profile & Notifications Routes (from Top-Right Dashboard Actions)
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => const MaterialPage(
          child: ProfileScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => const MaterialPage(
          child: NotificationsScreen(),
        ),
      ),

      // Important Dates & Moments Route (Preserved)
      GoRoute(
        path: AppRoutes.moments,
        name: 'moments',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => const MaterialPage(
          child: MomentsScreen(),
        ),
      ),

      // Top-level Dedicated Full-Screen Creation Studio (No bottom navigation bar)
      GoRoute(
        path: AppRoutes.create,
        name: 'create',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => const MaterialPage(
          child: CreateHubScreen(),
        ),
      ),

      // Create a Page Flow (Dedicated Full-Screen Experience)
      GoRoute(
        path: AppRoutes.createPageWrite,
        name: 'createPageWrite',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => const MaterialPage(
          child: PageContentWriteScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.createPageEditor,
        name: 'createPageEditor',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final extra = state.extra;
          final initialPick = extra is Map && extra['pickImage'] == true;
          return MaterialPage(
            child: PageEditorScreen(initialPickImage: initialPick),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.createPagePreview,
        name: 'createPagePreview',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => const MaterialPage(
          child: PagePreviewScreen(),
        ),
      ),

      // Shared Card Deep Link / Viewer Routes (Accessible from WhatsApp or Web)
      GoRoute(
        path: '/p/:token',
        name: 'sharedPage',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final token = state.pathParameters['token'] ?? '';
          return MaterialPage(
            child: SharedCardViewerScreen(token: token),
          );
        },
      ),
      GoRoute(
        path: '/page/:token',
        name: 'sharedPageAlt',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final token = state.pathParameters['token'] ?? '';
          return MaterialPage(
            child: SharedCardViewerScreen(token: token),
          );
        },
      ),
      GoRoute(
        path: '/card/:token',
        name: 'sharedCardAlt',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final token = state.pathParameters['token'] ?? '';
          return MaterialPage(
            child: SharedCardViewerScreen(token: token),
          );
        },
      ),

      // Top-level Dedicated Settings Pages
      GoRoute(
        path: AppRoutes.themeSettings,
        name: 'themeSettings',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => const MaterialPage(
          child: ThemeSettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.appearanceSettings,
        name: 'appearanceSettings',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => const MaterialPage(
          child: AppearanceSettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.accountSettings,
        name: 'accountSettings',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => const MaterialPage(
          child: AccountSettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.appSettings,
        name: 'appSettings',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => const MaterialPage(
          child: AppSettingsScreen(),
        ),
      ),

      // Core 5-Tab Dashboard Navigation Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home (Social Feed)
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
              ),
            ],
          ),

          // Branch 1: Explore (Discover & Inspiration)
          StatefulShellBranch(
            navigatorKey: _exploreNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.explore,
                name: 'explore',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ExploreScreen(),
                ),
              ),
            ],
          ),

          // Branch 2: Library (Saved & Unsaved Creations)
          StatefulShellBranch(
            navigatorKey: _momentsNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.library,
                name: 'library',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: LibraryScreen(),
                ),
              ),
            ],
          ),

          // Branch 3: Inbox (Chats & Messaging)
          StatefulShellBranch(
            navigatorKey: _inboxNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.inbox,
                name: 'inbox',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: InboxScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
