import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';

/// Main screen with bottom navigation
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationController = Get.find<NavigationController>();

    return Obx(() {
      return Scaffold(
        body: IndexedStack(
          index: navigationController.currentIndex.value,
          children: const [
            HomeScreen(),
            FavoritesScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationController.currentIndex.value,
          onDestinationSelected: navigationController.changePage,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_outline),
              selectedIcon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
          ],
        ),
      );
    });
  }
}
