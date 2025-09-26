import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenify_auth/zenify_auth.dart' as zenifyAuth;
import 'package:go_router/go_router.dart';
import 'package:socket_io_riverpod/socket_io_riverpod.dart';

class HomeTestScreen extends ConsumerStatefulWidget {
  const HomeTestScreen({super.key});

  @override
  ConsumerState<HomeTestScreen> createState() => _HomeTestScreenState();
}

class _HomeTestScreenState extends ConsumerState<HomeTestScreen> {
  late SocketIOManager socketManager;
  bool _isSocketReconnecting = false;
  Color colorConnection = Colors.grey;
  bool _socketInitialized = false;
  bool _authDataLoaded = false;
  bool _isRefreshingSocket = false; // Added for refresh button state
  final StreamController<zenifyAuth.AuthState> _authStreamController =
      StreamController<zenifyAuth.AuthState>.broadcast();
  @override
  void initState() {
    super.initState();
    print("initstateeee");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAuthAndSocket();
      _refreshSocket();

    });
  }

  Future<void> _initializeAuthAndSocket() async {
    try {
      // // Initialize ZenifyAuth first
      // await zenifyAuth.ZenifyAuth.initialize(
      //   baseUrl: "https://api.staging.zenifytrip.com",
      //   fromJson: (json) => zenifyAuth.User.fromJson(json),
      // );

      // Clear cached user data and fetch fresh profile
      await zenifyAuth.ZenifyAuth.clearUserData();
      await ref.read(zenifyAuth.authProvider.notifier).fetchUserProfile();

      setState(() {
        _authDataLoaded = true;
      });

      _setupSocket();

      // Initialize socket after auth data is loaded
    } catch (e) {
      print('Error initializing auth and socket: $e');
    }
  }

  void _setupSocket() {
    if (_socketInitialized) return;

    final authState = ref.read(zenifyAuth.authProvider);

    if (authState.token == null) {
      print('No token available for socket setup');
      return;
    }

    socketManager = SocketIOManager.instance;

    final config = SocketConfig(
      currentUserID: authState.user?.id ?? "default-user-id",
      url: 'https://api.staging.zenifytrip.com',
      enableLogging: true,
      token: authState.token!,
    );

    socketManager.configure(
      config,
      headersProvider: () async {
        final currentAuthState = ref.read(zenifyAuth.authProvider);
        return {
          if (currentAuthState.cookie != null)
            'Cookie': currentAuthState.cookie!,
        };
      },
      providerContainer: ProviderScope.containerOf(context),
    );

    _initializeSocketConnection();
    _socketInitialized = true;
  }

  Future<void> _initializeSocketConnection() async {
    try {
      await socketManager.initialize();

      // Listen for socket state changes
      socketManager.addConnectionListener((state) {
        if (mounted) {
          setState(() {
            if (state.isConnected) {
              _isSocketReconnecting = false;
              _isRefreshingSocket = false;
              colorConnection = Colors.teal;
            } else if (state.error != null) {
              _isSocketReconnecting = state.isReconnecting;
              colorConnection = Colors.red;
            } else if (state.isReconnecting) {
              _isSocketReconnecting = true;
              colorConnection = Colors.blue;
            }
          });
        }
      });
    } catch (e) {
      print('Error initializing socket connection: $e');
      setState(() {
        colorConnection = Colors.red;
        _isRefreshingSocket = false;
      });
    }
  }

  // Added socket refresh method
  Future<void> _refreshSocket() async {
    if (_isRefreshingSocket) return;

    setState(() {
      _isRefreshingSocket = true;
      colorConnection = Colors.orange;
    });

    try {
      // Disconnect the current socket
      socketManager.disconnect();

      // Clear provider states
      socketManager.clearAllProviderStates();

      // Wait a bit before reconnecting
      await Future.delayed(const Duration(milliseconds: 500));

      // Re-initialize the socket connection
      await _initializeSocketConnection();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Socket refreshed successfully'),
            backgroundColor: Colors.teal,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error refreshing socket: $e');
      setState(() {
        colorConnection = Colors.red;
        _isRefreshingSocket = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to refresh socket'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 Watch auth provider to react to changes
    final authState = ref.watch(zenifyAuth.authProvider);

    // 🔹 Re-setup socket when auth state changes (and we have fresh data)
    if (_authDataLoaded && !_socketInitialized && authState.token != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setupSocket();
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Stack(
        children: [
          Center(
            child:
                authState.user != null
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "✅ Logged in as: ${authState!.cookie ?? 'Unknown'}${authState!.token ?? 'Unknown'}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "✅ Logged in as: ${authState.user!.firstName ?? 'Unknown'}${authState.user!.lastName ?? 'Unknown'}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "📧 Email: ${authState.user!.email ?? 'N/A'}",
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "🔑 Token: ${authState.token != null ? '${authState.token!.substring(0, 20)}...' : 'No token'}",
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "🍪 Cookies: ${authState.cookie != null ? 'Available' : 'No cookies'}",
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text("🔌 Socket: "),
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: colorConnection,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isRefreshingSocket
                                        ? "Refreshing..."
                                        : _isSocketReconnecting
                                        ? "Reconnecting..."
                                        : colorConnection == Colors.teal
                                        ? "Connected"
                                        : colorConnection == Colors.red
                                        ? "Disconnected"
                                        : "Connecting...",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Added Socket Refresh Button
                        const SizedBox(height: 24),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed:
                                _isRefreshingSocket ? null : _refreshSocket,
                            icon:
                                _isRefreshingSocket
                                    ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Icon(
                                      Icons.refresh,
                                      color: Colors.white,
                                    ),
                            label: Text(
                              _isRefreshingSocket
                                  ? 'Refreshing...'
                                  : 'Refresh Socket',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                    : const CircularProgressIndicator(),
          ),

          // Logout button
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    await _showLogoutDialog();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 12),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Connection indicator
          Positioned(
            top: 80,
            right: 35,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: colorConnection,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorConnection.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Sign Out',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Are you sure you want to sign out of your account?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Sign Out'),
              ),
            ],
          ),
    );

    if (shouldLogout == true) {
      try {
        // Logout through auth provider
        await ref.read(zenifyAuth.authProvider.notifier).logout();

        // Clean up socket
        SocketIOManager.instance.clearAllProviderStates();
        SocketIOManager.instance.disconnect();

        if (mounted) {
          context.go('/');
        }
      } catch (e) {
        print('Error during logout: $e');
      }
    }
  }
}
