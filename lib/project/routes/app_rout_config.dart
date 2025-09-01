
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zenifytrip_guide/pages/about.dart';
import 'package:zenifytrip_guide/pages/home.dart';
import 'package:zenifytrip_guide/pages/login.dart';
import 'package:zenifytrip_guide/project/routes/app_rout_const.dart';
class AppRoutConfig {
  static GoRouter returnRouter(bool isAuthenticated) {
    final GoRouter router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          name: AppRouteConst.home,
          builder: (BuildContext context, GoRouterState state) => HomePage(),
          routes: <RouteBase>[
            GoRoute(
              name: AppRouteConst.details,
              path: 'details', // relative path (no leading slash)
              builder: (BuildContext context, GoRouterState state) => AboutPage(),
            ),
            GoRoute(
              name: AppRouteConst.login,
              path: 'login', // relative path (no leading slash)
              builder: (BuildContext context, GoRouterState state) => LoginScreen(),
            ),
          ],
        ),
      ],
      errorPageBuilder: (BuildContext context, GoRouterState state) {
        return MaterialPage(
          key: state.pageKey,
          child: Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text(state.error.toString())),
          ),
        );
      },
      redirect: (BuildContext context, GoRouterState state) {
  final loggingIn = state.uri.toString() == '/login';
        if (!isAuthenticated && !loggingIn) {
          return '/login';
        }
        return null;
      },
    );
    return router;
  }
}
  
