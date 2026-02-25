import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _matriculeController = TextEditingController(); // Nouveau
  
  String _selectedRole = 'Etudiant';
  String? _selectedPromo;
  String? _selectedFiliere;

  final List<String> _promotions = ['L1', 'L2', 'L3', 'L4'];
  
  List<String> _getFilieresForPromo(String? promo) {
    if (promo == 'L1' || promo == 'L2') {
      return ['Informatique Générale'];
    } else if (promo == 'L3' || promo == 'L4') {
      return ['Réseaux', 'Sécurité Informatique', 'Ingénierie Logiciel', 'Data Science', 'Robotique'];
    }
    return [];
  }

  void _signUp() async {
    final authProvider = context.read<AuthProvider>();
    
    if (_selectedRole == 'Etudiant' && (_selectedPromo == null || _selectedFiliere == null || _matriculeController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs (Matricule, Promo, Filière)')),
      );
      return;
    }

    bool success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      username: _usernameController.text.trim(),
      role: _selectedRole,
      promotion: _selectedRole == 'Etudiant' ? _selectedPromo : null,
      filiere: _selectedRole == 'Etudiant' ? _selectedFiliere : null,
      matricule: _selectedRole == 'Etudiant' ? _matriculeController.text.trim().toUpperCase() : null, // Nouveau
    );

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inscription réussie !')));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authProvider.errorMessage ?? "Erreur")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Nom complet', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email académique', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mot de passe', border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Je suis un...', border: OutlineInputBorder()),
                items: ['Etudiant', 'Professeur', 'Administration'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (val) => setState(() {
                  _selectedRole = val!;
                  _selectedPromo = null;
                  _selectedFiliere = null;
                }),
              ),
              
              if (_selectedRole == 'Etudiant') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _matriculeController,
                  decoration: const InputDecoration(
                    labelText: 'N° Matricule',
                    hintText: 'Ex: 2024-INF-001',
                    helperText: 'Format: ANNEE-FILIERE-NUMERO',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedPromo,
                  decoration: const InputDecoration(labelText: 'Promotion', border: OutlineInputBorder()),
                  items: _promotions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (val) => setState(() {
                    _selectedPromo = val;
                    _selectedFiliere = null;
                  }),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedFiliere,
                  decoration: const InputDecoration(labelText: 'Filière', border: OutlineInputBorder()),
                  items: _getFilieresForPromo(_selectedPromo).map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                  onChanged: (val) => setState(() => _selectedFiliere = val),
                ),
              ],
              
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: authProvider.isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                child: authProvider.isLoading ? const CircularProgressIndicator() : const Text('S\'inscrire'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
