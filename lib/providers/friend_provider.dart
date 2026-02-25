import 'package:flutter/material.dart';
import '../services/friend_service.dart';

class FriendProvider with ChangeNotifier {
  final FriendService _friendService = FriendService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> sendRequest(String userId) async {
    _isLoading = true;
    notifyListeners();
    await _friendService.sendFriendRequest(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> cancelRequest(String userId) async {
    _isLoading = true;
    notifyListeners();
    await _friendService.cancelFriendRequest(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> acceptRequest(String userId) async {
    _isLoading = true;
    notifyListeners();
    await _friendService.acceptFriendRequest(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refuseRequest(String userId) async {
    _isLoading = true;
    notifyListeners();
    await _friendService.refuseFriendRequest(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> removeFriend(String userId) async {
    _isLoading = true;
    notifyListeners();
    await _friendService.removeFriend(userId);
    _isLoading = false;
    notifyListeners();
  }
}
