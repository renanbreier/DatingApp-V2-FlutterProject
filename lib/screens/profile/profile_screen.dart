// Importe os pacotes do Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import 'package:datingapp/helpers/navigation.dart';
import 'package:datingapp/screens/profile/widgets/profile_photo.dart';
import 'package:datingapp/screens/profile/widgets/name_input_fields.dart';
import 'package:datingapp/screens/profile/widgets/birth_date_picker.dart';
import 'package:datingapp/screens/profile/widgets/orientation_selector.dart';
import 'package:datingapp/screens/profile/widgets/interests_selector.dart';
import 'package:datingapp/screens/profile/widgets/confirm_button.dart';
import 'package:datingapp/screens/match/match_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController(text: "Cauã");
  final lastNameController = TextEditingController(text: "Moreto");

  DateTime? selectedDate;
  String? selectedOrientation;
  List<String> selectedInterests = [];

  // Adicionamos um estado para o carregamento, sem impactar o layout
  bool _isLoading = false;

  // ⭐ A LÓGICA DE SALVAR OS DADOS FOI MOVIDA PARA CÁ ⭐
  Future<void> _submitForm() async {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid || selectedDate == null || selectedOrientation == null || selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.'), backgroundColor: Colors.red),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum usuário logado. Por favor, faça login novamente.'), backgroundColor: Colors.red),
      );
      return;
    }
    
    setState(() { _isLoading = true; });

    try {
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'birthDate': Timestamp.fromDate(selectedDate!),
        'orientation': selectedOrientation,
        'interests': selectedInterests,
        'profileCreatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(userData);
      
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MatchScreen()), 
        (route) => false,
      );

    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocorreu um erro ao salvar o perfil: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if(mounted) { setState(() { _isLoading = false; }); }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 👇 O SEU BUILD METHOD ORIGINAL, SEM NENHUMA ALTERAÇÃO NO LAYOUT 👇
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Text("Seu perfil", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const ProfilePhoto(),
                    const SizedBox(height: 24),

                    isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: NameInputFields(
                                  firstNameController: firstNameController,
                                  lastNameController: lastNameController,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: BirthDatePicker(
                                  selectedDate: selectedDate,
                                  onDateSelected: (date) => setState(() => selectedDate = date),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              NameInputFields(
                                firstNameController: firstNameController,
                                lastNameController: lastNameController,
                              ),
                              const SizedBox(height: 16),
                              BirthDatePicker(
                                selectedDate: selectedDate,
                                onDateSelected: (date) => setState(() => selectedDate = date),
                              ),
                            ],
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
                    
                    // ⭐ ÚNICA PEQUENA MUDANÇA VISUAL: MOSTRAR O LOADING NO LUGAR DO BOTÃO ⭐
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      ConfirmButton(onPressed: _submitForm),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}