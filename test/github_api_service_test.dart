import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:github_users_app/data/datasources/github_api_service.dart';
import 'package:github_users_app/core/exceptions/app_exceptions.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late GitHubApiService apiService;
  late MockHttpClient mockClient;

  setUp(() {
    mockClient = MockHttpClient();
    apiService = GitHubApiService(client: mockClient);
  });

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://api.github.com/users'));
  });

  group('GitHubApiService', () {
    group('getUsers', () {
      test('should return list of users on successful response', () async {
        final mockResponse = [
          {
            'id': 1,
            'login': 'mojombo',
            'avatar_url': 'https://avatars.githubusercontent.com/u/1?v=4',
            'html_url': 'https://github.com/mojombo',
            'type': 'User',
          },
          {
            'id': 2,
            'login': 'defunkt',
            'avatar_url': 'https://avatars.githubusercontent.com/u/2?v=4',
            'html_url': 'https://github.com/defunkt',
            'type': 'User',
          },
        ];

        when(() => mockClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(json.encode(mockResponse), 200));

        final users = await apiService.getUsers();

        expect(users.length, 2);
        expect(users[0].id, 1);
        expect(users[0].login, 'mojombo');
        expect(users[1].id, 2);
        expect(users[1].login, 'defunkt');
      });

      test('should throw ApiException on error response', () async {
        when(() => mockClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response('Error', 500));

        expect(
          () => apiService.getUsers(),
          throwsA(isA<ApiException>()),
        );
      });

      test('should throw ApiException with rate limit message on 403', () async {
        when(() => mockClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response('Rate limit exceeded', 403));

        expect(
          () => apiService.getUsers(),
          throwsA(
            isA<ApiException>().having(
              (e) => e.message,
              'message',
              contains('rate limit'),
            ),
          ),
        );
      });

      test('should use since parameter for pagination', () async {
        when(() => mockClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response('[]', 200));

        await apiService.getUsers(since: 100);

        verify(() => mockClient.get(
              any(that: predicate<Uri>((uri) => uri.queryParameters['since'] == '100')),
              headers: any(named: 'headers'),
            )).called(1);
      });
    });

    group('getUserDetail', () {
      test('should return user detail on successful response', () async {
        final mockResponse = {
          'id': 1,
          'login': 'octocat',
          'avatar_url': 'https://avatars.githubusercontent.com/u/1?v=4',
          'html_url': 'https://github.com/octocat',
          'type': 'User',
          'name': 'The Octocat',
          'company': '@github',
          'blog': 'https://github.blog',
          'location': 'San Francisco',
          'email': null,
          'bio': 'A cat',
          'public_repos': 8,
          'public_gists': 8,
          'followers': 1000,
          'following': 50,
          'created_at': '2011-01-25T18:44:36Z',
        };

        when(() => mockClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(json.encode(mockResponse), 200));

        final user = await apiService.getUserDetail('octocat');

        expect(user.id, 1);
        expect(user.login, 'octocat');
        expect(user.name, 'The Octocat');
        expect(user.followers, 1000);
      });

      test('should throw NotFoundException on 404', () async {
        when(() => mockClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response('Not found', 404));

        expect(
          () => apiService.getUserDetail('nonexistent'),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('searchUsers', () {
      test('should return search results on successful response', () async {
        final mockResponse = {
          'total_count': 2,
          'incomplete_results': false,
          'items': [
            {
              'id': 1,
              'login': 'octocat',
              'avatar_url': 'https://avatars.githubusercontent.com/u/1?v=4',
              'html_url': 'https://github.com/octocat',
              'type': 'User',
            },
          ],
        };

        when(() => mockClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(json.encode(mockResponse), 200));

        final users = await apiService.searchUsers('octocat');

        expect(users.length, 1);
        expect(users[0].login, 'octocat');
      });

      test('should return empty list for empty query', () async {
        final users = await apiService.searchUsers('');

        expect(users, isEmpty);
        verifyNever(() => mockClient.get(any(), headers: any(named: 'headers')));
      });
    });
  });
}
