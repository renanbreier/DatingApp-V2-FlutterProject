import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datingapp/screens/login/login_screen.dart';
import 'package:datingapp/screens/preferences/preferences_screen.dart';
import 'package:datingapp/screens/profile/profile_screen.dart'; // Importe a ProfileScreen
import 'package:flutter/material.dart';

// Convertido para StatefulWidget para gerenciar a lógica dos botões
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Lista de botões atualizada
  final List<Map<String, dynamic>> settings = const [
    {'icon': Icons.person_outline, 'label': 'Perfil'},
    {'icon': Icons.room_preferences, 'label': 'Preferências'},
    {'icon': Icons.notifications_none, 'label': 'Notificações'},
    {'icon': Icons.language, 'label': 'Idioma'},
    {'icon': Icons.palette_outlined, 'label': 'Tema'},
    {'icon': Icons.help_outline, 'label': 'Ajuda'},
    // Botão "Sobre" substituído por "Excluir Conta"
    {'icon': Icons.delete_forever, 'label': 'Excluir Conta', 'isDelete': true},
    {'icon': Icons.logout, 'label': 'Sair', 'isLogout': true},
  ];

  // Função para navegar para a tela de edição de perfil
  Future<void> _navigateToProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !mounted) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted && doc.exists) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ProfileScreen(userData: doc.data())),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao buscar perfil: $e")));
    }
  }

  // Função para deletar a conta do usuário
  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !mounted) return;

    try {
      // 1. Deleta os dados do usuário do Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      
      // 2. Deleta o usuário do Firebase Authentication
      await user.delete();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta excluída com sucesso.'), backgroundColor: Colors.green),
        );
        // 3. Leva o usuário de volta para a tela de login
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message = 'Ocorreu um erro ao excluir a conta.';
        if (e.code == 'requires-recent-login') {
          message = 'Esta operação é sensível e requer autenticação recente. Por favor, faça logout e login novamente antes de tentar excluir sua conta.';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
    }
  }

  // Função para mostrar o diálogo de confirmação antes de deletar
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Conta?'),
        content: const Text('Isso é permanente e todos os seus dados, incluindo matches e conversas, serão perdidos. Você tem certeza?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteAccount();
            },
          ),
        ],
      ),
    );
  }

  // Função principal para lidar com os cliques nos itens da grade
  Future<void> _handleTap(Map<String, dynamic> item) async {
    final label = item['label'];
    
    switch (label) {
      case 'Sair':
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false,
        );
        break;
      case 'Preferências':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => const PreferencesScreen()),
        );
        break;
      case 'Perfil':
        _navigateToProfile();
        break;
      case 'Excluir Conta':
        _showDeleteConfirmationDialog();
        break;
      default:
        print('Clicou em: $label');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Configurações"),
        backgroundColor: const Color(0xFFE94057),
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: settings.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            final item = settings[index];
            final bool isDestructiveAction = item['isLogout'] == true || item['isDelete'] == true;

            return InkWell(
              onTap: () => _handleTap(item),
              borderRadius: BorderRadius.circular(12),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: isDestructiveAction ? Colors.red.withOpacity(0.1) : Colors.grey.shade200,
                      child: Icon(
                        item['icon'], 
                        size: 30, 
                        color: isDestructiveAction ? Colors.red : Colors.black87
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(item['label'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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