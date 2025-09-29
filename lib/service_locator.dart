import 'package:get_it/get_it.dart';
import 'package:zenify_auth/zenify_auth.dart';

final sl = GetIt.instance;

Future<void> initServices() async {
  // Register and initialize storage FIRST
  final authStorage = AuthStorage();
  await authStorage.init();
  // sl.registerSingleton<AuthStorage>(authStorage);

  // // Register auth repository
  // sl.registerLazySingleton<AuthRepository<User>>(() => ZenifyAuth.authRepo);

  // // Register notifier
  // sl.registerLazySingleton<AuthNotifier<User>>(
  //   () => AuthNotifier<User>(sl<AuthRepository<User>>()),
  // );
}
