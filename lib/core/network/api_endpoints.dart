/// Centralized backend API endpoints
class ApiEndpoints {
  ApiEndpoints._();

  // Creations / Books endpoints
  static const String creations = '/creations';
  static String creationById(String id) => '/creations/$id';
  static String syncCreations = '/creations/sync';

  // Templates
  static const String templates = '/templates';
  static String templateById(String id) => '/templates/$id';

  // User Profile & Social
  static const String profile = '/users/profile';
  static const String inbox = '/inbox';
}
