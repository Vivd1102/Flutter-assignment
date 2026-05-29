import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/users_controller.dart';
import '../widgets/user_card.dart';
import '../widgets/shimmer_widgets.dart';
import '../widgets/error_widget.dart' as app_error;
import '../widgets/empty_state_widget.dart';
import 'user_detail_screen.dart';

/// Home screen displaying GitHub users list
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      Get.find<UsersController>().loadMoreUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersController = Get.find<UsersController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Users'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _SearchBar(
              controller: _searchController,
              onSearch: (query) {
                usersController.searchUsers(query);
              },
              onClear: () {
                _searchController.clear();
                usersController.refresh();
              },
            ),
          ),
        ),
      ),
      body: Obx(() => _buildBody(usersController)),
    );
  }

  Widget _buildBody(UsersController controller) {
    // Loading state (initial load)
    if (controller.isLoading.value && controller.users.isEmpty) {
      return const ShimmerLoadingList();
    }

    // Error state (no data)
    if (controller.hasError.value && controller.users.isEmpty) {
      return app_error.ErrorWidget(
        message: controller.errorMessage.value,
        isNetworkError: controller.errorMessage.value.toLowerCase().contains('internet') ||
            controller.errorMessage.value.toLowerCase().contains('network'),
        onRetry: () => controller.retry(),
      );
    }

    // Empty state
    if (controller.users.isEmpty) {
      if (controller.searchQuery.isNotEmpty) {
        return NoSearchResultsWidget(query: controller.searchQuery.value);
      }
      return NoUsersWidget(onRefresh: () => controller.refresh());
    }

    // Data loaded
    return RefreshIndicator(
      onRefresh: () => controller.refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: controller.users.length + (controller.isLoadingMore.value ? 1 : 0),
        itemBuilder: (context, index) {
          // Loading more indicator
          if (index == controller.users.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final user = controller.users[index];
          return Obx(() => UserCard(
                user: user,
                isFavorite: controller.isFavorite(user.id),
                heroTagPrefix: 'home',
                onTap: () => _navigateToDetail(user.login, user.avatarUrl, user.id, 'home'),
                onFavoriteToggle: () => controller.toggleFavorite(user),
              ));
        },
      ),
    );
  }

  void _navigateToDetail(String username, String avatarUrl, int userId, String heroTagPrefix) {
    Get.to(() => UserDetailScreen(
          username: username,
          avatarUrl: avatarUrl,
          userId: userId,
          heroTagPrefix: heroTagPrefix,
        ));
  }
}

/// Search bar widget
class _SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onSearch,
    required this.onClear,
  });

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateHasText);
  }

  void _updateHasText() {
    setState(() {
      _hasText = widget.controller.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: 'Search users...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _hasText
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: widget.onClear,
              )
            : null,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      textInputAction: TextInputAction.search,
      onChanged: widget.onSearch,
    );
  }
}
