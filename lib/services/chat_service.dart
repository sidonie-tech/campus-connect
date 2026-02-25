import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Créer ou obtenir une conversation existante
  Future<String> createOrGetChat(String otherUserId) async {
    String currentUserId = _auth.currentUser!.uid;
    List<String> participants = [currentUserId, otherUserId]..sort();

    // Vérifier si une conversation existe déjà entre ces deux personnes
    QuerySnapshot existingChat = await _firestore
        .collection('chats')
        .where('participants', isEqualTo: participants)
        .limit(1)
        .get();

    if (existingChat.docs.isNotEmpty) {
      return existingChat.docs.first.id;
    } else {
      // Créer une nouvelle conversation
      DocumentReference chatRef = _firestore.collection('chats').doc();
      ChatModel newChat = ChatModel(
        chatId: chatRef.id,
        participants: participants,
        lastMessage: "",
        updatedAt: DateTime.now(),
      );
      await chatRef.set(newChat.toMap());
      return chatRef.id;
    }
  }

  // Envoyer un message (Corrigé avec le paramètre type)
  Future<void> sendMessage(String chatId, String content, {String type = 'text'}) async {
    String currentUserId = _auth.currentUser!.uid;
    DocumentReference messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    MessageModel message = MessageModel(
      messageId: messageRef.id,
      senderId: currentUserId,
      content: content,
      type: type, // Paramètre désormais bien transmis
      timestamp: DateTime.now(),
    );

    // Ajouter le message
    await messageRef.set(message.toMap());

    // Mettre à jour le dernier message de la conversation
    String lastMsgText = type == 'text' ? content : "[$type]";
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': lastMsgText,
      'updatedAt': Timestamp.now(),
    });
  }

  // Récupérer les messages en temps réel
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromSnap(doc))
            .toList());
  }

  // Récupérer la liste des conversations de l'utilisateur
  Stream<List<ChatModel>> getMyChats() {
    String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return const Stream.empty();

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatModel.fromSnap(doc))
            .toList());
  }
}
