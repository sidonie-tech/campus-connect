import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../models/post_model.dart';
import '../widgets/post_card.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('📅 Événements du Campus', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0056b3), // Bleu officiel
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: postProvider.eventsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Erreur : L\'index Firestore pour les événements est peut-être en cours de création ou manquant.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_available_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucun événement prévu pour le moment.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          List<PostModel> events = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: events.length,
            itemBuilder: (context, index) {
              return PostCard(post: events[index]);
            },
          );
        },
      ),
    );
  }
}
