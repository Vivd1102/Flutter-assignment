import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/users_controller.dart';
import '../widgets/user_card.dart';
import '../widgets/empty_state_widget.dart';
import 'user_detail_screen.dart';

/// Favorites screen displaying saved users
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesController = Get.find<FavoritesController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        elevation: 0,
      ),
      body: Obx(() {
        if (favoritesController.isEmpty) {
          return const EmptyFavoritesWidget();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: favoritesController.favorites.length,
          itemBuilder: (context, index) {
            final user = favoritesController.favorites[index];
            return FavoriteUserCard(
              user: user,
              heroTagPrefix: 'fav',
              onTap: () => _navigateToDetail(user.login, user.avatarUrl, user.id, 'fav'),
              onRemove: () => _removeFromFavorites(favoritesController, user),
            );
          },
        );
      }),
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

  void _removeFromFavorites(FavoritesController controller, dynamic user) {
    controller.removeFavorite(user);
    Get.snackbar(
      'Removed',
      '${user.login} removed from favorites',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}
