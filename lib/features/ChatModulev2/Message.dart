class Message {
  final String id;
  final String content;
  final String creatorUserId;
  final String conversationId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String guideUserId;
   bool? isDelevred;
  //final String conversationName;

  // final User sender;
  // final Conversation conversation;

  Message({
    required this.id,
    required this.content,
    required this.creatorUserId,
    required this.conversationId,
    required this.createdAt,
    required this.updatedAt,
    required this.guideUserId,
this.isDelevred,
    // required this.conversation,
  });
factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? "",
      content: json['content'] ?? "No Content",
      creatorUserId: json['creatorUserId'] ?? "",
      conversationId: json['conversationId'] ?? "",
      guideUserId: json['guideUserId'] ?? "",
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      // sender: User.fromJson(json['creatorUser'] ?? {}),
      // conversation: Conversation.fromJson(json['conversation'] ?? {}),
    );
  }

}

class Conversation {
  final String id;
  String? name;
  String? lastMessage;
  DateTime lastMessageAt;
  DateTime? lastMessageCreatedAt;
  String? clientUserId;
  String? guideUserId;
  String? latestMessageId;
  String? clientLastReadMessageId;
  String? guideLastReadMessageId;
  User? clientUser;
  User? guideUser;
  LatestMessage? latestMessage;

  Conversation({
    required this.id,
this.lastMessageCreatedAt,
    this.name,
    this.lastMessage,
    required this.lastMessageAt,
    this.clientUserId,
    this.guideUserId,
    this.latestMessageId,
    this.clientLastReadMessageId,
    this.guideLastReadMessageId,
    this.clientUser,
    this.guideUser,
    this.latestMessage,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? '',
      name: json['name'],
      lastMessage: json['latestMessage']
          ?['content'], // Get latest message content
      lastMessageAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
lastMessageCreatedAt: json['lastMessageCreatedAt'] != null
          ? DateTime.tryParse(json['lastMessageCreatedAt']) ?? DateTime.now()
          : DateTime.now(),
      clientUserId: json['clientUserId'],
      guideUserId: json['guideUserId'],
      latestMessageId: json['latestMessageId'],
      clientLastReadMessageId: json['clientLastReadMessageId'],
      guideLastReadMessageId: json['guideLastReadMessageId'],
      clientUser:
          json['clientUser'] != null ? User.fromJson(json['clientUser']) : null,
      guideUser:
          json['guideUser'] != null ? User.fromJson(json['guideUser']) : null,
      latestMessage: json['latestMessage'] != null
          ? LatestMessage.fromJson(json['latestMessage'])
          : null,
    );
  }
// Add this to your Conversation class
  Conversation copyWith({
    String? id,
    String? clientUserId,
    String? guideUserId,
    String? lastMessage,
User? clientUser,
  User? guideUser,
  LatestMessage? latestMessage,

    DateTime? lastMessageAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      clientUserId: clientUserId ?? this.clientUserId,
      guideUserId: guideUserId ?? this.guideUserId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
latestMessage: latestMessage??this.latestMessage,
clientUser: clientUser??this.clientUser,
guideUser: guideUser??this.guideUser
    );
  }
  // toJson() {}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'clientUserId': clientUserId,
      'guideUserId': guideUserId,
      'latestMessageId': latestMessageId,
      'clientLastReadMessageId': clientLastReadMessageId,
      'guideLastReadMessageId': guideLastReadMessageId,
      // 'clientUser': clientUser?.toJson(),
      // 'guideUser': guideUser?.toJson(),
      'latestMessage': latestMessage?.toJson(),
    };
  }
}

class LatestMessage {
   String? id;
   String? content;
  DateTime? createdAt;
   String? creatorUserId;
  String? conversationId;
  LatestMessage({ this.id,  this.content,this.createdAt,this.creatorUserId,this.conversationId});

  factory LatestMessage.fromJson(Map<String, dynamic> json) {
    return LatestMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
        creatorUserId: json['creatorUserId'] ?? "",
        conversationId: json['conversationId'] ?? "",
 createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now(): null);
    

    
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
    };
  }
}

// Participant class to map the participants inside the conversation
class Participant {
  final String id;
  final String userId;
  final String conversationId;

  final bool isAdmin;
  bool? isRead;
  DateTime? lastReadAt;
  User? user; // Added user field

  Participant({
    required this.id,
    required this.userId,
    required this.conversationId,
    required this.isAdmin,
    this.isRead,
    this.lastReadAt,
    this.user, // Added user to the constructor
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      userId: json['userId'],
      conversationId: json['conversationId'],
      isAdmin: json['isAdmin'],
      isRead: json['isRead'],
      lastReadAt: json['lastReadAt'] != null
          ? DateTime.parse(json['lastReadAt'])
          : null,
      user: User.fromJson(json['user']), // Parsing user from JSON
    );
  }
}

class User {
  final String id;
  String? email;
  String? firstName;
  String? lastName;
    String? picture;

  User({
    required this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.picture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'] ?? "",
      picture: json['picture'] ?? "",
      firstName: json['firstName'] ?? "",
      lastName: json['lastName'] ?? "",
    );
  }
}
