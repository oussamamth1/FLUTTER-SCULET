import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart' as pro;
import 'package:zenifytrip_guide/env.dart';
import 'package:zenifytrip_guide/features/ChatModulev2/SocketManagment.dart';
import 'package:zenifytrip_guide/features/task/TaskService.dart';
import 'package:zenifytrip_guide/features/task/task.dart';
import 'package:zenifytrip_guide/map.dart';
import 'package:zenifytrip_guide/project/routes/app_rout_config.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:zenifytrip_guide/provider/location_provider.dart';
import 'package:zenifytrip_guide/theme.dart';
import 'package:go_router/go_router.dart';

void main() async{
    WidgetsFlutterBinding.ensureInitialized();
      await Hive.initFlutter();
      await Hive.openBox('authBox');
    usePathUrlStrategy(); // ✅ No hash in URLs
     // Register the Task adapter
  Hive.registerAdapter(TaskAdapter());
   AppEnvironment.setupEnv(Environment.tunisie);
  WidgetsFlutterBinding.ensureInitialized();


//   if (Firebase.apps.isEmpty) {
//     await Firebase.initializeApp(
//       //ios add name
//  name: "TUNISIEPROMO",
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//   } else {
//     Firebase.app(); // Get the default app
//   }

  await SocketIOManager.instance.initSocket();
  // Initialize TaskService
  final taskService = TaskService();
  await taskService.init();
runApp(
    ProviderScope( // Riverpod root
      child: pro.MultiProvider( // Classic provider root
        providers: [
          pro.ChangeNotifierProvider(
          create: (context) => LocationProvider(),
          child: GoogleMapPage(),
        )
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
   MyApp({super.key});

  // This widget is the root of your application.


Widget build(BuildContext context,WidgetRef ref) {
  final _router = AppRoutConfig.returnRouter(ref);
  return MaterialApp.router(theme: AppEnvironment.lightTheme,
    title: 'ZenifyTrip Guide',

      debugShowCheckedModeBanner: false,
      restorationScopeId: null, // Disable restoration to avoid the error
      routerConfig: _router, // 👈 This is enough! Remove parser/delegate
  );
}
}

