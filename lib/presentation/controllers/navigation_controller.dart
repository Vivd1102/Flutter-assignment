import 'package:get/get.dart';

/// Controller for bottom navigation
class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }

  void goToHome() {
    currentIndex.value = 0;
  }

  void goToFavorites() {
    currentIndex.value = 1;
  }
}
