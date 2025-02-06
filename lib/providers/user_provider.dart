import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aqua_filter/models/user_model.dart'
    as user_model; // Используем алиас

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  user_model.User? _user; // Используем алиас для User
  user_model.User? get user => _user;

  // Вход с помощью email и пароля
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Загрузка данных пользователя из Firestore
      final userData = await _fetchUserData(result.user!.uid);
      _user = userData;
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка входа: $e');
    }
  }

  // Выход из аккаунта
  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  // Метод для загрузки данных пользователя из Firestore
  Future<user_model.User?> _fetchUserData(String userId) async {
    try {
      final docSnapshot = await _db.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return user_model.User(
          email: data['email'],
          name: data['name'],
          bonusBalance: data['bonusBalance'],
          purchaseHistory: (data['purchaseHistory'] as List<dynamic>?)
                  ?.map((item) => user_model.Purchase(
                        productName: item['productName'],
                        price: item['price'],
                        date: DateTime.fromMillisecondsSinceEpoch(item['date']),
                      ))
                  .toList() ??
              [],
        );
      }
    } catch (e) {
      debugPrint('Ошибка загрузки данных пользователя: $e');
    }
    return null;
  }

  // Метод для обновления данных пользователя в Firestore
  Future<void> updateUserData(user_model.User user) async {
    try {
      await _db.collection('users').doc(_auth.currentUser?.uid).set({
        'email': user.email,
        'name': user.name,
        'bonusBalance': user.bonusBalance,
        'purchaseHistory': user.purchaseHistory
            .map((purchase) => {
                  'productName': purchase.productName,
                  'price': purchase.price,
                  'date': purchase.date.millisecondsSinceEpoch,
                })
            .toList(),
      });
      _user = user;
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка обновления данных пользователя: $e');
    }
  }
}
