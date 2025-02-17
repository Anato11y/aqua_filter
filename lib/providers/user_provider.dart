import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  late final Stream<User?> _authStateChanges;

  User? get user => _user;

  UserProvider() {
    _authStateChanges = _auth.authStateChanges();
    _authStateChanges.listen((User? newUser) {
      _user = newUser;
      notifyListeners();
    });
  }

  /// ✅ Обновляем данные пользователя вручную при необходимости
  Future<void> refreshUser() async {
    await _auth.currentUser?.reload();
    _user = _auth.currentUser;
    notifyListeners();
  }

  /// ✅ Метод выхода из аккаунта
  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
}
