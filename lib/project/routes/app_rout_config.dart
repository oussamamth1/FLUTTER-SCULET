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
          builder: (BuildContext context, GoRouterState state) => HomePage(),
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
              path: '/login',
              builder:
                  (BuildContext context, GoRouterState state) => LoginScreen(
                    backgroundImage:
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTKfP5aLyOd2XJQEwo54_P5a9fM7iOwOZzK4nl6Zj6Ydg2ZKFCbXR1C7hIVEg7iP-mTZ7FXrkpFAoolYClhq4UeAm9AO5W03VNuJSnYPBwcyg",

                    snackBarColor: Colors.green, // ✅ Custom SnackBar color
                    showForgotPassword: true, // ✅ Show Forgot Password
                    canRegister: true,
                    onRegister: () => context.go('/register'),
                    onForgotPassword: () {
                      // ✅ Your forgot password logic
                      print("Forgot Password Clicked");
                      // You can navigate to forgot password screen:
                      // context.go('/forgot-password');
                    },
                  ),
            ),
            GoRoute(
              name: AppRouteConst.register,
              path: '/register',
              builder:
                  (BuildContext context, GoRouterState state) => RegisterScreen(
                    snackBarColor: Colors.green,
                    canLogin: true,
                    requireTermsAcceptance:
                        true, // Optional: require terms acceptance
                    backgroundImage:
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTKfP5aLyOd2XJQEwo54_P5a9fM7iOwOZzK4nl6Zj6Ydg2ZKFCbXR1C7hIVEg7iP-mTZ7FXrkpFAoolYClhq4UeAm9AO5W03VNuJSnYPBwcyg",
                    onLogin: () {
                      // Navigate back to login page
                      context.go('/login');
                    },
                    onTermsPressed: () {
                      // Navigate to terms and conditions page
                      print("Terms and Conditions Clicked");
                      // context.go('/terms');
                    },
                    // Optional: Add background image
                    // backgroundImage: 'assets/images/auth_bg.jpg',
                    // overlayColor: Colors.black.withOpacity(0.3),
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
        final currentPath = state.matchedLocation;

        final isAuthPage =
            currentPath == '/login' || currentPath == '/register';

        if (isLoading) return null;
        if (!isLoggedIn && !isAuthPage) return '/login';
        if (isLoggedIn && isAuthPage) return '/';
        return null;
      },
      // Refresh GoRouter when auth state changes
      refreshListenable: GoRouterRefreshStream(authNotifier.stream),
    );
  }
}
