import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'profile_screen.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final UserService _userService = UserService();

  // États pour la simulation du vocal
  bool _isRecording = false;
  int _recordDuration = 0;
  Timer? _timer;

  @override
  void dispose() {
    _messageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _recordDuration++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _recordDuration = 0);
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _sendMessage(bool areFriends, {String? content, String type = 'text'}) async {
    if (!areFriends) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vous devez être amis pour envoyer un message.")));
      return;
    }
    
    final message = content ?? _messageController.text.trim();
    if (message.isNotEmpty) {
      await context.read<ChatProvider>().sendMessage(widget.chatId, message, type: type);
      _messageController.clear();
    }
  }

  // Simulation du menu Plus
  void _showPlusMenu(bool areFriends) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
              title: const Text("Envoyer un fichier", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _sendMessage(areFriends, content: "📄 Document envoyé", type: 'file');
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.blue),
              title: const Text("Ma position", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _sendMessage(areFriends, content: "📍 Position partagée", type: 'text');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage(bool fromCamera, bool areFriends) async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: fromCamera ? ImageSource.camera : ImageSource.gallery);
    if (file != null) {
      _sendMessage(areFriends, content: "📷 Photo envoyée", type: 'image');
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final currentUser = Provider.of<UserProvider>(context).user;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: StreamBuilder<ChatModel>(
          stream: FirebaseFirestore.instance.collection('chats').doc(widget.chatId).snapshots().map((doc) => ChatModel.fromSnap(doc)),
          builder: (context, chatSnap) {
            if (!chatSnap.hasData) return const Text("");
            String otherUserId = chatSnap.data!.participants.firstWhere((id) => id != currentUserId);
            return FutureBuilder<UserModel>(
              future: _userService.getUserDetails(otherUserId),
              builder: (context, userSnap) => Text(userSnap.data?.username ?? "Chat", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            );
          }
        ),
      ),
      body: StreamBuilder<ChatModel>(
        stream: FirebaseFirestore.instance.collection('chats').doc(widget.chatId).snapshots().map((doc) => ChatModel.fromSnap(doc)),
        builder: (context, chatSnap) {
          if (!chatSnap.hasData) return const Center(child: CircularProgressIndicator());
          String otherUserId = chatSnap.data!.participants.firstWhere((id) => id != currentUserId);

          return FutureBuilder<UserModel>(
            future: _userService.getUserDetails(otherUserId),
            builder: (context, userSnap) {
              if (!userSnap.hasData) return const Center(child: CircularProgressIndicator());
              final otherUser = userSnap.data!;
              bool areFriends = currentUser?.friends.contains(otherUserId) ?? false;

              return Column(
                children: [
                  Expanded(
                    child: StreamBuilder<List<MessageModel>>(
                      stream: chatProvider.getMessagesStream(widget.chatId),
                      builder: (context, msgSnap) {
                        if (!msgSnap.hasData || msgSnap.data!.isEmpty) return _buildHeader(otherUser, areFriends);
                        return ListView.builder(
                          reverse: true,
                          itemCount: msgSnap.data!.length,
                          itemBuilder: (context, index) {
                            final message = msgSnap.data![index];
                            bool isMe = message.senderId == currentUserId;
                            return _buildMessageItem(message, isMe);
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    color: Colors.black,
                    child: _isRecording ? _buildRecordingBar(areFriends) : _buildInputBar(areFriends),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInputBar(bool areFriends) {
    return Row(
      children: [
        IconButton(icon: const Icon(Icons.add_circle, color: Colors.blue, size: 28), onPressed: () => _showPlusMenu(areFriends)),
        IconButton(icon: const Icon(Icons.camera_alt, color: Colors.blue, size: 28), onPressed: () => _pickImage(true, areFriends)),
        IconButton(icon: const Icon(Icons.photo, color: Colors.blue, size: 28), onPressed: () => _pickImage(false, areFriends)),
        IconButton(icon: const Icon(Icons.mic, color: Colors.blue, size: 28), onPressed: () {
          setState(() => _isRecording = true);
          _startTimer();
        }),
        Expanded(
          child: Container(
            decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(25)),
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'Message...', hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
            ),
          ),
        ),
        IconButton(onPressed: () => _sendMessage(areFriends), icon: const Icon(Icons.send, color: Colors.blue, size: 28)),
      ],
    );
  }

  Widget _buildRecordingBar(bool areFriends) {
    return Row(
      children: [
        IconButton(icon: const Icon(Icons.delete, color: Colors.blue), onPressed: () {
          _stopTimer();
          setState(() => _isRecording = false);
        }),
        Expanded(
          child: Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(25)),
            child: Row(
              children: [
                const Icon(Icons.pause_circle_filled, color: Colors.white, size: 30),
                const SizedBox(width: 8),
                const Expanded(child: Text("••••••••••••••••••••••••••••••••", style: TextStyle(color: Colors.white, letterSpacing: 2), overflow: TextOverflow.ellipsis)),
                Text(_formatDuration(_recordDuration), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        IconButton(icon: const Icon(Icons.send, color: Colors.blue, size: 30), onPressed: () {
          _sendMessage(areFriends, content: "🎤 Vocal envoyé (${_formatDuration(_recordDuration)})", type: 'audio');
          _stopTimer();
          setState(() => _isRecording = false);
        }),
      ],
    );
  }

  Widget _buildHeader(UserModel otherUser, bool areFriends) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          CircleAvatar(radius: 50, backgroundImage: otherUser.photoUrl.isNotEmpty ? NetworkImage(otherUser.photoUrl) : null, child: otherUser.photoUrl.isEmpty ? Text(otherUser.username.isNotEmpty ? otherUser.username[0].toUpperCase() : "?", style: const TextStyle(fontSize: 32)) : null),
          const SizedBox(height: 12),
          Text(otherUser.username, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          Text("@${otherUser.username.toLowerCase().replaceAll(' ', '.')}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          Text(areFriends ? "Vous êtes ami(e)s sur CampusConnect" : "Pas encore amis", style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())), style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[900], foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text("Voir le profil")),
        ],
      ),
    );
  }

  Widget _buildMessageItem(MessageModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey[850],
              borderRadius: BorderRadius.circular(20),
            ),
            child: _buildMessageContent(message),
          ),
          if (isMe)
            const Padding(
              padding: EdgeInsets.only(right: 20, bottom: 4),
              child: Text("Envoyé", style: TextStyle(color: Colors.grey, fontSize: 10)),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(MessageModel message) {
    if (message.type == 'image') {
      return Container(
        padding: const EdgeInsets.all(12),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.image, color: Colors.white), SizedBox(width: 8), Text("Photo", style: TextStyle(color: Colors.white))]),
      );
    } else if (message.type == 'audio') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        width: 200,
        child: Row(
          children: [
            const Icon(Icons.play_arrow, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Expanded(child: LinearProgressIndicator(value: 0.5, backgroundColor: Colors.white.withOpacity(0.3), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
            const SizedBox(width: 8),
            const Text("0:05", style: TextStyle(color: Colors.white, fontSize: 10)),
          ],
        ),
      );
    } else if (message.type == 'file') {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.insert_drive_file, color: Colors.white), const SizedBox(width: 8), Text(message.content, style: const TextStyle(color: Colors.white))]),
      );
    }
    return Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14), child: Text(message.content, style: const TextStyle(color: Colors.white, fontSize: 16)));
  }
}
