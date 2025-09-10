import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:dio/dio.dart';
import 'package:zenifytrip_guide/env.dart';

import 'dart:async';

import 'package:zenifytrip_guide/features/ChatModulev2/Message.dart';
import 'package:zenifytrip_guide/features/ChatModulev2/WebsocketEvents.dart';
 String baseUrls =AppEnvironment.baseApiUrl;

// Define a class to store messages for later delivery
class QueuedMessage {
  final String event;
  final dynamic data;
  final DateTime timestamp;

  QueuedMessage(this.event, this.data) : timestamp = DateTime.now();
}

class SocketIOManager {
  // Properly define the socket variable that we'll initialize later
  late IO.Socket socket;

  // Private constructor
  SocketIOManager._() {
    // Initialize any properties that need to be set immediately
  }

  // Singleton instance - declaring static final ensures it's created only once
  static final SocketIOManager _instance = SocketIOManager._();

  // Getter for the instance
  static SocketIOManager get instance => _instance;

  // Secure storage for session ID
  //final storage = sc.FlutterSecureStorage();

  // Connection status
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // Add these properties for reconnection handling
  int _reconnectionAttempts = 0;
  final int _maxReconnectionAttempts = 5;
  Timer?
      _reconnectionTimer; // Making it nullable to avoid initialization issues
  bool _isReconnecting = false;

  // Callback listeners
  final List<Function(Message)> _messageListeners = [];
  final List<Function(Conversation)> _conversationListeners = [];
  final List<Function(bool)> _connectionListeners = [];

  // Data storage
  final Map<String, Conversation> conversations = {};
  final Map<String, List<Message>> conversationMessages = {};

  // Queue for storing messages when offline - using our improved QueuedMessage class
  final List<QueuedMessage> _messageQueue = [];

  // Legacy queue (keeping for compatibility)
  final List<Map<String, dynamic>> _pendingMessages = [];

  // Initialize socket with reconnection handling
  Future<void> initSocket() async {
    if (_isConnected || _isReconnecting) return;

    try {
      await connectToSocket();
    } catch (e) {
      print('Socket connection error initSocket: $e');   _isConnected = false;
      _notifyConnectionListeners(false);
      _scheduleReconnection();
    }
  }

  // Connect to socket with proper error handling
  Future<void> connectToSocket() async {
    String? sessionIds = "await storage.read(key: )";

    // Initialize the socket here
    socket = IO.io(
      baseUrls,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableMultiplex()
          .setExtraHeaders({'Cookie': "$sessionIds"})
          // Disable automatic reconnection to handle it manually
          // .disableAutoConnect()
          .enableForceNew()
          .build(),
    );

    // Connection events
    socket.onConnect((_) {
      print('Socket connected');
      socket.emit('ping', {'message': 'Testing connection'});
      _isConnected = true;
      _reconnectionAttempts = 0;
      _isReconnecting = false;
      _notifyConnectionListeners(true);
      onSocketConnected(); // Process any queued messages
       
    });

    socket.onDisconnect((_) {
      print('Socket disconnected');
      _isConnected = false;
      _notifyConnectionListeners(false);
      _scheduleReconnection();
    });

    socket.onError((error) {
      print('Socket error: $error');
      _isConnected = false;
      _scheduleReconnection();
    });

    socket.onConnectError((error) {
      _isConnected = false;
      print('Connection error: $error');
      _scheduleReconnection();
    });

    // Message received event
    socket.on(WebsocketEvents.chatConversationMessageCreated, (data) {
      print("Raw socket onMessage received: $data"); // Debug print
      socket.emit('ping', {'message': 'Testing connection'});
      try {
        var message = Message.fromJson(data);
        print("Message parsed successfully: ${message.content}");
        // _updateConversation(message.conversationId ?? "", message);
        _notifyMessageListeners(message);
      } catch (e) {
        print("Error parsing message: $e");
        // Consider logging the raw data for debugging
        print("Raw data causing error: $data");
      }
    });

    socket.on('chat.conversation.read', (data) {
      print("Raw socket chatConversationUpdate received: $data"); // Debug print
      // socket.emit('ping', {'message': 'Testing connection'});
      try {
        final conversation = Conversation.fromJson(data);
        _notifyConversationListeners(conversation);
      } catch (e) {
        print("Error parsing message: $e");
        // Consider logging the raw data for debugging
        print("Raw data causing error: $data");
      }
    });

    socket.on(WebsocketEvents.chatConversationUpdate, (data) {
      print("Raw socket chatConversationUpdate received: $data"); // Debug print
      // socket.emit('ping', {'message': 'Testing connection'});
      try {
        final conversation = Conversation.fromJson(data);
        _notifyConversationListeners(conversation);
      } catch (e) {
        print("Error parsing message: $e");
        // Consider logging the raw data for debugging
        print("Raw data causing error: $data");
      }
    });

    socket.connect();
  }

  // Process all queued messages using API instead of socket
  Future<void> _processQueuedMessages() async {
    if (_messageQueue.isEmpty) return;

    print('Processing ${_messageQueue.length} queued messages');

    // Create a copy of the queue to avoid modification during iteration
    final messagesToProcess = List<QueuedMessage>.from(_messageQueue);
    _messageQueue.clear();

    String? token = "";
    //await storage.read(key: 'access_token');

    for (var message in messagesToProcess) {
      try {
        // Send queued messages to API instead of socket
        if (message.event == 'message') {
          await Dio().post(
            '$baseUrls/api/message',
            data: message.data,
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            ),
          );
          print('Sent queued message to API: ${message.event}');
        } else {
          // For other event types, still use socket if needed
          if (_isConnected) {
            socket.emit(message.event, message.data);
            print('Sent queued message via socket: ${message.event}');
          } else {
            // Re-queue non-message events if socket not connected
            _messageQueue.add(message);
            print('Re-queued non-message event: ${message.event}');
          }
        }
      } catch (e) {
        // If sending fails, re-queue the message
        _messageQueue.add(message);
        print('Failed to send queued message: $e');
      }
    }
        Get.snackbar(
              '',
              '',
              titleText: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                         "Connexion rétablie.",
       

                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 226, 225, 225),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
           
        backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
          
              // boxShadows: [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(0.25),
              //     spreadRadius: 0,
              //     blurRadius: 8,
              //     offset: Offset(0, 4),
              //   ),
              // ],
            
            );
      
    // Also process legacy pending messages for backward compatibility
    _sendPendingMessages();
  }

  // This method should be called when socket connection is established
  Future<void> onSocketConnected() async {
    _isConnected = true;
    _isReconnecting = false;

    // Process any queued messages
    await _processQueuedMessages();
  }

  set isConnected(bool value) {
    if (_isConnected != value) {
      _isConnected = value;
      _notifyListeners();
    }
  }

  void _notifyListeners() {
    for (final listener in _connectionListeners) {
      listener(
          _isConnected); // Pass the current connection status to the listener
    }
  }

  void addConnectionChangeListener(Function(bool) listener) {
    _connectionListeners.add(listener);
  }

  void removeConnectionChangeListener(Function(bool) listener) {
    _connectionListeners.remove(listener);
  }

  // Schedule reconnection with exponential backoff
  void _scheduleReconnection() {
    if (_isReconnecting || _reconnectionAttempts >= _maxReconnectionAttempts)
      return;

    _isReconnecting = true;

    // Calculate backoff time (exponential with jitter)
    // Fixed calculation to avoid double to int type error
    int backoffSeconds = (1 << _reconnectionAttempts);
    double jitter = 1 + (0.1 * (DateTime.now().millisecondsSinceEpoch % 10));
    int delayMs = (backoffSeconds * jitter).round();

    print(
        'Scheduling reconnection attempt ${_reconnectionAttempts + 1} in ${delayMs}ms');

    _reconnectionTimer = Timer(Duration(milliseconds: delayMs), () {
      _reconnectionAttempts++;
      _isReconnecting = false;
      initSocket();
    });
  }

  // Cancel reconnection if needed
  void cancelReconnection() {
    if (_isReconnecting && _reconnectionTimer != null) {
      _reconnectionTimer!.cancel();
      _isReconnecting = false;
    }
  }

  // Disconnect socket
  void disconnect() {
    if (_isConnected) {
      socket.disconnect();
      _isConnected = false;
      _notifyConnectionListeners(false);
    }

    // Cancel any reconnection attempts
    cancelReconnection();
  }

  // Enhanced method to store messages for later delivery with duplicate detection
  void _storeMessageForLaterDelivery(String event, dynamic data) {
    // Avoid duplicate messages in the queue
    final isDuplicate = _messageQueue.any((qm) =>
        qm.event == event &&
        (event == 'message'
            ? qm.data['conversationId'] == data['conversationId'] &&
                qm.data['content'] == data['content']
            : qm.data == data));

    if (!isDuplicate) {
      _messageQueue.add(QueuedMessage(event, data));
      print('Message queued for later delivery: $event');
    } else {
      print('Duplicate message not queued: $event');
    }
  }

  // Handle sending messages when socket may be disconnected
  Future<void> sendMessage(String event, dynamic data) async {
    // If it's a message type event and we have internet connection, try API first
    if (event == 'message') {
      try {
        String? token = "";
        //await storage.read(key: 'access_token');
        await Dio().post(
          '$baseUrls/api/message',
          data: data,
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ),
        );
        print('Message sent via API: $event');
        return; // If API call succeeds, we're done
      } catch (e) {
        // If API call fails, store for later and try socket as fallback
        print('API call failed, storing message for later: $e');
               Get.snackbar(
              '',
              '',
              titleText: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                          " Échec de l'envoi du message. Une nouvelle tentative sera effectuée lors de la reconnexion",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 244, 242, 242),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              backgroundColor: Color.fromARGB(255, 249, 3, 3),
              // boxShadows: [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(0.25),
              //     spreadRadius: 0,
              //     blurRadius: 8,
              //     offset: Offset(0, 4),
              //   ),
              // ],
            
            );
      
        _storeMessageForLaterDelivery(event, data);
      }
    }

    // Try socket if still needed
    if (_isConnected) {
      try {
        socket.emit(event, data);
        print('Message sent via socket: $event');
      } catch (e) {
        // If socket emit fails, ensure message is queued
        print('Socket emit failed: $e');
        _storeMessageForLaterDelivery(event, data);
      }
    } else {
      // Socket not connected, store message if not already stored
      _storeMessageForLaterDelivery(event, data);

      // Try to reconnect
      if (!_isReconnecting) {
        _isReconnecting = true;
        initSocket().then((_) async {
          _isReconnecting = false;
          // Process queued messages after successful reconnection
          if (_isConnected) {
       
            await _processQueuedMessages();
          }
        }).catchError((error) {
          _isReconnecting = false;
          print('Socket reconnection failed: $error');
        });
      }
    }
  }

  // Legacy method for backward compatibility
  void _sendPendingMessages() {
    if (_pendingMessages.isEmpty) return;

    print('Sending ${_pendingMessages.length} pending messages');

    for (var message in _pendingMessages) {
      socket.emit(message['event'], message['data']);
    }

    _pendingMessages.clear();
  }

  // Add message listener
  void addMessageListener(Function(Message) listener) {
    print("addMessageListener");

    try {
      _messageListeners.add(listener);
      
    } catch (e) {
      print(e);
    }
  }

  // Remove message listener
  void removeMessageListener(Function(Message) listener) {
    _messageListeners.remove(listener);
  }

  // Add conversation listener
  void addConversationListener(Function(Conversation) listener) {
    // _conversationListeners.add(listener);
    print(" _conversationListeners.add(listener);");

    try {
      _conversationListeners.add(listener);
    } catch (e) {
      print("_conversationListeners $e");
    }
  }

  // Remove conversation listener
  void removeConversationListener(Function(Conversation) listener) {
    _conversationListeners.remove(listener);
  }

  // Add connection state listener
  void addConnectionListener(Function(bool) listener) {
    _connectionListeners.add(listener);
  }

  // Remove connection state listener
  void removeConnectionListener(Function(bool) listener) {
    _connectionListeners.remove(listener);
  }

  // Notify all message listeners
  void _notifyMessageListeners(Message message) {
    for (var listener in _messageListeners) {
      listener(message);
    }
  }

  // Notify all conversation listeners
  void _notifyConversationListeners(Conversation conversation) {
    for (var listener in _conversationListeners) {
      listener(conversation);
    }
  }

  // Notify all connection listeners
  void _notifyConnectionListeners(bool isConnected) {
    for (var listener in _connectionListeners) {
      listener(isConnected);
    }
  }

  // Update conversation with new message
  void _updateConversation(String conversationId, Message message) {
    if (conversationId.isEmpty) return;

    // Add message to conversation's message list
    if (!conversationMessages.containsKey(conversationId)) {
      conversationMessages[conversationId] = [];
    }
    conversationMessages[conversationId]?.add(message);

    // Update last message in conversation if it exists
    if (conversations.containsKey(conversationId)) {
      conversations[conversationId]?.lastMessage = message as String?;
    }
  }

  // Update conversation list with new conversation
  void _updateConversationList(Conversation conversation) {
    String id = conversation.id ?? "";
    if (id.isEmpty) return;

    conversations[id] = conversation;
  }

  // Method to update a conversation (by ID)
  void updateConversationLists(Conversation updatedConversation) {
    conversations[updatedConversation.id] = updatedConversation;
  }

  // Method to notify listeners (you can use this as you did before)
  void notifyConversationListeners(Conversation conversation) {
    for (var listener in _conversationListeners) {
      listener(conversation);
    }
  }

  // In your SocketManager class or similar
  void updateConversationListAndContentListener(
      Function(Conversation? conversation, Message? message)
          onConversationUpdate) {
    // Listen for new messages
    socket.on(WebsocketEvents.chatConversationMessageCreated, (data) {
      print(
          'Received new message updateConversationListAndContentListener: $data');

      // Parse the message data into your Message model
      final message = Message.fromJson(data);

      // You might want to update your local message list here
      // This depends on your state management approach

      // Pass null for conversation as this event only contains message data
      onConversationUpdate(null, message);
    });

    // Listen for conversation updates
    socket.on(WebsocketEvents.chatConversationUpdate, (data) {
      print('Conversation updated: $data');

      // Parse the conversation data into your Conversation model
      final conversation = Conversation.fromJson(data);

      // You might want to update your local conversation list here
      // This depends on your state management approach

      // Pass the conversation and null for message
      onConversationUpdate(conversation, null);
    });
  }
}
