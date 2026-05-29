import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../models/github_user.dart';

/// Remote data source for GitHub API
class GitHubApiService {
  final http.Client _client;

  GitHubApiService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Accept': 'application/vnd.github.v3+json',
      };

  /// Fetch list of GitHub users
  Future<List<GitHubUser>> getUsers({int? since, int perPage = ApiConstants.defaultPerPage}) async {
    final queryParams = <String, String>{
      'per_page': perPage.toString(),
    };

    if (since != null) {
      queryParams['since'] = since.toString();
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.usersEndpoint}')
        .replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri, headers: _headers);
      return _handleListResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch users: ${e.toString()}');
    }
  }

  /// Fetch user details
  Future<GitHubUserDetail> getUserDetail(String username) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.usersEndpoint}/$username');

    try {
      final response = await _client.get(uri, headers: _headers);
      return _handleDetailResponse(response);
    } catch (e) {
      if (e is ApiException || e is NotFoundException) rethrow;
      throw ApiException('Failed to fetch user details: ${e.toString()}');
    }
  }

  /// Search users by query
  Future<List<GitHubUser>> searchUsers(String query, {int page = 1, int perPage = ApiConstants.defaultPerPage}) async {
    if (query.isEmpty) return [];

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.searchUsersEndpoint}')
        .replace(queryParameters: {
      'q': query,
      'page': page.toString(),
      'per_page': perPage.toString(),
    });

    try {
      final response = await _client.get(uri, headers: _headers);
      return _handleSearchResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to search users: ${e.toString()}');
    }
  }

  List<GitHubUser> _handleListResponse(http.Response response) {
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => GitHubUser.fromJson(json)).toList();
    }
    throw _createApiException(response);
  }

  GitHubUserDetail _handleDetailResponse(http.Response response) {
    if (response.statusCode == 200) {
      return GitHubUserDetail.fromJson(json.decode(response.body));
    }
    if (response.statusCode == 404) {
      throw NotFoundException('User not found');
    }
    throw _createApiException(response);
  }

  List<GitHubUser> _handleSearchResponse(http.Response response) {
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> items = jsonData['items'] ?? [];
      return items.map((json) => GitHubUser.fromJson(json)).toList();
    }
    throw _createApiException(response);
  }

  ApiException _createApiException(http.Response response) {
    String message;
    switch (response.statusCode) {
      case 403:
        message = 'API rate limit exceeded. Please try again later.';
        break;
      case 404:
        message = 'Resource not found';
        break;
      case 500:
        message = 'Server error. Please try again later.';
        break;
      default:
        message = 'Request failed with status: ${response.statusCode}';
    }
    return ApiException(message, statusCode: response.statusCode, responseBody: response.body);
  }

  void dispose() {
    _client.close();
  }
}
