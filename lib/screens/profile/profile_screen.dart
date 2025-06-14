// Imports utilizados para armazenamento local da foto de perfil
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p; // Usado para pegar o nome do arquivo
import 'package:shared_preferences/shared_preferences.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:datingapp/screens/match/match_screen.dart';
import 'package:datingapp/screens/profile/widgets/name_input_fields.dart';
import 'package:datingapp/screens/profile/widgets/birth_date_picker.dart';
import 'package:datingapp/screens/profile/widgets/orientation_selector.dart';
import 'package:datingapp/screens/profile/widgets/interests_selector.dart';
import 'package:datingapp/screens/profile/widgets/confirm_button.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ProfileScreen({super.key, this.userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  DateTime? selectedDate;
  String? selectedOrientation;
  List<String> selectedInterests = [];
  bool _isLoading = false;

  File? _profileImageFile; // Armazena a imagem

  @override
  void initState() {
    super.initState();
    // Carrega os dados de texto do formulário
    _loadTextFields();
    // Carrega a imagem de perfil salva localmente
    _loadProfileImage();
  }
  
  void _loadTextFields() {
    if (widget.userData != null) {
      final data = widget.userData!;
      firstNameController.text = data['firstName'] ?? '';
      lastNameController.text = data['lastName'] ?? '';
      if (data['birthDate'] is Timestamp) {
        selectedDate = (data['birthDate'] as Timestamp).toDate();
      }
      selectedOrientation = data['orientation'];
      if (data['interests'] is List) {
        selectedInterests = List<String>.from(data['interests']);
      }
    }
  }

  // Função para carregar a imagem local
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    // Busca o caminho da imagem que salvamos anteriormente
    final imagePath = prefs.getString('profile_image_path');
    if (imagePath != null) {
      setState(() {
        _profileImageFile = File(imagePath);
      });
    }
  }

  // Função para abrir a câmera
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 600,
    );
    if (pickedImage == null) return;
    setState(() {
      _profileImageFile = File(pickedImage.path);
    });
  }
  
  Future<void> _submitForm() async {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid || selectedDate == null || selectedOrientation == null || selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, preencha todos os campos.')));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    setState(() { _isLoading = true; });

    try {
      // Se uma nova imagem foi escolhida, salva ela localmente
      if (_profileImageFile != null) {
        // Encontra a pasta de documentos do app
        final appDir = await getApplicationDocumentsDirectory();
        // Pega o nome do arquivo da imagem temporária
        final fileName = p.basename(_profileImageFile!.path);
        // Cria o caminho de destino permanente
        final savedImagePath = p.join(appDir.path, fileName);
        
        // Copia o arquivo para o novo caminho
        await _profileImageFile!.copy(savedImagePath);

        // Salva o caminho permanente nas SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path', savedImagePath);
      }
      
      // Monta os dados para o Firestore
      final userDataToSave = {
        'uid': user.uid,
        'email': user.email,
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'birthDate': Timestamp.fromDate(selectedDate!),
        'orientation': selectedOrientation,
        'interests': selectedInterests,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      };
      
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(userDataToSave, SetOptions(merge: true));
      
      if (!mounted) return;
      final successMessage = widget.userData != null ? 'Perfil atualizado!' : 'Perfil criado!';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage), backgroundColor: Colors.green));
      if (widget.userData != null) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const MatchScreen()), (route) => false);
      }

    } catch (e) {
      // ...
    } finally {
      if(mounted) { setState(() { _isLoading = false; }); }
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: const SizedBox(height: 10),
                ),
                const Text("Seu perfil", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade400,
                    backgroundImage: _profileImageFile != null
                        ? FileImage(_profileImageFile!) // Mostra a imagem do arquivo
                        : null,
                    child: _profileImageFile == null
                        ? Icon(Icons.camera_alt, size: 50, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                NameInputFields(
                  firstNameController: firstNameController,
                  lastNameController: lastNameController,
                ),
                const SizedBox(height: 16),
                BirthDatePicker(
                  selectedDate: selectedDate,
                  onDateSelected: (date) => setState(() => selectedDate = date),
                ),
                const SizedBox(height: 16),
                OrientationSelector(
                  selectedOrientation: selectedOrientation,
                  onChanged: (value) => setState(() => selectedOrientation = value),
                ),
                const SizedBox(height: 16),
                InterestsSelector(
                  selectedInterests: selectedInterests,
                  onChanged: (interests) => setState(() => selectedInterests = interests),
                ),
                const SizedBox(height: 24),
                
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ConfirmButton(onPressed: _submitForm),
              ],
            ),
          ),
        ),
      ),
    );
  }
}