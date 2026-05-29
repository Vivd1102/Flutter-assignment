import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../models/github_user.dart';

/// Local data source for caching and favorites
class LocalDataSource {
  final SharedPreferences _prefs;

  LocalDataSource(this._prefs);

  /// Get all favorite users
  List<GitHubUser> getFavorites() {
    try {
      final jsonString = _prefs.getString(StorageKeys.favorites);
      if (jsonString == null || jsonString.isEmpty) return [];

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => GitHubUser.fromJson(json)).toList();
    } catch (e) {
      throw CacheException('Failed to read favorites: ${e.toString()}');
    }
  }

  /// Save favorites list
  Future<void> saveFavorites(List<GitHubUser> favorites) async {
    try {
      final jsonString = json.encode(favorites.map((u) => u.toJson()).toList());
      await _prefs.setString(StorageKeys.favorites, jsonString);
    } catch (e) {
      throw CacheException('Failed to save favorites: ${e.toString()}');
    }
  }

  /// Add user to favorites
  Future<void> addFavorite(GitHubUser user) async {
    final favorites = getFavorites();
    if (!favorites.any((u) => u.id == user.id)) {
      favorites.add(user);
      await saveFavorites(favorites);
    }
  }

  /// Remove user from favorites
  Future<void> removeFavorite(int userId) async {
    final favorites = getFavorites();
    favorites.removeWhere((u) => u.id == userId);
    await saveFavorites(favorites);
  }

  /// Check if user is in favorites
  bool isFavorite(int userId) {
    final favorites = getFavorites();
    return favorites.any((u) => u.id == userId);
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(GitHubUser user) async {
    if (isFavorite(user.id)) {
      await removeFavorite(user.id);
      return false;
    } else {
      await addFavorite(user);
      return true;
    }
  }

  /// Get cached users (for offline mode)
  List<GitHubUser> getCachedUsers() {
    try {
      final jsonString = _prefs.getString(StorageKeys.cachedUsers);
      if (jsonString == null || jsonString.isEmpty) return [];

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => GitHubUser.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Cache users for offline mode
  Future<void> cacheUsers(List<GitHubUser> users) async {
    try {
      final jsonString = json.encode(users.map((u) => u.toJson()).toList());
      await _prefs.setString(StorageKeys.cachedUsers, jsonString);
    } catch (e) {
      // Silently fail caching
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    await _prefs.remove(StorageKeys.cachedUsers);
  }
}
