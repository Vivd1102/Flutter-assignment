import 'package:flutter/material.dart';

/// Reusable empty state widget
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty favorites state
class EmptyFavoritesWidget extends StatelessWidget {
  const EmptyFavoritesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.favorite_border,
      title: 'No Favorites Yet',
      subtitle: 'Tap the heart icon on any user to add them to your favorites.',
    );
  }
}

/// No search results
class NoSearchResultsWidget extends StatelessWidget {
  final String query;

  const NoSearchResultsWidget({
    super.key,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No Results Found',
      subtitle: 'No users found matching "$query".\nTry a different search term.',
    );
  }
}

/// No users state
class NoUsersWidget extends StatelessWidget {
  final VoidCallback? onRefresh;

  const NoUsersWidget({
    super.key,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.people_outline,
      title: 'No Users Found',
      subtitle: 'Unable to load users. Please try again.',
      action: onRefresh != null
          ? ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            )
          : null,
    );
  }
}
