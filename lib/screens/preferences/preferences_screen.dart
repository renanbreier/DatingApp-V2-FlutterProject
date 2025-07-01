import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  RangeValues _ageRange = const RangeValues(18, 40);
  bool _isLoading = true;

  final List<String> _allOrientations = ['Heterossexual', 'Homossexual', 'Bissexual', 'Panssexual', 'Assexual'];
  final List<String> _allInterests = ['Música', 'Viagens', 'Esportes', 'Filmes', 'Leitura', 'Video Game', 'Tecnologia', 'Pets', 'Arte', 'Culinária'];

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() { _isLoading = false; });
      return;
    }

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (mounted && doc.exists && doc.data()!.containsKey('preferences')) {
      final prefs = doc.data()!['preferences'] as Map<String, dynamic>;
      setState(() {
        _ageRange = RangeValues(
          (prefs['minAge'] ?? 18).toDouble(),
          (prefs['maxAge'] ?? 40).toDouble(),
        );
      });
    }
    setState(() { _isLoading = false; });
  }

  Future<void> _savePreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() { _isLoading = true; });

    final preferencesData = {
      'minAge': _ageRange.start.round(),
      'maxAge': _ageRange.end.round(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'preferences': preferencesData}, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferência de idade salva!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      // ... tratamento de erro
    } finally {
      if(mounted) { setState(() { _isLoading = false; }); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Suas preferências"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Idade:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  RangeSlider(
                    values: _ageRange,
                    min: 18,
                    max: 70,
                    divisions: 52,
                    labels: RangeLabels('${_ageRange.start.round()}', '${_ageRange.end.round()}'),
                    onChanged: (values) => setState(() => _ageRange = values),
                    activeColor: const Color(0xFFE94057),
                  ),
                  const SizedBox(height: 24),

                  Text('Distância:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Slider(value: 25, min: 1, max: 50, onChanged: null),
                  const SizedBox(height: 24),
                  Text('Orientação Sexual:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8.0,
                    children: _allOrientations.map((o) => Chip(label: Text(o))).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text('Interesses:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8.0,
                    children: _allInterests.map((i) => Chip(label: Text(i))).toList(),
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _savePreferences,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE94057),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}