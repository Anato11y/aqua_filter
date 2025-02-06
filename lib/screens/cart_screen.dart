import 'package:aqua_filter/models/cart_model.dart';
import 'package:aqua_filter/models/product_list.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  final Cart cart = Cart();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.keys.length,
              itemBuilder: (context, index) {
                final productId = cart.items.keys.elementAt(index);
                final product =
                    productList.firstWhere((p) => p.id == productId);
                final quantity = cart.items[productId]!;
                return ListTile(
                  leading: Image.asset(product.imageUrl, width: 50, height: 50),
                  title: Text(product.name),
                  subtitle:
                      Text('${product.price.toStringAsFixed(2)} ₽ x $quantity'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            cart.removeItem(productId);
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            cart.addItem(product);
                          });
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
                  '${cart.calculateTotal().toStringAsFixed(2)} ₽',
                  style: const TextStyle(fontSize: 18, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
