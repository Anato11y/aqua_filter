import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aqua_filter/screens/main_scrin.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _name = ''; // 🔹 Теперь запрашиваем имя пользователя
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
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        User? user = userCredential.user;
        if (user != null) {
          await _createUserInFirestore(user);
        }
      }

      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const MainScreen()));
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.code);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// ✅ **Метод для добавления нового пользователя в `users`**
  Future<void> _createUserInFirestore(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'displayName': _name,
        'bonusBalance': 0.0,
        'orderHistory': [],
      });
    } catch (e) {
      debugPrint('❌ Ошибка при создании пользователя в Firestore: $e');
    }
  }

  void _showErrorDialog(String errorCode) {
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
              if (!_isLogin)
                TextFormField(
                  decoration: _inputDecoration('Имя', Icons.person),
                  validator: (v) =>
                      v != null && v.isNotEmpty ? null : 'Введите имя',
                  onChanged: (v) => _name = v,
                ),
              const SizedBox(height: 20),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)), // Закругление
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isLogin ? 'Войти' : 'Зарегистрироваться',
                        style: const TextStyle(color: Colors.white),
                      ),
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
