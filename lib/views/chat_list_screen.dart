import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'chat_screen.dart';
import 'user_list_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final userService = UserService();
    final currentUser = Provider.of<UserProvider>(context).user;
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    if (currentUser == null) return const Scaffold(backgroundColor: Colors.white, body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chats', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 24)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(icon: const Icon(Icons.camera_alt_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // --- BARRE DE RECHERCHE ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.black),
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Recherche',
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          // --- AMIS EN LIGNE (Horizontal) ---
          StreamBuilder<List<UserModel>>(
            stream: userService.getAllUsers(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              
              final onlineFriends = snapshot.data!.where((u) => 
                currentUser.friends.contains(u.uid) && u.isOnline
              ).toList();

              if (onlineFriends.isEmpty) return const SizedBox.shrink();

              return Container(
                height: 110,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16),
                  itemCount: onlineFriends.length,
                  itemBuilder: (context, index) {
                    final friend = onlineFriends[index];
                    return _buildOnlineAvatar(context, friend, chatProvider);
                  },
                ),
              );
            },
          ),

          // --- LISTE DES DISCUSSIONS ---
          Expanded(
            child: StreamBuilder<List<ChatModel>>(
              stream: chatProvider.myChatsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Aucune discussion.', style: TextStyle(color: Colors.grey)));
                }

                List<ChatModel> chats = snapshot.data!;

                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    ChatModel chat = chats[index];
                    String otherUserId = chat.participants.firstWhere((id) => id != currentUserId);

                    return FutureBuilder<UserModel>(
                      future: userService.getUserDetails(otherUserId),
                      builder: (context, userSnap) {
                        if (!userSnap.hasData) return const SizedBox.shrink();
                        final otherUser = userSnap.data!;

                        if (_searchQuery.isNotEmpty && !otherUser.username.toLowerCase().contains(_searchQuery)) {
                          return const SizedBox.shrink();
                        }

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: otherUser.photoUrl.isNotEmpty ? NetworkImage(otherUser.photoUrl) : null,
                                child: otherUser.photoUrl.isEmpty ? Text(otherUser.username[0].toUpperCase(), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)) : null,
                              ),
                              if (otherUser.isOnline)
                                Positioned(
                                  right: 0, bottom: 0,
                                  child: Container(
                                    height: 16, width: 16,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                            otherUser.username, 
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16)
                          ),
                          subtitle: Text(
                            chat.lastMessage.isNotEmpty ? chat.lastMessage : "Dites bonjour !",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: Text(
                            DateFormat('HH:mm').format(chat.updatedAt),
                            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ChatScreen(chatId: chat.chatId)),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UserListScreen())),
        backgroundColor: Colors.blue[900],
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }

  Widget _buildOnlineAvatar(BuildContext context, UserModel user, ChatProvider chatProvider) {
    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: InkWell(
        onTap: () async {
          // Créer ou obtenir la conversation dès le clic
          String chatId = await chatProvider.startChatWithUser(user.uid);
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatScreen(chatId: chatId)),
            );
          }
        },
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[100],
                  backgroundImage: (user.photoUrl.isNotEmpty) ? NetworkImage(user.photoUrl) : null,
                  child: (user.photoUrl.isEmpty) ? Text(user.username[0].toUpperCase(), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)) : null,
                ),
                if (user.isOnline)
                  Positioned(
                    right: 2, bottom: 2,
                    child: Container(
                      height: 15, width: 15,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 65,
              child: Text(
                user.username, 
                textAlign: TextAlign.center,
                maxLines: 1, 
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black87, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
