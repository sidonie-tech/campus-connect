import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class PostProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    _errorMessage = null;
    notifyListeners();
  }

  // Créer un post avec multi-ciblage
  Future<bool> addPost(
    String content,
    Uint8List? file, {
    bool isAnnouncement = false,
    bool isEvent = false,
    List<String> tags = const [],
    bool isPoll = false,
    String pollQuestion = "",
    List<String> pollOptions = const [],
    List<String> targetPromotions = const [], // Modifié en liste
    List<String> targetFilieres = const [],   // Modifié en liste
  }) async {
    _setLoading(true);
    try {
      String imageUrl = "";
      if (file != null) {
        imageUrl = await _storageService.uploadImageToStorage('posts', file, true);
      }

      String res = await _firestoreService.uploadPost(
        content,
        imageUrl,
        isAnnouncement: isAnnouncement,
        isEvent: isEvent,
        tags: tags,
        isPoll: isPoll,
        pollQuestion: pollQuestion,
        pollOptions: pollOptions,
        targetPromotions: targetPromotions,
        targetFilieres: targetFilieres,
      );
      _setLoading(false);

      if (res == "success") {
        return true;
      } else {
        _errorMessage = res;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Voter dans un sondage
  Future<void> vote(String postId, int optionIndex) async {
    await _firestoreService.voteOnPoll(postId, optionIndex);
  }

  Stream<List<PostModel>> get postsStream => _firestoreService.getPosts();
  Stream<List<PostModel>> get announcementsStream => _firestoreService.getAnnouncements();
  Stream<List<PostModel>> get eventsStream => _firestoreService.getEvents();

  Future<bool> deletePost(String postId) async {
    String res = await _firestoreService.deletePost(postId);
    return res == "success";
  }
}
