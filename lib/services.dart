import 'package:get_it/get_it.dart';
import 'package:nebx/nebx.dart';
import 'package:nebx_minimal_example/persistence/auth_handler.dart';
import 'package:nebx_minimal_example/persistence/dummy_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getIt = GetIt.instance;

void initServices() {
  final storage = SharedPreferencesAsync();

  const baseUrl = "https://dummyjson.com/";
  final normalClient = DioBuilderFactory.clientBasic(baseUrl: baseUrl)
      .addRequestTimeOut()
      .buildErrorHandling();

  final jwtClient = DioBuilderFactory.clientJsonWebToken(
          baseUrl: baseUrl,
          onTokenLoad: AuthHandler.loadAccessToken,
          onTokenRefresh: (fetcher) => AuthHandler.refreshAccessToken(fetcher))
      .addRequestTimeOut()
      .buildErrorHandling();

  getIt.registerSingleton<SharedPreferencesAsync>(storage);

  /// toggle comment to swap the http client
  // getIt.registerSingleton<IDioClient>(normalClient);
  getIt.registerSingleton<IDioClient>(jwtClient);

  /// try swapping the client between normalClient and jwtClient
  final dummyRepo = DummyRepository(
    client: getIt<IDioClient>(),
    sharedPref: storage,
  );
  getIt.registerFactory<IDummyRepository>(() => dummyRepo);
}
