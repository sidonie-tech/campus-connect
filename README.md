# 📚 Documentation Technique Complète - Campus Social

## Table des Matières

1. [Presentation du Projet](#1-presentacion-du-projet)
2. [Architecture et Technologies](#2-architecture-et-technologies)
3. [Structure du Projet](#3-structure-du-projet)
4. [Description des Fonctionnalites](#4-description-des-fonctionnalites)
5. [Modeles de Donnees](#5-modeles-de-donnees)
6. [Services](#6-services)
7. [Gestion d'Etat (Providers)](#7-gestion-detat-providers)
8. [Ecrans et Vues](#8-ecrans-et-vues)
9. [Configuration Firebase](#9-configuration-firebase)
10. [Structure de la Base de Donnees Firestore](#10-structure-de-la-base-de-donnees-firestore)
11. [Installation et Configuration](#11-installation-et-configuration)
12. [API et References](#12-api-et-references)

---

## 1. Presentation du Projet

**Campus Social** (appeleegalement **CampusConnect**) est une application mobile de reseau social interne concue pour un environnement universitaire. Elle permet aux etudiants, professeurs et au personnel administratif de l'universite de communiquer, partager du contenu et interagir les uns avec les autres.

### Caracteristiques Principales

- **Publication de contenu**: Creer des posts, annonces, evenements et sondages
- **Messagerie instantanee**: Discuter en temps reel avec d'autres utilisateurs
- **Systeme d'amis**: Ajouter des connexions et gerer les demandes d'amis
- **Ciblage avance**: Cibler les publications par promotion et/ou filiere
- **Gestion des roles**: Differents niveaux d'acces selon le role utilisateur

### Types d'Utilisateurs

| Role | Description | Permissions |
|------|-------------|-------------|
| `Etudiant` | Apprenants de l'universite | Publication, messagerie, amis |
| `Professeur` | Enseignants | Publication avancee, corrections |
| `Administration` | Personnel administratif | Gestion des annonces, approbations |

---

## 2. Architecture et Technologies

### Stack Technique

| Categorie | Technologie | Version |
|-----------|-------------|---------|
| **Framework** | Flutter | >= 3.10.0 |
| **Langage** | Dart | >= 3.1.0 |
| **Backend** | Firebase | - |
| **Authentification** | Firebase Auth | ^4.19.4 |
| **Base de donnees** | Cloud Firestore | ^4.17.3 |
| **Stockage** | Firebase Storage | ^11.7.5 |
| **Gestion d'etat** | Provider | ^6.1.2 |
| **UI** | Material Design 3 | - |

### Architecture MVVM

Le projet suit le pattern **Model-View-ViewModel (MVVM)** avec une separation claire des responsabilites:

```
┌─────────────────────────────────────────────────────────┐
│                      VUES (UI)                          │
│   ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐  │
│   │ LoginScreen │ │ HomeScreen  │ │ CreatePostScreen│  │
│   └─────────────┘ └─────────────┘ └─────────────────┘  │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                    PROVIDERS (ViewModels)               │
│   ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐  │
│   │AuthProvider │ │PostProvider │ │  ChatProvider   │  │
│   └─────────────┘ └─────────────┘ └─────────────────┘  │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                    SERVICES (Model)                     │
│   ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐  │
│   │AuthService  │ │FirestoreServ│ │  ChatService    │  │
│   └─────────────┘ └─────────────┘ └─────────────────┘  │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                      FIREBASE                           │
│  ┌──────────────┐  ┌─────────────┐  ┌──────────────┐  │
│  │Firebase Auth │  │Cloud Firest. │  │Firebase Stor.│  │
│  └──────────────┘  └─────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## 3. Structure du Projet

```
lib/
├── main.dart                         # Point d'entree de l'application
├── firebase_options.dart             # Configuration Firebase (generee)
│
├── models/                           # Modeles de donnees
│   ├── user_model.dart               # Modele utilisateur
│   ├── post_model.dart               # Modele publication
│   ├── chat_model.dart               # Modele conversation/message
│   ├── comment_model.dart            # Modele commentaire
│   └── quote_model.dart              # Modele citation
│
├── providers/                        # Gestionnaires d'etat (ViewModels)
│   ├── auth_provider.dart            # Authentification
│   ├── post_provider.dart            # Publications
│   ├── user_provider.dart            # Utilisateur actuel
│   ├── chat_provider.dart            # Messagerie
│   ├── friend_provider.dart          # Systeme d'amis
│   └── quote_provider.dart           # Citations
│
├── services/                         # Logique metier (Model layer)
│   ├── auth_service.dart             # Service Authentification
│   ├── firestore_service.dart        # Service Base de donnees
│   ├── user_service.dart             # Service Utilisateur
│   ├── chat_service.dart             # Service Messagerie
│   ├── friend_service.dart           # Service Amis
│   ├── storage_service.dart          # Service Stockage fichiers
│   └── api_service.dart              # Service API externe
│
├── views/                            # Ecrans de l'application
│   ├── auth/
│   │   ├── login_screen.dart          # Ecran de connexion
│   │   └── register_screen.dart       # Ecran d'inscription
│   │
│   ├── home_screen.dart               # Ecran principal
│   ├── create_post_screen.dart        # Creer une publication
│   ├── post_detail_screen.dart       # Detail d'une publication
│   ├── chat_list_screen.dart         # Liste des conversations
│   ├── chat_screen.dart               # Discussion individuelle
│   ├── profile_screen.dart            # Profil utilisateur
│   ├── connections_screen.dart       # Liste des connexions
│   ├── announcement_list_screen.dart # Liste des annonces
│   ├── event_list_screen.dart         # Liste des evenements
│   └── user_list_screen.dart         # Liste des utilisateurs
│
└── widgets/                          # Composants reutilisables
    └── post_card.dart                 # Carte de publication
```

---

## 4. Description des Fonctionnalites

### 4.1 Authentification

L'application utilise **Firebase Authentication** pour gerer les utilisateurs:

- **Inscription**: Creation de compte avec email/mot de passe
- **Connexion**: Authentification avec identifiants
- **Gestion du role**: Specification du role lors de l'inscription
- **Matricule etudiant**: Format obligatoire `AAAA-XXX-XXX` (ex: `2024-INF-001`)

### 4.2 Systeme de Publications

Les utilisateurs peuvent creer differents types de contenu:

| Type | Description | Caracteristiques |
|------|-------------|------------------|
| **Post** | Publication standard | Texte, image, tags |
| **Annonce** | Information importante | Visible uniquement par cible |
| **Evenement** | Activite campus | Date, description |
| **Sondage** | Question avec options | Votes multiples |

### 4.3 Ciblage des Publications

Les publications peuvent etre ciblees par:

- **Promotions**: L1, L2, L3, L4
- **Filieres**: Informatique Generale, Reseaux, Securite, etc.

### 4.4 Messagerie

- **Conversations privees**: Echange entre deux utilisateurs
- **Messages**: Texte, images (support prepare)
- **Temps reel**: Mise a jour instantanee via Firestore

### 4.5 Systeme d'Amis

- **Demande d'ami**: Envoyer une requete
- **Accepter/Refuser**: Gerer les requetes recues
- **Liste d'amis**: Voir toutes ses connexions

---

## 5. Modeles de Donnees

### 5.1 UserModel ([`lib/models/user_model.dart`](lib/models/user_model.dart))

```dart
class UserModel {
  final String uid;                    // ID unique Firebase
  final String username;                // Nom d'utilisateur
  final String email;                   // Email universitaire
  final String photoUrl;                // URL de la photo de profil
  final String bio;                     // Biographie
  final String role;                    // 'Etudiant', 'Professeur', 'Administration'
  final String? promotion;             // Promotion (ex: 'L3')
  final String? filiere;                // Filiere (ex: 'Informatique')
  final String? matricule;               // Matricule etudiant
  final List<String> friends;           // Liste des IDs amis
  final List<String> friendRequestsSent;    // Demandes envoyees
  final List<String> friendRequestsReceived; // Demandes recues
  final bool isOnline;                   // Statut de connexion
  final DateTime createdAt;              // Date de creation
}
```

### 5.2 PostModel ([`lib/models/post_model.dart`](lib/models/post_model.dart))

```dart
class PostModel {
  final String postId;                  // ID unique de la publication
  final String authorId;                // ID de l'auteur
  final String content;                 // Contenu textuel
  final String imageUrl;                // URL de l'image (si presente)
  final DateTime createdAt;             // Date de creation
  final List likes;                     // Liste des IDs ayant liké
  final bool isAnnouncement;            // Est-ce une annonce?
  final bool isEvent;                   // Est-ce un evenement?
  final List<String> tags;               // Tags de la publication
  final bool isPoll;                    // Est-ce un sondage?
  final String pollQuestion;            // Question du sondage
  final List<String> pollOptions;        // Options de vote
  final Map<String, dynamic> pollVotes;  // Votes par option
  final List<String> targetPromotions;   // Promotions ciblees
  final List<String> targetFilieres;     // Filieres ciblees
}
```

### 5.3 ChatModel ([`lib/models/chat_model.dart`](lib/models/chat_model.dart))

```dart
class ChatModel {
  final String chatId;                  // ID de la conversation
  final List<String> participants;      // IDs des participants
  final String lastMessage;             // Dernier message
  final DateTime updatedAt;             // Date de mise a jour
}

class MessageModel {
  final String messageId;               // ID du message
  final String senderId;                // ID de l'expediteur
  final String content;                 // Contenu du message
  final String type;                    // 'text', 'image', 'audio', 'file'
  final DateTime timestamp;             // Horodatage
}
```

### 5.4 CommentModel ([`lib/models/comment_model.dart`](lib/models/comment_model.dart))

```dart
class CommentModel {
  final String commentId;               // ID du commentaire
  final String authorId;                // ID de l'auteur
  final String content;                 // Contenu du commentaire
  final DateTime createdAt;             // Date de creation
}
```

---

## 6. Services

### 6.1 AuthService ([`lib/services/auth_service.dart`](lib/services/auth_service.dart))

Gestion de l'authentification Firebase.

**Methodes principales:**

| Methode | Description |
|---------|-------------|
| `signUpUser()` | Creer un nouvel utilisateur |
| `loginUser()` | Connecter un utilisateur |
| `logoutUser()` | Deconnecter l'utilisateur |
| `isMatriculeUnique()` | Verifier l'unicite du matricule |
| `currentUser` | Obtenir l'utilisateur actuel |

### 6.2 FirestoreService ([`lib/services/firestore_service.dart`](lib/services/firestore_service.dart))

Gestion des operations Firestore pour les publications.

**Methodes principales:**

| Methode | Description |
|---------|-------------|
| `uploadPost()` | Creer une nouvelle publication |
| `likePost()` | Ajouter/retirer un like |
| `voteOnPoll()` | Voter dans un sondage |
| `addComment()` | Ajouter un commentaire |
| `getPosts()` | Recuperer les publications |
| `deletePost()` | Supprimer une publication |

### 6.3 UserService ([`lib/services/user_service.dart`](lib/services/user_service.dart))

Gestion des donnees utilisateur.

**Methodes principales:**

| Methode | Description |
|---------|-------------|
| `getUserDetails()` | Recuperer les details d'un utilisateur |
| `getAllUsers()` | Recuperer tous les utilisateurs |
| `updateProfile()` | Mettre a jour le profil |

### 6.4 ChatService ([`lib/services/chat_service.dart`](lib/services/chat_service.dart))

Gestion de la messagerie.

**Methodes principales:**

| Methode | Description |
|---------|-------------|
| `createOrGetChat()` | Creer/obtenir une conversation |
| `sendMessage()` | Envoyer un message |
| `getMessages()` | Recuperer les messages en temps reel |
| `getMyChats()` | Recuperer les conversations de l'utilisateur |

### 6.5 FriendService ([`lib/services/friend_service.dart`](lib/services/friend_service.dart))

Gestion du systeme d'amis.

**Methodes principales:**

| Methode | Description |
|---------|-------------|
| `sendFriendRequest()` | Envoyer une demande d'ami |
| `cancelFriendRequest()` | Annuler une demande |
| `acceptFriendRequest()` | Accepter une demande |
| `refuseFriendRequest()` | Refuser une demande |
| `removeFriend()` | Retirer un ami |

### 6.6 StorageService ([`lib/services/storage_service.dart`](lib/services/storage_service.dart))

Gestion du stockage Firebase pour les images.

**Methodes principales:**

| Methode | Description |
|---------|-------------|
| `uploadImageToStorage()` | Uploader une image vers Firebase Storage |

---

## 7. Gestion d'Etat (Providers)

L'application utilise **Provider** pour la gestion d'etat reactif.

### 7.1 AuthProvider ([`lib/providers/auth_provider.dart`](lib/providers/auth_provider.dart))

```dart
class AuthProvider with ChangeNotifier {
  User? _user;              // Utilisateur actuel
  bool _isLoading;          // Indicateur de chargement
  String? _errorMessage;    // Message d'erreur
  
  // Proprietes
  User? get user;
  bool get isLoading;
  String? get errorMessage;
  
  // Methodes
  Future<bool> signUp({...});
  Future<bool> login({...});
  Future<void> logout();
}
```

### 7.2 PostProvider ([`lib/providers/post_provider.dart`](lib/providers/post_provider.dart))

Gestion des publications et du contenu.

```dart
class PostProvider with ChangeNotifier {
  bool _isLoading;
  String? _errorMessage;
  
  // Methodes
  Future<bool> addPost(String content, Uint8List? file, {...});
  // ... autres methodes
}
```

### 7.3 UserProvider ([`lib/providers/user_provider.dart`](lib/providers/user_provider.dart))

Gestion du profil utilisateur.

```dart
class UserProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading;
  
  // Methodes
  Future<void> refreshUser();
  Future<bool> updateProfile({...});
}
```

### 7.4 ChatProvider ([`lib/providers/chat_provider.dart`](lib/providers/chat_provider.dart))

Gestion de la messagerie.

```dart
class ChatProvider with ChangeNotifier {
  Stream<List<ChatModel>> get myChatsStream;
  Stream<List<MessageModel>> getMessagesStream(String chatId);
  Future<void> sendMessage(String chatId, String content, {String type});
  Future<String> startChatWithUser(String otherUserId);
}
```

### 7.5 FriendProvider ([`lib/providers/friend_provider.dart`](lib/providers/friend_provider.dart))

Gestion des relations d'amitie.

```dart
class FriendProvider with ChangeNotifier {
  // Methodes pour gerer les demandes d'amis
  Future<void> sendRequest(String userId);
  Future<void> acceptRequest(String userId);
  Future<void> refuseRequest(String userId);
  Future<void> removeFriend(String userId);
}
```

---

## 8. Ecrans et Vues

### 8.1 Ecrans d'Authentification

#### LoginScreen ([`lib/views/auth/login_screen.dart`](lib/views/auth/login_screen.dart))
- Formulaire de connexion email/mot de passe
- Navigation vers l'inscription

#### RegisterScreen ([`lib/views/auth/register_screen.dart`](lib/views/auth/register_screen.dart))
- Formulaire d'inscription avec:
  - Email, mot de passe
  - Nom d'utilisateur
  - Selection du role (Etudiant/Professeur/Administration)
  - Promotion et filiere (pour etudiants)
  - Matricule (format: `AAAA-XXX-XXX`)

### 8.2 Ecrans Principaux

#### HomeScreen ([`lib/views/home_screen.dart`](lib/views/home_screen.dart))
- Barre de recherche
- Liste des publications
- Navigation laterale (Drawer)
- Acces rapide a la messagerie

#### CreatePostScreen ([`lib/views/create_post_screen.dart`](lib/views/create_post_screen.dart))
- Creation de publication avec options:
  - Type: Post, Annonce, Evenement, Sondage
  - Contenu textuel
  - Image (camera/galerie)
  - Tags
  - Ciblage par promotion/filiere
  - Options de sondage (si type sondage)

#### PostDetailScreen ([`lib/views/post_detail_screen.dart`](lib/views/post_detail_screen.dart))
- Detail d'une publication
- Systeme de likes
- Commentaires

### 8.3 Ecrans de Communication

#### ChatListScreen ([`lib/views/chat_list_screen.dart`](lib/views/chat_list_screen.dart))
- Liste des conversations
- Apercu du dernier message

#### ChatScreen ([`lib/views/chat_screen.dart`](lib/views/chat_screen.dart))
- Discussion avec un utilisateur
- Envoi de messages
- Affichage temps reel

### 8.4 Ecrans de Profil et Connexions

#### ProfileScreen ([`lib/views/profile_screen.dart`](lib/views/profile_screen.dart))
- Informations du profil
- Modification du profil (photo, bio)

#### ConnectionsScreen ([`lib/views/connections_screen.dart`](lib/views/connections_screen.dart))
- Liste des amis
- Demandes d'amis recues
- Suggestions de connexions

### 8.5 Ecrans d'Informations

#### AnnouncementListScreen ([`lib/views/announcement_list_screen.dart`](lib/views/announcement_list_screen.dart))
- Liste des annonces
- Filtrage par cible

#### EventListScreen ([`lib/views/event_list_screen.dart`](lib/views/event_list_screen.dart))
- Liste des evenements

#### UserListScreen ([`lib/views/user_list_screen.dart`](lib/views/user_list_screen.dart))
- Liste de tous les utilisateurs
- Recherche d'utilisateurs

---

## 9. Configuration Firebase

### 9.1 Installation de Firebase CLI

```bash
# Installer Node.js (si non present)
# puis installer Firebase CLI
npm install -g firebase-tools

# Installer FlutterFire CLI
dart pub global activate flutterfire_cli
```

### 9.2 Configuration du Projet

```bash
# Se placer dans le repertoire du projet
cd campussocial

# Configurer Firebase
flutterfire configure --project campuslink-25c35
```

Cette commande:
- Telecharge la configuration pour chaque plateforme
- Genere le fichier `lib/firebase_options.dart`
- Configure les fichiers `google-services.json` (Android) et `GoogleService-Info.plist` (iOS)

### 9.3 Fichiers de Configuration Requis

| Plateforme | Fichier | Emplacement |
|------------|---------|-------------|
| Android | `google-services.json` | `android/app/` |
| iOS | `GoogleService-Info.plist` | `ios/Runner/` |
| Web | genere automatiquement | `lib/firebase_options.dart` |

> ⚠️ **Important**: Ces fichiers ne doivent jamais etre commites sur GitHub. Ajouter les a `.gitignore`.

---

## 10. Structure de la Base de Donnees Firestore

### 10.1 Collections

```
databases (default)
├── users/
│   └── {userId}/
│       ├── uid: string
│       ├── username: string
│       ├── email: string
│       ├── photoUrl: string
│       ├── bio: string
│       ├── role: string
│       ├── promotion: string?
│       ├── filiere: string?
│       ├── matricule: string?
│       ├── friends: string[]
│       ├── friendRequestsSent: string[]
│       ├── friendRequestsReceived: string[]
│       ├── isOnline: boolean
│       └── createdAt: timestamp
│
├── posts/
│   └── {postId}/
│       ├── postId: string
│       ├── authorId: string
│       ├── content: string
│       ├── imageUrl: string
│       ├── createdAt: timestamp
│       ├── likes: string[]
│       ├── isAnnouncement: boolean
│       ├── isEvent: boolean
│       ├── tags: string[]
│       ├── isPoll: boolean
│       ├── pollQuestion: string
│       ├── pollOptions: string[]
│       ├── pollVotes: map
│       ├── targetPromotions: string[]
│       └── targetFilieres: string[]
│
├── chats/
│   └── {chatId}/
│       ├── chatId: string
│       ├── participants: string[]
│       ├── lastMessage: string
│       ├── updatedAt: timestamp
│       └── messages/
│           └── {messageId}/
│               ├── messageId: string
│               ├── senderId: string
│               ├── content: string
│               ├── type: string
│               └── timestamp: timestamp
```

### 10.2 Regles de Securite Firestore Recommandees

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Regles pour les utilisateurs
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null 
                   && request.auth.uid == userId;
    }
    
    // Regles pour les posts
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null 
                            && request.auth.uid == resource.data.authorId;
    }
    
    // Regles pour les chats
    match /chats/{chatId} {
      allow read: if request.auth != null 
                  && request.auth.uid in resource.data.participants;
      allow create: if request.auth != null;
      allow update: if request.auth != null 
                    && request.auth.uid in resource.data.participants;
      
      match /messages/{messageId} {
        allow read, create: if request.auth != null;
      }
    }
  }
}
```

---

## 11. Installation et Configuration

### 11.1 Prérequis

| Outil | Version minimale | Installation |
|-------|-----------------|--------------|
| Flutter | >= 3.10.0 | [flutter.dev](https://flutter.dev) |
| Dart | >= 3.1.0 | Inclus avec Flutter |
| Node.js | >= 14 | [nodejs.org](https://nodejs.org) |
| Firebase CLI | Derniere | `npm install -g firebase-tools` |
| FlutterFire CLI | Derniere | `dart pub global activate flutterfire_cli` |

### 11.2 Installation du Projet

```bash
# 1. Cloner le projet
git clone https://github.com/josehemedi/campussocial.git
cd campussocial

# 2. Installer les dependances
flutter pub get

# 3. Configurer Firebase
flutterfire configure --project campuslink-25c35

# 4. Lancer l'application
flutter run
```

### 11.3 Lancement sur Different Platformes

```bash
# Android
flutter run -d android

# iOS (sur Mac uniquement)
flutter run -d ios

# Web
flutter run -d chrome

# Pour voir les appareils disponibles
flutter devices
```

---

## 12. API et References

### 12.1 Dependances Principales (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.31.0
  firebase_auth: ^4.19.4
  cloud_firestore: ^4.17.3
  firebase_storage: ^11.7.5
  
  # State Management
  provider: ^6.1.2
  
  # Utilities
  http: ^1.2.1
  image_picker: ^1.1.2
  intl: ^0.19.0
  cached_network_image: ^3.3.1
  uuid: ^4.4.0
  path_provider: ^2.1.1
```

### 12.2 Points d'Entree de l'Application

L'application demarre dans [`lib/main.dart`](lib/main.dart):

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => QuoteProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FriendProvider()),
      ],
      child: MaterialApp(
        // Configuration de l'app
      ),
    );
  }
}
```

### 12.3 Flux Utilisateur

```
┌──────────────────┐     ┌──────────────────┐
│   LoginScreen    │────▶│ RegisterScreen   │
└────────┬─────────┘     └──────────────────┘
         │
         ▼
┌──────────────────┐     ┌──────────────────┐
│   HomeScreen     │────▶│CreatePostScreen  │
│   ├─ Posts       │     └──────────────────┘
│   ├─ Annonces    │
│   └─ Evenements  │
         │
         ▼
┌──────────────────┐     ┌──────────────────┐
│  ChatListScreen  │────▶│   ChatScreen     │
└──────────────────┘     └──────────────────┘
         │
         ▼
┌──────────────────┐
│  ProfileScreen   │
└──────────────────┘
```

---

## 📝 A Propos

**Auteur**: Jose HEMEDI  
**GitHub**: [https://github.com/josehemedi](https://github.com/josehemedi)  
**Projet**: Campus Social - Reseau social universitaire

---

## 📋 Checklist de Developpement

- [x] Authentification Firebase
- [x] Inscription/Connexion
- [x] Gestion des roles
- [x] Systeme de publications
- [x] Types de posts (standard, annonce, evenement, sondage)
- [x] Ciblage par promotion/filiere
- [x] Systeme de likes
- [x] Systeme de commentaires
- [x] Messagerie temps reel
- [x] Systeme d'amis
- [x] Profil utilisateur
- [x] Recherche

---

*Documentation generee automatiquement pour le projet Campus Social*
