import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../providers/user_provider.dart';
import '../models/post_model.dart';
import 'create_post_screen.dart';
import 'chat_list_screen.dart';
import 'profile_screen.dart';
import 'announcement_list_screen.dart';
import 'event_list_screen.dart';
import 'connections_screen.dart';
import '../widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _showTopAlert = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusConnect', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Rechercher sur le campus...',
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                hintStyle: const TextStyle(color: Colors.white70),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatListScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(userProvider.user?.username ?? 'Chargement...'),
              accountEmail: Text(userProvider.user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  (userProvider.user?.username.isNotEmpty == true) 
                      ? userProvider.user!.username.substring(0, 1).toUpperCase() 
                      : '?',
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
              decoration: BoxDecoration(color: Colors.blue[900]),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Fil d\'actualités'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.people_outline, color: Colors.blue),
              title: const Text('Connexions / Amis'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ConnectionsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.campaign, color: Colors.orange),
              title: const Text('📢 Annonces Officielles'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AnnouncementListScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.event, color: Colors.blue),
              title: const Text('📅 Événements'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EventListScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Mon Profil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Déconnexion'),
              onTap: () {
                Navigator.pop(context);
                authProvider.signOut();
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await userProvider.refreshUser();
        },
        child: Column(
          children: [
            // BARRE D'ALERTE DYNAMIQUE SÉCURISÉE
            if (_showTopAlert && _searchQuery.isEmpty)
              StreamBuilder<List<PostModel>>(
                stream: postProvider.announcementsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  
                  final announcements = snapshot.data!;
                  if (announcements.isEmpty) return const SizedBox.shrink();
                  
                  final latestAnnouncement = announcements[0];

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Nouvelle annonce !", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(latestAnnouncement.content, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _showTopAlert = false),
                        )
                      ],
                    ),
                  );
                },
              ),
            
            Expanded(
              child: StreamBuilder<List<PostModel>>(
                stream: postProvider.postsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Erreur lors du chargement des publications.'));
                  }

                  List<PostModel> posts = snapshot.data ?? [];

                  // --- LOGIQUE DE FILTRAGE PAR AUDIENCE (NOUVEAU) ---
                  if (currentUser != null && currentUser.role == 'Etudiant') {
                    posts = posts.where((post) {
                      // Un post s'affiche si :
                      // 1. Il est Tout Public (listes cibles vides)
                      bool isPublic = post.targetPromotions.isEmpty && post.targetFilieres.isEmpty;
                      
                      // 2. Ou si l'étudiant fait partie de la promo cible
                      bool isMyPromo = post.targetPromotions.contains(currentUser.promotion);
                      
                      // 3. Ou si l'étudiant fait partie de la filière cible
                      bool isMyFiliere = post.targetFilieres.contains(currentUser.filiere);
                      
                      // 4. Les professeurs et admins voient toujours tout (déjà géré par le rôle)
                      // Pour un étudiant, on applique le filtre :
                      return isPublic || isMyPromo || isMyFiliere;
                    }).toList();
                  }

                  // Filtrage par recherche (déjà existant)
                  if (_searchQuery.isNotEmpty) {
                    posts = posts.where((post) => post.content.toLowerCase().contains(_searchQuery)).toList();
                  }

                  if (posts.isEmpty) {
                    return const Center(child: Text('Aucun post correspondant à votre profil.'));
                  }

                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) => PostCard(post: posts[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePostScreen()));
        },
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        label: const Text('Publier'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
