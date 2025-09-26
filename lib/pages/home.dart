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
import 'package:zenify_auth/zenify_auth.dart' hide SocketIOManager;
import 'package:provider/provider.dart' as p;
import 'package:zenify_auth/zenify_auth.dart' as zenifyAuth;
import 'package:socket_io_riverpod/socket_io_riverpod.dart';
import 'package:socket_io_riverpod/socket_io_riverpod.dart' as m;

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
  late SocketIOManager socketManager;
  LocationProvider? _locationProvider;
  bool _locationInitialized = false;
  final taskService = TaskService();

  // Socket state
  bool _isSocketReconnecting = false;
  Color colorconnction = Colors.transparent;
  // Provide a prompt that contains text
  late AuthState<User> userelement = AuthState();
  @override
  void initState() {
    super.initState();
    // _initializeSocket();
   // ref.read(zenifyAuth.authProvider.notifier).fetchUserProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //   socketManager = SocketIOManager.instance;

      _initializeSocket();
      socketManager.addMessageListener((m.ChatMessage message) {
        print('New message received: ${message.content}');
        // Handle the message as needed
        // The message is automatically added to Riverpod state
      });

      // Add connection state listener
      // final config = SocketConfig(
      //   url: 'https://api.staging.zenifytrip.com',
      //   enableLogging: true,
      //   token:
      //       "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjA2Mzk5NWU0LTZmMjQtNGNmYi05YzQwLWU4Y2M4N2I1MTJlZSIsInN1YiI6IjA2Mzk5NWU0LTZmMjQtNGNmYi05YzQwLWU4Y2M4N2I1MTJlZSIsInVzZXJuYW1lIjoib3Vzc2FtYW1ldGhuYW5pQGdtYWlsLmNvbSIsImVtYWlsIjoib3Vzc2FtYW1ldGhuYW5pQGdtYWlsLmNvbSIsInJvbGUiOiJBZG1pbmlzdHJhdG9yIiwiZmlyc3ROYW1lIjoiT3Vzc2FtYSIsInBob25lIjoiMjA2NDA3ODMiLCJsYXN0TmFtZSI6Ik1ldGhuYW5pIiwiZXhwaXJlcyI6MTc1ODg5MjQxNywiY3JlYXRlZCI6MTc1ODI4NzYxNywiaWF0IjoxNzU4Mjg3NjE3LCJleHAiOjE3NTg4OTI0MTd9.iySsbRuzF8VPBWWnF7JubVENdQXYgrQj7vxWk4ZIBMA",
      // );

      // socketManager.configure(
      //   config,
      //   headersProvider: () async {
      //     // final box = await Hive.openBox('cookieBox');
      //     // final cookie = box.get('ZENIFY_SESSION_ID');
      //     return {
      //       if ("s" != null)
      //         'Cookie':
      //             'ZENIFY_SESSION_ID=s%3AUx9AGMQc-Jhljlo3wqJA_NDlkh-r_3bl.Uc56ZOF6oHHfXfDBQwMgluyGv9r315kjRbp040myYcI; Path=/; HttpOnly; Expires=Mon, 20 Oct 2025 13:28:26 GMT;',
      //     };
      //   },
      // );
    });
    // socketManager.initialize();

    // Add connection state listener

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
   
  }

  void _initializeSocket() async {

   
    // final  user =
    //     await  ref.read(zenifyAuth.authProvider.notifier).fetchUserProfile();
    var userelement = ref.read(zenifyAuth.authProvider);
    final cookies = userelement?.cookie;

    final token = userelement?.token;
    print('hiiiiii $token $cookies');
    // Configure socket

    socketManager = SocketIOManager.instance;

    final config = SocketConfig(
      currentUserID: userelement.user?.id ?? "",
      url: 'https://api.staging.zenifytrip.com',
      enableLogging: true,
      token: "$token",
    );

    socketManager.configure(
      config,
      headersProvider: () async {
        return {if (cookies != null) 'Cookie': cookies};
      },
      providerContainer: ProviderScope.containerOf(context),
    );

    //   // Add message listener using the new method

    //   // Initialize socket connection
    await socketManager.initialize();
    //  await zenifyAuth.ZenifyAuth.initialize(
    //   baseUrl: "https://api.staging.zenifytrip.com", // project-specific URL
    //   fromJson: (json) => zenifyAuth.User.fromJson(json),
    // );
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
        ConversationsScreen(
          initialConversationId: "c153a884-ebb1-41eb-99cb-2b465491430b",
          currentUserId: userelement.user?.id ?? "",
        ),
        // TaskListPage(),
        const MapLoadingIndicator(), // Placeholder for map
        ChatScreen(
          conversationId: 'c153a884-ebb1-41eb-99cb-2b465491430b',
          conversationName: 'Team Chat',
          currentUserID: userelement.user?.id ?? "",
        ),
        //zenifyAuth.AuthFlowScreen(),
        ProfilePage(),
      ];
    }

    return [
      const DiscoveryPage(),
      ConversationsScreen(
        initialConversationId: "c153a884-ebb1-41eb-99cb-2b465491430b",
        currentUserId: userelement.user?.id ?? "",
      ),
      //TaskListPage(),
      p.ChangeNotifierProvider.value(
        value: _locationProvider!,
        child: const MapScreenContent(),
      ),
      //  MapScreenContent(),
      ChatScreen(
        conversationId: 'c153a884-ebb1-41eb-99cb-2b465491430b',
        conversationName: 'Team Chat',
        currentUserID: userelement.user?.id ?? "",
      ),
      ProfilePage(),
      //zenifyAuth.AuthFlowScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen for socket changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      socketManager.addConnectionListener((state) {
        if (state.isConnected) {
          _isSocketReconnecting = state.isConnected;
          colorconnction = Colors.teal;
          // ScaffoldMessenger.of(
          //   context,
          // ).showSnackBar(SnackBar(content: Text('Connected to server')));
        } else if (state.error != null) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('Connection error: ${state.error}')),
          // );
          colorconnction = Colors.red;

          _isSocketReconnecting = state.isReconnecting;
        } else if (state.isReconnecting) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('Connection error: ${state.error}')),
          // );
          colorconnction = Colors.blue;

          _isSocketReconnecting = state.isReconnecting;
        }
      });

      // zenifyAuth.SocketIOManager.instance.addConnectionChangeListener(
      //   _onConnectionChanged,
      // );

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
          // appBar: AppBar(
          //   title: Text('Socket App'),
          //   actions: [
          //     // Show connection status
          //     SocketStatusWidget(),
          //   ],
          // ),
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

              Positioned(
                top: 80,
                right: 35,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colorconnction,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorconnction.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              //   if (!_isSocketReconnecting)
              //     Positioned(
              //       top: 40,
              //       left: 20,
              //       child: Container(
              //         width: 16,
              //         height: 16,
              //         decoration: BoxDecoration(
              //           color: const Color.fromARGB(255, 240, 75, 15),
              //           shape: BoxShape.circle,
              //           boxShadow: [
              //             BoxShadow(
              //               color: const Color.fromARGB(
              //                 255,
              //                 125,
              //                 3,
              //                 3,
              //               ).withOpacity(0.5),
              //               blurRadius: 8,
              //               spreadRadius: 2,
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
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
