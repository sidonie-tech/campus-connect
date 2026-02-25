import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  final UserService _userService = UserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  UserProvider() {
    _initOnlineStatus();
  }

  // Gérer le statut en ligne automatiquement
  void _initOnlineStatus() {
    FirebaseAuth.instance.authStateChanges().listen((User? authUser) {
      if (authUser != null) {
        // En ligne quand connecté
        _firestore.collection('users').doc(authUser.uid).update({'isOnline': true});
        
        // Note: Pour une gestion réelle "offline", il faudrait utiliser Firebase Database (RTDB)
        // car Firestore ne détecte pas nativement la perte de connexion brutale.
        // Ici on simplifie pour votre démonstration.
      }
    });
  }

  Future<void> refreshUser() async {
    _isLoading = true;
    notifyListeners();
    
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _user = await _userService.getUserDetails(currentUser.uid);
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String username,
    required String bio,
    required String photoUrl,
  }) async {
    if (_user == null) return false;
    
    _isLoading = true;
    notifyListeners();
    
    String res = await _userService.updateProfile(
      uid: _user!.uid,
      username: username,
      bio: bio,
      photoUrl: photoUrl,
    );
    
    if (res == "success") {
      await refreshUser();
      return true;
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Mettre à jour le statut manuellement (ex: déconnexion)
  Future<void> setOffline() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await _firestore.collection('users').doc(currentUser.uid).update({'isOnline': false});
    }
  }
}
