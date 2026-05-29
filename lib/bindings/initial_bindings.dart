import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/network_service.dart';
import '../data/datasources/github_api_service.dart';
import '../data/datasources/local_data_source.dart';
import '../data/repositories/user_repository.dart';
import '../presentation/controllers/navigation_controller.dart';
import '../presentation/controllers/users_controller.dart';

/// Initial bindings for app startup
class InitialBindings extends Bindings {
  final SharedPreferences sharedPreferences;

  InitialBindings({required this.sharedPreferences});

  @override
  void dependencies() {
    // Core services
    Get.put<NetworkService>(NetworkService(), permanent: true);

    // Data sources
    Get.lazyPut<GitHubApiService>(() => GitHubApiService(), fenix: true);
    Get.lazyPut<LocalDataSource>(() => LocalDataSource(sharedPreferences), fenix: true);

    // Repository
    Get.lazyPut<UserRepository>(
      () => UserRepository(
        apiService: Get.find<GitHubApiService>(),
        localDataSource: Get.find<LocalDataSource>(),
        networkService: Get.find<NetworkService>(),
      ),
      fenix: true,
    );

    // Controllers
    Get.put<NavigationController>(NavigationController(), permanent: true);
    Get.put<UsersController>(
      UsersController(repository: Get.find<UserRepository>()),
      permanent: true,
    );
    Get.put<FavoritesController>(
      FavoritesController(repository: Get.find<UserRepository>()),
      permanent: true,
    );
  }
}
