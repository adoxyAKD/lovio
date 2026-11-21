enum Environment { dev, staging, prod }

enum BackendType {
  firebase,
  restApi,
}

class AppConfig {
  final Environment environment;
  final BackendType backendType;
  final String apiBaseUrl;
  final bool enableAnalytics;
  final bool enableCrashlytics;

  const AppConfig({
    required this.environment,
    this.backendType = BackendType.firebase,
    required this.apiBaseUrl,
    this.enableAnalytics = true,
    this.enableCrashlytics = true,
  });

  static AppConfig current = const AppConfig(
    environment: Environment.dev,
    backendType: BackendType.firebase,
    apiBaseUrl: 'https://api.lovio.app/api/v1',
    enableAnalytics: false,
    enableCrashlytics: false,
  );
}
