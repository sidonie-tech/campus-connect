import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../models/comment_model.dart';
import '../services/firestore_service.dart';
import '../services/user_service.dart';
import '../providers/post_provider.dart';
import '../providers/user_provider.dart';
import '../views/profile_screen.dart';
import '../views/post_detail_screen.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
    final firestoreService = FirestoreService();
    final userService = UserService();
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final currentUser = Provider.of<UserProvider>(context).user;

    if (post.postId.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Hero(
      tag: 'post-${post.postId}',
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: post.isAnnouncement ? 4 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: post.isAnnouncement ? Colors.orange : Colors.grey.shade200, width: post.isAnnouncement ? 2 : 1),
            ),
            color: Colors.white,
            surfaceTintColor: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.isAnnouncement)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.campaign, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          "ANNONCE OFFICIELLE",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
        
                FutureBuilder<UserModel>(
                  future: post.authorId.isNotEmpty 
                      ? userService.getUserDetails(post.authorId) 
                      : Future.error("ID vide"),
                  builder: (context, snapshot) {
                    String username = "Utilisateur";
                    String matriculeInfo = "";
                    String roleIcon = "";
                    Color roleColor = Colors.grey;
                    bool isAuthorOnline = false;
                    bool isFriend = false;

                    if (snapshot.hasData) {
                      final author = snapshot.data!;
                      username = author.username;
                      isAuthorOnline = author.isOnline;
                      isFriend = currentUser?.friends.contains(author.uid) ?? false;

                      if (author.matricule != null && author.matricule!.isNotEmpty) {
                        matriculeInfo = " (${author.matricule})";
                      }

                      if (author.role == 'Professeur') {
                        roleIcon = "👨‍🏫";
                        roleColor = Colors.orange;
                      } else if (author.role == 'Administration') {
                        roleIcon = "🏛";
                        roleColor = Colors.red;
                      } else {
                        roleIcon = "🎓";
                        roleColor = Colors.blue;
                      }
                    }
                    
                    return ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: roleColor,
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                          // Indicateur en ligne (Point vert) si amis
                          if (isFriend && isAuthorOnline)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                height: 12,
                                width: 12,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: RichText(
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: username,
                                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: matriculeInfo,
                                    style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (roleIcon.isNotEmpty) Padding(padding: const EdgeInsets.only(left: 4), child: Text(roleIcon)),
                        ],
                      ),
                      subtitle: Text(
                        DateFormat('dd MMM HH:mm').format(post.createdAt),
                        style: const TextStyle(fontSize: 11, color: Colors.black45),
                      ),
                      trailing: post.authorId == currentUserId
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => firestoreService.deletePost(post.postId),
                            )
                          : null,
                    );
                  },
                ),
        
                if (post.content.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      post.content,
                      style: const TextStyle(fontSize: 15, color: Colors.black),
                    ),
                  ),
    
                if (post.isPoll && post.pollOptions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("📊 ${post.pollQuestion}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 8),
                        ...post.pollOptions.asMap().entries.map((e) {
                          List votes = (post.pollVotes[e.key.toString()] as List?) ?? [];
                          bool hasVoted = votes.contains(currentUserId);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: InkWell(
                              onTap: () => postProvider.vote(post.postId, e.key),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: hasVoted ? Colors.blue.withOpacity(0.1) : Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: hasVoted ? Colors.blue : Colors.grey[300]!),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(e.value, style: const TextStyle(color: Colors.black)),
                                    if (hasVoted) const Icon(Icons.check_circle, size: 16, color: Colors.blue),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
        
                if (post.imageUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: CachedNetworkImage(
                      imageUrl: post.imageUrl,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(height: 250, color: Colors.grey[100]),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
        
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          post.likes.contains(currentUserId) ? Icons.favorite : Icons.favorite_border,
                          color: post.likes.contains(currentUserId) ? Colors.red : Colors.black54,
                        ),
                        onPressed: () => firestoreService.likePost(post.postId, currentUserId, post.likes),
                      ),
                      Text('${post.likes.length}', style: const TextStyle(color: Colors.black)),
                      const SizedBox(width: 16),
                      const Icon(Icons.chat_bubble_outline, size: 20, color: Colors.black54),
                      const SizedBox(width: 4),
                      StreamBuilder<List<CommentModel>>(
                        stream: (post.postId.isNotEmpty) ? firestoreService.getComments(post.postId) : const Stream.empty(),
                        builder: (context, snapshot) => Text('${snapshot.data?.length ?? 0}', style: const TextStyle(color: Colors.black)),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.share_outlined, color: Colors.black54),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lien copié !")));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
