class AppRoutes {
  AppRoutes._();

  // Splash & Onboarding
  static const String splash = '/splash';

  // Auth Routes
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';

  // Core 5-Tab Dashboard Routes
  static const String home = '/';
  static const String explore = '/explore';
  static const String create = '/create';
  static const String createPageWrite = '/create/page/write';
  static const String createPageEditor = '/create/page/editor';
  static const String createPagePreview = '/create/page/preview';
  static const String moments = '/moments';
  static const String inbox = '/inbox';

  // Additional Dashboard Routes
  static const String library = '/library';
  static const String profile = '/profile';
  static const String notifications = '/notifications';

  // Dedicated Settings Pages
  static const String appSettings = '/settings/app';
  static const String themeSettings = '/settings/theme';
  static const String appearanceSettings = '/settings/appearance';
  static const String accountSettings = '/settings/account';

  // Shared Card Deep Link Route
  static const String sharedPage = '/p/:token';
}
