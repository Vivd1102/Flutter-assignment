import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:github_users_app/data/models/github_user.dart';
import 'package:github_users_app/presentation/widgets/user_card.dart';
import 'package:github_users_app/presentation/widgets/empty_state_widget.dart';
import 'package:github_users_app/presentation/widgets/error_widget.dart' as app_error;

void main() {
  setUp(() {
    Get.reset();
  });

  group('GitHubUser Model Tests', () {
    test('should create GitHubUser from JSON', () {
      final json = {
        'id': 1,
        'login': 'octocat',
        'avatar_url': 'https://avatars.githubusercontent.com/u/1?v=4',
        'html_url': 'https://github.com/octocat',
        'type': 'User',
      };

      final user = GitHubUser.fromJson(json);

      expect(user.id, 1);
      expect(user.login, 'octocat');
      expect(user.avatarUrl, 'https://avatars.githubusercontent.com/u/1?v=4');
      expect(user.htmlUrl, 'https://github.com/octocat');
      expect(user.type, 'User');
    });

    test('should convert GitHubUser to JSON', () {
      final user = GitHubUser(
        id: 1,
        login: 'octocat',
        avatarUrl: 'https://avatars.githubusercontent.com/u/1?v=4',
        htmlUrl: 'https://github.com/octocat',
        type: 'User',
      );

      final json = user.toJson();

      expect(json['id'], 1);
      expect(json['login'], 'octocat');
      expect(json['avatar_url'], 'https://avatars.githubusercontent.com/u/1?v=4');
      expect(json['html_url'], 'https://github.com/octocat');
      expect(json['type'], 'User');
    });

    test('should compare two GitHubUsers by id', () {
      final user1 = GitHubUser(
        id: 1,
        login: 'octocat',
        avatarUrl: 'https://example.com/avatar.png',
        htmlUrl: 'https://github.com/octocat',
        type: 'User',
      );

      final user2 = GitHubUser(
        id: 1,
        login: 'different',
        avatarUrl: 'https://example.com/different.png',
        htmlUrl: 'https://github.com/different',
        type: 'User',
      );

      expect(user1, equals(user2));
    });
  });

  group('GitHubUserDetail Model Tests', () {
    test('should create GitHubUserDetail from JSON', () {
      final json = {
        'id': 1,
        'login': 'octocat',
        'avatar_url': 'https://avatars.githubusercontent.com/u/1?v=4',
        'html_url': 'https://github.com/octocat',
        'type': 'User',
        'name': 'The Octocat',
        'company': '@github',
        'blog': 'https://github.blog',
        'location': 'San Francisco',
        'email': 'octocat@github.com',
        'bio': 'A cat that loves to code',
        'public_repos': 8,
        'public_gists': 8,
        'followers': 1000,
        'following': 50,
        'created_at': '2011-01-25T18:44:36Z',
      };

      final user = GitHubUserDetail.fromJson(json);

      expect(user.id, 1);
      expect(user.login, 'octocat');
      expect(user.name, 'The Octocat');
      expect(user.company, '@github');
      expect(user.publicRepos, 8);
      expect(user.followers, 1000);
    });

    test('should convert GitHubUserDetail to basic GitHubUser', () {
      final detail = GitHubUserDetail(
        id: 1,
        login: 'octocat',
        avatarUrl: 'https://example.com/avatar.png',
        htmlUrl: 'https://github.com/octocat',
        type: 'User',
        name: 'The Octocat',
        publicRepos: 8,
        publicGists: 8,
        followers: 1000,
        following: 50,
        createdAt: DateTime.now(),
      );

      final basicUser = detail.toBasicUser();

      expect(basicUser.id, 1);
      expect(basicUser.login, 'octocat');
      expect(basicUser is GitHubUserDetail, false);
    });
  });

  group('Widget Tests', () {
    testWidgets('UserCard displays user information', (WidgetTester tester) async {
      final user = GitHubUser(
        id: 1,
        login: 'testuser',
        avatarUrl: 'https://example.com/avatar.png',
        htmlUrl: 'https://github.com/testuser',
        type: 'User',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserCard(
              user: user,
              isFavorite: false,
              onTap: () {},
              onFavoriteToggle: () {},
            ),
          ),
        ),
      );

      expect(find.text('testuser'), findsOneWidget);
      expect(find.text('User'), findsOneWidget);
      expect(find.text('ID: 1'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('UserCard shows filled heart when favorite', (WidgetTester tester) async {
      final user = GitHubUser(
        id: 1,
        login: 'testuser',
        avatarUrl: 'https://example.com/avatar.png',
        htmlUrl: 'https://github.com/testuser',
        type: 'User',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserCard(
              user: user,
              isFavorite: true,
              onTap: () {},
              onFavoriteToggle: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('EmptyFavoritesWidget displays correct message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyFavoritesWidget(),
          ),
        ),
      );

      expect(find.text('No Favorites Yet'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('NoSearchResultsWidget displays query', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NoSearchResultsWidget(query: 'testquery'),
          ),
        ),
      );

      expect(find.text('No Results Found'), findsOneWidget);
      expect(find.textContaining('testquery'), findsOneWidget);
    });

    testWidgets('ErrorWidget displays error message and retry button', (WidgetTester tester) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: app_error.ErrorWidget(
              message: 'Test error message',
              onRetry: () {
                retryPressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Test error message'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(retryPressed, true);
    });

    testWidgets('ErrorWidget shows network icon for network errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: app_error.ErrorWidget(
              message: 'No internet',
              isNetworkError: true,
            ),
          ),
        ),
      );

      expect(find.text('No Internet Connection'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });
  });
}
