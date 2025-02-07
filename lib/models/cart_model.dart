import 'package:flutter/foundation.dart';
import 'product_model.dart';

class Cart with ChangeNotifier {
  final Map<String, int> _items = {}; // Приватное хранилище товаров

  // Геттер для получения содержимого корзины
  Map<String, int> get items => Map.unmodifiable(_items);

  // ✅ Метод для добавления товара в корзину с указанием количества
  void addItem(Product product, int quantity) {
    if (_items.containsKey(product.id)) {
      _items.update(
          product.id, (existingQuantity) => existingQuantity + quantity);
    } else {
      _items[product.id] = quantity;
    }
    notifyListeners(); // 🔥 Уведомляем UI об изменениях
  }

  // ✅ Метод для удаления одного товара из корзины
  void removeItem(String productId) {
    if (_items.containsKey(productId)) {
      if (_items[productId]! > 1) {
        _items.update(productId, (quantity) => quantity - 1);
      } else {
        _items.remove(productId);
      }
    }
    notifyListeners();
  }

  // ✅ Очистка корзины
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
