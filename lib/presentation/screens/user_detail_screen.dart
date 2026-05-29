import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/repositories/user_repository.dart';
import '../controllers/user_detail_controller.dart';
import '../widgets/shimmer_widgets.dart';
import '../widgets/error_widget.dart' as app_error;

/// User detail screen
class UserDetailScreen extends StatelessWidget {
  final String username;
  final String avatarUrl;
  final int userId;
  final String heroTagPrefix;

  const UserDetailScreen({
    super.key,
    required this.username,
    required this.avatarUrl,
    required this.userId,
    this.heroTagPrefix = 'home',
  });

  @override
  Widget build(BuildContext context) {
    // Create controller for this specific user
    final controller = Get.put(
      UserDetailController(
        repository: Get.find<UserRepository>(),
        username: username,
      ),
      tag: username,
    );

    return Scaffold(
      body: Obx(() => _buildBody(context, controller)),
    );
  }

  Widget _buildBody(BuildContext context, UserDetailController controller) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, controller),
        SliverToBoxAdapter(
          child: _buildContent(context, controller),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, UserDetailController controller) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      actions: [
        Obx(() => IconButton(
              onPressed: () => controller.toggleFavorite(),
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  controller.isFavorite.value
                      ? Icons.favorite
                      : Icons.favorite_border,
                  key: ValueKey(controller.isFavorite.value),
                  color: controller.isFavorite.value ? Colors.red : null,
                ),
              ),
            )),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(username),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, UserDetailController controller) {
    if (controller.isLoading.value) {
      return const UserDetailShimmer();
    }

    if (controller.hasError.value) {
      return app_error.ErrorWidget(
        message: controller.errorMessage.value,
        isNetworkError: controller.errorMessage.value.toLowerCase().contains('internet'),
        onRetry: () => controller.retry(),
      );
    }

    final user = controller.userDetail.value;
    if (user == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Avatar
        Transform.translate(
          offset: const Offset(0, -50),
          child: Hero(
            tag: '${heroTagPrefix}_avatar_$userId',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: CachedNetworkImage(
                  imageUrl: avatarUrl,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, size: 60),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error, size: 60),
                  ),
                ),
              ),
            ),
          ),
        ),
        // User info
        Transform.translate(
          offset: const Offset(0, -30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Name
                if (user.name != null)
                  Text(
                    user.name!,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                const SizedBox(height: 4),
                Text(
                  '@${user.login}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                // Bio
                if (user.bio != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    user.bio!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 24),
                // Stats
                _buildStats(context, user),
                const SizedBox(height: 32),
                // Info section
                _buildInfoSection(context, user),
                const SizedBox(height: 24),
                // GitHub button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _launchUrl(user.htmlUrl),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('View on GitHub'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context, dynamic user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatColumn(
          icon: Icons.folder_outlined,
          value: user.publicRepos.toString(),
          label: 'Repos',
        ),
        _StatColumn(
          icon: Icons.people_outline,
          value: user.followers.toString(),
          label: 'Followers',
        ),
        _StatColumn(
          icon: Icons.person_add_outlined,
          value: user.following.toString(),
          label: 'Following',
        ),
        _StatColumn(
          icon: Icons.code,
          value: user.publicGists.toString(),
          label: 'Gists',
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, dynamic user) {
    final infoItems = <Widget>[];

    if (user.company != null) {
      infoItems.add(_InfoRow(
        icon: Icons.business,
        text: user.company!,
      ));
    }

    if (user.location != null) {
      infoItems.add(_InfoRow(
        icon: Icons.location_on_outlined,
        text: user.location!,
      ));
    }

    if (user.email != null) {
      infoItems.add(_InfoRow(
        icon: Icons.email_outlined,
        text: user.email!,
      ));
    }

    if (user.blog != null && user.blog!.isNotEmpty) {
      infoItems.add(_InfoRow(
        icon: Icons.link,
        text: user.blog!,
        isLink: true,
        onTap: () => _launchUrl(
          user.blog!.startsWith('http') ? user.blog! : 'https://${user.blog}',
        ),
      ));
    }

    infoItems.add(_InfoRow(
      icon: Icons.calendar_today_outlined,
      text: 'Joined ${_formatDate(user.createdAt)}',
    ));

    if (infoItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: infoItems,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

/// Stat column widget
class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatColumn({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}

/// Info row widget
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isLink;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.isLink = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: isLink
                ? GestureDetector(
                    onTap: onTap,
                    child: Text(
                      text,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(text),
          ),
        ],
      ),
    );
  }
}
