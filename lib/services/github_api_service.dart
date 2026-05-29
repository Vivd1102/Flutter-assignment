import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/github_user.dart';

class GitHubApiService {
  static const String _baseUrl = 'https://api.github.com';
  
  final http.Client _client;
  
  GitHubApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches a list of GitHub users
  /// [since] - A user ID. Only users with an ID greater than this ID will be returned.
  /// [perPage] - Number of results per page (max 100)
  Future<List<GitHubUser>> getUsers({int? since, int perPage = 30}) async {
    final queryParams = <String, String>{
      'per_page': perPage.toString(),
    };
    
    if (since != null) {
      queryParams['since'] = since.toString();
    }

    final uri = Uri.parse('$_baseUrl/users').replace(queryParameters: queryParams);
    
    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => GitHubUser.fromJson(json)).toList();
    } else {
      throw GitHubApiException(
        'Failed to load users',
        response.statusCode,
        response.body,
      );
    }
  }

  /// Fetches detailed information about a specific user
  Future<GitHubUserDetail> getUserDetail(String username) async {
    final uri = Uri.parse('$_baseUrl/users/$username');
    
    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return GitHubUserDetail.fromJson(jsonData);
    } else {
      throw GitHubApiException(
        'Failed to load user details',
        response.statusCode,
        response.body,
      );
    }
  }

  /// Searches for users matching a query
  Future<List<GitHubUser>> searchUsers(String query, {int page = 1, int perPage = 30}) async {
    if (query.isEmpty) {
      return [];
    }

    final uri = Uri.parse('$_baseUrl/search/users').replace(
      queryParameters: {
        'q': query,
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
    );
    
    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> items = jsonData['items'] ?? [];
      return items.map((json) => GitHubUser.fromJson(json)).toList();
    } else {
      throw GitHubApiException(
        'Failed to search users',
        response.statusCode,
        response.body,
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

class GitHubApiException implements Exception {
  final String message;
  final int statusCode;
  final String responseBody;

  GitHubApiException(this.message, this.statusCode, this.responseBody);

  @override
  String toString() => 'GitHubApiException: $message (Status: $statusCode)';
}
