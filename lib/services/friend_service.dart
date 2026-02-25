import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Envoyer une demande d'amis
  Future<void> sendFriendRequest(String receiverId) async {
    if (currentUserId == null || receiverId.isEmpty) return;
    
    await _firestore.collection('users').doc(currentUserId!).update({
      'friendRequestsSent': FieldValue.arrayUnion([receiverId]),
    });
    await _firestore.collection('users').doc(receiverId).update({
      'friendRequestsReceived': FieldValue.arrayUnion([currentUserId!]),
    });
  }

  // Annuler une demande envoyée
  Future<void> cancelFriendRequest(String receiverId) async {
    if (currentUserId == null || receiverId.isEmpty) return;

    await _firestore.collection('users').doc(currentUserId!).update({
      'friendRequestsSent': FieldValue.arrayRemove([receiverId]),
    });
    await _firestore.collection('users').doc(receiverId).update({
      'friendRequestsReceived': FieldValue.arrayRemove([currentUserId!]),
    });
  }

  // Accepter une demande
  Future<void> acceptFriendRequest(String senderId) async {
    if (currentUserId == null || senderId.isEmpty) return;

    await _firestore.collection('users').doc(currentUserId!).update({
      'friendRequestsReceived': FieldValue.arrayRemove([senderId]),
      'friends': FieldValue.arrayUnion([senderId]),
    });
    await _firestore.collection('users').doc(senderId).update({
      'friendRequestsSent': FieldValue.arrayRemove([currentUserId!]),
      'friends': FieldValue.arrayUnion([currentUserId!]),
    });
  }

  // Refuser une demande
  Future<void> refuseFriendRequest(String senderId) async {
    if (currentUserId == null || senderId.isEmpty) return;

    await _firestore.collection('users').doc(currentUserId!).update({
      'friendRequestsReceived': FieldValue.arrayRemove([senderId]),
    });
    await _firestore.collection('users').doc(senderId).update({
      'friendRequestsSent': FieldValue.arrayRemove([currentUserId!]),
    });
  }

  // Retirer un ami
  Future<void> removeFriend(String friendId) async {
    if (currentUserId == null || friendId.isEmpty) return;

    await _firestore.collection('users').doc(currentUserId!).update({
      'friends': FieldValue.arrayRemove([friendId]),
    });
    await _firestore.collection('users').doc(friendId).update({
      'friends': FieldValue.arrayRemove([currentUserId!]),
    });
  }
}
