import 'package:flutter/foundation.dart';
import 'package:aqua_filter/models/cart_model.dart';
import 'package:aqua_filter/models/product_model.dart';

class CartProvider with ChangeNotifier {
  final Cart cart = Cart();

  void addItem(Product product) {
    cart.addItem(product);
    notifyListeners();
  }

  void removeItem(String productId) {
    cart.removeItem(productId);
    notifyListeners();
  }

  double get totalAmount => cart.calculateTotal();

  Map<String, int> get items => cart.items;
}
