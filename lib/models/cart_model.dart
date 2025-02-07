import 'package:aqua_filter/models/product_list.dart';
import 'package:flutter/foundation.dart'; // Импортируем ChangeNotifier
import 'product_model.dart'; // Импортируем модель продукта

class Cart with ChangeNotifier {
  final Map<String, int> _items = {}; // Приватное хранилище товаров

  // Геттер для получения содержимого корзины
  Map<String, int> get items => Map.unmodifiable(_items);

  // Метод для добавления товара в корзину
  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(product.id!, (quantity) => quantity + 1);
    } else {
      _items[product.id!] = 1;
    }
    notifyListeners(); // Уведомляем слушателей о изменении состояния
  }

  // Метод для удаления одного товара из корзины
  void removeItem(String productId) {
    if (_items.containsKey(productId)) {
      if (_items[productId]! > 1) {
        _items.update(productId, (quantity) => quantity - 1);
      } else {
        _items.remove(productId);
      }
    }
    notifyListeners(); // Уведомляем слушателей о изменении состояния
  }

  // Метод для полного удаления товара из корзины
  void removeAll(String productId) {
    _items.remove(productId);
    notifyListeners(); // Уведомляем слушателей о изменении состояния
  }

  // Метод для расчета общей стоимости
  double calculateTotal() {
    double total = 0;
    for (final entry in _items.entries) {
      // Предполагается, что есть список продуктов productList
      final product = productList.firstWhere((p) => p.id == entry.key);
      total += product.price * entry.value;
    }
    return total;
  }

  // Очистка корзины
  void clear() {
    _items.clear();
    notifyListeners(); // Уведомляем слушателей о изменении состояния
  }
}
