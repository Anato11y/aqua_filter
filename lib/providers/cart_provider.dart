import 'package:flutter/foundation.dart';
import 'package:aqua_filter/models/cart_model.dart';
import 'package:aqua_filter/models/product_model.dart';
import 'package:aqua_filter/models/product_list.dart';

class CartProvider with ChangeNotifier {
  final Cart _cart = Cart(); // Используем внутренний объект корзины

  // ✅ Добавление товара в корзину
  void addItem(Product product, int quantity) {
    if (quantity > 0) {
      _cart.addItem(product, quantity);
      notifyListeners(); // 🔥 Обновляем UI
    }
  }

  // ✅ Удаление товара из корзины
  void removeItem(String productId) {
    _cart.removeItem(productId);
    notifyListeners();
  }

  // ✅ Очистка всей корзины
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // ✅ Получение общего количества товаров в корзине
  int get totalItems =>
      _cart.items.values.fold(0, (sum, quantity) => sum + quantity);

  // ✅ Получение суммы всех товаров в корзине
  double get totalAmount => _cart.items.entries.fold(0, (sum, entry) {
        final product = getProductById(entry.key);
        return sum + (product.price * entry.value);
      });

  // ✅ Получение списка товаров в корзине
  Map<String, int> get items => Map.unmodifiable(_cart.items);

  // ✅ Метод для получения продукта по его ID
  Product getProductById(String productId) {
    return productList.firstWhere(
      (product) => product.id == productId,
      orElse: () => Product(
        id: productId,
        name: 'Неизвестный товар',
        description: 'Описание отсутствует',
        price: 0.0,
        imageUrl: '',
        characteristics: [],
        categoryId: '',
      ),
    );
  }
}
