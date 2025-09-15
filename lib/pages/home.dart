import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zenifytrip_guide/env.dart';
import 'package:zenifytrip_guide/features/task/TaskService.dart';
import 'package:zenifytrip_guide/features/task/tasklist.dart';
import 'package:zenifytrip_guide/features/task/taskpage.dart';
import 'package:zenifytrip_guide/map.dart';
import 'package:zenifytrip_guide/pages/about.dart';
import 'package:zenifytrip_guide/screens/explore.dart';
import 'package:zenifytrip_guide/theme.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import 'discovery_page.dart';
import 'package:zenify_auth/zenify_auth.dart';
import 'message_page.dart';
import 'profile_page.dart';

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

  final taskService = TaskService();

  final List<Widget> _pages = [
    const DiscoveryPage(),
    TaskListPage(),
    ExplorePage(),
    const MessagePage(),
    ProfilePage(),
  ];

  // Socket state
  bool _isSocketReconnecting = false;

  @override
  void initState() {
    super.initState();
    SocketIOManager.instance.initialize(url: "https://api.staging.zenifytrip.com");  
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    // ZenifyAuth.initialize(
    //       baseUrl: "https://api.staging.zenifytrip.com", // project-specific URL
    //       fromJson: (json) => User.fromJson(json),
    //     );
    //await SocketIOManager.instance.initSocket();
    // Listen to socket connection/reconnection

    //SocketIOManager.addConnectionListener(_onConnectionStatusChanged);
  }

  void _onConnectionChanged(bool isConnected) {
    if (mounted) {
      setState(() {
        _isSocketReconnecting = isConnected;
        if (isConnected) {
          // Reconnected - reload conversations
          // socketManager.updateConversationListAndContentListener(_onConversation);
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
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

  @override
  Widget build(BuildContext context) {
    //  final user = ref.watch(authProvider);
    final theme = Theme.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SocketIOManager.instance.addConnectionChangeListener(
        _onConnectionChanged,
      );
    });
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: _pages[_selectedIndex],
          ),
          // Green circular overlay when socket reconnecting
          if (_isSocketReconnecting)
            Positioned(
              top: 40,
              left: 20,
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

  String _getDiscoveryBadgeCount() => '3';
  String _getMessageBadgeCount() => '12';
}
