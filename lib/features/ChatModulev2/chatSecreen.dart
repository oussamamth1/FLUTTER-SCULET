// import 'dart:convert';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:gap/gap.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:vibration/vibration.dart';
// import 'package:zenify_app/ChatModulev2/ConversationList.dart';
// import 'package:zenify_app/ChatModulev2/Message.dart';
// import 'package:zenify_app/ChatModulev2/ScreenListenerProvider.dart';
// import 'package:zenify_app/ChatModulev2/SocketManagment.dart';
// import 'package:zenify_app/ChatModulev2/TravellerInfoDialog.dart';
// import 'package:zenify_app/ChatModulev2/UserInfoScreen.dart';
// import 'package:zenify_app/ChatModulev2/WebsocketEvents.dart';
// import 'package:zenify_app/features/Socet/Controllers/socket_controller.dart';
// import 'package:zenify_app/login/Login.dart';
// import 'package:zenify_app/services/constent.dart';
// import 'package:get/get.dart';
// import 'package:dio/dio.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:firebase_messaging/firebase_messaging.dart';

// class ChatScreenOnetoOne extends StatefulWidget {
//   final Conversation conversation;

//   const ChatScreenOnetoOne({
//     Key? key,
//     required this.conversation,
//   }) : super(key: key);

//   @override
//   _ChatScreenOnetoOneState createState() => _ChatScreenOnetoOneState();
// }

// class _ChatScreenOnetoOneState extends State<ChatScreenOnetoOne>
//     with WidgetsBindingObserver, TickerProviderStateMixin {

//   // Animation Controllers
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   Future<bool> _onWillPop() async {
//     await markConversationAsOpened(widget.conversation.id);
//     return true;
//   }

//   ScrollController _scrollController = ScrollController();
//   final FlutterSecureStorage storage = FlutterSecureStorage();
//   final TextEditingController _messageController = TextEditingController();
//   final FocusNode _focusNode = FocusNode(descendantsAreFocusable: false);
//   late Future<List<Message>> _futureMessages;
//   List<Message> _messages = [];
//   String userId = '';
//   String lastmessageidfromsocket = '';
//   bool isLoading = true;
//   bool connction = true;
//   int length = 15;
//   final SocketIOManager socketManager = SocketIOManager.instance;
//   int _limit = 20;
//   bool _isFetchingMore = false;
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   bool _isTyping = false;

//   @override
//   void initState() {
//     super.initState();

//     // Initialize animations
//     _fadeController = AnimationController(
//       duration: Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _slideController = AnimationController(
//       duration: Duration(milliseconds: 400),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: Offset(0, 0.1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

//     _scrollController = ScrollController(initialScrollOffset: 500);
//     Provider.of<ScreenListenerProvider>(context, listen: false)
//         .setConversation(widget.conversation.id);
//     _getCurrentUser();
//     _setOnScreen(true);
//     lastmessageidfromsocket = widget.conversation.clientLastReadMessageId ?? "";
//     markConversationAsRead(widget.conversation.id);
//     markConversationAsOpened(widget.conversation.id);
//     FirebaseMessaging.instance.unsubscribeFromTopic('Topic-Message');

//     _futureMessages = fetchMessages(widget.conversation.id, 20);

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _futureMessages.then((messages) {
//         if (mounted) {
//           setState(() {
//             _messages.clear();
//             _messages.addAll(messages);
//             _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
//             isLoading = false;
//             _scrollToBottom();
//           });
//           _fadeController.forward();
//           _slideController.forward();
//         }
//       }).catchError((error) {
//         print('Error loading messages: $error');
//       });
//     });

//     socketManager.addMessageListener(_onNewMessage);
//     socketManager.addConnectionChangeListener(_onConnectionChanged);
//     socketManager.addConversationListener(_onConversation);

//     Provider.of<ScreenListenerProvider>(context, listen: false)
//         .setOnScreen(true);

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollController.addListener(() {
//         if (_scrollController.hasClients) {
//           if (_scrollController.position.pixels <= 0.0 &&
//               (!_isFetchingMore && length > 14)) {
//             _loadMoreMessagesOptimized();
//           }
//         }
//       });
//     });

//     // Add typing listener
//     _messageController.addListener(() {
//       final isCurrentlyTyping = _messageController.text.isNotEmpty;
//       if (isCurrentlyTyping != _isTyping) {
//         setState(() {
//           _isTyping = isCurrentlyTyping;
//         });
//       }
//     });
//   }

//   Conversation? _extractConversation(dynamic data) {
//     if (data is Conversation) {
//       return data;
//     } else if (data is Map<String, dynamic>) {
//       return Conversation.fromJson(data);
//     }
//     return null;
//   }

//   void _onConversation(dynamic data) {
//     if (!mounted) return;

//     Conversation? conversation = _extractConversation(data);
//     if (conversation != null) {
//       setState(() {
//         lastmessageidfromsocket = conversation.clientLastReadMessageId ?? "";
//       });

//       if (conversation.latestMessage?.id != null) {
//         lastmessageidfromsocket = conversation?.clientLastReadMessageId ?? "";
//       }
//     } else if (data is Map<String, dynamic>) {
//       if (data['latestMessage'] != null) {
//         final latestMessage = data['latestMessage'] is Message
//             ? data['latestMessage']
//             : Message.fromJson(data['latestMessage']);
//         if (conversation?.latestMessage?.id != null) {
//           lastmessageidfromsocket = conversation?.clientLastReadMessageId ?? "";
//         }
//         final conversationId = latestMessage.conversationId;
//         if (conversationId != null && conversationId.isNotEmpty) {
//           final conversation = Conversation(
//             id: conversationId,
//             clientUserId: data['clientUserId'],
//             guideUserId: data['guideUserId'],
//             lastMessageAt: latestMessage.createdAt,
//             lastMessage: latestMessage.content,
//             latestMessage: latestMessage,
//             latestMessageId: latestMessage.id,
//             guideLastReadMessageId: "",
//           );
//         }
//       }
//     }
//   }

//   void _onConnectionChanged(bool isConnected) {
//     if (mounted) {
//       setState(() {
//         connction = isConnected;
//         if (isConnected) {
//           fetchMessages(widget.conversation.id, 20).then((messages) {
//             if (mounted) {
//               final existingIds = _messages.map((m) => m.id).toSet();
//               final newMessages =
//                   messages.where((m) => !existingIds.contains(m.id)).toList();
//               _messages.addAll(newMessages);
//               _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
//               isLoading = false;
//             }
//           }).catchError((error) {
//             print('Error loading messages: $error');
//           });
//         }
//       });
//     }
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _setOnScreen(true);
//     } else {
//       _setOnScreen(false);
//     }
//   }

//   void _setOnScreen(bool value) {
//     if (mounted) {
//       Provider.of<ScreenListenerProvider>(context, listen: false)
//           .setOnScreen(value);
//     }
//   }

//   void onProfilePictureClick() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return TravellerInfoDialog(
//           userId: widget.conversation.clientUserId ?? "",
//           conversation: widget.conversation,
//           userImage: widget.conversation.clientUser?.picture ?? "",
//         );
//       },
//     );
//   }

//   void _onNewMessage(dynamic data) async {
//     try {
//       Message? newMessage;

//       if (data is Message) {
//         newMessage = data;
//       } else if (data is Map<String, dynamic>) {
//         newMessage = Message.fromJson(data);
//       }

//       if (newMessage != null) {
//         if (newMessage.conversationId == widget.conversation.id) {
//           if (mounted) {
//             setState(() {
//               _futureMessages = _addMessageToList(newMessage!);
//               _messages.add(newMessage);
//               _scrollToBottom();
//             });
//             await markConversationAsOpened(widget.conversation.id);

//             if (newMessage.creatorUserId != widget.conversation.guideUserId) {
//               Vibration.vibrate(duration: 500);
//               _audioPlayer.play(AssetSource('sounds/message_tone.mp3'));
//             }
//           }
//         } else if (newMessage.conversationId != widget.conversation.id &&
//             newMessage.creatorUserId != widget.conversation.guideUserId) {
//           if (mounted) {
//             Vibration.vibrate(duration: 500);
//             _audioPlayer.play(AssetSource('sounds/message_tone.mp3'));

//             _showModernSnackbar(newMessage.content);
//           }
//         }
//       }
//     } catch (e) {
//       print("Error processing new message: $e");
//     }
//   }

//   void _showModernSnackbar(String message) {
//     Get.snackbar(
//       '',
//       '',
//       titleText: Container(
//         padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//         child: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 Icons.message,
//                 color: Colors.white,
//                 size: 20,
//               ),
//             ),
//             SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 message,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//       ),
//       snackPosition: SnackPosition.TOP,
//       backgroundColor: Colors.transparent,
//       margin: EdgeInsets.all(16),
//       borderRadius: 16,
//       backgroundGradient: LinearGradient(
//         colors: [
//           Color(0xFF667eea),
//           Color(0xFF764ba2),
//         ],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//       boxShadows: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.15),
//           blurRadius: 20,
//           offset: Offset(0, 8),
//         ),
//       ],
//       duration: Duration(seconds: 3),
//     );
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _slideController.dispose();
//     _focusNode.dispose();
//     _scrollController.dispose();
//     _audioPlayer.dispose();
//     markConversationAsRead(widget.conversation.id);
//     super.dispose();
//   }

//   Future<List<Message>> _addMessageToList(Message newMessage) async {
//     List<Message> messages = await _futureMessages;
//     bool isDuplicate = messages.any((msg) => msg.id == newMessage.id);

//     if (!isDuplicate) {
//       messages.add(newMessage);
//       messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
//     }
//     return messages;
//   }

//   void _getCurrentUser() async {
//     userId = await storage.read(key: 'id') ?? "";
//     setState(() {});
//   }
// void _loadMoreMessagesOptimized() async {
//   if (_isFetchingMore) return; // Prevent multiple simultaneous requests

//   setState(() => _isFetchingMore = true);

//   // Store current scroll position relative to content
//   final currentScrollPosition = _scrollController.hasClients
//       ? _scrollController.offset
//       : 0.0;

//   _limit += 10;
//   try {
//     final allMessages = await fetchMessages(widget.conversation.id, _limit);
//     length = allMessages.length;

//     setState(() {
//       // Simply replace all messages with the newly fetched ones
//       // since fetchMessages should return all messages up to the limit
//       _messages.clear();
//       _messages.addAll(allMessages);

//       // Ensure proper sorting
//       _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
//     });

//     // Restore scroll position
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         // Jump to a position that shows the newly loaded content
//         final newScrollPosition = _scrollController.position.maxScrollExtent * 0.15;
//         _scrollController.jumpTo(newScrollPosition);
//       }
//     });

//   } catch (e) {
//     print("Error fetching more messages: $e");
//   } finally {
//     setState(() => _isFetchingMore = false);
//   }
// }
//   Future<List<Message>> fetchMessages(String conversationId, int limit) async {
//     try {
//       String? token = await storage.read(key: "access_token");
//       final response = await http.get(
//         Uri.parse(
//             "$baseUrls/api/message/conversation/${widget.conversation.id}?limit=$limit"),
//         headers: {"Authorization": "Bearer $token"},
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);

//         if (!data.containsKey('results') || data['results'] == null) {
//           return [];
//         }

//         final List<dynamic> results = data['results'];
//         return results.map((item) => Message.fromJson(item)).toList();
//       } else {
//         print("Failed to load messages ${widget.conversation.id}");
//         return [];
//       }
//     } catch (e) {
//       print("Error fetching messages: $e");
//       return [];
//     }
//   }

//   Widget _buildModernMessageBubble(Message message, bool isSentByMe) {
//     return AnimatedContainer(
//       duration: Duration(milliseconds: 300),
//       curve: Curves.easeOutBack,
//       margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
//       child: Row(
//         mainAxisAlignment:
//             isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           if (!isSentByMe) ...[
//             _buildModernAvatar(
//               widget.conversation.clientUser?.picture,
//               widget.conversation.clientUser?.firstName,
//               widget.conversation.clientUser?.lastName,
//               onTap: onProfilePictureClick,
//             ),
//             SizedBox(width: 8),
//           ],
//           Flexible(
//             child: Container(
//               constraints: BoxConstraints(
//                 maxWidth: MediaQuery.of(context).size.width * 0.75,
//               ),
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 gradient: isSentByMe
//                     ? LinearGradient(
//                         colors: message.isDelevred == true
//                             ? [Color(0xFF757575), Color(0xFF616161)]
//                             : [Color(0xFF0084FF), Color(0xFF0066CC)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       )
//                     : null,
//                 color: isSentByMe ? null : Color(0xFFF5F5F5),
//                 borderRadius: BorderRadius.circular(20).copyWith(
//                   bottomRight:
//                       isSentByMe ? Radius.circular(6) : Radius.circular(20),
//                   bottomLeft:
//                       !isSentByMe ? Radius.circular(6) : Radius.circular(20),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     offset: Offset(0, 2),
//                     blurRadius: 8,
//                     color: Colors.black.withOpacity(0.08),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     message.content ?? '',
//                     style: TextStyle(
//                       color: isSentByMe ? Colors.white : Color(0xFF2C2C2C),
//                       fontSize: 15,
//                       fontWeight: FontWeight.w400,
//                       height: 1.4,
//                     ),
//                   ),
//                   SizedBox(height: 6),
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         formatDate(message.createdAt ?? DateTime.now()),
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: isSentByMe
//                               ? Colors.white.withOpacity(0.8)
//                               : Color(0xFF757575),
//                           fontWeight: FontWeight.w300,
//                         ),
//                       ),
//                       if (isSentByMe) ...[
//                         SizedBox(width: 4),
//                         Icon(
//                           message.id == lastmessageidfromsocket
//                               ? Icons.done_all
//                               : message.isDelevred == true ?Icons.access_time:Icons.done,
//                           size: 14,
//                           color: message.id == lastmessageidfromsocket
//                               ? Color(0xFF4CAF50)
//                               : Colors.white.withOpacity(0.8),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (isSentByMe) ...[
//             SizedBox(width: 8),
//             _buildModernAvatar(
//               widget.conversation.guideUser?.picture,
//               widget.conversation.guideUser?.firstName,
//               widget.conversation.guideUser?.lastName,
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildModernAvatar(String? pictureUrl, String? firstName, String? lastName, {VoidCallback? onTap}) {
//     Widget avatar = Container(
//       width: 32,
//       height: 32,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         gradient: LinearGradient(
//           colors: [Color(0xFF667eea), Color(0xFF764ba2)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: pictureUrl != null && pictureUrl.isNotEmpty
//           ? ClipRRect(
//               borderRadius: BorderRadius.circular(16),
//               child: CachedNetworkImage(
//                 imageUrl: '${baseUrls}/assets/uploads/traveller/${pictureUrl}',
//                 width: 32,
//                 height: 32,
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) => Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Color(0xFFF5F5F5),
//                   ),
//                   child: Center(
//                     child: Text(
//                       _getInitials(firstName, lastName),
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//                 errorWidget: (context, url, error) => Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Color(0xFFF5F5F5),
//                   ),
//                   child: Center(
//                     child: Text(
//                       _getInitials(firstName, lastName),
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             )
//           : Center(
//               child: Text(
//                 _getInitials(firstName, lastName),
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//     );

//     return onTap != null
//         ? GestureDetector(onTap: onTap, child: avatar)
//         : avatar;
//   }

//   String _getInitials(String? firstName, String? lastName) {
//     String initials = '';
//     if (firstName != null && firstName.isNotEmpty) {
//       initials += firstName[0];
//     }
//     if (lastName != null && lastName.isNotEmpty) {
//       initials += lastName[0];
//     }
//     return initials.toUpperCase();
//   }

//   void markConversationAsRead(String conversationId) async {
//     String? token = await storage.read(key: "access_token");

//     final response = await http.patch(
//       Uri.parse("$baseUrls/api/message/conversation/$conversationId"),
//       headers: {
//         "Authorization": "Bearer $token",
//         "Content-Type": "application/json",
//       },
//     );

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       print("Conversation marked as read");
//     } else {
//       print("Failed to mark conversation as read");
//     }
//   }

//   Future<void> markConversationAsOpened(String conversationId) async {
//     String? token = await storage.read(key: 'access_token');

//     try {
//       final response = await Dio().post(
//         '$baseUrls/api/conversation/$conversationId/opened',
//         options: Options(
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer $token',
//           },
//         ),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         print("Conversation marked as opened successfully.");
//       }
//     } catch (e) {
//       print("Error: $e");
//     }
//   }

//   void sendMessage(String content) async {
//     if (content.trim().isEmpty) return;

//     String? currentUserId = userId;

//     final messageData = {
//       'conversationId': widget.conversation.id,
//       'content': content,
//       'senderId': currentUserId,
//     };

//     try {
//       await socketManager.sendMessage('message', messageData);
//       _messageController.clear();

//       setState(() {
//         final tempMessage = Message(
//           id: DateTime.now().millisecondsSinceEpoch.toString(),
//           conversationId: widget.conversation.id,
//           content: content,
//           createdAt: DateTime.now().toLocal(),
//           updatedAt: DateTime.now(),
//           isDelevred: true,
//           guideUserId: widget.conversation.guideUserId ?? "",
//           creatorUserId: widget.conversation.guideUserId ?? "",
//         );

//         try {
//           if (!connction) {
//             _messages.add(tempMessage);
//           }
//         } catch (e) {
//           print("error to add message: $e");
//         }
//         isLoading = false;
//       });
//       _scrollToBottom();
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       print('Error sending message: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (connction) {
//       _messages.removeWhere((message) => message.isDelevred == true);
//     }

//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: Color(0xFFFAFAFA),
//         appBar: _buildModernAppBar(),
//         body: GestureDetector(
//   onTap: () {
//     // Close keyboard and unfocus when tapping outside
//     FocusScope.of(context).unfocus();
//   },
//   child:Column(
//             children: [
//               Expanded(
//                 child: isLoading
//                     ? _buildModernLoadingIndicator()
//                     : _messages.isEmpty
//                         ? _buildEmptyState()
//                         : SlideTransition(
//                             position: _slideAnimation,
//                             child: FadeTransition(
//                               opacity: _fadeAnimation,
//                               child: ListView.builder(
//                                 controller: _scrollController,
//                                 padding: EdgeInsets.symmetric(vertical: 16),
//                                 itemCount: _messages.length,
//                                 itemBuilder: (context, index) {
//                                   final message = _messages[index];
//                                   final isCurrentUser = message.creatorUserId == userId;
//                                   return _buildModernMessageBubble(message, isCurrentUser);
//                                 },
//                               ),
//                             ),
//                           ),
//               ),
//               _buildModernMessageInput(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   PreferredSizeWidget _buildModernAppBar() {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.white,
//     //  systemOverlayStyle: SystemUiOverlayStyle.dark,
//       leading: IconButton(
//         icon: Icon(Icons.arrow_back_ios, color: Color(0xFF2C2C2C), size: 20),
//         onPressed: () => Navigator.of(context).pop(),
//       ),
//       title: GestureDetector(
//         onTap: () {
//           Get.to(UserInfoScreen(userId: widget.conversation.clientUser?.id ?? ""));
//         },
//         child: Row(
//           children: [
//             _buildModernAvatar(
//               widget.conversation.clientUser?.picture,
//               widget.conversation.clientUser?.firstName,
//               widget.conversation.clientUser?.lastName,
//             ),
//             SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "${widget.conversation.clientUser?.firstName ?? ''} ${widget.conversation.clientUser?.lastName ?? ''}",
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF2C2C2C),
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   SizedBox(height: 2),
//                   Row(
//                     children: [
//                       // Container(
//                       //   width: 8,
//                       //   height: 8,
//                       //   decoration: BoxDecoration(
//                       //     shape: BoxShape.circle,
//                       //     color: connction ? Color(0xFF4CAF50) : Color(0xFFFF5722),
//                       //   ),
//                       // ),
//                       SizedBox(width: 6),
//                       // Text(
//                       //   connction ? 'Online' : 'Offline',
//                       //   style: TextStyle(
//                       //     fontSize: 12,
//                       //     color: Color(0xFF757575),
//                       //     fontWeight: FontWeight.w400,
//                       //   ),
//                       // ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       // actions: [
//       //   IconButton(
//       //     icon: Icon(Icons.videocam_outlined, color: Color(0xFF2C2C2C)),
//       //     onPressed: () {
//       //       // Video call functionality
//       //     },
//       //   ),
//       //   IconButton(
//       //     icon: Icon(Icons.phone_outlined, color: Color(0xFF2C2C2C)),
//       //     onPressed: () {
//       //       // Voice call functionality
//       //     },
//       //   ),
//       //   SizedBox(width: 8),
//       // ],
//     );
//   }

//   Widget _buildModernLoadingIndicator() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             child: CircularProgressIndicator(
//               strokeWidth: 3,
//               valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0084FF)),
//             ),
//           ),
//           SizedBox(height: 16),
//           Text(
//             'Loading messages...',
//             style: TextStyle(
//               color: Color(0xFF757575),
//               fontSize: 14,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Color(0xFF0084FF).withOpacity(0.1),
//             ),
//             child: Icon(
//               Icons.chat_bubble_outline,
//               size: 40,
//               color: Color(0xFF0084FF),
//             ),
//           ),
//           SizedBox(height: 24),
//           Text(
//             'No messages yet',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF2C2C2C),
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             'Start a conversation!',
//             style: TextStyle(
//               fontSize: 14,
//               color: Color(0xFF757575),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// Widget _buildModernMessageInput() {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             offset: Offset(0, -2),
//             blurRadius: 12,
//             color: Colors.black.withOpacity(0.05),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             Expanded(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Color(0xFFF5F5F5),
//                   borderRadius: BorderRadius.circular(24),
//                   border: Border.all(
//                     color: _isTyping ? Color.fromARGB(0, 0, 132, 255) : Colors.transparent,
//                     width: 1,
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     // IconButton(
//                     //   icon: Icon(
//                     //     Icons.add,
//                     //     color: Color(0xFF757575),
//                     //     size: 20,
//                     //   ),
//                     //   onPressed: () {
//                     //     // Add attachment functionality
//                     //     _showAttachmentOptions();
//                     //   },
//                     // ),

//                      Expanded(
//                       child:
//                 TextField(
//   controller: _messageController,
//   focusNode: _focusNode,
//   decoration: InputDecoration(
//     hintText: 'Type a message...',
//     hintStyle: TextStyle(
//       color: Color(0xFF757575),
//       fontSize: 14,
//       fontWeight: FontWeight.w400,
//     ),
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(20),
//       borderSide: BorderSide(
//         color: Color(0xFFE0E0E0),
//         width: 1,
//       ),
//     ),
//     enabledBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(20),
//       borderSide: BorderSide(
//         color: Color(0xFFE0E0E0),
//         width: 1,
//       ),
//     ),
//     focusedBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(20),
//       borderSide: BorderSide(
//         color: Theme.of(context).primaryColor.withOpacity(0.3),
//         width: 2,
//       ),
//     ),
//     disabledBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(20),
//       borderSide: BorderSide(
//         color: Color(0xFFBDBDBD),
//         width: 1,
//       ),
//     ),
//     contentPadding: EdgeInsets.symmetric(
//       horizontal: 16,
//       vertical: 12,
//     ),
//   ),
//   style: TextStyle(
//     fontSize: 14,
//     color: Color(0xFF2C2C2C),
//   ),
//   textCapitalization: TextCapitalization.sentences,
//   minLines: 1,
//   maxLines: 4,
//   onSubmitted: (text) {
//     if (text.trim().isNotEmpty) {
//       sendMessage(text);
//     }
//   },
// ),  ),
//                     IconButton(
//                       icon: Icon(
//                         Icons.emoji_emotions_outlined,
//                         color: Color(0xFF757575),
//                         size: 20,
//                       ),
//                       onPressed: () {
//                         // Add emoji picker functionality
//                         _showEmojiPicker();
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(width: 12),
//             GestureDetector(
//               onTap: () {
//                 if (_messageController.text.trim().isNotEmpty) {
//                   sendMessage(_messageController.text);
//                 }
//               },
//               child: AnimatedContainer(
//                 duration: Duration(milliseconds: 200),
//                 width: 44,
//                 height: 44,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: _isTyping
//                       ? LinearGradient(
//                           colors: [Color(0xFF0084FF), Color(0xFF0066CC)],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         )
//                       : LinearGradient(
//                           colors: [Color.fromARGB(38, 224, 224, 224), Color(0xFFBDBDBD)],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                   // boxShadow: _isTyping
//                   //     ? [
//                   //         BoxShadow(
//                   //           color: Color(0xFF0084FF).withOpacity(0.3),
//                   //           blurRadius: 8,
//                   //           offset: Offset(0, 2),
//                   //         ),
//                   //       ]
//                   //     : [],
//                 ),
             
//                 child:  Visibility(visible: _isTyping,
//                   child: Icon(
//                      Icons.send ,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showAttachmentOptions() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               margin: EdgeInsets.only(top: 12),
//               decoration: BoxDecoration(
//                 color: Color(0xFFE0E0E0),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.all(20),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       _buildAttachmentOption(
//                         icon: Icons.photo_library,
//                         label: 'Gallery',
//                         color: Color(0xFF4CAF50),
//                         onTap: () {
//                           Navigator.pop(context);
//                           // Add gallery functionality
//                         },
//                       ),
//                       _buildAttachmentOption(
//                         icon: Icons.camera_alt,
//                         label: 'Camera',
//                         color: Color(0xFF2196F3),
//                         onTap: () {
//                           Navigator.pop(context);
//                           // Add camera functionality
//                         },
//                       ),
//                       _buildAttachmentOption(
//                         icon: Icons.insert_drive_file,
//                         label: 'Document',
//                         color: Color(0xFFFF9800),
//                         onTap: () {
//                           Navigator.pop(context);
//                           // Add document functionality
//                         },
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       _buildAttachmentOption(
//                         icon: Icons.location_on,
//                         label: 'Location',
//                         color: Color(0xFFF44336),
//                         onTap: () {
//                           Navigator.pop(context);
//                           // Add location functionality
//                         },
//                       ),
//                       _buildAttachmentOption(
//                         icon: Icons.contact_phone,
//                         label: 'Contact',
//                         color: Color(0xFF9C27B0),
//                         onTap: () {
//                           Navigator.pop(context);
//                           // Add contact functionality
//                         },
//                       ),
//                       _buildAttachmentOption(
//                         icon: Icons.audiotrack,
//                         label: 'Audio',
//                         color: Color(0xFF607D8B),
//                         onTap: () {
//                           Navigator.pop(context);
//                           // Add audio functionality
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAttachmentOption({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             width: 56,
//             height: 56,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               icon,
//               color: color,
//               size: 24,
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               color: Color(0xFF757575),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showEmojiPicker() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => Container(
//         height: MediaQuery.of(context).size.height * 0.4,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               margin: EdgeInsets.only(top: 12),
//               decoration: BoxDecoration(
//                 color: Color(0xFFE0E0E0),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
    
// Expanded(
//   child: Padding(
//     padding: EdgeInsets.all(16),
//     child: SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Smileys & Emotion
//           Text(
//             'Smileys & Emotion',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[700],
//             ),
//           ),
//           SizedBox(height: 8),
//           GridView.count(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             crossAxisCount: 8,
//             children: [
//               '😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣',
//               '😊', '😇', '🙂', '🙃', '😉', '😌', '😍', '🥰',
//               '😘', '😗', '😙', '😚', '😋', '😛', '😝', '😜',
//               '🤪', '🤨', '🧐', '🤓', '😎', '🤩', '🥳', '😏',
//               '😒', '😞', '😔', '😟', '😕', '🙁', '☹️', '😣',
//               '😖', '😫', '😩', '🥺', '😢', '😭', '😤', '😠',
//               '😡', '🤬', '🤯', '😳', '🥵', '🥶', '😱', '😨',
//               '😰', '😥', '😓', '🤗', '🤔', '🤭', '🤫', '🤥',
//             ].map((emoji) => _buildEmojiItem(emoji)).toList(),
//           ),
          
//           SizedBox(height: 24),
          
//           // People & Body
//           Text(
//             'People & Body',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[700],
//             ),
//           ),
//           SizedBox(height: 8),
//           GridView.count(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             crossAxisCount: 8,
//             children: [
//               '👶', '🧒', '👦', '👧', '🧑', '👱', '👨', '🧔',
//               '👩', '🧓', '👴', '👵', '🙍', '🙎', '🙅', '🙆',
//               '💁', '🙋', '🧏', '🙇', '🤦', '🤷', '👮', '🕵️',
//               '💂', '🥷', '👷', '🤴', '👸', '👳', '👲', '🧕',
//               '🤵', '👰', '🤰', '🤱', '👼', '🎅', '🤶', '🦸',
//               '🦹', '🧙', '🧚', '🧛', '🧜', '🧝', '🧞', '🧟',
//               '💆', '💇', '🚶', '🧍', '🧎', '🏃', '💃', '🕺',
//               '🕴️', '👯', '🧖', '🧗', '🤺', '🏇', '⛷️', '🏂',
//             ].map((emoji) => _buildEmojiItem(emoji)).toList(),
//           ),
          
//           SizedBox(height: 24),
          
//           // Animals & Nature
//           Text(
//             'Animals & Nature',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[700],
//             ),
//           ),
//           SizedBox(height: 8),
//           GridView.count(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             crossAxisCount: 8,
//             children: [
//               '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼',
//               '🐨', '🐯', '🦁', '🐮', '🐷', '🐽', '🐸', '🐵',
//               '🙈', '🙉', '🙊', '🐒', '🐔', '🐧', '🐦', '🐤',
//               '🐣', '🐥', '🦆', '🦅', '🦉', '🦇', '🐺', '🐗',
//               '🐴', '🦄', '🐝', '🐛', '🦋', '🐌', '🐞', '🐜',
//               '🦟', '🦗', '🕷️', '🕸️', '🦂', '🐢', '🐍', '🦎',
//               '🦖', '🦕', '🐙', '🦑', '🦐', '🦞', '🦀', '🐡',
//               '🐠', '🐟', '🐬', '🐳', '🐋', '🦈', '🐊', '🐅',
//             ].map((emoji) => _buildEmojiItem(emoji)).toList(),
//           ),
          
//           SizedBox(height: 24),
          
//           // Food & Drink
//           Text(
//             'Food & Drink',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[700],
//             ),
//           ),
//           SizedBox(height: 8),
//           GridView.count(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             crossAxisCount: 8,
//             children: [
//               '🍎', '🍐', '🍊', '🍋', '🍌', '🍉', '🍇', '🍓',
//               '🫐', '🍈', '🍒', '🍑', '🥭', '🍍', '🥥', '🥝',
//               '🍅', '🍆', '🥑', '🥦', '🥬', '🥒', '🌶️', '🫒',
//               '🌽', '🥕', '🫒', '🧄', '🧅', '🥔', '🍠', '🥐',
//               '🥖', '🍞', '🥨', '🥯', '🧀', '🥚', '🍳', '🧈',
//               '🥞', '🧇', '🥓', '🥩', '🍗', '🍖', '🌭', '🍔',
//               '🍟', '🍕', '🥪', '🥙', '🧆', '🌮', '🌯', '🫔',
//               '🥗', '🥘', '🫕', '🍝', '🍜', '🍲', '🍛', '🍣',
//             ].map((emoji) => _buildEmojiItem(emoji)).toList(),
//           ),
          
//           SizedBox(height: 24),
          
//           // Activities & Objects
//           Text(
//             'Activities & Objects',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[700],
//             ),
//           ),
//           SizedBox(height: 8),
//           GridView.count(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             crossAxisCount: 8,
//             children: [
//               '⚽', '🏀', '🏈', '⚾', '🥎', '🎾', '🏐', '🏉',
//               '🥏', '🎱', '🪀', '🏓', '🏸', '🏒', '🏑', '🥍',
//               '🏏', '🪃', '🥅', '⛳', '🪁', '🏹', '🎣', '🤿',
//               '🥊', '🥋', '🎽', '🛹', '🛼', '🛷', '⛸️', '🥌',
//               '🎯', '🪀', '🪃', '🎮', '🕹️', '🎰', '🎲', '🧩',
//               '🃏', '🀄', '🎴', '🎭', '🖼️', '🎨', '🧵', '🪡',
//               '🧶', '🪢', '📱', '📞', '☎️', '📟', '📠', '📺',
//               '📻', '🎙️', '🎚️', '🎛️', '🧭', '⏱️', '⏰', '⏲️',
//             ].map((emoji) => _buildEmojiItem(emoji)).toList(),
//           ),
          
//           SizedBox(height: 24),
          
//           // Travel & Places
//           Text(
//             'Travel & Places',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[700],
//             ),
//           ),
//           SizedBox(height: 8),
//           GridView.count(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             crossAxisCount: 8,
//             children: [
//               '🚗', '🚕', '🚙', '🚌', '🚎', '🏎️', '🚓', '🚑',
//               '🚒', '🚐', '🛻', '🚚', '🚛', '🚜', '🏍️', '🛵',
//               '🚲', '🛴', '🛹', '🛼', '🚁', '✈️', '🛩️', '🛫',
//               '🛬', '🪂', '💺', '🚀', '🛸', '🚉', '🚇', '🚂',
//               '🚃', '🚄', '🚅', '🚆', '🚈', '🚊', '🚝', '🚞',
//               '🚋', '🚌', '🚍', '🎡', '🎢', '🎠', '🏗️', '🌁',
//               '🗼', '🏭', '⛲', '🎡', '🎢', '🏰', '🏯', '🏟️',
//               '🎪', '🎨', '🎭', '📍', '🗿', '⛪', '🕌', '🛕',
//             ].map((emoji) => _buildEmojiItem(emoji)).toList(),
//           ),
//         ],
//       ),
//     ),
//   ),
// ),
//    ],
//         ),
//       ),
//     );
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   String formatDate(DateTime date) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(Duration(days: 1));
//     final messageDate = DateTime(date.year, date.month, date.day);

//     if (messageDate == today) {
//       return DateFormat('HH:mm').format(date);
//     } else if (messageDate == yesterday) {
//       return 'Yesterday ${DateFormat('HH:mm').format(date)}';
//     } else {
//       return DateFormat('dd/MM/yyyy HH:mm').format(date);
//     }
//   }
// Widget _buildEmojiItem(String emoji) {
//   return GestureDetector(
//     onTap: () {
//       _messageController.text += emoji;
//       Navigator.pop(context);
//     },
//     child: Container(
//       margin: EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         color: Colors.grey[100],
//       ),
//       child: Center(
//         child: Text(
//           emoji,
//           style: TextStyle(fontSize: 20),
//         ),
//       ),
//     ),
//   );
// }
//   // Add missing import for SystemUiOverlayStyle
//   // Add this import at the top of your file:
//   // import 'package:flutter/services.dart';
// }