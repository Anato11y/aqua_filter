import 'package:flutter/foundation.dart';
import 'package:aqua_filter/models/product_model.dart';

class CartProvider with ChangeNotifier {
  final Map<Product, int> _cartItems = {}; // ✅ Хранит товары в корзине

  // ✅ Геттер для получения товаров
  Map<Product, int> get items => Map.unmodifiable(_cartItems);

  // ✅ Добавление товара в корзину
  void addItem(Product product, int quantity) {
    if (_cartItems.containsKey(product)) {
      _cartItems.update(
          product, (existingQuantity) => existingQuantity + quantity);
    } else {
      _cartItems[product] = quantity;
    }
    notifyListeners();
  }

  // ✅ Удаление товара из корзины
  void removeItem(Product product) {
    if (_cartItems.containsKey(product)) {
      if (_cartItems[product]! > 1) {
        _cartItems.update(product, (quantity) => quantity - 1);
      } else {
        _cartItems.remove(product);
      }
    }
    notifyListeners();
  }

  // ✅ Очистка корзины
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // ✅ Получение суммы всех товаров в корзине
  double get totalAmount => _cartItems.entries.fold(0, (sum, entry) {
        return sum + (entry.key.price * entry.value);
      });

  // ✅ Получение общего количества товаров
  int get totalItems =>
      _cartItems.values.fold(0, (sum, quantity) => sum + quantity);
}
