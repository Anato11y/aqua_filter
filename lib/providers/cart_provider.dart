import 'package:flutter/material.dart';
import 'package:aqua_filter/models/product_model.dart';

class CartProvider with ChangeNotifier {
  final Map<String, Map<String, dynamic>> _items = {};

  Map<String, Map<String, dynamic>> get items => _items;

  int get totalItems => _items.values
      .fold(0, (sum, item) => sum + (item['quantity'] as num).toInt());

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
}
