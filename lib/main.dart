import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart' as pro;
import 'package:zenifytrip_guide/env.dart';
import 'package:zenifytrip_guide/features/ChatModulev2/SocketManagment.dart';
import 'package:zenifytrip_guide/features/task/TaskService.dart';
import 'package:zenifytrip_guide/features/task/task.dart';
import 'package:zenifytrip_guide/map.dart';
import 'package:zenifytrip_guide/pages/home.dart';
import 'package:zenifytrip_guide/project/routes/app_rout_config.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:zenifytrip_guide/provider/location_provider.dart';
import 'package:zenifytrip_guide/provider/mapSecreen..dart';
import 'package:zenifytrip_guide/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:zenify_auth/zenify_auth.dart' as zenifyAuth;
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // Timer(Duration(seconds: 10), () {
  //   FlutterNativeSplash.remove();
  //   // This block of code will be executed when the timer finishes.
  //   print('Timer has finished counting down.');
  // });

  await Hive.initFlutter();
  await Hive.openBox('authBox');
  usePathUrlStrategy(); // ✅ No hash in URLs
  // Register the Task adapter
  Hive.registerAdapter(TaskAdapter());
  AppEnvironment.setupEnv(Environment.tunisie);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //   if (Firebase.apps.isEmpty) {
  //     await Firebase.initializeApp(
  //       //ios add name
  //  name: "TUNISIEPROMO",
  //       options: DefaultFirebaseOptions.currentPlatform,
  //     );
  //   } else {
  //     Firebase.app(); // Get the default app
  //   }

  zenifyAuth.ZenifyAuth.initialize(
    baseUrl: "https://api.staging.zenifytrip.com", // project-specific URL
    fromJson: (json) => zenifyAuth.User.fromJson(json),
  );

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
      restorationScopeId: null, // Disable restoration to avoid the error
      routerConfig: router, // 👈 This is enough! Remove parser/delegate
    );
  }
}
