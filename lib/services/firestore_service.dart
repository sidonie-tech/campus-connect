import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Créer un post (Annonce, Événement ou Sondage) avec ciblage
  Future<String> uploadPost(
    String content, 
    String imageUrl, {
    bool isAnnouncement = false, 
    bool isEvent = false, 
    List<String> tags = const [],
    bool isPoll = false,
    String pollQuestion = "",
    List<String> pollOptions = const [],
    List<String> targetPromotions = const [], // Nouveau : liste des promos cibles
    List<String> targetFilieres = const [],   // Nouveau : liste des filières cibles
  }) async {
    String res = "Une erreur est survenue";
    try {
      DocumentReference postRef = _firestore.collection('posts').doc();
      String postId = postRef.id;
      String uid = _auth.currentUser!.uid;

      // Initialiser la Map des votes si c'est un sondage
      Map<String, List<String>> pollVotes = {};
      if (isPoll) {
        for (int i = 0; i < pollOptions.length; i++) {
          pollVotes[i.toString()] = [];
        }
      }

      PostModel post = PostModel(
        postId: postId,
        authorId: uid,
        content: content,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        likes: [],
        isAnnouncement: isAnnouncement,
        isEvent: isEvent,
        tags: tags,
        isPoll: isPoll,
        pollQuestion: pollQuestion,
        pollOptions: pollOptions,
        pollVotes: pollVotes,
        targetPromotions: targetPromotions, // Ajout du paramètre manquant
        targetFilieres: targetFilieres,     // Ajout du paramètre manquant
      );

      await postRef.set(post.toMap());
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  // Voter dans un sondage
  Future<void> voteOnPoll(String postId, int optionIndex) async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot snap = await _firestore.collection('posts').doc(postId).get();
      Map pollVotes = (snap.data() as Map)['pollVotes'];

      // Retirer l'ancien vote s'il existe
      pollVotes.forEach((key, value) {
        if ((value as List).contains(uid)) {
          (value).remove(uid);
        }
      });

      // Ajouter le nouveau vote
      if (pollVotes.containsKey(optionIndex.toString())) {
        (pollVotes[optionIndex.toString()] as List).add(uid);
      }

      await _firestore.collection('posts').doc(postId).update({
        'pollVotes': pollVotes,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  // --- Autres méthodes (Likes, Posts, Annonces...) ---
  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Stream<List<PostModel>> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => PostModel.fromSnap(doc)).toList();
    });
  }

  Stream<List<PostModel>> getAnnouncements() {
    return _firestore
        .collection('posts')
        .where('isAnnouncement', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PostModel.fromSnap(doc)).toList());
  }

  Stream<List<PostModel>> getEvents() {
    return _firestore
        .collection('posts')
        .where('isEvent', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PostModel.fromSnap(doc)).toList());
  }

  Future<String> deletePost(String postId) async {
    String res = "Une erreur est survenue";
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> postComment(String postId, String content) async {
    String res = "Une erreur est survenue";
    try {
      if (content.isNotEmpty) {
        String uid = _auth.currentUser!.uid;
        DocumentReference commentRef = _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc();

        CommentModel comment = CommentModel(
          commentId: commentRef.id,
          authorId: uid,
          content: content,
          createdAt: DateTime.now(),
        );

        await commentRef.set(comment.toMap());
        res = "success";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Stream<List<CommentModel>> getComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CommentModel.fromSnap(doc)).toList();
    });
  }
}
