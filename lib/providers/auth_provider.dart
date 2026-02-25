import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    required String role,
    String? promotion,
    String? filiere,
    String? matricule, // Ajout
  }) async {
    _setLoading(true);
    String res = await _authService.signUpUser(
      email: email,
      password: password,
      username: username,
      role: role,
      promotion: promotion,
      filiere: filiere,
      matricule: matricule, // Transmission
    );
    _setLoading(false);

    if (res == "success") {
      return true;
    } else {
      _errorMessage = res;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    String res = await _authService.loginUser(email: email, password: password);
    _setLoading(false);

    if (res == "success") {
      return true;
    } else {
      _errorMessage = res;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
