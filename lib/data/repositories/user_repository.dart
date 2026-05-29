import '../../core/exceptions/app_exceptions.dart';
import '../../core/network/network_service.dart';
import '../datasources/github_api_service.dart';
import '../datasources/local_data_source.dart';
import '../models/github_user.dart';

/// Repository that manages data from remote and local sources
class UserRepository {
  final GitHubApiService _apiService;
  final LocalDataSource _localDataSource;
  final NetworkService _networkService;

  UserRepository({
    required GitHubApiService apiService,
    required LocalDataSource localDataSource,
    required NetworkService networkService,
  })  : _apiService = apiService,
        _localDataSource = localDataSource,
        _networkService = networkService;

  /// Get users list with offline fallback
  Future<List<GitHubUser>> getUsers({int? since, int perPage = 30}) async {
    if (await _networkService.hasConnection()) {
      try {
        final users = await _apiService.getUsers(since: since, perPage: perPage);
        // Cache users only for initial load (without pagination)
        if (since == null) {
          await _localDataSource.cacheUsers(users);
        }
        return users;
      } catch (e) {
        // If API fails, try to get cached data
        final cached = _localDataSource.getCachedUsers();
        if (cached.isNotEmpty) return cached;
        rethrow;
      }
    } else {
      // Offline - return cached data
      final cached = _localDataSource.getCachedUsers();
      if (cached.isEmpty) {
        throw NetworkException('No internet connection and no cached data available');
      }
      return cached;
    }
  }

  /// Get user details
  Future<GitHubUserDetail> getUserDetail(String username) async {
    if (!await _networkService.hasConnection()) {
      throw NetworkException();
    }
    return _apiService.getUserDetail(username);
  }

  /// Search users
  Future<List<GitHubUser>> searchUsers(String query, {int page = 1, int perPage = 30}) async {
    if (!await _networkService.hasConnection()) {
      throw NetworkException();
    }
    return _apiService.searchUsers(query, page: page, perPage: perPage);
  }

  /// Get all favorites
  List<GitHubUser> getFavorites() {
    return _localDataSource.getFavorites();
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(GitHubUser user) async {
    return _localDataSource.toggleFavorite(user);
  }

  /// Check if user is favorite
  bool isFavorite(int userId) {
    return _localDataSource.isFavorite(userId);
  }

  /// Add to favorites
  Future<void> addFavorite(GitHubUser user) async {
    await _localDataSource.addFavorite(user);
  }

  /// Remove from favorites
  Future<void> removeFavorite(int userId) async {
    await _localDataSource.removeFavorite(userId);
  }
}
