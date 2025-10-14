import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart' as pro;
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:zt_common_i18n/zt_common_i18n.dart' as zt_common_i18n;
import 'package:network_layer/network_layer.dart' as layer;
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as storage;

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

Future<void> checkPlugins() async {
  print('🔍 Checking plugin registration...');

  try {
    const storages = storage.FlutterSecureStorage();
    await storages.containsKey(key: 'test');
    print('✅ FlutterSecureStorage: OK');
  } catch (e) {
    print('❌ FlutterSecureStorage: FAILED - $e');
  }

  try {
    await SharedPreferences.getInstance();
    print('✅ SharedPreferences: OK');
  } catch (e) {
    print('❌ SharedPreferences: FAILED - $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();

  //   await Hive.initFlutter();
  //   await Hive.openBox('authBox');
  //   Hive.registerAdapter(zenifyAuth.UserAdapter()); // <-- important

  //   // await Hive.openBox<zenifyAuth.User>('users');
  //   usePathUrlStrategy(); // ✅ No hash in URLs
  //   //   // Register the Task adapter
  //Hive.registerAdapter(TaskAdapter());
  AppEnvironment.setupEnv(Environment.tunisie);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Create your environment config (base url, etc.)
  final config = layer.EnvironmentConfig(
    environment: layer.Environment.staging,
    baseUrl: "https://api.staging.zenifytrip.com",
    apiVersion: "api",
    connectTimeout: 5000,
    receiveTimeout: 5000,
    sendTimeout: 5000,
    enableLogging: true,
    enableSSLPinning: false,
    allowedSSLFingerprints: null,
  );
  storage.FlutterSecureStorage? secureStorage;
  if (!kIsWeb) {
    secureStorage = const storage.FlutterSecureStorage(
      aOptions: storage.AndroidOptions(encryptedSharedPreferences: true),
      iOptions: storage.IOSOptions(
        accessibility: storage.KeychainAccessibility.first_unlock,
      ),
    );
  }

  final tokenService = layer.TokenService(secureStorage: secureStorage);

  // final connectivityService = layer.ConnectivityService();
  final connectivity = Connectivity();
  //final connectivityService = ConnectivityService(connectivity: connectivity);
  final connectivityService = layer.ConnectivityService(
    connectivity: connectivity,
  );
  //connectivityService.initialize();

  await connectivityService.initialize();
  final dioClient = layer.DioClient(
    config: config,
    tokenService: tokenService,
    connectivityService: connectivityService,
  );
  await dioClient.initialize(); // important

  final container = ProviderContainer(
    // observers: [Logger()],
    overrides: [
      // isarProvider.overrideWithValue(isar),
      // secureStorageProvider.overrideWithValue(storage),
    ],
  );
  final token = await dioClient.refreshToken();
  print("token $token");
  // get tokens from secure storage
  // await container.read(authProvider.notifier);
  await checkPlugins();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProviderScope(child: TestApiWrapper(dioClient: dioClient)),
    ),
  );
  // runApp(
  //   ProviderScope(
  //     // Riverpod root
  //     child: pro.MultiProvider(
  //       // Classic provider root
  //       providers: [
  //         pro.ChangeNotifierProvider(
  //           create: (context) => LocationProvider(),
  //           child: MyApp(),
  //         ),
  //       ],
  //       child: MyApp(),
  //     ),
  //   ),
  // );
}

//final authRepo = zenifyAuth.ZenifyAuth.authRepo; // ✅ correct usage
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:dio/dio.dart';
// import 'package:your_package/connectivity_service.dart'; // Update this import
// import 'package:your_package/network_layer.dart'; // Update this import
class TestApiWrapper extends ConsumerWidget {
  final layer.DioClient dioClient;

  const TestApiWrapper({super.key, required this.dioClient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Example router (if you have one)
    // final router = AppRoutConfig.returnRouter(ref);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "ZenifyTrip Test API",
      locale: const Locale('en'), // 🌍 Change to Locale('en') or Locale('ar')
      supportedLocales: const [Locale('en'), Locale('ar'), Locale('fr')],
      localizationsDelegates: [
        // FlutterI18nDelegate(
        //   translationLoader: FileTranslationLoader(
        //     basePath: "packages/zenify_auth/assets/flutter_i18n",
        //     // fallbackFile: 'en',
        //     useCountryCode: false,
        //   ),
        // ),
        FlutterI18nDelegate(
          translationLoader: FileTranslationLoader(
            basePath: "assets/flutter_i18n",
            // fallbackFile: 'en',
            // useCountryCode: false,
          ),
        ),
        // FlutterI18nDelegate(
        //   translationLoader: NamespaceFileTranslationLoader(
        //     namespaces: ["fr", "en"],
        //     basePath:
        //         "C:/Users/oussa/zenify_auth/zenify_auth/assets/flutter_i18n",
        //   ),
        // ),
        // Localization from network_layer (if defined)
        layer.AppLocalizations.delegate,
        // Localization from auth module (if used)
        // zenifyAuth.commonI18nDelegate(),
        zt_common_i18n.commonI18nDelegate(),
        FlutterI18nDelegate(
          translationLoader: FileTranslationLoader(
            basePath: "packages/zenify_auth/assets/flutter_i18n",
            fallbackFile: "en",
            useCountryCode: false,
          ),
        ),
        // Flutter built-in
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),

      // If you want router-based navigation:
      // routerConfig: router,
      home: TestApiScreen(dioClient: dioClient),
    );
  }
}

class TestApiScreen extends ConsumerStatefulWidget {
  final layer.DioClient dioClient;
  const TestApiScreen({super.key, required this.dioClient});

  @override
  ConsumerState<TestApiScreen> createState() => _TestApiScreenState();
}

class _TestApiScreenState extends ConsumerState<TestApiScreen> {
  String _result = "Loading...";
  zenifyAuth.User? user;
  bool _isLoading = false;
  layer.NetworkStatus _lastStatus = layer.NetworkStatus.unknown;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authState = ref.read<zenifyAuth.AuthState?>(
        zenifyAuth.authProvider,
      );
      final accessToken = authState!.token;
      final refreshToken = authState!.refreshToken;

      if (accessToken != null && refreshToken != null) {
        await widget.dioClient.tokenService.saveAccessToken(accessToken);
        await widget.dioClient.tokenService.saveRefreshToken(refreshToken);
        print('✅ Tokens saved');
      } else {
        print('⚠️ Tokens not available yet');
      }
    });
    // Wrap in addPostFrameCallback to ensure safe usage after build
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ref.listen<zenifyAuth.AuthState>(zenifyAuth.authProvider, (
    //     previous,
    //     next,
    //   ) async {
    //     // if (next.token != null && next.refreshToken != null) {
    //     await widget.dioClient.tokenService.saveAccessToken(next.token!);
    //     await widget.dioClient.tokenService.saveRefreshToken(
    //       next.refreshToken!,
    //     );
    //     print('✅ Tokens saved from ref.listen');
    //     // }
    //   });
    // });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _result = "🔍 Loading data...";
    });

    try {
      print("🔍 Logging in...");

      final loginResponse = await widget.dioClient.post(
        "/auth/login",
        data: {"email": "oussamamethnani321@gmail.com", "password": "123456"},
      );

      if (loginResponse.statusCode == 200 || loginResponse.statusCode == 201) {
        print("✅ Login Response: ${loginResponse.data}");

        final accessToken = loginResponse.data['accessToken'];
        final refreshToken = loginResponse.data['refreshToken'];
        print("✅ Tokens $accessToken ✅ Tokens2 $refreshToken");
        await widget.dioClient.tokenService.saveAccessToken(
          loginResponse.data['accessToken'],
        );
        await widget.dioClient.tokenService.saveRefreshToken(
          loginResponse.data['refreshToken'],
        );
        // // ✅ UNCOMMENTED: Save tokens so subsequent requests are authenticated
        // print("🔍 Saving tokens...");
        // await widget.dioClient.tokenService.saveTokens(
        //   accessToken: accessToken,
        //   refreshToken: refreshToken,
        // );
        setState(() {
          _result = "Authontificatecd";

          //  user = zenifyAuth.User.fromJson(usersResponse.data);
        });

        print("🔍 Verifying saved token...");
        final savedToken = await widget.dioClient.tokenService.getAccessToken();
        print("🔍 Saved token: $savedToken");

        await Future.delayed(const Duration(milliseconds: 100));
        //   getUserProfile("0cb2fae9-a0bc-4c93-b4d1-cf1c19252d36");

        // print("🔍 Fetching users...");
        // final usersResponse = await widget.dioClient.get(
        //   "/users/${loginResponse.data['user']['id']}",
        // );
        // print("✅ Users Response: ${usersResponse.data}");
      }
    } on DioException catch (dioError) {
      print("❌ DioException caught");
      print("❌ Status Code: ${dioError.response?.statusCode}");
      print("❌ Response Data: ${dioError.response?.data}");

      // Check if AuthInterceptor wrapped a NetworkException in error field
      if (dioError.error is layer.NetworkException) {
        final networkError = dioError.error as layer.NetworkException;
        print("🔍 Custom NetworkException detected from AuthInterceptor");

        // Handle authentication-specific errors using maybeWhen
        final errorMessage = layer.NetworkException.getErrorMessage(
          networkError,
        );
        setState(() {
          _result = errorMessage.toString();

          //  user = zenifyAuth.User.fromJson(usersResponse.data);
        });
        setState(() => _isLoading = false);
        networkError.maybeWhen(
          tokenExpired: () {
            print("❌ Token expired - Redirecting to login");
            _handleAuthenticationRequired(
              "Your session has expired. Please log in again.",
            );
          },
          tokenMalformed: () {
            print("❌ Token malformed - Redirecting to login");
            _handleAuthenticationRequired(
              "Authentication error. Please log in again.",
            );
          },
          sessionExpired: () {
            print("❌ Session expired - Redirecting to login");
            _handleAuthenticationRequired(
              "Your session has expired. Please log in again.",
            );
          },
          unauthorised: () {
            print("❌ Unauthorised - Redirecting to login");
            _handleAuthenticationRequired(
              "Unauthorised access. Please log in.",
            );
          },
          orElse: () {
            // For all other error types, get the message and show it
            final errorMessage = layer.NetworkException.getErrorMessage(
              networkError,
              response: dioError.response,
            );
            final localizedMessage = layer.AppLocalizations.of(
              context,
            )!.translate(errorMessage);
            _showError(localizedMessage, dioError.response?.statusCode);
          },
        );
      } else {
        // Handle regular DioException (not from AuthInterceptor)
        final networkError = layer.NetworkException.getDioException(dioError);
        final errorMessage = layer.NetworkException.getErrorMessage(
          networkError,
          response: dioError.response,
        );
        setState(() {
          _result = networkError.toString();

          //  user = zenifyAuth.User.fromJson(usersResponse.data);
        });
        setState(() => _isLoading = false);
        // Special handling for 422 Validation Errors
        if (dioError.response?.statusCode == 422) {
          print("❌ Validation Error (422)");
          final errorData = dioError.response?.data?['error'];
          final mainMessage = errorData?['message'] as String?;
          final details = errorData?['details'] as List?;

          if (details != null && details.isNotEmpty) {
            print("📋 Validation details:");
            final validationMessages = <String>[];

            for (var detail in details) {
              final field = detail['field'] as String? ?? 'unknown';
              final message = detail['message'] as String? ?? '';
              final code = detail['code'] as int?;

              print("   • $field: $message (code: $code)");
              validationMessages.add("$field: $message");
            }

            final combinedMessage = validationMessages.join('\n');
            _showError(combinedMessage, 422);
          } else {
            // No details, just show main message
            _showError(mainMessage ?? 'Validation failed', 422);
          }
        } else {
          // For all other errors, use standard error message
          final errorMessage = layer.NetworkException.getErrorMessage(
            networkError,
            response: dioError.response,
          );
          final localizedMessage = layer.AppLocalizations.of(
            context,
          )!.translate(errorMessage);
          _showError(localizedMessage, dioError.response?.statusCode);
        }
      }
    } catch (e, stackTrace) {
      print("❌ Unexpected Error: $e");
      print("❌ Stack Trace: $stackTrace");
      setState(() => _result = "❌ Unexpected Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Helper method to show errors
  void _showError(String message, int? statusCode) {
    print("❌ Showing error to user: $message");

    setState(() {
      _result =
          "❌ Error: $message${statusCode != null ? '\nStatus: $statusCode' : ''}";
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Handle authentication required scenarios
  void _handleAuthenticationRequired(String message) {
    print("🔒 Authentication required: $message");

    setState(() {
      _result = "🔒 $message";
    });

    // Clear tokens
    // widget.dioClient.tokenService.clearTokens();

    if (mounted) {
      // Show snackbar with login action
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Login',
            textColor: Colors.white,
            onPressed: _navigateToLogin,
          ),
        ),
      );

      // Optional: Auto-redirect after delay
      //   Future.delayed(const Duration(seconds: 4), () {
      //     if (mounted) {
      //       _navigateToLogin();
      //     }
      //   });
    }
  }

  Future<zenifyAuth.User?> getUserProfile(String userId) async {
    setState(() => _isLoading = true);

    try {
      final response = await widget.dioClient.get('/users/$userId');
      print("✅ Request succeeded: /users/$userId");
      print("✅ Status Code: ${response.statusCode}");
      print("✅ Response Data: ${response.data}");

      user = zenifyAuth.User.fromJson(response.data);
      setState(() => _isLoading = false);
      setState(() {
        _result = "Authontificatecd";

        //  user = zenifyAuth.User.fromJson(usersResponse.data);
      });
      return user;
    } on DioException catch (dioError) {
      print("❌ DioException caught");
      print("❌ Status Code: ${dioError.response?.statusCode}");
      print("❌ Response Data: ${dioError.response?.data}");

      setState(() => _isLoading = false);

      // Convert to NetworkException if needed
      final networkError =
          dioError.error is layer.NetworkException
              ? dioError.error as layer.NetworkException
              : layer.NetworkException.getDioException(dioError);

      // Get error message
      final errorMessage = layer.NetworkException.getErrorMessage(
        networkError,
        response: dioError.response,
      );

      setState(() => _result = errorMessage);

      // Handle authentication errors (redirect to login)
      networkError.maybeWhen(
        tokenExpired: () => _handleAuthenticationRequired(errorMessage),
        tokenMalformed: () => _handleAuthenticationRequired(errorMessage),
        sessionExpired: () => _handleAuthenticationRequired(errorMessage),
        unauthorised: () => _handleAuthenticationRequired(errorMessage),
        orElse: () => _showError(errorMessage, dioError.response?.statusCode),
      );

      return null;
    } catch (e) {
      print("❌ Unexpected error: $e");
      setState(() {
        _isLoading = false;
        _result = "Unexpected error: $e";
      });
      _showError("An unexpected error occurred", null);
      return null;
    }
  }

  //   void _showError(String message, int? statusCode) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(message),
  //         backgroundColor: Colors.red,
  //         duration: const Duration(seconds: 4),
  //       ),
  //     );
  //   }

  //   void _handleAuthenticationRequired(String message) {
  //     _showError(message, 401);
  //     Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  //   }
  // Navigate to login screen
  void _navigateToLogin() {
    print("🔄 Navigating to login screen");

    // Replace with your actual login route
    // Navigator.of(context).pushReplacementNamed('/login');

    // OR use pushNamedAndRemoveUntil to clear the navigation stack:
    // Navigator.of(context).pushNamedAndRemoveUntil(
    //   '/login',
    //   (route) => false,
    // );

    // OR if you have a login widget directly:
    // Navigator.of(context).pushReplacement(
    //   MaterialPageRoute(builder: (context) => LoginScreen()),
    // );
  }

  // Future<void> _loadData() async {
  //   setState(() {
  //     _isLoading = true;
  //     _result = "🔍 Loading data...";
  //   });

  //   try {
  //     print("🔍 Logging in...");

  //     // IMPORTANT: Use widget.dioClient.post (NOT widget.dioClient.dio.post)
  //     // This ensures proper initialization
  //     final loginResponse = await widget.dioClient.post(
  //       "/auth/login",
  //       data: {
  //         "email":
  //             "oussamamethnani321@gmail.com", // Changed from "username" to "email"
  //         "password": "123456",
  //       },
  //     );

  //     if (loginResponse.statusCode == 200 || loginResponse.statusCode == 201) {
  //       print("✅ Login Response: ${loginResponse.data}");

  //       final accessToken = loginResponse.data['accessToken'];
  //       final refreshToken = loginResponse.data['refreshToken'];

  //       print("🔍 Saving tokens...");
  //       await widget.dioClient.tokenService.saveTokens(
  //         accessToken: accessToken,
  //         refreshToken:
  //             refreshToken, // Fixed: was accessToken, should be refreshToken
  //       );

  //       print("✅ Tokens saved successfully");
  //       print("🔍 Verifying saved token...");
  //       final savedToken = await widget.dioClient.tokenService.getAccessToken();
  //       print("🔍 Saved token: $savedToken");
  //       final savedRefToken =
  //           await widget.dioClient.tokenService.getRefreshToken();
  //       print("🔍 Saved Reftoken: $savedRefToken");
  //       await Future.delayed(const Duration(milliseconds: 100));

  //       print("🔍 Fetching users...");

  //       // IMPORTANT: Use widget.dioClient.get (NOT widget.dioClient.dio.get)
  //       // This ensures the AuthInterceptor adds the Bearer token
  //       final usersResponse = await widget.dioClient.get(
  //         "/users/${loginResponse.data['user']['id']}",
  //       );

  //       print("✅ Users Response: ${usersResponse.data}");

  //       setState(() {
  //         _result = usersResponse.data.toString();
  //         user = zenifyAuth.User.fromJson(usersResponse.data);
  //       });
  //     } else {
  //       print('❌ Login failed with status: ${loginResponse.statusCode}');
  //       print('Error: ${loginResponse.data}');
  //     }
  //   } on DioException catch (dioError) {
  //     final networkError = layer.NetworkException.getDioException(dioError);

  //     final errorMessage = layer.NetworkException.getErrorMessage(networkError);
  //     final localizedMessage = layer.AppLocalizations.of(
  //       context,
  //     )!.translate(errorMessage);

  //     setState(() {
  //       _result =
  //           "❌ Error: $localizedMessage\nStatus: ${dioError.response?.statusCode}";
  //     });
  //   } catch (e, stackTrace) {
  //     print("❌ Unexpected Error: $e");
  //     print("❌ Stack Trace: $stackTrace");
  //     setState(() => _result = "❌ Unexpected Error: $e");
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final networkAsync = ref.watch(layer.networkStatusProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authState = ref.watch<zenifyAuth.AuthState?>(
        zenifyAuth.authProvider,
      );
      final accessToken = authState!.token;
      final refreshToken = authState!.refreshToken;

      if (accessToken != null && refreshToken != null) {
        await widget.dioClient.tokenService.saveAccessToken(accessToken);
        await widget.dioClient.tokenService.saveRefreshToken(refreshToken);
        print('✅ Tokens saved $accessToken');
        print('✅ Tokens saved $refreshToken');
      } else {
        print('⚠️ Tokens not available yet');
      }
    });

    // FlutterI18n.refresh(context, forcedLocale: Locale('en'));
    FlutterI18n.translate(context, "login_email_hint");
    FlutterI18n.translate(context, "hello");
    // React to network changes
    ref.listen<AsyncValue<layer.NetworkStatus>>(layer.networkStatusProvider, (
      prev,
      next,
    ) {
      if (next.hasValue) {
        final newStatus = next.value!;
        if (_lastStatus != newStatus) {
          _lastStatus = newStatus;

          final message =
              newStatus == layer.NetworkStatus.online
                  ? "✅ Back online — retrying..."
                  : "📴 You are offline";

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));

          // Auto-retry when coming online
          if (newStatus == layer.NetworkStatus.online) {
            // _loadData();
          }
        }
      }
    });

    return networkAsync.when(
      data: (status) {
        final isOnline = status == layer.NetworkStatus.online;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                //Text(FlutterI18n.translate(context, "oussama")),
                // I18nText("auth_login_email", child: Text("")),
                // Text(
                //   "${zenifyAuth.AppLocalizations.of(context)?.auth_login_email}",
                // ),
                // const SizedBox(width: 8),
                // const Icon(Icons.cloud, size: 20),
              ],
            ),
            backgroundColor: isOnline ? Colors.green : Colors.red,
          ),
          body: zenifyAuth.LoginScreen(
            // passwordLabel: "hi",
            passwordDecoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.amberAccent),
              // prefixIcon: const Icon(Icons.ey),
              hintStyle: TextStyle(
                color: const Color.fromARGB(255, 72, 50, 43),
              ),
              filled: true,
              fillColor: const Color.fromARGB(255, 116, 175, 201),
            ),
            emailDecoration: InputDecoration(
              //    hintText: 'Email s',
              hintStyle: TextStyle(
                color: const Color.fromARGB(255, 222, 65, 18),
              ),
              filled: true,
              prefixIcon: const Icon(Icons.email_outlined),
              border: const OutlineInputBorder(),

              fillColor: const Color.fromARGB(255, 163, 165, 166),

              // border: OutlineInputBorder(
              //   borderRadius: BorderRadius.circular(12),
              //   borderSide: BorderSide.none,
              // ),
            ),
            minPasswordLength: 5,
            showLoginwithCode: false,
            onLoginwithCode: () {
              // Handle login with code action
              // For example, navigate to a code input screen
              // Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (context) => CodeLoginScreen(),
              //   ),
              // );
              context.go('/loginwithcode');
            },
            title: FlutterI18n.translate(context, "oussama"),
            loginWithCodeText: 'Login with Code', // Optional: customize text
            loginWithCodeButtonStyle: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ), // Optional: customize button style
            // backgroundImage:
            //     "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTKfP5aLyOd2XJQEwo54_P5a9fM7iOwOZzK4nl6Zj6Ydg2ZKFCbXR1C7hIVEg7iP-mTZ7FXrkpFAoolYClhq4UeAm9AO5W03VNuJSnYPBwcyg",
            loginButtonText: "Sign In",
            showSocialLogin: true,
            accentColor: Colors.amber,
            //   socialProviders: [
            // SocialLoginProvider(
            //   name: 'Google',
            //   icon: Icon(Icons.g_mobiledata, color: Colors.red),
            //   onPressed: () => _handleGoogleLogin(),
            // ),
            // SocialLoginProvider(
            //   name: 'Facebook',
            //   icon: Icon(Icons.facebook, color: Colors.white),
            //   onPressed: () => _handleFacebookLogin(),
            //   backgroundColor: Color(0xFF1877F2),
            //   textColor: Colors.white,
            // ),
            // ],
            snackBarColor: Colors.green, // ✅ Custom SnackBar color
            showForgotPassword: true, // ✅ Show Forgot Password
            canRegister: true,
            onRegister: () => context.go('/register'),
            onForgotPassword: () async {
              //  await _showForgotPasswordDialog(context);
              // ✅ Your forgot password logic
              print("Forgot Password Clicked");
              // You can navigate to forgot password screen:
              // context.go('/forgot-password');
            },
          ),

          // Center(
          //             child:
          //                 _isLoading
          //                     ? const CircularProgressIndicator()
          //                     : Padding(
          //                       padding: const EdgeInsets.all(16.0),
          //                       child: SingleChildScrollView(
          //                         child: Column(
          //                           children: [
          //                             if (user != null) ...[
          //                               CircleAvatar(
          //                                 radius: 50,
          //                                 backgroundImage:
          //                                     user!.picture != null
          //                                         ? NetworkImage(
          //                                           "${widget.dioClient.config.baseUrl}/assets/uploads/traveller/${user!.picture!}",
          //                                         )
          //                                         : null,
          //                                 child:
          //                                     user!.picture == null
          //                                         ? Icon(Icons.person, size: 50)
          //                                         : null,
          //                               ),
          //                               const SizedBox(height: 16),
          //                               Text(
          //                                 "${user!.firstName} ${user!.lastName}",
          //                                 style: const TextStyle(
          //                                   fontSize: 20,
          //                                   fontWeight: FontWeight.bold,
          //                                 ),
          //                               ),
          //                               const SizedBox(height: 8),
          //                               Text(
          //                                 user!.email ?? "",
          //                                 style: const TextStyle(
          //                                   fontSize: 16,
          //                                   color: Colors.grey,
          //                                 ),
          //                               ),
          //                             ],
          //                             Text(
          //                               isOnline
          //                                   ? _result
          //                                   : "⚠️ Offline — unable to load data.\n\nLast known result:\n$_result",
          //                               textAlign: TextAlign.center,
          //                             ),
          //                           ],
          //                         ),
          //                       ),
          //                     ),
          //           ),
        );
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text("Error: $e"))),
    );
  }
}

class MyApp extends ConsumerWidget {
  MyApp({super.key});
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  // This widget is the root of your application.

  Widget build(BuildContext context, WidgetRef ref) {
    final router = AppRoutConfig.returnRouter(ref);
    return MaterialApp.router(
      //  locale: const Locale('en'), // Add this line
      locale: const Locale('fr'),

      localizationsDelegates: [
        FlutterI18nDelegate(
          translationLoader: FileTranslationLoader(
            basePath: "assets/flutter_i18n",
            // fallbackFile: 'en',
            // useCountryCode: false,
          ),
        ),
        zt_common_i18n.commonI18nDelegate(),
        zenifyAuth.AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        // ...GlobalMaterialLocalizations.delegates,
      ],

      supportedLocales: const [Locale('en'), Locale('ar'), Locale('fr')],

      // routerConfig: _router,
      //    locale: const Locale('en'),
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: AppEnvironment.lightTheme,
      title: 'ZenifyTrip Guide',
      //locale: const Locale('ar'),
      debugShowCheckedModeBanner: false,
      //restorationScopeId: null, // Disable restoration to avoid the error
      routerConfig: router, // 👈 This is enough! Remove parser/delegate
    );
  }
}
