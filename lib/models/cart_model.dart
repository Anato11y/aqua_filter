import 'package:aqua_filter/models/product_list.dart';

import 'product_model.dart';

class Cart {
  final Map<String, int> items = {};

  void addItem(Product product) {
    if (items.containsKey(product.id)) {
      items[product.id] = items[product.id]! + 1;
    } else {
      items[product.id] = 1;
    }
  }

  void removeItem(String productId) {
    if (items.containsKey(productId)) {
      if (items[productId]! > 1) {
        items[productId] = items[productId]! - 1;
      } else {
        items.remove(productId);
      }
    }
  }

  double calculateTotal() {
    double total = 0;
    for (final entry in items.entries) {
      final product = productList.firstWhere((p) => p.id == entry.key);
      total += product.price * entry.value;
    }
    return total;
  }
}
