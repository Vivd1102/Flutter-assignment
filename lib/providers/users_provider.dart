import 'package:flutter/foundation.dart';
import '../models/github_user.dart';
import '../services/github_api_service.dart';

class UsersProvider extends ChangeNotifier {
  final GitHubApiService _apiService;
  
  List<GitHubUser> _users = [];
  GitHubUserDetail? _selectedUser;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String _searchQuery = '';
  
  UsersProvider({GitHubApiService? apiService})
      : _apiService = apiService ?? GitHubApiService();

  List<GitHubUser> get users => _users;
  GitHubUserDetail? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get hasUsers => _users.isNotEmpty;

  /// Load initial users list
  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _apiService.getUsers();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more users (pagination)
  Future<void> loadMoreUsers() async {
    if (_isLoadingMore || _users.isEmpty) return;
    
    _isLoadingMore = true;
    notifyListeners();

    try {
      final lastUserId = _users.last.id;
      final moreUsers = await _apiService.getUsers(since: lastUserId);
      _users.addAll(moreUsers);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Search users by query
  Future<void> searchUsers(String query) async {
    _searchQuery = query;
    
    if (query.isEmpty) {
      await loadUsers();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _apiService.searchUsers(query);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get user details
  Future<void> getUserDetail(String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedUser = await _apiService.getUserDetail(username);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear selected user
  void clearSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh users list
  Future<void> refresh() async {
    _searchQuery = '';
    await loadUsers();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
