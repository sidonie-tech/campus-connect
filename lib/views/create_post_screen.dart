import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../providers/user_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _pollQuestionController = TextEditingController();
  final List<TextEditingController> _pollOptionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  Uint8List? _image;
  bool _isAnnouncement = false;
  bool _isEvent = false;
  bool _isPoll = false;

  // --- NOUVEAU : Multi-sélection de ciblage ---
  final List<String> _selectedPromos = [];
  final List<String> _selectedFilieres = [];

  final List<String> _promotions = ['L1', 'L2', 'L3', 'L4'];
  final List<String> _filieresList = [
    'Informatique Générale',
    'Réseaux',
    'Sécurité Informatique',
    'Ingénierie Logiciel',
    'Data Science',
    'Robotique'
  ];

  @override
  void dispose() {
    _contentController.dispose();
    _tagsController.dispose();
    _pollQuestionController.dispose();
    for (var controller in _pollOptionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      Uint8List img = await file.readAsBytes();
      setState(() {
        _image = img;
      });
    }
  }

  void _addPollOption() {
    if (_pollOptionControllers.length < 5) {
      setState(() {
        _pollOptionControllers.add(TextEditingController());
      });
    }
  }

  void _post(BuildContext context) async {
    final postProvider = context.read<PostProvider>();
    
    List<String> tags = _tagsController.text.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
    List<String> pollOptions = _pollOptionControllers.map((c) => c.text.trim()).where((text) => text.isNotEmpty).toList();

    bool success = await postProvider.addPost(
      _contentController.text.trim(),
      _image,
      isAnnouncement: _isAnnouncement,
      isEvent: _isEvent,
      tags: tags,
      isPoll: _isPoll,
      pollQuestion: _pollQuestionController.text.trim(),
      pollOptions: pollOptions,
      targetPromotions: _selectedPromos, // On envoie la liste des promos cibles
      targetFilieres: _selectedFilieres,   // On envoie la liste des filières cibles
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post publié avec succès !')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(postProvider.errorMessage ?? "Erreur lors du postage")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();
    final userProvider = context.watch<UserProvider>();
    final userRole = userProvider.user?.role;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau Post'),
        actions: [
          TextButton(
            onPressed: postProvider.isLoading ? null : () => _post(context),
            child: const Text('Publier', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: postProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- CIBLAGE MULTI-SÉLECTION (Visible uniquement pour Profs/Admins) ---
                  if (userRole == 'Professeur' || userRole == 'Administration') ...[
                    const Text("Ciblage de l'audience :", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    
                    const Text("Promotions :", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Wrap(
                      spacing: 8,
                      children: _promotions.map((p) => FilterChip(
                        label: Text(p),
                        selected: _selectedPromos.contains(p),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedPromos.add(p);
                            } else {
                              _selectedPromos.remove(p);
                            }
                          });
                        },
                      )).toList(),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    const Text("Filières :", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Wrap(
                      spacing: 8,
                      children: _filieresList.map((f) => FilterChip(
                        label: Text(f),
                        selected: _selectedFilieres.contains(f),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedFilieres.add(f);
                            } else {
                              _selectedFilieres.remove(f);
                            }
                          });
                        },
                      )).toList(),
                    ),
                    
                    if (_selectedPromos.isEmpty && _selectedFilieres.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text("🌍 Tout public (visible par tous)", style: TextStyle(color: Colors.blue, fontStyle: FontStyle.italic)),
                      ),
                    
                    const Divider(height: 32),
                  ],

                  TextField(
                    controller: _contentController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "Un message pour le campus ?",
                      border: InputBorder.none,
                    ),
                  ),
                  const Divider(),
                  
                  TextField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      hintText: "Tags (#Cours, #Examen...)",
                      icon: Icon(Icons.tag, size: 20),
                      border: InputBorder.none,
                    ),
                  ),
                  
                  SwitchListTile(
                    title: const Text("Ajouter un sondage"),
                    secondary: const Icon(Icons.poll_outlined),
                    value: _isPoll,
                    onChanged: (val) => setState(() => _isPoll = val),
                  ),

                  if (_isPoll) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _pollQuestionController,
                      decoration: const InputDecoration(
                        labelText: "Question du sondage",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._pollOptionControllers.asMap().entries.map((entry) {
                      int idx = entry.key;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TextField(
                          controller: entry.value,
                          decoration: InputDecoration(
                            labelText: "Option ${idx + 1}",
                            border: const OutlineInputBorder(),
                            suffixIcon: idx > 1 ? IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => setState(() => _pollOptionControllers.removeAt(idx)),
                            ) : null,
                          ),
                        ),
                      );
                    }).toList(),
                    if (_pollOptionControllers.length < 5)
                      TextButton.icon(
                        onPressed: _addPollOption,
                        icon: const Icon(Icons.add),
                        label: const Text("Ajouter une option"),
                      ),
                  ],

                  const SizedBox(height: 16),

                  if (userRole == 'Professeur' || userRole == 'Administration') ...[
                    CheckboxListTile(
                      title: const Text("Annonce officielle"),
                      value: _isAnnouncement,
                      onChanged: (val) => setState(() {
                        _isAnnouncement = val ?? false;
                        if (_isAnnouncement) _isEvent = false;
                      }),
                    ),
                    CheckboxListTile(
                      title: const Text("Marquer comme événement"),
                      value: _isEvent,
                      onChanged: (val) => setState(() {
                        _isEvent = val ?? false;
                        if (_isEvent) _isAnnouncement = false;
                      }),
                    ),
                  ],

                  if (_image != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(_image!, height: 200, width: double.infinity, fit: BoxFit.cover),
                        ),
                        Positioned(
                          right: 5, top: 5,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => setState(() => _image = null),
                            ),
                          ),
                        )
                      ],
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectImage,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
