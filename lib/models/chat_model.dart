import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;
  final List<String> participants;
  final String lastMessage;
  final DateTime updatedAt;

  ChatModel({
    required this.chatId,
    required this.participants,
    required this.lastMessage,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'participants': participants,
      'lastMessage': lastMessage,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ChatModel.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return ChatModel(
      chatId: snapshot['chatId'] ?? '',
      participants: List<String>.from(snapshot['participants'] ?? []),
      lastMessage: snapshot['lastMessage'] ?? '',
      updatedAt: (snapshot['updatedAt'] as Timestamp).toDate(),
    );
  }
}

class MessageModel {
  final String messageId;
  final String senderId;
  final String content;
  final String type; // 'text', 'image', 'audio', 'file'
  final DateTime timestamp;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'content': content,
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory MessageModel.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return MessageModel(
      messageId: snapshot['messageId'] ?? '',
      senderId: snapshot['senderId'] ?? '',
      content: snapshot['content'] ?? '',
      type: snapshot['type'] ?? 'text',
      timestamp: (snapshot['timestamp'] as Timestamp).toDate(),
    );
  }
}
