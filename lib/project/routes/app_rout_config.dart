import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zenifytrip_guide/GoRouterRefreshStream.dart';
import 'package:zenifytrip_guide/features/auth/presentation/providers/auth_provider.dart';
import 'package:zenifytrip_guide/pages/about.dart';
import 'package:zenifytrip_guide/pages/discovery_page.dart';
import 'package:zenifytrip_guide/pages/home.dart';
import 'package:zenifytrip_guide/features/auth/presentation/login.dart';
import 'package:zenifytrip_guide/pages/message_page.dart';
import 'package:zenifytrip_guide/pages/profile_page.dart';
import 'package:zenifytrip_guide/project/routes/app_rout_const.dart';

class AppRoutConfig {
  /// Returns a GoRouter configured with auth state from Riverpod
  static GoRouter returnRouter(WidgetRef ref) {
    // Get the auth notifier from Riverpod
    final authNotifier = ref.watch(authProvider.notifier);

    return GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          name: AppRouteConst.home,
          builder: (BuildContext context, GoRouterState state) => const HomePage(),
          routes: <RouteBase>[
            GoRoute(
              name: AppRouteConst.details,
              path: 'details/:username', // relative path
              builder: (BuildContext context, GoRouterState state) {
                final username = state.pathParameters['username']!;
                return AboutPage(id: username);
              },
            ),
            GoRoute(
              name: AppRouteConst.discovery,
              path: 'discovery', // relative path
              builder: (BuildContext context, GoRouterState state) => DiscoveryPage(),
            ),
               GoRoute(
              name: AppRouteConst.login,
              path: 'login', // relative path
              builder: (BuildContext context, GoRouterState state) => LoginScreen(),
            ),   GoRoute(
              name: AppRouteConst.messages,
              path: 'messages', // relative path
              builder: (BuildContext context, GoRouterState state) => MessagePage(),
            ),
            GoRoute(
              name: AppRouteConst.profile,
              path: 'profile', // relative path
              builder: (BuildContext context, GoRouterState state) => ProfilePage(),
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
        final loggingIn = state.path == '/login';
        // Use Riverpod auth state instead of bool
        if (!authNotifier.isLoggedIn && !loggingIn) return '/login';
       if (authNotifier.isLoggedIn && loggingIn) return '/';
        return null;
      },
 refreshListenable: GoRouterRefreshStream(ref.watch(authProvider.notifier).stream),

    );
  }
}
