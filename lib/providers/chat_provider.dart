import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../models/chat_model.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    _errorMessage = null;
    notifyListeners();
  }

  // Obtenir le flux des conversations de l'utilisateur
  Stream<List<ChatModel>> get myChatsStream => _chatService.getMyChats();

  // Obtenir le flux des messages pour une conversation donnée
  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    return _chatService.getMessages(chatId);
  }

  // Envoyer un message (Corrigé avec le paramètre type)
  Future<void> sendMessage(String chatId, String content, {String type = 'text'}) async {
    if (content.trim().isEmpty && type == 'text') return;
    await _chatService.sendMessage(chatId, content.trim(), type: type);
  }

  // Démarrer une nouvelle conversation
  Future<String> startChatWithUser(String otherUserId) async {
    _setLoading(true);
    String chatId = await _chatService.createOrGetChat(otherUserId);
    _setLoading(false);
    return chatId;
  }
}
