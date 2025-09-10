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
import 'package:zenifytrip_guide/theme.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import 'discovery_page.dart';

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

  // Define color scheme for professional look
  static const Color _primaryColor = Color(0xFF2E7D32); // Professional green
  static const Color _secondaryColor = Color(0xFF81C784); // Light green
  static const Color _accentColor = Color(0xFF4CAF50); // Vibrant green
  static const Color _backgroundColor = Color(0xFFF8F9FA); // Clean background
  static const Color _badgeColor = Color(0xFFFF5722); // Orange for attention
final taskService = TaskService();
  // Pages to display
  final List<Widget> _pages = [
    const DiscoveryPage(),
      TaskListPage(),
      GoogleMapPage(),
    const MessagePage(),
    const ProfilePage(),
  
  ];

  @override
  void initState() {
    super.initState();

  
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      
      // Add haptic feedback for better UX
      HapticFeedback.selectionClick();
      
      // Reset and restart animation for smooth transitions
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _pages[_selectedIndex],
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
          // Enhanced styling properties
       
          // Badge configuration with improved positioning
          //badgeMargin: const EdgeInsets.only(top: 8, right: 4),
          badgeColor: _badgeColor,
          badgeTextColor: Colors.white,
          
          // Badge data - you can make this dynamic based on actual data
          {
            0: _getDiscoveryBadgeCount(),
            3: _getMessageBadgeCount(),
          },
          
          // Professional styling
          style: TabStyle.titled, // More stable than reactCircle
         backgroundColor: AppEnvironment.lightTheme.primaryColor,
          activeColor: AppEnvironment.lightTheme.secondaryHeaderColor,
          color: _secondaryColor,
          
          // Tab items with better icons and titles - 5 tabs for odd number
          items: [
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

  // Helper methods to get dynamic badge counts
  // You can replace these with actual data from your providers/state
  String _getDiscoveryBadgeCount() {
    // Replace with actual logic to get discovery notifications
    return '3'; // Example count
  }

  String _getMessageBadgeCount() {
    // Replace with actual logic to get unread messages
    return '12'; // Example count
  }
}

