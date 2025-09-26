import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenify_auth/zenify_auth.dart' as zenifyAuth;
import 'package:go_router/go_router.dart';
import 'package:zenifytrip_guide/features/ChatModulev2/SocketManagment.dart'
    hide SocketIOManager;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:socket_io_riverpod/socket_io_riverpod.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  String? socketId;
  List<ChatMessage> chatMessages = [];
  bool _isLoading = false;
  late final GenerativeModel model;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late zenifyAuth.AuthState<zenifyAuth.User> user;
  late SocketIOManager socketManager;

  @override
  void initState() {
    super.initState();
 //   _initializeSocket();
    ref.read(zenifyAuth.authProvider.notifier).fetchUserProfile();

    user = ref.read(zenifyAuth.authProvider);
    final firstName = user.user?.firstName ?? "traveler";
    final lastname = user.user?.username ?? "an unknown place";
    model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.0-flash',
      systemInstruction: Content.text(
        "You are chatting with user $firstName  $lastname ",
        // "Answer in a friendly and helpful way.",
      ),
    );
    _initializeChat();
  }

  void _initializeSocket() async {
    // Clear cached user data before fetching fresh profile
    //await zenifyAuth.ZenifyAuth.clearUserData();

    // Fetch fresh user profile
    // await ref.read(zenifyAuth.authProvider.notifier).fetchUserProfile();
    var userelement = ref.read(zenifyAuth.authProvider);
    // var userelement = ref.read(zenifyAuth.authProvider);
    //var userelements = ref.watch(zenifyAuth.authProvider);
    final token = userelement?.token;
    //final user = ZenifyAuth.getSavedUser();
    final cookies = userelement?.user?.cookie;

    print('userelement $token $cookies');
    // Configure socket

    socketManager = SocketIOManager.instance;

    final config = SocketConfig(
      currentUserID: "c46f41f5-91d3-43dd-8fc2-f452405b66a3",
      url: 'https://api.staging.zenifytrip.com',
      enableLogging: true,
      token:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjA2Mzk5NWU0LTZmMjQtNGNmYi05YzQwLWU4Y2M4N2I1MTJlZSIsInN1YiI6IjA2Mzk5NWU0LTZmMjQtNGNmYi05YzQwLWU4Y2M4N2I1MTJlZSIsInVzZXJuYW1lIjoib3Vzc2FtYW1ldGhuYW5pQGdtYWlsLmNvbSIsImVtYWlsIjoib3Vzc2FtYW1ldGhuYW5pQGdtYWlsLmNvbSIsInJvbGUiOiJBZG1pbmlzdHJhdG9yIiwiZmlyc3ROYW1lIjoiT3Vzc2FtYSIsInBob25lIjoiMjA2NDA3ODMiLCJsYXN0TmFtZSI6Ik1ldGhuYW5pIiwiZXhwaXJlcyI6MTc1OTQ5ODcyNCwiY3JlYXRlZCI6MTc1ODg5MzkyNCwiaWF0IjoxNzU4ODkzOTI0LCJleHAiOjE3NTk0OTg3MjR9.Ysjx9r5QoLrImKw0eKhK_zcATKMYB-2nSIXC4nSFnTI",
    );

    socketManager.configure(
      config,
      headersProvider: () async {
        return {'Cookie': "$cookies"};
      },
      //  providerContainer: ProviderScope.containerOf(context),
    );

    //   // Add message listener using the new method

    //   // Initialize socket connection
    await socketManager.initialize();
    //  await zenifyAuth.ZenifyAuth.initialize(
    //   baseUrl: "https://api.staging.zenifytrip.com", // project-specific URL
    //   fromJson: (json) => zenifyAuth.User.fromJson(json),
    // );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    // Add initial welcome message
    setState(() {
      chatMessages.add(
        ChatMessage(
          text: "Hello! I'm your AI assistant. How can I help you today?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  Future<void> _sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    // Add user message to chat
    setState(() {
      chatMessages.add(
        ChatMessage(text: input, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    // Clear input field
    _controller.clear();

    // Scroll to bottom
    _scrollToBottom();

    try {
      final response = await model.generateContent([Content.text(input)]);
      final text =
          response.text ??
          "I apologize, but I couldn't generate a response. Please try again.";

      setState(() {
        chatMessages.add(
          ChatMessage(text: text, isUser: false, timestamp: DateTime.now()),
        );
      });
    } catch (e, st) {
      debugPrint("AI error: $e\n$st");
      setState(() {
        chatMessages.add(
          ChatMessage(
            text:
                "I'm experiencing some technical difficulties. Please try again in a moment.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(zenifyAuth.authProvider);
    final authState = ref.watch(zenifyAuth.authProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Profile Header SliverAppBar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFFF75003),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFF75003),
                      const Color(0xFFF75003).withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Hero(
                        tag: 'profile-image',
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: CachedNetworkImage(
                            imageUrl:
                                "https://api.staging.zenifytrip.com/assets/uploads/traveller/${authState.user?.picture}",
                            errorWidget:
                                (context, url, error) => Container(
                                  width: 120,
                                  height: 120,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Color(0xFFF75003),
                                    size: 60,
                                  ),
                                ),
                            placeholder:
                                (context, url) => Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                            imageBuilder:
                                (context, imageProvider) => Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${authState.user?.firstName ?? ''} ${authState.user?.lastName ?? ''}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.status.name ?? 'Traveller',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  // Navigate to edit profile
                },
              ),
            ],
          ),

          // Stats and Menu Section
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF75003).withOpacity(0.05),
                            const Color(0xFFF75003).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFF75003).withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Trips', '12', Icons.flight_takeoff),
                          _buildDivider(),
                          _buildStatItem('Countries', '8', Icons.public),
                          _buildDivider(),
                          _buildStatItem('Reviews', '47', Icons.star),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Menu Section
                    const Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'Personal Information',
                      subtitle: 'Update your personal details',
                      onTap: () {
                        // Navigate to personal info
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.security_outlined,
                      title: 'Privacy & Security',
                      subtitle: 'Manage your privacy settings',
                      onTap: () {
                        // Navigate to privacy settings
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      subtitle: 'Configure your notifications',
                      onTap: () {
                        // Navigate to notifications
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.payment_outlined,
                      title: 'Payment Methods',
                      subtitle: 'Manage your payment options',
                      onTap: () {
                        // Navigate to payment methods
                      },
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Support',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: 'Help Center',
                      subtitle: 'Get help with your account',
                      onTap: () {
                        // Navigate to help
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.feedback_outlined,
                      title: 'Send Feedback',
                      subtitle: 'Help us improve the app',
                      onTap: () {
                        // Navigate to feedback
                      },
                    ),

                    const SizedBox(height: 32),

                    // Logout Button
                    Container(
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

                    const SizedBox(height: 24),

                    // Version Info
                    Center(
                      child: Text(
                        'Version 1.0.0',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // AI Chat Section Header
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF75003).withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    color: const Color(0xFFF75003),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'AI Assistant',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Chat Messages
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index < chatMessages.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: _buildChatMessage(chatMessages[index]),
                );
              }
              return null;
            }, childCount: chatMessages.length),
          ),

          // Loading Indicator
          if (_isLoading)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFFF75003),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'AI is typing...',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom padding for input field
          SliverToBoxAdapter(
            child: SizedBox(height: 80), // Space for fixed input field
          ),
        ],
      ),

      // Fixed Chat Input at bottom
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Ask me anything...',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  enabled: !_isLoading,
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: const Color(0xFFF75003),
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: _isLoading ? null : _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFF75003),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    message.isUser ? const Color(0xFFF75003) : Colors.grey[200],
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomRight:
                      message.isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(18),
                  bottomLeft:
                      message.isUser
                          ? const Radius.circular(18)
                          : const Radius.circular(4),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: CachedNetworkImage(
                imageUrl:
                    "https://api.staging.zenifytrip.com/assets/uploads/traveller/${user.user?.picture}",
                errorWidget:
                    (context, url, error) => Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFFF75003),
                        size: 60,
                      ),
                    ),
                placeholder:
                    (context, url) => Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                imageBuilder:
                    (context, imageProvider) => Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFF75003), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF75003),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: const Color(0xFFF75003).withOpacity(0.2),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF75003).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFF75003), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
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
      await ref.read(zenifyAuth.authProvider.notifier).logout();
      // SocketIOManager.instance.disconnect();
      // ref.invalidate(messagesProvider);
      //       ref.invalidate(conversationProvider);
      //       ref.invalidate(socketConnectionProvider);
      SocketIOManager.instance.clearAllProviderStates();
      SocketIOManager.instance.disconnect();

      // Clear auth data
      //await zenifyAuth.ZenifyAuth.logout();
      if (mounted) {
        context.go('/');
      }
    }
  }
}

// Chat Message Model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
