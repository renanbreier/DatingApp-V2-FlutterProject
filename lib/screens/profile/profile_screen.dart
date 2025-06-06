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

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      navigateTo(context, const MatchScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
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