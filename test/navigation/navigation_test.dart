import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovio/app/router/app_router.dart';
import 'package:lovio/app/router/routes.dart';
import 'package:lovio/core/services/deep_link_service.dart';

void main() {
  group('Lovio Router & Navigation Tests', () {
    test('Router provider initializes with initial route', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);
      expect(router, isNotNull);
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.splash);
    });

    test('DeepLinkService token extraction handles all shared card link patterns', () {
      final service = DeepLinkService.instance;

      // 1. Custom Schemes
      expect(service.extractToken('lovio://p/2affb4f75d'), '2affb4f75d');
      expect(service.extractToken('lovio://card/5642b9f35c'), '5642b9f35c');
      expect(service.extractToken('lovio://page/my_token_123'), 'my_token_123');
      expect(service.extractToken('lovio://2affb4f75d'), '2affb4f75d');

      // 2. Universal Web Links (Firebase Hosting & Custom Domain)
      expect(service.extractToken('https://lovio-e5990.web.app/p/2affb4f75d'), '2affb4f75d');
      expect(service.extractToken('https://lovio-e5990.firebaseapp.com/card/5642b9f35c'), '5642b9f35c');
      expect(service.extractToken('https://lovio.app/p/2affb4f75d'), '2affb4f75d');
      expect(service.extractToken('https://www.lovio.app/page/sample_card'), 'sample_card');

      // 3. Query Parameter Links
      expect(service.extractToken('https://lovio-e5990.web.app?token=2affb4f75d'), '2affb4f75d');
      expect(service.extractToken('https://lovio-e5990.web.app?p=2affb4f75d'), '2affb4f75d');

      // 4. Do NOT extract standard app navigation paths as card tokens
      expect(service.extractToken('/home'), isNull);
      expect(service.extractToken('/sign-in'), isNull);
      expect(service.extractToken('/sign-up'), isNull);
      expect(service.extractToken(''), isNull);
    });

    test('Route constants are correctly configured', () {
      // 5-Tab Dashboard Routes
      expect(AppRoutes.home, '/');
      expect(AppRoutes.explore, '/explore');
      expect(AppRoutes.create, '/create');
      expect(AppRoutes.moments, '/moments');
      expect(AppRoutes.inbox, '/inbox');

      // Additional Top-Right & Preserved Routes
      expect(AppRoutes.profile, '/profile');
      expect(AppRoutes.notifications, '/notifications');
      expect(AppRoutes.library, '/library');

      // Authentication Routes
      expect(AppRoutes.signIn, '/sign-in');
      expect(AppRoutes.signUp, '/sign-up');

      // Dedicated Settings Routes
      expect(AppRoutes.appSettings, '/settings/app');
      expect(AppRoutes.themeSettings, '/settings/theme');
      expect(AppRoutes.appearanceSettings, '/settings/appearance');
      expect(AppRoutes.accountSettings, '/settings/account');
    });
  });
}
