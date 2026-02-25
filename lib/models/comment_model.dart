import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId;
  final String authorId;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.commentId,
    required this.authorId,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'authorId': authorId,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CommentModel.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return CommentModel(
      commentId: snapshot['commentId'] ?? '',
      authorId: snapshot['authorId'] ?? '',
      content: snapshot['content'] ?? '',
      createdAt: (snapshot['createdAt'] as Timestamp).toDate(),
    );
  }
}
