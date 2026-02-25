import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/user_service.dart';
import '../widgets/post_card.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;
  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final UserService _userService = UserService();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() async {
    if (_commentController.text.isNotEmpty) {
      await _firestoreService.postComment(
        widget.post.postId,
        _commentController.text.trim(),
      );
      _commentController.clear();
      if (mounted) {
        FocusScope.of(context).unfocus(); // Fermer le clavier
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussion'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  PostCard(post: widget.post),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Commentaires',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  
                  // Liste des commentaires en temps réel
                  StreamBuilder<List<CommentModel>>(
                    stream: _firestoreService.getComments(widget.post.postId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('Soyez le premier à commenter !', style: TextStyle(color: Colors.grey)),
                        );
                      }

                      List<CommentModel> comments = snapshot.data!;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          CommentModel comment = comments[index];
                          return FutureBuilder<UserModel>(
                            future: _userService.getUserDetails(comment.authorId),
                            builder: (context, userSnap) {
                              String name = "Chargement...";
                              if (userSnap.hasData) name = userSnap.data!.username;
                              
                              return ListTile(
                                leading: const CircleAvatar(
                                  radius: 15,
                                  child: Icon(Icons.person, size: 15),
                                ),
                                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(comment.content, style: const TextStyle(color: Colors.black87)),
                                    Text(
                                      DateFormat('dd/MM HH:mm').format(comment.createdAt),
                                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Barre de saisie de commentaire
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, -1),
                    blurRadius: 5,
                    color: Colors.black.withOpacity(0.05),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Ajouter un commentaire...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _addComment,
                    icon: const Icon(Icons.send, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
