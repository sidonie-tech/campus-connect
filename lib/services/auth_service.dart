import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RegExp _matriculeRegExp = RegExp(r'^\d{4}-[A-Z]{2,4}-\d{3}$');

  User? get currentUser => _auth.currentUser;

  Future<bool> isMatriculeUnique(String matricule) async {
    final query = await _firestore
        .collection('users')
        .where('matricule', isEqualTo: matricule)
        .get();
    return query.docs.isEmpty;
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String role,
    String? promotion,
    String? filiere,
    String? matricule,
    String bio = "",
  }) async {
    String res = "Une erreur est survenue";
    try {
      if (email.isNotEmpty && password.isNotEmpty && username.isNotEmpty) {
        
        if (role == 'Etudiant') {
          if (matricule == null || matricule.isEmpty) {
            return "Le matricule est obligatoire pour les étudiants";
          }
          
          if (!_matriculeRegExp.hasMatch(matricule)) {
            return "Format matricule invalide (Exemple requis: 2024-INF-001)";
          }

          bool isUnique = await isMatriculeUnique(matricule);
          if (!isUnique) {
            return "Ce matricule est déjà enregistré";
          }
        }

        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        UserModel user = UserModel(
          uid: cred.user!.uid,
          username: username,
          email: email,
          photoUrl: "",
          bio: bio,
          role: role,
          promotion: promotion,
          filiere: filiere,
          matricule: matricule,
          friends: [],
          friendRequestsSent: [],
          friendRequestsReceived: [],
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(cred.user!.uid).set(user.toMap());
        res = "success";
      } else {
        res = "Veuillez remplir tous les champs";
      }
    } on FirebaseAuthException catch (e) {
      res = e.message ?? res;
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> loginUser({required String email, required String password}) async {
    String res = "Une erreur est survenue";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        res = "success";
      } else {
        res = "Veuillez remplir tous les champs";
      }
    } on FirebaseAuthException catch (e) {
      res = e.message ?? res;
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
