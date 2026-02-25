import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../models/post_model.dart';
import '../widgets/post_card.dart';

class AnnouncementListScreen extends StatelessWidget {
  const AnnouncementListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📢 Annonces Officielles', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0056b3), // Bleu de la photo
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: postProvider.announcementsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucune annonce officielle pour le moment.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          List<PostModel> announcements = snapshot.data!;

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              return PostCard(post: announcements[index]);
            },
          );
        },
      ),
    );
  }
}
