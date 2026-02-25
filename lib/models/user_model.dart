import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String photoUrl;
  final String bio;
  final String role;
  final String? promotion;
  final String? filiere;
  final String? matricule;
  final List<String> friends;
  final List<String> friendRequestsSent;
  final List<String> friendRequestsReceived;
  final bool isOnline; // Nouveau : Statut en ligne
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.photoUrl,
    required this.bio,
    required this.role,
    this.promotion,
    this.filiere,
    this.matricule,
    required this.friends,
    required this.friendRequestsSent,
    required this.friendRequestsReceived,
    this.isOnline = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'role': role,
      'promotion': promotion,
      'filiere': filiere,
      'matricule': matricule,
      'friends': friends,
      'friendRequestsSent': friendRequestsSent,
      'friendRequestsReceived': friendRequestsReceived,
      'isOnline': isOnline,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return UserModel(
      uid: snapshot['uid'] ?? '',
      username: snapshot['username'] ?? '',
      email: snapshot['email'] ?? '',
      photoUrl: snapshot['photoUrl'] ?? '',
      bio: snapshot['bio'] ?? '',
      role: snapshot['role'] ?? 'Etudiant',
      promotion: snapshot['promotion'],
      filiere: snapshot['filiere'],
      matricule: snapshot['matricule'],
      friends: List<String>.from(snapshot['friends'] ?? []),
      friendRequestsSent: List<String>.from(snapshot['friendRequestsSent'] ?? []),
      friendRequestsReceived: List<String>.from(snapshot['friendRequestsReceived'] ?? []),
      isOnline: snapshot['isOnline'] ?? false,
      createdAt: (snapshot['createdAt'] as Timestamp).toDate(),
    );
  }
}
