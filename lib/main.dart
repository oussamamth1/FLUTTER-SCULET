import 'package:flutter/material.dart';
import 'package:zenifytrip_guide/project/routes/app_rout_config.dart';
import 'package:go_router/go_router.dart';

void main() {
    WidgetsFlutterBinding.ensureInitialized();
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  // This widget is the root of your application.
final GoRouter _router = AppRoutConfig.returnRouter(true);

Widget build(BuildContext context) {
  return MaterialApp.router(
    title: 'ZenifyTrip Guide',

      debugShowCheckedModeBanner: false,
      restorationScopeId: null, // Disable restoration to avoid the error
      routerConfig: _router, // 👈 This is enough! Remove parser/delegate
  );
}
}

