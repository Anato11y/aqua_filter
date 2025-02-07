import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aqua_filter/providers/cart_provider.dart';
import 'package:aqua_filter/models/product_list.dart';
import 'package:aqua_filter/models/product_model.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

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
                      final productId =
                          cartProvider.items.keys.elementAt(index);
                      final quantity = cartProvider.items[productId]!;
                      final product = productList.firstWhere(
                        (p) => p.id == productId,
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

                      return ListTile(
                        leading: product.imageUrl.isNotEmpty
                            ? Image.network(
                                product.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.image_not_supported),
                        title: Text(product.name),
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
              width: double.infinity,
              child: ElevatedButton(
                onPressed: cartProvider.items.isNotEmpty
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Заказ оформлен!'),
                          ),
                        );
                        cartProvider.clearCart();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: cartProvider.items.isNotEmpty
                      ? Colors.blueAccent
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
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
