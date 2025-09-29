import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart' as pro;
import 'package:zenifytrip_guide/env.dart';
import 'package:zenifytrip_guide/features/ChatModulev2/SocketManagment.dart';
import 'package:zenifytrip_guide/features/auth/presentation/providers/auth_provider.dart';
import 'package:zenifytrip_guide/features/task/TaskService.dart';
import 'package:zenifytrip_guide/features/task/task.dart';
import 'package:zenifytrip_guide/map.dart';
import 'package:zenifytrip_guide/pages/home.dart';
import 'package:zenifytrip_guide/project/routes/app_rout_config.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:zenifytrip_guide/provider/location_provider.dart';
import 'package:zenifytrip_guide/provider/mapSecreen..dart';
import 'package:zenifytrip_guide/service_locator.dart';
import 'package:zenifytrip_guide/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:zenify_auth/zenify_auth.dart' as zenifyAuth;
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

String? initialToken;
String? initialCookie;
// service_locator.dart (better approach)
Future<void> initServices() async {
  // 1. Register and initialize storage
  final authStorage = zenifyAuth.AuthStorage();
  await authStorage.init();
  sl.registerSingleton<zenifyAuth.AuthStorage>(authStorage);

  // 2. Create repository first (needed for notifier)
  // Note: We need to initialize ZenifyAuth first to create the repo
  await zenifyAuth.ZenifyAuth.initialize(
    baseUrl: "https://api.staging.zenifytrip.com",
    fromJson: (json) => zenifyAuth.User.fromJson(json),
    storage: sl<zenifyAuth.AuthStorage>(),
    autoRestore: false, // We'll do it manually with notifier below
  );

  // 3. Register auth repository
  sl.registerLazySingleton<zenifyAuth.AuthRepository<zenifyAuth.User>>(
    () => zenifyAuth.ZenifyAuth.authRepo,
  );

  // 4. Create and register notifier
  final authNotifier = zenifyAuth.AuthNotifier<zenifyAuth.User>(
    sl<zenifyAuth.AuthRepository<zenifyAuth.User>>(),
  );
  sl.registerSingleton<zenifyAuth.AuthNotifier<zenifyAuth.User>>(authNotifier);

  // 5. Now manually restore session with the notifier
  final storage = sl<zenifyAuth.AuthStorage>();
  // if (storage.isLoggedIn()) {
  final token = storage.getToken();
  final cookie = storage.getCookie();
  final userData = storage.getUserJson();
  print('✅ Session restored $token');
  print('✅ Session restored $cookie');
  print('✅ Session restored $userData');
  print('✅ Session user $userData');
  print('✅ Session user ${userData?.firstName}');

  if (token != null && cookie != null) {
    try {
      authNotifier.setAuthState(
        zenifyAuth.AuthState<zenifyAuth.User>(
          status: zenifyAuth.AuthStatus.authenticated,
          user: userData,
          token: token,
          cookie: cookie,
        ),
      );
      print('✅ Session restored successfully');
    } catch (e) {
      print('❌ Failed to restore session: $e');
      await storage.clear();
    }
  }
  // }
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // Timer(Duration(seconds: 10), () {
  //   FlutterNativeSplash.remove();
  //   // This block of code will be executed when the timer finishes.
  //   print('Timer has finished counting down.');
  // });
  // await initServices();
  // await zenifyAuth.ZenifyAuth.initialize(
  //   baseUrl: "https://api.staging.zenifytrip.com",
  //   fromJson: (json) => zenifyAuth.User.fromJson(json),
  //   storage: sl<zenifyAuth.AuthStorage>(),
  //   autoRestore: false, // We'll do it manually with notifier below
  // );

  // // Try to restore previous session
  // final storage = sl<zenifyAuth.AuthStorage>();
  // final authNotifier = sl<zenifyAuth.AuthNotifier<zenifyAuth.User>>();

  // if (storage.isLoggedIn()) {
  //   final token = storage.getToken();
  //   final cookie = storage.getCookie();
  //   final userData = storage.getUserJson();

  //   if (token != null && cookie != null && userData != null) {
  //     // Restore the auth state
  //     try {
  //       // Create User object from stored data
  //       // final user = zenifyAuth.User.fromJson(userData);

  //       // Set the auth state as authenticated
  //       authNotifier.setAuthState(
  //         zenifyAuth.AuthState<zenifyAuth.User>(
  //           status: zenifyAuth.AuthStatus.authenticated,
  //           user: userData,
  //           token: token,
  //           cookie: cookie,
  //         ),
  //       );

  //       print('✅ Session restored successfully');
  //     } catch (e) {
  //       print('❌ Failed to restore session: $e');
  //       await storage.clear(); // Clear corrupted data
  //     }
  //   }
  // }

  await Hive.initFlutter();
  await Hive.openBox('authBox');
  //Hive.registerAdapter(UserAdapter()); // <-- important

  // await Hive.openBox<zenifyAuth.User>('users');
  usePathUrlStrategy(); // ✅ No hash in URLs
  // Register the Task adapter
  Hive.registerAdapter(TaskAdapter());
  AppEnvironment.setupEnv(Environment.tunisie);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final container = ProviderContainer(
    // observers: [Logger()],
    overrides: [
      // isarProvider.overrideWithValue(isar),
      // secureStorageProvider.overrideWithValue(storage),
    ],
  );

  // get tokens from secure storage
  await container.read(authProvider.notifier);

  //   if (Firebase.apps.isEmpty) {
  //     await Firebase.initializeApp(
  //       //ios add name
  //  name: "TUNISIEPROMO",
  //       options: DefaultFirebaseOptions.currentPlatform,
  //     );
  //   } else {
  //     Firebase.app(); // Get the default app
  //   }

  //  await SocketIOManager.instance.initSocket();
  // Initialize TaskService
  final taskService = TaskService();
  await taskService.init();

  runApp(
    ProviderScope(
      // Riverpod root
      child: pro.MultiProvider(
        // Classic provider root
        providers: [
          pro.ChangeNotifierProvider(
            create: (context) => LocationProvider(),
            child: MyApp(),
          ),
        ],
        child: MyApp(),
      ),
    ),
  );
}
//final authRepo = zenifyAuth.ZenifyAuth.authRepo; // ✅ correct usage

class MyApp extends ConsumerWidget {
  MyApp({super.key});

  // This widget is the root of your application.

  Widget build(BuildContext context, WidgetRef ref) {
    final router = AppRoutConfig.returnRouter(ref);
    return MaterialApp.router(
      theme: AppEnvironment.lightTheme,
      title: 'ZenifyTrip Guide',

      debugShowCheckedModeBanner: false,
      //restorationScopeId: null, // Disable restoration to avoid the error
      routerConfig: router, // 👈 This is enough! Remove parser/delegate
    );
  }
}
