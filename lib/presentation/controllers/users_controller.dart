import 'dart:async';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../data/models/github_user.dart';
import '../../data/repositories/user_repository.dart';

/// Controller for managing GitHub users list
class UsersController extends GetxController {
  final UserRepository _repository;

  UsersController({required UserRepository repository}) : _repository = repository;

  // Observable state
  final RxList<GitHubUser> users = <GitHubUser>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isSearching = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxBool hasError = false.obs;
  final RxSet<int> favoriteIds = <int>{}.obs;

  // Debounce timer for search
  Timer? _debounceTimer;

  // Retry count for failed requests
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
    _loadFavoriteIds();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  /// Load initial users list
  Future<void> loadUsers() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    _retryCount = 0;

    await _fetchUsers();
  }

  /// Internal fetch with retry logic
  Future<void> _fetchUsers({int? since}) async {
    try {
      final fetchedUsers = await _repository.getUsers(since: since);
      if (since == null) {
        users.value = fetchedUsers;
      } else {
        users.addAll(fetchedUsers);
      }
      hasError.value = false;
      errorMessage.value = '';
      _retryCount = 0;
    } on NetworkException catch (e) {
      _handleError(e.message, isNetworkError: true);
    } on ApiException catch (e) {
      _handleError(e.message);
    } catch (e) {
      _handleError('An unexpected error occurred');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Load more users (pagination)
  Future<void> loadMoreUsers() async {
    if (isLoadingMore.value || users.isEmpty || searchQuery.isNotEmpty) return;

    isLoadingMore.value = true;
    final lastUserId = users.last.id;
    await _fetchUsers(since: lastUserId);
  }

  /// Search users with debounce
  void searchUsers(String query) {
    searchQuery.value = query;
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      loadUsers();
      return;
    }

    _debounceTimer = Timer(
      Duration(milliseconds: ApiConstants.searchDebounceMs),
      () => _performSearch(query),
    );
  }

  /// Perform the actual search
  Future<void> _performSearch(String query) async {
    isSearching.value = true;
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final searchResults = await _repository.searchUsers(query);
      users.value = searchResults;
    } on NetworkException catch (e) {
      _handleError(e.message, isNetworkError: true);
    } on ApiException catch (e) {
      _handleError(e.message);
    } catch (e) {
      _handleError('Search failed');
    } finally {
      isLoading.value = false;
      isSearching.value = false;
    }
  }

  /// Handle errors
  void _handleError(String message, {bool isNetworkError = false}) {
    hasError.value = true;
    errorMessage.value = message;

    if (users.isEmpty) {
      // Only show error if we have no data to display
    }
  }

  /// Retry loading
  Future<void> retry() async {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      if (searchQuery.isNotEmpty) {
        await _performSearch(searchQuery.value);
      } else {
        await loadUsers();
      }
    }
  }

  /// Refresh users list
  @override
  Future<void> refresh() async {
    searchQuery.value = '';
    _debounceTimer?.cancel();
    await loadUsers();
  }

  /// Load favorite IDs
  void _loadFavoriteIds() {
    final favorites = _repository.getFavorites();
    favoriteIds.clear();
    favoriteIds.addAll(favorites.map((u) => u.id).toSet());
  }

  /// Toggle favorite status for a user
  Future<void> toggleFavorite(GitHubUser user) async {
    final isFavorite = await _repository.toggleFavorite(user);
    if (isFavorite) {
      favoriteIds.add(user.id);
    } else {
      favoriteIds.remove(user.id);
    }
    // Notify favorites controller
    Get.find<FavoritesController>().refreshFavorites();
  }

  /// Check if user is favorite
  bool isFavorite(int userId) {
    return favoriteIds.contains(userId);
  }
}

/// Controller for managing favorites
class FavoritesController extends GetxController {
  final UserRepository _repository;

  FavoritesController({required UserRepository repository}) : _repository = repository;

  final RxList<GitHubUser> favorites = <GitHubUser>[].obs;

  @override
  void onInit() {
    super.onInit();
    refreshFavorites();
  }

  /// Refresh favorites from local storage
  void refreshFavorites() {
    favorites.value = _repository.getFavorites();
  }

  /// Remove user from favorites
  Future<void> removeFavorite(GitHubUser user) async {
    await _repository.removeFavorite(user.id);
    favorites.removeWhere((u) => u.id == user.id);
    
    // Update users controller
    final usersController = Get.find<UsersController>();
    usersController.favoriteIds.remove(user.id);
  }

  /// Check if favorites is empty
  bool get isEmpty => favorites.isEmpty;
}
