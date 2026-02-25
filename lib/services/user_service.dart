import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Récupérer les détails d'un utilisateur par son UID
  Future<UserModel> getUserDetails(String uid) async {
    DocumentSnapshot snap = await _firestore.collection('users').doc(uid).get();
    return UserModel.fromSnap(snap);
  }
  
  // Récupérer tous les utilisateurs conformes (avec ID et nom) sauf soi-même
  Stream<List<UserModel>> getAllUsers() {
    String? currentUserId = _auth.currentUser?.uid;
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) {
            final data = doc.data();
            // On ignore si pas d'ID, pas de nom, ou si c'est l'utilisateur actuel
            return doc.id.isNotEmpty && 
                   data['username'] != null && 
                   data['username'].toString().trim().isNotEmpty &&
                   doc.id != currentUserId;
          })
          .map((doc) => UserModel.fromSnap(doc))
          .toList();
    });
  }

  // Mettre à jour le profil
  Future<String> updateProfile({
    required String uid,
    required String username,
    required String bio,
    required String photoUrl,
  }) async {
    String res = "Une erreur est survenue";
    try {
      await _firestore.collection('users').doc(uid).update({
        'username': username,
        'bio': bio,
        'photoUrl': photoUrl,
      });
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }
}
