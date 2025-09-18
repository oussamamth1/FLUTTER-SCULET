import 'dart:convert';
import 'package:http/http.dart' as http;


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zenifytrip_guide/GoRouterRefreshStream.dart';
import 'package:zenify_auth/zenify_auth.dart';
import 'package:zenifytrip_guide/env.dart';
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
                  (BuildContext context, GoRouterState state) => LoginScreen(minPasswordLength :5,
                    backgroundImage:
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTKfP5aLyOd2XJQEwo54_P5a9fM7iOwOZzK4nl6Zj6Ydg2ZKFCbXR1C7hIVEg7iP-mTZ7FXrkpFAoolYClhq4UeAm9AO5W03VNuJSnYPBwcyg",
                    loginButtonText: "Sign In",
                    showSocialLogin: true,
                    accentColor: Colors.amber,
                    socialProviders: [
                      SocialLoginProvider(
                        name: 'Google',
                        icon: Icon(Icons.g_mobiledata, color: Colors.red),
                        onPressed: () => _handleGoogleLogin(),
                      ),
                      SocialLoginProvider(
                        name: 'Facebook',
                        icon: Icon(Icons.facebook, color: Colors.white),
                        onPressed: () => _handleFacebookLogin(),
                        backgroundColor: Color(0xFF1877F2),
                        textColor: Colors.white,
                      ),
                    ],
                    snackBarColor: Colors.green, // ✅ Custom SnackBar color
                    showForgotPassword: true, // ✅ Show Forgot Password
                    canRegister: true,
                    onRegister: () => context.go('/register'),
                    onForgotPassword: () async {
                      await _showForgotPasswordDialog(context);
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
                    primaryButtonColor: Colors.green,
                    minimumPasswordLength: 9,
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
                    onTermsPressed: () async {
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

  static Future<void> _handleGoogleLogin() async {
    try {
      // Add your Google Sign-In implementation here
      // Example with google_sign_in package:
      // final GoogleSignIn googleSignIn = GoogleSignIn();
      // final GoogleSignInAccount? account = await googleSignIn.signIn();
      // if (account != null) {
      //   // Handle successful login
      // }

      print('Google login initiated');
    } catch (e) {
      print('Google login error: $e');
      // Show error to user
    }
  }

  static Future<void> _handleFacebookLogin() async {
    try {
      // Add your Facebook Login implementation here
      // Example with flutter_facebook_auth package:
      // final LoginResult result = await FacebookAuth.instance.login();
      // if (result.status == LoginStatus.success) {
      //   // Handle successful login
      // }

      print('Facebook login initiated');
    } catch (e) {
      print('Facebook login error: $e');
      // Show error to user
    }
  }

  static Future<void> _handleAppleLogin() async {
    try {
      // Add your Apple Sign-In implementation here
      // Example with sign_in_with_apple package:
      // final credential = await SignInWithApple.getAppleIDCredential(
      //   scopes: [
      //     AppleIDAuthorizationScopes.email,
      //     AppleIDAuthorizationScopes.fullName,
      //   ],
      // );

      print('Apple login initiated');
    } catch (e) {
      print('Apple login error: $e');
      // Show error to user
    }
  }

  static Future<void> _showForgotPasswordDialog(BuildContext context) async {
    final TextEditingController emailController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Password'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter your email address and we\'ll send you a reset code.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Send Reset Code'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(); // Close the email dialog
                  await sendPasswordResetEmailRequest(emailController.text,context);
                }
              },
            ),
          ],
        );
      },
    );
  }

static  Future<void> sendPasswordResetEmailRequest(String email,BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('${AppEnvironment.baseApiUrl}/api/auth/forgot-password'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{'email': email}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        await showResetDialogEmail(context, email);
        print('Password reset request sent successfully');
      } else {
        print('Failed to send password reset request');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send reset email. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error sending password reset request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error. Please check your connection.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<void> showResetDialogEmail(BuildContext context, String email) async {
    final TextEditingController resetTokenController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    bool _obscurePassword = true;
    bool _obscureConfirmPassword = true;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.security, color: Colors.amber),
                  SizedBox(width: 8),
                  Text('Reset Password'),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'We\'ve sent a reset code to $email',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: resetTokenController,
                        decoration: const InputDecoration(
                          labelText: 'Reset Code',
                          prefixIcon: Icon(Icons.confirmation_number),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter the reset code';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        obscureText: _obscurePassword,
                        controller: newPasswordController,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a new password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        obscureText: _obscureConfirmPassword,
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (value != newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                  ),
                  child: const Text('Reset Password'),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        final resetResponse = await http.post(
                          Uri.parse(
                            '${AppEnvironment.baseApiUrl}/api/auth/reset-password/${resetTokenController.text}',
                          ),
                          headers: <String, String>{
                            'Content-Type': 'application/json',
                          },
                          body: jsonEncode(<String, dynamic>{
                            'email': email,
                            'newPassword': newPasswordController.text,
                          }),
                        );

                        Navigator.of(context).pop(); // Close the dialog

                        if (resetResponse.statusCode == 201 ||
                            resetResponse.statusCode == 200) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Password reset successful! You can now login.',
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.green,
                            ),
                          ); Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Invalid reset code or error occurred'),
                                ],
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Network error. Please try again.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
