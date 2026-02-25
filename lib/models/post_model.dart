import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String authorId;
  final String content;
  final String imageUrl;
  final DateTime createdAt;
  final List likes;
  final bool isAnnouncement;
  final bool isEvent;
  final List<String> tags;
  final bool isPoll;
  final String pollQuestion;
  final List<String> pollOptions;
  final Map<String, dynamic> pollVotes;
  final List<String> targetPromotions; 
  final List<String> targetFilieres;

  PostModel({
    required this.postId,
    required this.authorId,
    required this.content,
    required this.imageUrl,
    required this.createdAt,
    required this.likes,
    this.isAnnouncement = false,
    this.isEvent = false,
    required this.tags,
    this.isPoll = false,
    this.pollQuestion = "",
    this.pollOptions = const [],
    this.pollVotes = const {},
    required this.targetPromotions,
    required this.targetFilieres,
  });

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'authorId': authorId,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
      'isAnnouncement': isAnnouncement,
      'isEvent': isEvent,
      'tags': tags,
      'isPoll': isPoll,
      'pollQuestion': pollQuestion,
      'pollOptions': pollOptions,
      'pollVotes': pollVotes,
      'targetPromotions': targetPromotions,
      'targetFilieres': targetFilieres,
    };
  }

  factory PostModel.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return PostModel(
      postId: snapshot['postId'] ?? '',
      authorId: snapshot['authorId'] ?? '',
      content: snapshot['content'] ?? '',
      imageUrl: snapshot['imageUrl'] ?? '',
      createdAt: (snapshot['createdAt'] != null) 
          ? (snapshot['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      likes: snapshot['likes'] ?? [],
      isAnnouncement: snapshot['isAnnouncement'] ?? false,
      isEvent: snapshot['isEvent'] ?? false,
      tags: snapshot['tags'] != null ? List<String>.from(snapshot['tags']) : [],
      isPoll: snapshot['isPoll'] ?? false,
      pollQuestion: snapshot['pollQuestion'] ?? '',
      pollOptions: snapshot['pollOptions'] != null ? List<String>.from(snapshot['pollOptions']) : [],
      pollVotes: (snapshot['pollVotes'] as Map<String, dynamic>?) ?? {},
      targetPromotions: snapshot['targetPromotions'] != null ? List<String>.from(snapshot['targetPromotions']) : [],
      targetFilieres: snapshot['targetFilieres'] != null ? List<String>.from(snapshot['targetFilieres']) : [],
    );
  }
}
