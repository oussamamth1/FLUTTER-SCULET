// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:http/http.dart' as http;
// import 'package:zenify_app/ChatModulev2/Message.dart';
// import 'package:zenify_app/ChatModulev2/ScreenListenerProvider.dart';
// import 'package:zenify_app/ChatModulev2/TravellersListPage.dart';
// import 'package:zenify_app/ChatModulev2/WebsocketEvents.dart';

// import 'package:zenify_app/ChatModulev2/chatSecreen.dart';
// import 'package:zenify_app/RouteObserver.dart';

// import 'dart:convert';
// import 'package:zenify_app/login/Login.dart';
// import 'package:zenify_app/ChatModulev2/SocketManagment.dart';
// import 'package:zenify_app/modele/traveller/TravellerModel.dart';
// import 'package:zenify_app/services/constent.dart';

// class ConversationListState extends StatefulWidget {
//   String? conversationId; // Add this parameter

//   // Update constructor to accept the new parameter
//   ConversationListState({Key? key, this.conversationId}) : super(key: key);
//   @override
//   _ConversationListStateState createState() => _ConversationListStateState();
// }

// class _ConversationListStateState extends State<ConversationListState>
//     with RouteAware {
//   List<Conversation> conversations = [];
//   final TextEditingController _codeController = TextEditingController();
//   // late IO.Socket socket;

//   // late Future<List<Conversation>> _futureMessages;

//   final SocketIOManager socketManager = SocketIOManager.instance;
//   String userId = '';
//   bool loading = false;
//   bool _hasNavigated = false;
//   bool connction = true;
//   @override
//   void initState() {
//     super.initState();
//     connction = socketManager.isConnected;

//     // Add listener for connection changes
//     // socketManager.updateConversationListAndContentListener(_onConversation);

// // Add socket listeners
//     //socketManager.addMessageListener(_onNewMessage);
//     socketManager.addConversationListener(_onConversation);

//     socketManager.addConnectionChangeListener(_onConnectionChanged);

//     // socketManager.addConnectionListener(_onConversation);
//     Provider.of<ScreenListenerProvider>(context, listen: false)
//         .setOnScreen(false);
//     fetchConversations().then((fetchedConversations) {
//       conversations = fetchedConversations;
//       if (mounted) {
//         setState(() {
//           // _futureMessages = Future.value(conversations);
//           if (widget.conversationId != null &&
//               widget.conversationId!.isNotEmpty &&
//               !_hasNavigated) {
//             // Find the conversation with the matching ID
//             final conversation = conversations.firstWhere(
//               (c) => c.id == widget.conversationId,
//               orElse: () => Conversation(id: "", lastMessageAt: DateTime.now()),
//             );

//             // If the conversation exists, navigate to the chat screen
//             if (conversation.id.isNotEmpty) {
//               // Use a small delay to ensure the widget is fully built
//               Future.delayed(Duration(microseconds: 300), () {
//                 Get.to(ChatScreenOnetoOne(
//                   conversation: conversation,
//                 ));
//               });
//             }
//           }
//         });
//       }
//     });

//     _refreshToken();
//     _getCurrentUser();
//     FirebaseMessaging.instance.subscribeToTopic('Topic-Message');
//     // WidgetsBinding.instance.addPostFrameCallback((_) {
//     //   socketManager.socket.on(WebsocketEvents.chatConversationMessageCreated,
//     //       (data) {
//     //     if (mounted) {
//     //       var message = Message.fromJson(data);
//     //       _updateConversation(message.conversationId ?? "", message);
//     //     }
//     //   });
//     //   socketManager.socket.on(WebsocketEvents.chatConversationUpdate, (data) {
//     //     print("updateConversations $data");
//     //     var conversation = Conversation.fromJson(data);
//     //     _updateConversationList(conversation);
//     //     // _notifyConversationListeners(conversation);
//     //     setState(() {});
//     //   });
//     // });

//     // socketManager.socket.on(WebsocketEvents.chatConversationUpdate, (data) {
//     //   if (mounted) {
//     //     print("updateConversationsss $data");
//     //     var conversation = Conversation.fromJson(data);
//     //     _updateConversationList(conversation);
//     //   }
//     // });

//     socketManager.socket.on('chat.conversation.read', (data) {
//       // print("🔔 Conversation marked as read: $data");
//       if (mounted) {
//         print("updateConversationsss $data");
//         print("?? 🔔 Conversation marked as read: $data");
//         var conversation = Conversation.fromJson(data);
//         updateConversationList(conversation);
//         setState(() {});
//       }
//     });
//   }

//   @override
//   void didPopNext() {
//     widget.conversationId = null;
//     Provider.of<ScreenListenerProvider>(context, listen: false)
//         .setOnScreen(false);

//     // Called when coming back to this screen (e.g., navigating back)
//     print("ConversationListScreen is now visible again");
//     ;
// // socketManager.updateConversationListAndContentListener(_onConversation);

//     fetchConversations().then(
//       (value) {
//         FirebaseMessaging.instance.subscribeToTopic('Topic-Message');
//       },
//     ); // Refresh conversations when returning to the screen
//   }

//   Future<String?> _refreshToken() async {
//     print("_refreshToken");
//     final refreshTokenUrl = Uri.parse('${baseUrls}/api/auth/refresh-token');
//     String? token = await storage.read(key: "access_token");
//     try {
//       final headers = {'Content-Type': 'application/json'};
//       final payload = jsonEncode({'refreshToken': token});

//       final response =
//           await http.post(refreshTokenUrl, headers: headers, body: payload);

//       if (response.statusCode == 201) {
//         final responseBody = jsonDecode(response.body);
//         print(responseBody);
//         String refreshedToken = responseBody['accessToken'] as String;
//         await storage.write(key: "access_token", value: refreshedToken);
//         return responseBody['accessToken'] as String;
//       } else {
//         print('Error refreshing token: ${response.statusCode}');
//         return null;
//       }
//     } catch (error) {
//       print('Error refreshing token: $error');
//       return null;
//     }
//   }

//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     ObserverUtils.routeObserver.subscribe(this, ModalRoute.of(context)!);
//     // socketManager.socket.on(WebsocketEvents.chatConversationMessageCreated,
//     //     (data) {
//     //   if (mounted) {
//     //     var message = Message.fromJson(data);
//     //     _updateConversation(message.conversationId ?? "", message);
//     //   }
//     // });
//     // // routeObserver.subscribe(
//     //this, ModalRoute.of(context)!); // Subscribe to RouteObserver
//   }

//   void _onConnectionChanged(bool isConnected) {
//     if (mounted) {
//       setState(() {
//         connction = isConnected;
//         if (isConnected) {
//           // Reconnected - reload conversations
//           // socketManager.updateConversationListAndContentListener(_onConversation);
//         }
//       });
//     }
//   }
// // Add socket listeners

// // Process new message events
//   void _onNewMessage(dynamic data) async {
//     try {
//       Message? message = _extractMessage(data);
//       if (message != null) {
//         _updateConversationWithMessage(message);
//       }
//     } catch (e) {
//       print("Error processing new message: $e");
//     }
//   }

// // Process conversation events
//   void _onConversation(dynamic data) {
//     if (!mounted) return;

//     print("Socket chatConversationUpdate received: $data");

//     // First, try to extract and update a conversation object
//     Conversation? conversation = _extractConversation(data);
//     if (conversation != null) {
//       _updateConversationList(conversation);
//     } else if (data is Map<String, dynamic>) {
//       // Handle the specific socket format shown in your debug log
//       // Create a conversation object from the socket message
//       if (data['latestMessage'] != null) {
//         final latestMessage = data['latestMessage'] is Message
//             ? data['latestMessage']
//             : Message.fromJson(data['latestMessage']);

//         // Create or update conversation
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

//           _updateConversationList(conversation);
//         }
//       }
//     }
//   }

//   void _updateConversationList(Conversation updatedConversation) {
//     if (!mounted) return;

//     setState(() {
//       // Find the index of the existing conversation
//       int existingIndex = conversations.indexWhere(
//           (c) => c.id == updatedConversation.latestMessage?.conversationId);

//       if (existingIndex >= 0) {
//         // Update existing conversation instead of removing and re-adding
//         Conversation existingConversation = conversations[existingIndex];

//         // Preserve necessary fields from the existing conversation
//         String? lastMessage = existingConversation.lastMessage;
//         DateTime? lastMessageAt = existingConversation.lastMessageAt;

//         // Update fields from the socket update
//         existingConversation.clientLastReadMessageId =
//             updatedConversation.clientLastReadMessageId;
//         existingConversation.latestMessageId =
//             updatedConversation.latestMessageId;
//         existingConversation.guideLastReadMessageId = "";

//         // Update latest message creator if available
//         if (updatedConversation.latestMessage != null &&
//             existingConversation.latestMessage != null) {
//           existingConversation.latestMessage!.creatorUserId =
//               updatedConversation.latestMessage!.creatorUserId;

//           // Update message content
//           if (updatedConversation.latestMessage!.content != null) {
//             existingConversation.lastMessage =
//                 updatedConversation.latestMessage!.content;
//           }

//           // If the updated conversation has a newer message, update the timestamp
//           if (updatedConversation.latestMessage!.createdAt != null) {
//             existingConversation.latestMessage!.createdAt =
//                 updatedConversation.latestMessage!.createdAt;
//             existingConversation.lastMessageAt =
//                 updatedConversation.latestMessage!.createdAt ?? DateTime.now();
//           }
//         }

//         print("🔔 Conversation updated: ${existingConversation.id}");
//       } else {
//         // This is a new conversation, add it to the list
//         // Make sure the conversation ID is set
//         // if (updatedConversation.id.isEmpty && updatedConversation.latestMessage != null) {
//         //   updatedConversation.id = updatedConversation.id;
//         // }
//         int existingIndex = conversations.indexWhere(
//             (c) => c.id == updatedConversation.id);

//         if (updatedConversation.id.isEmpty &&
//             updatedConversation.latestMessage != null) {}
//         if (existingIndex >= 0) {
//           // Update existing conversation instead of removing and re-adding
//           Conversation existingConversation = conversations[existingIndex];
//           // Ensure guideLastReadMessageId is initialized
//           // updatedConversation.guideLastReadMessageId = "";
//           existingConversation.clientLastReadMessageId =
//               updatedConversation.clientLastReadMessageId;

//           conversations.add(updatedConversation);
//           print("🔔 New conversation added: ${updatedConversation.id}");
//         }
//       }

//       // Sort conversations by most recent message
//       _sortConversations();
//     });
//   }
// // Process conversation events
//   // void _onConversation(dynamic data) {
//   //   if (!mounted) return;

//   //   try {
//   //     // First, try to extract and update a conversation object
//   //     Conversation? conversation = _extractConversation(data);
//   //     if (conversation != null) {
//   //       _updateConversationListsockt(conversation);
//   //     }

//   //     // Also check if there's a message in the data
//   //     Message? message = _extractMessage(data);
//   //     if (message != null) {
//   //       _updateConversationWithMessage(message);
//   //     }

//   //     if (mounted) {
//   //       setState(() {});
//   //     }
//   //   } catch (e) {
//   //     print("Error processing conversation update: $e");
//   //   }
//   // }

// // Helper method to extract Message from different data types
//   Message? _extractMessage(dynamic data) {
//     if (data is Message) {
//       return data;
//     } else if (data is Map<String, dynamic>) {
//       return Message.fromJson(data);
//     }
//     return null;
//   }

// // Helper method to extract Conversation from different data types
//   Conversation? _extractConversation(dynamic data) {
//     if (data is Conversation) {
//       return data;
//     } else if (data is Map<String, dynamic>) {
//       return Conversation.fromJson(data);
//     }
//     return null;
//   }

// // Helper method to update a conversation with a new message
//   void _updateConversationWithMessage(Message message) {
//     // Find or create the conversation for this message
//     var conversationIndex =
//         conversations.indexWhere((c) => c.id == message.conversationId);

//     Conversation conversation;
//     if (conversationIndex >= 0) {
//       conversation = conversations[conversationIndex];
//     } else {
//       // Create a new conversation if we don't have it yet
//       conversation = Conversation(
//         id: message.conversationId,
//         name: "",
//         lastMessageAt: message.createdAt,
//       );
//       conversations.add(conversation);
//     }

//     // Update the conversation with the message info
//     setState(() {
//       conversation.lastMessage = message.content;
//       if (conversation.latestMessage != null) {
//         conversation.latestMessage!.createdAt = message.createdAt!;
//       } else {
//         // If latestMessage is null, we might need to create it
//         // (depends on your Conversation class implementation)
//       }
//       conversation.guideLastReadMessageId = "";

//       // Ensure the conversation list is properly sorted if needed
//       // (e.g., by lastMessageAt)
//       _sortConversations();
//     });
//   }

// // Sort conversations by last message time (most recent first)
//   void _sortConversations() {
//     conversations.sort((a, b) =>
//         b.lastMessageAt?.compareTo(a.lastMessageAt ?? DateTime(0)) ?? 0);
//   }
//   // void _onNewMessage(dynamic data) async {
//   //   // if (conversation != null) {
//   //   //   _updateConversationList(conversation);
//   //   //   setState(() {});
//   //   // }
//   //   try {
//   //     Message? message;

//   //     // Case 1: data is already a Message object
//   //     if (data is Message) {
//   //       message = data;
//   //     }
//   //     // Case 2: data is a Map that needs to be converted to Message
//   //     else if (data is Map<String, dynamic>) {
//   //       message = Message.fromJson(data);
//   //     }
//   //     // Process the message if we have it and it belongs to this conversation
//   //     if (message != null) {
//   //       // Find the associated conversation
//   //       var conversation = conversations.firstWhere(
//   //         (c) => c.id == message!.conversationId,
//   //         orElse: () => Conversation(
//   //           id: message!.conversationId,
//   //           name: "",
//   //           lastMessageAt: message.createdAt,
//   //         ),
//   //       );

//   //       setState(() {
//   //         conversation.lastMessage = message?.content;
//   //         conversation.latestMessage?.createdAt = message?.createdAt!;
//   //         conversation.guideLastReadMessageId = "";
//   //       });
//   //     }
//   //   } catch (e) {
//   //     print("Error processing new message: $e");
//   //   }
//   // }

//   // void _onConversation(dynamic data) {
//   //   if (mounted) {
//   //     Conversation? conversation;
//   //     if (data is Conversation) {
//   //       conversation = data;
//   //     }
//   //     // Case 2: data is a Map that needs to be converted to Message
//   //     else if (data is Map<String, dynamic>) {
//   //       conversation = Conversation.fromJson(data);
//   //     }
//   //     if (conversation != null) {
//   //       _updateConversationList(conversation);
//   //       if (mounted) {
//   //         setState(() {});
//   //       }
//   //     }

//   //     Message? message;

//   //     // Case 1: data is already a Message object
//   //     if (data is Message) {
//   //       message = data;
//   //     }
//   //     // Case 2: data is a Map that needs to be converted to Message
//   //     else if (data is Map<String, dynamic>) {
//   //       message = Message.fromJson(data);
//   //     }
//   //     // Process the message if we have it and it belongs to this conversation
//   //     if (message != null) {
//   //       // Find the associated conversation
//   //       var conversation = conversations.firstWhere(
//   //         (c) => c.id == message!.conversationId,
//   //         orElse: () => Conversation(
//   //           id: message!.conversationId,
//   //           name: "",
//   //           lastMessageAt: message.createdAt,
//   //         ),
//   //       );

//   //       setState(() {
//   //         conversation.lastMessage = message?.content;
//   //         conversation.latestMessage?.createdAt = message?.createdAt!;
//   //         conversation.guideLastReadMessageId = "";
//   //       });
//   //     }
//   //   }
//   // }

//   @override
//   void dispose() {
//     //routeObserver.unsubscribe(this); // Unsubscribe when disposed
//     super.dispose();
//   }

//   void _getCurrentUser() async {
//     // Replace with your actual implementation
//     userId = await storage.read(key: 'id') ?? "";
//     if (mounted) {
//       setState(() {});
//     }
//   }

//   Future<List<Conversation>> fetchConversations() async {
//     if (mounted) {
//       setState(() {
//         loading = true;
//       });
//     }

//     try {
//       String? token = await storage.read(key: "access_token");

//       // Replace with your actual API URL and the correct query parameter
//       String url = "$baseUrls/api/conversation/me";
//       //?filters[guideUserId]=$userId&&limit=20
//       final response = await http
//           .get(Uri.parse(url), headers: {"Authorization": "Bearer $token"});

//       if (response.statusCode == 200) {
//         // Parse the response body
//         final Map<String, dynamic> data = json.decode(response.body);
//         final List<dynamic> results = data['results'];
//         print(results);

//         // Map the API response to Conversation objects
//         List<Conversation> fetchedConversations =
//             results.map((item) => Conversation.fromJson(item)).toList();

//         // Sort the conversations by 'lastMessageAt' in descending order
//         fetchedConversations
//             .sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));

//         if (mounted) {
//           setState(() {
//             conversations = fetchedConversations;
//             loading = false;

//             // Check if a specific conversationId was provided
//             if (widget.conversationId != null &&
//                 widget.conversationId!.isNotEmpty) {
//               // Find the conversation with the matching ID
//               final conversation = conversations.firstWhere(
//                 (c) => c.id == widget.conversationId,
//                 orElse: () =>
//                     Conversation(id: "", lastMessageAt: DateTime.now()),
//               );

//               // If the conversation exists, navigate to the chat screen
//               if (conversation.id.isNotEmpty) {
//                 // Use a small delay to ensure the widget is fully built
//                 Future.delayed(Duration(milliseconds: 300), () {
//                   Get.to(ChatScreenOnetoOne(
//                     conversation: conversation,
//                   ));
//                 });
//               }
//             }
//           });

//           return fetchedConversations;
//         }
//         return fetchedConversations;
//       } else {
//         // Handle error if the response is not successful
//         print('Failed to load conversations ${response.statusCode}');
//         setState(() {
//           loading = false;
//         });
//         return [];
//       }
//     } catch (e) {
//       print('Error fetching conversations: $e');
//       setState(() {
//         loading = false;
//       });
//       return [];
//     }
//   }
//   //   Future<void> fetchConversations() async {
//   //     setState(() {
//   //       loading = true;
//   //     });

//   //     try {
//   //       String? token = await storage.read(key: "access_token");

//   //       // Replace with your actual API URL and the correct query parameter
//   //       String url = "$baseUrls/api/conversation/me";
//   // //?filters[guideUserId]=$userId&&limit=20
//   //       final response = await http
//   //           .get(Uri.parse(url), headers: {"Authorization": "Bearer $token"});

//   //       if (response.statusCode == 200) {
//   //         // Parse the response body
//   //         final Map<String, dynamic> data = json.decode(response.body);
//   //         final List<dynamic> results = data['results'];
//   //         print(results);
//   //         setState(() {
//   //           // Map the API response to Conversation objects
//   //           conversations =
//   //               results.map((item) => Conversation.fromJson(item)).toList();
//   //           // Sort the conversations by 'lastMessageAt' in descending order
//   //           conversations
//   //               .sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
//   //           loading = false;
//   //         });
//   //       } else {
//   //         // Handle error if the response is not successful
//   //         print('Failed to load conversations ${response.statusCode}');
//   //         setState(() {
//   //           loading = false;
//   //         });
//   //       }
//   //     } catch (e) {
//   //       print('Error fetching conversations: $e');
//   //       setState(() {
//   //         loading = false;
//   //       });
//   //     }
//   //   }

//   // void connectToSocket() async {
//   //   String? sessionIds = await storage.read(key: "ss");
//   //   socket = IO.io(
//   //     '$baseUrls',
//   //     IO.OptionBuilder()
//   //         .setTransports(['websocket'])
//   //         .disableMultiplex()
//   //         .setExtraHeaders({'Cookie': "$sessionIds"})
//   //         .build(),
//   //   );

//   //   socket.on('onMessage', (data) {
//   //     if (mounted) {
//   //       var message = Message.fromJson(data);
//   //       _updateConversation(message.conversationId ?? "", message);
//   //     }
//   //   });

//   //   socket.on('updateConversations', (data) {
//   //     if (mounted) {
//   //       print("updateConversationsss $data");
//   //       var conversation = Conversation.fromJson(data);

//   //       _updateConversationList(conversation);
//   //     }
//   //   });
//   // }

//   void _updateConversation(String conversationId, Message message) {
//     var conversation = conversations.firstWhere(
//       (c) => c.id == conversationId,
//       orElse: () => Conversation(
//         id: conversationId,
//         name: "",
//         lastMessageAt: message.createdAt,
//       ),
//     );

//     if (mounted) {
//       setState(() {
//         conversation.lastMessage = message.content;
//         conversation.latestMessage?.createdAt = message.createdAt!;
//         conversation.guideLastReadMessageId = "";
//       });
//     }
//   }

//   // void _updateConversationList(Conversation updatedConversation) {
//   //   if (mounted) {
//   //     setState(() {
//   //       // Remove any existing instance of the conversation before adding it
//   //       conversations.removeWhere((c) => c.id == updatedConversation.id);

//   //       // Add the updated conversation
//   //       conversations.add(updatedConversation);
//   //       Conversation conversationToUpdate = conversations.firstWhere(
//   //         (c) => c.id == updatedConversation.id,
//   //         orElse: () => Conversation(id: "", lastMessageAt: DateTime.now()),
//   //       );

//   //       // // Sort the conversations by 'lastMessageAt' in descending order
//   //       // conversations.sort((b, a) =>
//   //       //     a.latestMessage!.createdAt!.compareTo(b.latestMessage!.createdAt!));
//   //       // conversations.removeWhere((c) => c.id == updatedConversation.id);
//   //       conversationToUpdate.guideLastReadMessageId = "";
//   //       print(
//   //           "🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔 Conversation marked as read: $conversationToUpdate");
//   //       conversationToUpdate.latestMessage?.creatorUserId =
//   //           updatedConversation.latestMessage?.creatorUserId;
//   //       // Update the fields of the existing conversation
//   //       conversationToUpdate.clientLastReadMessageId =
//   //           updatedConversation.clientLastReadMessageId;
//   //       // conversationToUpdate.guideLastReadMessageId =
//   //       //     updatedConversation.guideLastReadMessageId;
//   //       conversationToUpdate.latestMessageId =
//   //           updatedConversation.latestMessageId;
//   //     });
//   //   }
//   // }

//   //Update a conversation with data from a socket event
//   // void _updateConversationListsockt(Conversation updatedConversation) {
//   //   if (!mounted) return;

//   //   setState(() {
//   //     // Find the index of the existing conversation
//   //     int existingIndex =
//   //         conversations.indexWhere((c) => c.id == updatedConversation.id);

//   //     if (existingIndex >= 0) {
//   //       // Update existing conversation instead of removing and re-adding
//   //       Conversation existingConversation = conversations[existingIndex];

//   //       // Preserve necessary fields from the existing conversation
//   //       String? lastMessage = existingConversation.lastMessage;
//   //       DateTime? lastMessageAt = existingConversation.lastMessageAt;

//   //       // Update fields from the socket update
//   //       existingConversation.clientLastReadMessageId =
//   //           updatedConversation.clientLastReadMessageId;
//   //       existingConversation.latestMessageId =
//   //           updatedConversation.latestMessageId;
//   //       existingConversation.guideLastReadMessageId = "";

//   //       // Update latest message creator if available
//   //       if (updatedConversation.latestMessage != null &&
//   //           existingConversation.latestMessage != null) {
//   //         existingConversation.latestMessage!.creatorUserId =
//   //             updatedConversation.latestMessage!.creatorUserId;

//   //         // If the updated conversation has a newer message, update the timestamp
//   //         if (updatedConversation.latestMessage!.createdAt != null) {
//   //           existingConversation.latestMessage!.createdAt =
//   //               updatedConversation.latestMessage!.createdAt;
//   //           existingConversation.lastMessageAt =
//   //               updatedConversation.latestMessage?.createdAt ?? DateTime.now();
//   //         }
//   //       }

//   //       print("🔔 Conversation updated: ${existingConversation.id}");
//   //     } else {
//   //       // This is a new conversation, add it to the list
//   //       conversations.add(updatedConversation);
//   //       print("🔔 New conversation added: ${updatedConversation.id}");
//   //     }

//   //     // Sort conversations by most recent message
//   //     _sortConversations();
//   //   });
//   // }

//   void updateConversationList(Conversation updatedConversation) {
//     if (mounted) {
//       setState(() {
//         // Find the conversation that matches the updated conversation's id
//         Conversation conversationToUpdate = conversations.firstWhere(
//           (c) => c.id == updatedConversation.id,
//           orElse: () => Conversation(id: "", lastMessageAt: DateTime.now()),
//         );
//         print(
//             "🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔 Conversation marked as read: $conversationToUpdate");
//         conversationToUpdate.latestMessage?.creatorUserId = "aaaaaaaaaa";
//         // Update the fields of the existing conversation
//         conversationToUpdate.clientLastReadMessageId =
//             updatedConversation.clientLastReadMessageId;
//         // conversationToUpdate.guideLastReadMessageId =
//         //     updatedConversation.guideLastReadMessageId;
//         conversationToUpdate.latestMessageId =
//             updatedConversation.latestMessageId;

//         conversations
//             .sort((a, b) => a.lastMessageAt.compareTo(b.lastMessageAt));
//       });

//       // Trigger any necessary UI updates here
//       // For example, reload the notification count, fetch new data, etc.
//     }
//   }

//   void markConversationAsRead(String conversationId) async {
//     String? token = await storage.read(key: "access_token");

//     final response = await http.patch(
//       Uri.parse("$baseUrls/api/conversation/$conversationId/read"),
//       headers: {
//         "Authorization": "Bearer $token",
//         "Content-Type": "application/json",
//       },
//     );

//     if (response.statusCode == 200) {
//       print("Conversation marked as read");
//     } else {
//       print("Failed to mark conversation as read");
//     }
//   }

//   //   @override
//   //   void dispose() {
//   //     socket.dispose(); // Close the socket connection when the widget is disposed
//   //     super.dispose();
//   //   }
//   Future<void> fetchTravellersByCode(String code) async {
//     final url =
//         Uri.parse('${baseUrls}/api/travellers-mobile?filters[code]=$code');

//     try {
//       if (mounted) {
//         setState(() {
//           loading = true;
//         });
//       }
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         final List r = responseData["results"];
//         final List<Traveller> fetchedTravellers =
//             r.map((data) => Traveller.fromJson(data)).toList();
//         print(responseData["inlineCount"]);

//         if (fetchedTravellers.isEmpty) {
//           Get.snackbar(
//             'Code invalide',
//             "Veuillez vérifier votre code et réessayer. Code: $code",
//             backgroundColor: const Color.fromARGB(214, 248, 181, 72),
//             colorText: const Color.fromARGB(255, 130, 126, 126),
//             snackPosition: SnackPosition.BOTTOM,
//             margin: const EdgeInsets.all(16),
//             duration: const Duration(seconds: 3),
//           );
//         } else {
//           Get.to(
//             TravellersListPage(travellers: fetchedTravellers),
//           );
//         }
//       } else {
//         Get.snackbar(
//           'Code invalide',
//           "Veuillez vérifier votre code et réessayer. Code: $code",
//           backgroundColor: const Color.fromARGB(166, 249, 180, 68),
//           colorText: Colors.white,
//           snackPosition: SnackPosition.BOTTOM,
//           margin: const EdgeInsets.all(16),
//           duration: const Duration(seconds: 3),
//         );
//       }
//     } catch (error) {
//       Get.snackbar(
//         '${error.hashCode}',
//         "Vérifiez votre connexion Internet et réessayez. Code: $code",
//         backgroundColor: Colors.redAccent,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.BOTTOM,
//         margin: const EdgeInsets.all(16),
//         duration: const Duration(seconds: 3),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           loading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Create a set of unique conversation IDs to filter duplicates
//     final uniqueConversationIds = <String>{};
//     final uniqueConversations = conversations.where((conversation) {
//       // If the ID is not in the set, add it and return true
//       if (!uniqueConversationIds.contains(conversation.id)) {
//         uniqueConversationIds.add(conversation.id);
//         return true;
//       }
//       return false;
//     }).toList();

//     // Sort unique conversations by last message time before building the list
//     uniqueConversations.sort((a, b) =>
//         b.latestMessage!.createdAt!.compareTo(a.latestMessage!.createdAt!));

//     return Scaffold(
//         appBar: AppBar(
//           title: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Text("List Conversation"),
//               Gap(
//                 20,
//               ),
//               IconButton(
//                   onPressed: () {
//                     showDialog(
//                       context: context,
//                       builder: (context) {
//                         final TextEditingController _codeController =
//                             TextEditingController();

//                         return AlertDialog(
//                           title: const Text('Rechercher un voyageur'),
//                           content: TextField(
//                             controller: _codeController,
//                             decoration: const InputDecoration(
//                               labelText: 'Entrez le code du voyageur',
//                               border: OutlineInputBorder(),
//                             ),
//                           ),
//                           actions: [
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.pop(context); // Close the dialog
//                               },
//                               child: const Text('Annuler'),
//                             ),
//                             ElevatedButton(
//                               onPressed: () {
//                                 final code = _codeController.text.trim();
//                                 if (code.isNotEmpty) {
//                                   Navigator.pop(
//                                       context); // Close the dialog first
//                                   fetchTravellersByCode(code); // Then fetch
//                                 } else {
//                                   Get.snackbar(
//                                     'Code requis',
//                                     'Veuillez entrer un code avant de rechercher.',
//                                     backgroundColor: Colors.orange,
//                                     colorText: Colors.white,
//                                     snackPosition: SnackPosition.BOTTOM,
//                                     margin: const EdgeInsets.all(16),
//                                     duration: const Duration(seconds: 3),
//                                   );
//                                 }
//                               },
//                               child: const Text('Rechercher'),
//                             ),
//                           ],
//                         );
//                       },
//                     );
//                   },
//                   icon: Icon(
//                     Icons.add_circle_outline,
//                     size: 27,
//                   ))
//             ],
//           ),
//         ),
//         body: loading
//             ? Center(child: CircularProgressIndicator())
//             : RefreshIndicator(
//                 onRefresh: () async {
//                   await fetchConversations(); // Call your API function
//                 },
//                 child: uniqueConversations.isEmpty
//                     ? RefreshIndicator(
//                         onRefresh: () async {
//                           await fetchConversations(); // Call your API function
//                         },
//                         child: Center(
//                           child: Text("Aucun Conversation "),
//                         ),
//                       )
//                     : Column(
//                         children: [
//                           if (!connction)
//                             Container(
//                               width: double.infinity,
//                               color: Colors.red.shade100,
//                               padding: EdgeInsets.symmetric(vertical: 8),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(Icons.wifi_off, color: Colors.red),
//                                   SizedBox(width: 8),
//                                   Text(
//                                     "Déconnecté du serveur",
//                                     style: TextStyle(color: Colors.red),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           Expanded(
//                             child:
//                                 //  ListView.separated(
//                                 //     separatorBuilder: (context, index) => const Divider(
//                                 //       height: 1,
//                                 //       color: Colors.grey,
//                                 //       indent: 16,
//                                 //       endIndent: 16,
//                                 //     ),
//                                 //     itemCount: uniqueConversations.length,
//                                 //     itemBuilder: (context, index) {
//                                 //       final conversation = uniqueConversations[index];

//                                 //       // Calculate unread message count

//                                 //       return Container(
//                                 //         // color:
//                                 //         //     ? const Color.fromARGB(255, 205, 6, 6)
//                                 //         //     : const Color.fromARGB(255, 8, 135, 226),
//                                 //         child: Card(
//                                 //           elevation: 2,
//                                 //           margin: const EdgeInsets.symmetric(
//                                 //               horizontal: 8, vertical: 4),
//                                 //           shape: RoundedRectangleBorder(
//                                 //             borderRadius: BorderRadius.circular(12),
//                                 //           ),
//                                 //           child: ListTile(
//                                 //             contentPadding: const EdgeInsets.symmetric(
//                                 //                 horizontal: 16, vertical: 8),
//                                 //             tileColor:
//                                 //                 conversation.guideLastReadMessageId ==
//                                 //                         conversation.latestMessage?.id
//                                 //                     ? Colors.grey.shade100
//                                 //                     : Colors.blue.shade50,
//                                 //             title: Row(
//                                 //               children: [
//                                 //                 CachedNetworkImage(
//                                 //                   imageUrl:
//                                 //                       "${baseUrls}/assets/uploads/traveller/${conversation.clientUser?.picture}",
//                                 //                   errorWidget: (context, url, error) =>
//                                 //                       Container(
//                                 //                     width: Get.width * 0.08,
//                                 //                     height: Get.width * 0.08,
//                                 //                     child: Image.asset(
//                                 //                         "assets/man-user-circle-icon.png"),
//                                 //                   ),
//                                 //                   placeholder: (context, url) => SizedBox(
//                                 //                     height: 5,
//                                 //                   ),
//                                 //                   imageBuilder: (context, imageProvider) =>
//                                 //                       ClipOval(
//                                 //                     child: Container(
//                                 //                       width: Get.width * 0.08,
//                                 //                       height: Get.width * 0.08,
//                                 //                       decoration: BoxDecoration(
//                                 //                         image: DecorationImage(
//                                 //                           image: imageProvider,
//                                 //                           fit: BoxFit.cover,
//                                 //                         ),
//                                 //                         borderRadius:
//                                 //                             BorderRadius.circular(8),
//                                 //                         color: const Color.fromARGB(
//                                 //                             255, 235, 235, 202),
//                                 //                       ),
//                                 //                     ),
//                                 //                   ),
//                                 //                 ),
//                                 //                 Gap(20),
//                                 //                 Expanded(
//                                 //                   child: Text(
//                                 //                     conversation.clientUser?.firstName ??
//                                 //                         "",
//                                 //                     style: TextStyle(
//                                 //                       fontWeight: FontWeight.w600,
//                                 //                       color: Colors.black87,
//                                 //                       fontSize: 16,
//                                 //                     ),
//                                 //                     maxLines: 1,
//                                 //                     overflow: TextOverflow.ellipsis,
//                                 //                   ),
//                                 //                 ),
//                                 //                 // Unread message count badge
//                                 //               ],
//                                 //             ),
//                                 //             subtitle: Column(
//                                 //               crossAxisAlignment: CrossAxisAlignment.start,
//                                 //               children: [
//                                 //                 Padding(
//                                 //                   padding: const EdgeInsets.only(
//                                 //                       left: 18.0, top: 12),
//                                 //                   child: Text(
//                                 //                     conversation.lastMessage ??
//                                 //                         "No message",
//                                 //                     style: TextStyle(
//                                 //                       color: Colors.black54,
//                                 //                       fontSize: 14,
//                                 //                     ),
//                                 //                     maxLines: 1,
//                                 //                     overflow: TextOverflow.ellipsis,
//                                 //                   ),
//                                 //                 ),
//                                 //                 const SizedBox(height: 4),
//                                 //               ],
//                                 //             ),
//                                 //             trailing: Column(
//                                 //               mainAxisAlignment: MainAxisAlignment.center,
//                                 //               children: [
//                                 //                 Padding(
//                                 //                   padding: const EdgeInsets.all(10.0),
//                                 //                   child: Text(
//                                 //                     DateFormat('EEEE, hh:mm a').format(
//                                 //                         conversation
//                                 //                             .latestMessage!.createdAt!
//                                 //                             .toLocal()),
//                                 //                     style: TextStyle(
//                                 //                       color: true
//                                 //                           ? const Color.fromARGB(
//                                 //                               255, 40, 36, 36)
//                                 //                           : const Color.fromARGB(
//                                 //                               255, 8, 13, 16),
//                                 //                       fontSize: 12,
//                                 //                       fontWeight: FontWeight.w500,
//                                 //                     ),
//                                 //                   ),
//                                 //                 ),
//                                 //                 // conversation.clientLastReadMessageId ==
//                                 //                 //         conversation.latestMessageId
//                                 //                 Visibility(
//                                 //                   visible: conversation
//                                 //                           .clientLastReadMessageId ==
//                                 //                       conversation.latestMessageId,
//                                 //                   child: Icon(
//                                 //                     size: 20,
//                                 //                     Icons.done_all,
//                                 //                     color: const Color.fromARGB(
//                                 //                         255, 108, 110, 112),
//                                 //                   ),
//                                 //                 )
//                                 //                 //     : Icon(
//                                 //                 //         size: 10,
//                                 //                 //         Icons.circle,
//                                 //                 //         color: Colors.grey,
//                                 //                 //       )
//                                 //                 // //   AvatarGroupStack(
//                                 //                 //     imageNames: participantImages,
//                                 //                 //   ),
//                                 //               ],
//                                 //             ),
//                                 //             onTap: () async {
//                                 //               // markConversationAsRead(conversation.id);
//                                 //               // await fetchConversations();
//                                 //               Get.to(ChatScreenOnetoOne(
//                                 //                 conversation: conversation,
//                                 //               ));
//                                 //             },
//                                 //           ),
//                                 //         ),
//                                 //       );
//                                 //     },
//                                 //   ),

//                                 ListView.separated(
//                               separatorBuilder: (context, index) =>
//                                   const SizedBox(height: 8),
//                               itemCount: uniqueConversations.length,
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 16, vertical: 8),
//                               itemBuilder: (context, index) {
//                                 final conversation = uniqueConversations[index];
//                                 final bool isUnread =
//                                     (conversation.guideLastReadMessageId !=
//                                             conversation.latestMessage?.id) &&
//                                         (conversation
//                                                 .latestMessage!.creatorUserId !=
//                                             userId);

//                                 return Container(
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(12),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.05),
//                                         blurRadius: 5,
//                                         offset: const Offset(0, 2),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Card(
//                                     elevation: 0,
//                                     margin: EdgeInsets.zero,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                       side: BorderSide(
//                                         color: isUnread
//                                             ? Colors.blue.shade200
//                                             : Colors.grey.shade200,
//                                         width: 1,
//                                       ),
//                                     ),
//                                     child: InkWell(
//                                       borderRadius: BorderRadius.circular(12),
//                                       onTap: () async {
//                                         Get.to(ChatScreenOnetoOne(
//                                           conversation: conversation,
//                                         ));
//                                       },
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(16),
//                                         child: Row(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             // Profile Image with status indicator
//                                             Stack(
//                                               children: [
//                                                 CachedNetworkImage(
//                                                   imageUrl:
//                                                       "${baseUrls}/assets/uploads/traveller/${conversation.clientUser?.picture}",
//                                                   errorWidget:
//                                                       (context, url, error) =>
//                                                           Container(
//                                                     width: 56,
//                                                     height: 56,
//                                                     decoration: BoxDecoration(
//                                                       color:
//                                                           Colors.grey.shade200,
//                                                       shape: BoxShape.circle,
//                                                     ),
//                                                     child: Icon(Icons.person,
//                                                         color: Colors
//                                                             .grey.shade400,
//                                                         size: 32),
//                                                   ),
//                                                   placeholder: (context, url) =>
//                                                       Container(
//                                                     width: 56,
//                                                     height: 56,
//                                                     decoration: BoxDecoration(
//                                                       color:
//                                                           Colors.grey.shade100,
//                                                       shape: BoxShape.circle,
//                                                     ),
//                                                   ),
//                                                   imageBuilder: (context,
//                                                           imageProvider) =>
//                                                       Container(
//                                                     width: 56,
//                                                     height: 56,
//                                                     decoration: BoxDecoration(
//                                                       shape: BoxShape.circle,
//                                                       image: DecorationImage(
//                                                         image: imageProvider,
//                                                         fit: BoxFit.cover,
//                                                       ),
//                                                       border: Border.all(
//                                                         color: Colors.white,
//                                                         width: 2,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 // Online status indicator - you could add this if needed
//                                                 // Positioned(
//                                                 //   bottom: 0,
//                                                 //   right: 0,
//                                                 //   child: Container(
//                                                 //     width: 14,
//                                                 //     height: 14,
//                                                 //     decoration: BoxDecoration(
//                                                 //       color: Colors.green,
//                                                 //       shape: BoxShape.circle,
//                                                 //       border: Border.all(color: Colors.white, width: 2),
//                                                 //     ),
//                                                 //   ),
//                                                 // ),
//                                               ],
//                                             ),
//                                             const SizedBox(width: 12),
//                                             // Chat content
//                                             Expanded(
//                                               child: Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .spaceBetween,
//                                                     children: [
//                                                       Expanded(
//                                                         child: Text(
//                                                           conversation
//                                                                   .clientUser!
//                                                                   .firstName ??
//                                                               "Unknown",
//                                                           style: TextStyle(
//                                                             fontWeight: isUnread
//                                                                 ? FontWeight
//                                                                     .bold
//                                                                 : FontWeight
//                                                                     .w500,
//                                                             fontSize: 16,
//                                                             color:
//                                                                 Colors.black87,
//                                                           ),
//                                                           maxLines: 1,
//                                                           overflow: TextOverflow
//                                                               .ellipsis,
//                                                         ),
//                                                       ),
//                                                       Text(
//                                                         DateFormat(
//                                                                 'MMM d, h:mm a')
//                                                             .format(
//                                                           conversation
//                                                               .latestMessage!
//                                                               .createdAt!
//                                                               .toLocal(),
//                                                         ),
//                                                         style: TextStyle(
//                                                           fontSize: 12,
//                                                           color: isUnread
//                                                               ? Colors
//                                                                   .blue.shade700
//                                                               : Colors.grey
//                                                                   .shade600,
//                                                           fontWeight: isUnread
//                                                               ? FontWeight.w500
//                                                               : FontWeight
//                                                                   .normal,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   const SizedBox(height: 6),
//                                                   Text(
//                                                     conversation.lastMessage ??
//                                                         "No message",
//                                                     style: TextStyle(
//                                                       fontSize: 14,
//                                                       color: isUnread
//                                                           ? Colors.black87
//                                                           : Colors
//                                                               .grey.shade700,
//                                                       fontWeight: isUnread
//                                                           ? FontWeight.w500
//                                                           : FontWeight.normal,
//                                                     ),
//                                                     maxLines: 2,
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                   ),
//                                                   const SizedBox(height: 8),
//                                                   // Bottom row with read status and options
//                                                   Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment.end,
//                                                     children: [
//                                                       if (isUnread)
//                                                         Container(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .symmetric(
//                                                                   horizontal: 8,
//                                                                   vertical: 4),
//                                                           decoration:
//                                                               BoxDecoration(
//                                                             color: Colors
//                                                                 .blue.shade600,
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .circular(
//                                                                         10),
//                                                           ),
//                                                           child: const Text(
//                                                             "New",
//                                                             style: TextStyle(
//                                                               color:
//                                                                   Colors.white,
//                                                               fontSize: 12,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold,
//                                                             ),
//                                                           ),
//                                                         )
//                                                       else
//                                                         Visibility(
//                                                           visible: conversation
//                                                                   .clientLastReadMessageId ==
//                                                               conversation
//                                                                   .latestMessageId,
//                                                           child: Row(
//                                                             children: [
//                                                               Icon(
//                                                                 Icons.done_all,
//                                                                 size: 16,
//                                                                 color: Colors
//                                                                     .blue
//                                                                     .shade600,
//                                                               ),
//                                                               const SizedBox(
//                                                                   width: 4),
//                                                               Text(
//                                                                 "Read",
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize: 12,
//                                                                   color: Colors
//                                                                       .grey
//                                                                       .shade600,
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                     ],
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       )));

//     // Unread message count calculation function
//   }
// }
