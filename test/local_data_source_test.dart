import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:github_users_app/data/datasources/local_data_source.dart';
import 'package:github_users_app/data/models/github_user.dart';

void main() {
  late LocalDataSource localDataSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    localDataSource = LocalDataSource(prefs);
  });

  group('LocalDataSource', () {
    group('Favorites', () {
      final testUser = GitHubUser(
        id: 1,
        login: 'testuser',
        avatarUrl: 'https://example.com/avatar.png',
        htmlUrl: 'https://github.com/testuser',
        type: 'User',
      );

      test('should return empty list when no favorites', () {
        final favorites = localDataSource.getFavorites();
        expect(favorites, isEmpty);
      });

      test('should add user to favorites', () async {
        await localDataSource.addFavorite(testUser);
        final favorites = localDataSource.getFavorites();

        expect(favorites.length, 1);
        expect(favorites[0].id, testUser.id);
        expect(favorites[0].login, testUser.login);
      });

      test('should not add duplicate user to favorites', () async {
        await localDataSource.addFavorite(testUser);
        await localDataSource.addFavorite(testUser);

        final favorites = localDataSource.getFavorites();
        expect(favorites.length, 1);
      });

      test('should remove user from favorites', () async {
        await localDataSource.addFavorite(testUser);
        await localDataSource.removeFavorite(testUser.id);

        final favorites = localDataSource.getFavorites();
        expect(favorites, isEmpty);
      });

      test('should check if user is favorite', () async {
        expect(localDataSource.isFavorite(testUser.id), false);

        await localDataSource.addFavorite(testUser);
        expect(localDataSource.isFavorite(testUser.id), true);

        await localDataSource.removeFavorite(testUser.id);
        expect(localDataSource.isFavorite(testUser.id), false);
      });

      test('should toggle favorite status', () async {
        // Add to favorites
        bool result = await localDataSource.toggleFavorite(testUser);
        expect(result, true);
        expect(localDataSource.isFavorite(testUser.id), true);

        // Remove from favorites
        result = await localDataSource.toggleFavorite(testUser);
        expect(result, false);
        expect(localDataSource.isFavorite(testUser.id), false);
      });

      test('should persist multiple favorites', () async {
        final user1 = GitHubUser(
          id: 1,
          login: 'user1',
          avatarUrl: 'https://example.com/1.png',
          htmlUrl: 'https://github.com/user1',
          type: 'User',
        );

        final user2 = GitHubUser(
          id: 2,
          login: 'user2',
          avatarUrl: 'https://example.com/2.png',
          htmlUrl: 'https://github.com/user2',
          type: 'Organization',
        );

        await localDataSource.addFavorite(user1);
        await localDataSource.addFavorite(user2);

        final favorites = localDataSource.getFavorites();
        expect(favorites.length, 2);
        expect(favorites.any((u) => u.id == 1), true);
        expect(favorites.any((u) => u.id == 2), true);
      });
    });

    group('Cached Users', () {
      test('should return empty list when no cached users', () {
        final cached = localDataSource.getCachedUsers();
        expect(cached, isEmpty);
      });

      test('should cache users', () async {
        final users = [
          GitHubUser(
            id: 1,
            login: 'user1',
            avatarUrl: 'https://example.com/1.png',
            htmlUrl: 'https://github.com/user1',
            type: 'User',
          ),
          GitHubUser(
            id: 2,
            login: 'user2',
            avatarUrl: 'https://example.com/2.png',
            htmlUrl: 'https://github.com/user2',
            type: 'User',
          ),
        ];

        await localDataSource.cacheUsers(users);
        final cached = localDataSource.getCachedUsers();

        expect(cached.length, 2);
        expect(cached[0].id, 1);
        expect(cached[1].id, 2);
      });

      test('should clear cache', () async {
        final users = [
          GitHubUser(
            id: 1,
            login: 'user1',
            avatarUrl: 'https://example.com/1.png',
            htmlUrl: 'https://github.com/user1',
            type: 'User',
          ),
        ];

        await localDataSource.cacheUsers(users);
        await localDataSource.clearCache();

        final cached = localDataSource.getCachedUsers();
        expect(cached, isEmpty);
      });
    });
  });
}
