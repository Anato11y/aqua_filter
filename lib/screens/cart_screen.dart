import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aqua_filter/providers/cart_provider.dart';
import 'package:aqua_filter/models/product_model.dart';
import 'package:aqua_filter/screens/login_screen.dart';
import 'package:aqua_filter/screens/checkout_screen.dart'; // Страница оформления заказа

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _checkout(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // ❌ Если пользователь не авторизован, перенаправляем на страницу входа
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    } else {
      // ✅ Если авторизован, переходим к оформлению заказа
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CheckoutScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: cartProvider.items.isEmpty
                ? const Center(
                    child: Text(
                      'Ваша корзина пуста',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final String productId =
                          cartProvider.items.keys.elementAt(index);
                      final Map<String, dynamic> cartItem =
                          cartProvider.items[productId]!;
                      final Product product =
                          cartItem['product']; // ✅ Получаем объект `Product`
                      final int quantity = cartItem['quantity'];

                      return ListTile(
                        leading: product.imageUrl.isNotEmpty
                            ? Image.network(
                                product.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.image_not_supported),
                        title: Text(
                            product.name), // ✅ Теперь `product.name` работает
                        subtitle: Text(
                            '${product.price.toStringAsFixed(2)} ₽ x $quantity'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                cartProvider.removeItem(product.id);
                              },
                            ),
                            Text('$quantity'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                cartProvider.addItem(product, 1);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Итого:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${cartProvider.totalAmount.toStringAsFixed(2)} ₽',
                  style: const TextStyle(fontSize: 18, color: Colors.green),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width:
                  MediaQuery.of(context).size.width * 0.8, // 80% ширины экрана
              child: ElevatedButton(
                onPressed: cartProvider.items.isNotEmpty
                    ? () => _checkout(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: cartProvider.items.isNotEmpty
                      ? Colors.blueAccent
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)), // Закругление
                ),
                child: const Text(
                  'Оформить заказ',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
