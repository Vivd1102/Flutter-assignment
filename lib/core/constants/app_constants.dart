/// API constants
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.github.com';
  static const String usersEndpoint = '/users';
  static const String searchUsersEndpoint = '/search/users';

  static const int defaultPerPage = 30;
  static const int searchDebounceMs = 500;
}

/// Storage keys
class StorageKeys {
  StorageKeys._();

  static const String favorites = 'favorites';
  static const String cachedUsers = 'cached_users';
}
