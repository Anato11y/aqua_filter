import 'package:flutter/material.dart';
import 'package:aqua_filter/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartProvider with ChangeNotifier {
  final Map<String, Map<String, dynamic>> _items = {};

  Map<String, Map<String, dynamic>> get items => _items;

  /// ✅ Подсчет общего количества товаров в корзине
  int get totalItems => _items.values
      .fold(0, (sum, item) => sum + (item['quantity'] as num).toInt());

  /// ✅ Подсчет общей суммы заказа
  double get totalAmount => _items.entries.fold(
        0,
        (sum, entry) =>
            sum +
            (entry.value['product'].price *
                (entry.value['quantity'] as num).toInt()),
      );

  /// ✅ Исправленный метод добавления товара в корзину
  void addItem(Product product, int quantity) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!['quantity'] =
          (_items[product.id]!['quantity'] as num).toInt() + quantity;
    } else {
      _items[product.id] = {
        'product': product,
        'quantity': quantity.toInt(),
      };
    }
    notifyListeners();
  }

  /// ✅ Удаление товара
  void removeItem(String productId) {
    if (_items.containsKey(productId)) {
      if ((_items[productId]!['quantity'] as num).toInt() > 1) {
        _items[productId]!['quantity'] =
            (_items[productId]!['quantity'] as num).toInt() - 1;
      } else {
        _items.remove(productId);
      }
      notifyListeners();
    }
  }

  /// ✅ Очистка корзины
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// ✅ **Метод оформления заказа**
  Future<void> placeOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final totalPrice = totalAmount;
    final bonusEarned = totalPrice * 0.05; // 🔹 5% бонусов

    final orderData = {
      'userId': user.uid,
      'totalAmount': totalPrice,
      'bonusEarned': bonusEarned,
      'date': Timestamp.now(),
      'items': _items.values.map((item) {
        return {
          'productId': item['product'].id,
          'name': item['product'].name,
          'price': item['product'].price,
          'quantity': item['quantity'],
        };
      }).toList(),
    };

    // 🔹 Сохранение заказа в Firestore
    final orderRef = FirebaseFirestore.instance.collection('orders').doc();
    await orderRef.set(orderData);

    // 🔹 Обновляем бонусный баланс пользователя
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userData = await userRef.get();
    final currentBonus = (userData.data()?['bonusBalance'] ?? 0.0) as double;

    await userRef.update({
      'bonusBalance': currentBonus + bonusEarned,
      'orderHistory': FieldValue.arrayUnion([orderData]),
    });

    clearCart();
  }
}
