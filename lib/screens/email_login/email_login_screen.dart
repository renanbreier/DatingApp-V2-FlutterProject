import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datingapp/screens/match/match_screen.dart';
import 'package:datingapp/screens/profile/profile_screen.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  // Controladores para os campos de texto
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Gerenciamento de estado
  bool _isLoginMode = true; // Alterna entre a tela de Login e Cadastro
  bool _isLoading = false;  // Para mostrar um indicador de carregamento
  String _errorMessage = '';

  // Instância do Firebase Auth
  final _firebaseAuth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Função principal que é chamada ao clicar no botão
  Future<void> _submit() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, preencha todos os campos.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      UserCredential userCredential;
      if (_isLoginMode) {
        // --- MODO LOGIN ---
        userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // --- MODO CADASTRO ---
        userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      
      if (mounted && userCredential.user != null) {
        _navigateAfterLogin(userCredential.user!);
      }

    } on FirebaseAuthException catch (e) {
      // Trata erros específicos do Firebase Auth
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'Nenhum usuário encontrado para este e-mail.';
          break;
        case 'wrong-password':
          _errorMessage = 'Senha incorreta.';
          break;
        case 'email-already-in-use':
          _errorMessage = 'Este e-mail já está em uso.';
          break;
        case 'weak-password':
          _errorMessage = 'A senha deve ter no mínimo 6 caracteres.';
          break;
        case 'invalid-email':
           _errorMessage = 'O formato do e-mail é inválido.';
           break;
        default:
          _errorMessage = 'Ocorreu um erro. Tente novamente.';
      }
      setState(() {});
    } finally {
      if(mounted){
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Lógica de navegação pós-login
  Future<void> _navigateAfterLogin(User user) async {
    // 1. Pega o UID do usuário que acabou de logar
    final String uid = user.uid;

    // 2. Busca no Firestore por um documento com esse UID na coleção 'users'
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    
    if (!mounted) return;
    
    // 3. Verifica se o documento de perfil existe
    if (doc.exists) {
      // Se existe e o perfil está completo segue para a MatchScreen!
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MatchScreen()),
        (route) => false, // Remove todas as rotas anteriores
      );
    } else {
      // Se não existe, segue para a ProfileScreen!
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
        (route) => false, // Remove todas as rotas anteriores
      );
    }
  }
  
  // Função para alternar entre os modos
  void _switchAuthMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_isLoginMode ? 'Login' : 'Cadastre-se', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFE94057),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(_errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center,),
                ),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE94057),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _isLoginMode ? 'Entrar' : 'Cadastrar',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              TextButton(
                onPressed: _switchAuthMode,
                child: Text(
                  _isLoginMode ? 'Não tem uma conta? Cadastre-se' : 'Já tem uma conta? Faça login',
                  style: const TextStyle(color: Color(0xFFE94057)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}