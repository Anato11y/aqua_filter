import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:aqua_filter/models/product_model.dart';

class CartProvider with ChangeNotifier {
  final Map<String, Map<String, dynamic>> _items = {};

  Map<String, Map<String, dynamic>> get items => _items;

  int get totalItems => _items.values.fold(
        0,
        (sum, item) => sum + (item['quantity'] as int),
      );

  double get totalAmount => _items.entries.fold(
        0,
        (sum, entry) =>
            sum +
            (entry.value['product'].price * (entry.value['quantity'] as int)),
      );

  void addItem(Product product, int quantity) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!['quantity'] =
          (_items[product.id]!['quantity'] as int) + quantity;
    } else {
      _items[product.id] = {
        'product': product,
        'quantity': quantity,
      };
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    if (_items.containsKey(productId)) {
      if ((_items[productId]!['quantity'] as int) > 1) {
        _items[productId]!['quantity'] =
            (_items[productId]!['quantity'] as int) - 1;
      } else {
        _items.remove(productId);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool isCategoryInCart(String categoryId) {
    return _items.values.any((item) {
      final product = item['product'] as Product;
      return product.categoryId == categoryId;
    });
  }

  /// Оформление заказа с использованием авто-генерируемого ID.
  /// Логика номера заказа (orderNumber) реализуется на стороне Firestore (например, через Cloud Function).
  Future<void> placeOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final totalPrice = totalAmount;
    final bonusEarned = totalPrice * 0.05;
    final itemsList = _items.values.map((item) {
      return {
        'productId': item['product'].id,
        'name': item['product'].name,
        'price': item['product'].price,
        'quantity': item['quantity'],
      };
    }).toList();

    final orderData = {
      'userId': user.uid,
      'totalAmount': totalPrice,
      'bonusEarned': bonusEarned,
      'date': Timestamp.now(),
      'items': itemsList,
    };

    // Создание заказа с авто-генерируемым ID
    await FirebaseFirestore.instance.collection('orders').add(orderData);

    // Обновляем бонусный баланс пользователя
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userSnapshot = await userRef.get();
    final currentBonus =
        (userSnapshot.data()?['bonusBalance'] ?? 0.0) as double;
    await userRef.update({'bonusBalance': currentBonus + bonusEarned});

    clearCart();
  }
}
