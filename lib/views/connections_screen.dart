import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../providers/friend_provider.dart';
import '../providers/user_provider.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  final Set<String> _hiddenUserIds = {};

  @override
  Widget build(BuildContext context) {
    final userService = UserService();
    final friendProvider = Provider.of<FriendProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.user;

    if (currentUser == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Connexions / Amis', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Découvrir'),
              Tab(text: 'Demandes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- ONGLET DÉCOUVRIR ---
            StreamBuilder<List<UserModel>>(
              stream: userService.getAllUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final users = snapshot.data!.where((u) => !_hiddenUserIds.contains(u.uid)).toList();
                
                if (users.isEmpty) return const Center(child: Text("Plus de suggestions."));

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    bool isFriend = currentUser.friends.contains(user.uid);
                    bool hasSent = currentUser.friendRequestsSent.contains(user.uid);
                    bool hasReceived = currentUser.friendRequestsReceived.contains(user.uid);

                    return _buildUserCard(
                      context: context,
                      user: user,
                      isFriend: isFriend,
                      hasSent: hasSent,
                      hasReceived: hasReceived,
                      onPrimaryTap: () async {
                        if (hasSent) {
                          await friendProvider.cancelRequest(user.uid);
                        } else if (!isFriend) {
                          await friendProvider.sendRequest(user.uid);
                        }
                        userProvider.refreshUser();
                      },
                      onDeleteSuggestion: () => setState(() => _hiddenUserIds.add(user.uid)),
                      onAccept: () async {
                        await friendProvider.acceptRequest(user.uid);
                        userProvider.refreshUser();
                      },
                      onRefuse: () async {
                        await friendProvider.refuseRequest(user.uid);
                        userProvider.refreshUser();
                      },
                    );
                  },
                );
              },
            ),

            // --- ONGLET DEMANDES ---
            StreamBuilder<List<UserModel>>(
              stream: userService.getAllUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final incomingRequests = snapshot.data!.where((u) => currentUser.friendRequestsReceived.contains(u.uid)).toList();
                
                if (incomingRequests.isEmpty) return const Center(child: Text("Aucune demande en attente."));

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: incomingRequests.length,
                  itemBuilder: (context, index) {
                    final user = incomingRequests[index];
                    return _buildUserCard(
                      context: context,
                      user: user,
                      isFriend: false,
                      hasSent: false,
                      hasReceived: true,
                      onPrimaryTap: () {},
                      onDeleteSuggestion: () {},
                      onAccept: () async {
                        await friendProvider.acceptRequest(user.uid);
                        userProvider.refreshUser();
                      },
                      onRefuse: () async {
                        await friendProvider.refuseRequest(user.uid);
                        userProvider.refreshUser();
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard({
    required BuildContext context,
    required UserModel user,
    required bool isFriend,
    required bool hasSent,
    required bool hasReceived,
    required VoidCallback onPrimaryTap,
    required VoidCallback onDeleteSuggestion,
    required VoidCallback onAccept,
    required VoidCallback onRefuse,
  }) {
    // Sécurité sur le nom pour éviter l'erreur RangeError
    String name = user.username.isEmpty ? "Utilisateur" : user.username;
    String initial = name[0].toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[200],
            backgroundImage: user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
            child: user.photoUrl.isEmpty ? Text(initial, style: const TextStyle(fontSize: 24, color: Colors.blue)) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                if (hasSent) ...[
                  const Text("Invitation envoyée", style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: onPrimaryTap,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], foregroundColor: Colors.black, elevation: 0),
                      child: const Text("Annuler l'invitation", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ] else if (isFriend) ...[
                  const Text("Vous êtes maintenant ami(e)s.", style: TextStyle(fontSize: 14, color: Colors.grey)),
                ] else if (hasReceived) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onAccept,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, elevation: 0),
                          child: const Text("Confirmer"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onRefuse,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], foregroundColor: Colors.black, elevation: 0),
                          child: const Text("Supprimer"),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onPrimaryTap,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, elevation: 0),
                          child: const Text("Ajouter ami(e)"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onDeleteSuggestion,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], foregroundColor: Colors.black, elevation: 0),
                          child: const Text("Supprimer"),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
