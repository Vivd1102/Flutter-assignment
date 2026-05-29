import 'package:get/get.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../data/models/github_user.dart';
import '../../data/repositories/user_repository.dart';
import 'users_controller.dart';

/// Controller for user details screen
class UserDetailController extends GetxController {
  final UserRepository _repository;
  final String username;

  UserDetailController({
    required UserRepository repository,
    required this.username,
  }) : _repository = repository;

  final Rx<GitHubUserDetail?> userDetail = Rx<GitHubUserDetail?>(null);
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isFavorite = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserDetail();
  }

  /// Load user details from API
  Future<void> loadUserDetail() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final detail = await _repository.getUserDetail(username);
      userDetail.value = detail;
      isFavorite.value = _repository.isFavorite(detail.id);
    } on NetworkException catch (e) {
      hasError.value = true;
      errorMessage.value = e.message;
    } on NotFoundException catch (e) {
      hasError.value = true;
      errorMessage.value = e.message;
    } on ApiException catch (e) {
      hasError.value = true;
      errorMessage.value = e.message;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load user details';
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite() async {
    final user = userDetail.value;
    if (user == null) return;

    final nowFavorite = await _repository.toggleFavorite(user.toBasicUser());
    isFavorite.value = nowFavorite;
    
    // Update other controllers
    try {
      final usersController = Get.find<UsersController>();
      if (nowFavorite) {
        usersController.favoriteIds.add(user.id);
      } else {
        usersController.favoriteIds.remove(user.id);
      }
    } catch (_) {
      // Controller might not be registered
    }

    try {
      Get.find<FavoritesController>().refreshFavorites();
    } catch (_) {
      // Controller might not be registered
    }
  }

  /// Retry loading
  Future<void> retry() async {
    await loadUserDetail();
  }
}
