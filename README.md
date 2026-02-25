Parfait ! Voici un **README complet et professionnel** que tu peux mettre à la racine de ton projet `campussocial`. Il est conçu pour que **ton équipe puisse cloner le projet, configurer Firebase, et utiliser la même base Firestore** sans problèmes.

---

````markdown
# Campussocial

**CampusLink / Campussocial** est une application Flutter de réseau social interne pour la faculté.  
Elle permet aux utilisateurs (Étudiants, Professeurs, Administration) de se connecter, poster, et gérer des actions spécifiques selon leur rôle.

Le projet utilise **Firebase** pour l’authentification et **Cloud Firestore** pour la base de données.

---

## 🔧 Prérequis

Avant de lancer le projet, assurez-vous d’avoir installé :

- **Flutter** >= 3.10.0  
- **Dart** >= 3.1.0  
- **Firebase CLI** : `npm install -g firebase-tools`  
- **FlutterFire CLI** : `dart pub global activate flutterfire_cli`  

---

## ⚡ Installation du projet

1. **Cloner le projet**

```bash
git clone https://github.com/josehemedi/campussocial.git
cd campussocial
````

2. **Installer les dépendances Flutter**

```bash
flutter pub get
```

3. **Configurer Firebase**

Chaque membre de l’équipe doit configurer Firebase localement pour accéder au même projet `campuslink-25c35`.
Cette étape ne doit **pas** pousser les fichiers secrets sur GitHub.

```bash
flutterfire configure --project campuslink-25c35
```

* Cette commande générera **`lib/firebase_options.dart`** localement.
* Pour Android : ajouter `android/app/google-services.json`
* Pour iOS : ajouter `ios/Runner/GoogleService-Info.plist`

> ⚠️ Ne jamais pousser ces fichiers sur GitHub.

---

## 🗂 Structure du projet

```
lib/
 └─ views/
     ├─ auth/
     │   ├─ login_screen.dart
     │   ├─ register_screen.dart
     │   ├─ forgot_password_screen.dart
     │   └─ home_screen.dart
     └─ ...
```

* `login_screen.dart` : Connexion avec Firebase Auth
* `register_screen.dart` : Création d’utilisateur
* `home_screen.dart` : Tableau de bord selon le rôle de l’utilisateur
* `firebase_options.dart` : Configuration Firebase générée localement

---

## 🔐 Firestore

### Collection `users`

Chaque utilisateur est stocké dans **Firestore** avec les champs suivants :

| Champ   | Description                                       |
| ------- | ------------------------------------------------- |
| `email` | Email de l’utilisateur                            |
| `name`  | Nom complet                                       |
| `role`  | Rôle (`Etudiant`, `Professeur`, `Administration`) |
| `sms`   | Numéro SMS (optionnel)                            |

> ⚠️ **Password** n’est pas stocké en clair. Firebase Auth gère la sécurité.

### Règles Firestore recommandées

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

* Ces règles permettent à tous les utilisateurs authentifiés d’accéder aux données.
* Pour un usage production, adaptez les règles selon les rôles et permissions.

---

## ▶️ Lancer l’application

Pour le **web** :

```bash
flutter run -d chrome
```

Pour **Android/iOS** :

```bash
flutter run
```

---

## 🔄 Flux utilisateur

1. **Inscription (RegisterScreen)** :

    * Crée un utilisateur dans Firebase Auth
    * Ajoute un document dans Firestore `users` avec les informations initiales

2. **Connexion (LoginScreen)** :

    * Authentifie l’utilisateur avec Firebase Auth
    * Récupère les informations depuis Firestore
    * Redirige vers `HomeScreen` adapté au rôle

3. **HomeScreen** :

    * Affiche un tableau de bord personnalisé selon le rôle
    * Étudiant : Devoirs, Crédits
    * Professeur : Corrections, Posts
    * Administration : Approbations, Inscrits

---

## ⚠️ Important pour l’équipe

* Chaque membre doit **configurer Firebase localement**.
* Les fichiers sensibles (`google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`) **ne doivent pas être poussés** sur GitHub.
* Tous les membres doivent utiliser **le même projet Firebase** pour partager les données en temps réel.

---

## 👥 Collaborateurs

Pour travailler ensemble :

1. Cloner le projet.
2. Installer Flutter et dépendances.
3. Configurer Firebase localement.
4. Lancer l’application.

---

## 📝 Auteur

**Jose HEMEDI**
[GitHub](https://github.com/josehemedi)

````

---

## 2️⃣ Commandes pour envoyer ton projet sur GitHub

Si Git n’est pas encore initialisé :

```bash
git init
git add .
git commit -m "Initial commit - projet Campussocial avec README complet"
git remote add origin https://github.com/josehemedi/campussocial.git
git branch -M main
git push -u origin main
````

Si Git est déjà initialisé et que tu veux juste ajouter le README et les derniers changements :

```bash
git add .
git commit -m "Ajout README complet et mise à jour du projet"
git push origin main
```

---

💡 
