import 'package:aqua_filter/screens/main_scrin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Главный экран

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  bool _isLogin = true;

  Future<void> _authAction() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await _auth.signInWithEmailAndPassword(
            email: _email, password: _password);
      } else {
        await _auth.createUserWithEmailAndPassword(
            email: _email, password: _password);
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(context, e.code);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(BuildContext context, String errorCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.blue[50],
        title: const Text('Ошибка авторизации',
            style: TextStyle(color: Colors.blue)),
        content: Text(_parseFirebaseError(errorCode)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  String _parseFirebaseError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Неверный формат email';
      case 'user-not-found':
        return 'Пользователь не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      case 'email-already-in-use':
        return 'Email уже используется';
      case 'weak-password':
        return 'Пароль должен содержать минимум 6 символов';
      default:
        return 'Ошибка: $code';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle, size: 80, color: Colors.blue),
              const SizedBox(height: 30),
              TextFormField(
                decoration: _inputDecoration('Email', Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v != null && v.contains('@')
                    ? null
                    : 'Введите корректный email',
                onChanged: (v) => _email = v,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: _inputDecoration('Пароль', Icons.lock),
                obscureText: true,
                validator: (v) =>
                    v != null && v.length >= 6 ? null : 'Минимум 6 символов',
                onChanged: (v) => _password = v,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _authAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isLogin ? 'Войти' : 'Зарегистрироваться'),
              ),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                    _isLogin ? 'Создать аккаунт' : 'Уже есть аккаунт? Войти'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
    );
  }
}
