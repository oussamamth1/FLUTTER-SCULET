import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zenifytrip_guide/GoRouterRefreshStream.dart';
import 'package:zenify_auth/zenify_auth.dart';
import 'package:zenifytrip_guide/pages/about.dart';
import 'package:zenifytrip_guide/pages/discovery_page.dart';
import 'package:zenifytrip_guide/pages/home.dart';
import 'package:zenifytrip_guide/features/auth/presentation/login.dart';
import 'package:zenifytrip_guide/pages/message_page.dart';
import 'package:zenifytrip_guide/pages/profile_page.dart';
import 'package:zenifytrip_guide/project/routes/app_rout_const.dart';
import 'package:zenify_auth/zenify_auth.dart';

class AppRoutConfig {

  /// Returns a GoRouter configured with auth state from Riverpod
  static GoRouter returnRouter(WidgetRef ref) {
    // Watch the auth state notifier
    
    final authNotifier = ref.watch(authProvider.notifier);

    return GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          name: AppRouteConst.home,
          builder:
              (BuildContext context, GoRouterState state) => const HomePage(),
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
              path: 'discovery',
              builder:
                  (BuildContext context, GoRouterState state) =>
                      DiscoveryPage(),
            ),
            GoRoute(
              name: AppRouteConst.login,
              path: 'login',
              builder:
                  (BuildContext context, GoRouterState state) => LoginScreen(
                    snackBarColor: Colors.green, // ✅ Custom SnackBar color
                    showForgotPassword: true, // ✅ Show Forgot Password
                    onForgotPassword: () {
                      // ✅ Your forgot password logic
                      print("Forgot Password Clicked");
                    },
                  ),
            ),
            GoRoute(
              name: AppRouteConst.messages,
              path: 'messages',
              builder:
                  (BuildContext context, GoRouterState state) => MessagePage(),
            ),
            GoRoute(
              name: AppRouteConst.profile,
              path: 'profile',
              builder:
                  (BuildContext context, GoRouterState state) => ProfilePage(),
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
      redirect: (context, state) {
        final authState = ref.read(authProvider);
        final isLoggedIn = authState.status == AuthStatus.authenticated;
        final isLoading = authState.status == AuthStatus.loading;
        final loggingIn = state.matchedLocation == '/login';

        if (isLoading) return null; // Don't redirect yet while checking login
        if (!isLoggedIn && !loggingIn) return '/login';
        if (isLoggedIn && loggingIn) return '/';
        return null;
      },
      // Refresh GoRouter when auth state changes
      refreshListenable: GoRouterRefreshStream(authNotifier.stream),
    );
  }
}
