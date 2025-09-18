import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zenifytrip_guide/env.dart';
import 'package:zenifytrip_guide/features/task/TaskService.dart';
import 'package:zenifytrip_guide/features/task/tasklist.dart';
import 'package:zenifytrip_guide/provider/location_provider.dart';
import 'package:zenifytrip_guide/provider/mapLoader.dart';
import 'package:zenifytrip_guide/provider/mapSecreen..dart';
import 'package:zenifytrip_guide/screens/explore.dart';
import 'package:zenifytrip_guide/theme.dart';
import '../features/auth/presentation/providers/auth_provider.dart'
    hide authProvider;
import 'discovery_page.dart';
import 'message_page.dart';
import 'profile_page.dart';
import 'package:zenify_auth/zenify_auth.dart';
import 'package:provider/provider.dart' as p;
import 'package:zenify_auth/zenify_auth.dart' as zenifyAuth;

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  LocationProvider? _locationProvider;
  bool _locationInitialized = false;
  final taskService = TaskService();

  // Socket state
  bool _isSocketReconnecting = false;

  // Provide a prompt that contains text

  @override
  void initState() {
    super.initState();

    SocketIOManager.instance.initialize(
      url: "https://api.staging.zenifytrip.com",
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    ref.read(zenifyAuth.authProvider.notifier).fetchUserProfile();
  }

  Future<void> _initializeLocationProvider(String url) async {
    _locationProvider = LocationProvider();
    _locationProvider!.setPictureUrl(
      "https://api.staging.zenifytrip.com/assets/uploads/traveller/$url",
    );

    await _locationProvider!.initialization(startTracking: false);
    if (mounted) {
      await _locationProvider!.loadPositionsFromApi('', context);
      setState(() {
        _locationInitialized = true;
      });
    }
  }

  void _onConnectionChanged(bool isConnected) {
    if (mounted) {
      setState(() {
        _isSocketReconnecting = isConnected;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _locationProvider?.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
      HapticFeedback.selectionClick();
      _animationController.reset();
      _animationController.forward();
    }
  }

  List<Widget> _getPages() {
    if (!_locationInitialized || _locationProvider == null) {
      return [
        const DiscoveryPage(),
        TaskListPage(),
        const MapLoadingIndicator(), // Placeholder for map
        const MessagePage(),
        ProfilePage(),
      ];
    }

    return [
      const DiscoveryPage(),
      TaskListPage(),
      p.ChangeNotifierProvider.value(
        value: _locationProvider!,
        child: const MapScreenContent(),
      ),
      //  MapScreenContent(),
      const MessagePage(),
      ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen for socket changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SocketIOManager.instance.addConnectionChangeListener(
        _onConnectionChanged,
      );

      // Initialize location provider only once when authenticated
      if (authState.status == AuthStatus.authenticated &&
          !_locationInitialized &&
          authState.user?.picture != null) {
        _initializeLocationProvider(authState.user!.picture!);
      }
    });

    switch (authState.status) {
      case AuthStatus.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));

      case AuthStatus.unauthenticated:
        return const Scaffold(body: Center(child: Text("Please log in")));

      case AuthStatus.authenticated:
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: Stack(
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: IndexedStack(
                  index: _selectedIndex,
                  children: _getPages(),
                ),
              ),
              if (_isSocketReconnecting)
                Positioned(
                  top: 50,
                  left: 30,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              if (!_isSocketReconnecting)
                Positioned(
                  top: 40,
                  left: 20,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 240, 75, 15),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(
                            255,
                            125,
                            3,
                            3,
                          ).withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ConvexAppBar.badge(
              badgeMargin: const EdgeInsets.only(bottom: 30, right: 40),
              badgeColor: const Color(0xFFFF5722),
              badgeTextColor: Colors.white,
              {0: _getDiscoveryBadgeCount(), 3: _getMessageBadgeCount()},
              style: TabStyle.titled,
              backgroundColor: AppEnvironment.lightTheme.primaryColor,
              activeColor: AppEnvironment.lightTheme.secondaryHeaderColor,
              color: const Color(0xFF81C784),
              items: const [
                TabItem(
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore,
                  title: 'Discover',
                ),
                TabItem(
                  icon: Icons.add_circle_outline,
                  activeIcon: Icons.add_circle,
                  title: 'Create',
                ),
                TabItem(
                  icon: Icons.map_sharp,
                  activeIcon: Icons.map_sharp,
                  title: 'Map',
                ),
                TabItem(
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble,
                  title: 'Messages',
                ),
                TabItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  title: 'Profile',
                ),
              ],
              initialActiveIndex: _selectedIndex,
              onTap: _onTabTapped,
            ),
          ),
        );
    }
  }

  String _getDiscoveryBadgeCount() => '3';
  String _getMessageBadgeCount() => '12';
}
