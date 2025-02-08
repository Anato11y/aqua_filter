import 'package:flutter/material.dart';
import 'package:aqua_filter/models/product_model.dart';
import 'package:provider/provider.dart';
import 'package:aqua_filter/providers/cart_provider.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  ProductCardState createState() => ProductCardState();
}

class ProductCardState extends State<ProductCard> {
  int quantity = 0; // 🔹 Изначальное количество

  @override
  void initState() {
    super.initState();
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // ✅ Преобразуем Object в int
    quantity = (cartProvider.items[widget.product] ?? 0) as int;
  }

  /// ✅ Метод уменьшения количества
  void _decreaseQuantity() {
    if (quantity > 0) {
      setState(() {
        quantity--;
      });
    }
  }

  /// ✅ Метод увеличения количества
  void _increaseQuantity() {
    setState(() {
      quantity++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: AspectRatio(
                  aspectRatio: 10 / 8,
                  child: Container(
                    color: Colors.white,
                    child: widget.product.imageUrl.isNotEmpty
                        ? Image.network(
                            widget.product.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(child: Text('Ошибка изображения')),
                          )
                        : const Center(child: Text('Нет изображения')),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.product.name,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.product.price.toStringAsFixed(2)} ₽',
                style: const TextStyle(fontSize: 16, color: Colors.green),
              ),
              const SizedBox(height: 8),
              // 🔹 Выбор количества
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: quantity > 0 ? _decreaseQuantity : null,
                    icon: Icon(Icons.remove,
                        color: quantity > 0 ? Colors.red : Colors.grey),
                  ),
                  Text(
                    '$quantity',
                    style: const TextStyle(fontSize: 18),
                  ),
                  IconButton(
                    onPressed: _increaseQuantity,
                    icon: const Icon(Icons.add, color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: quantity > 0
                    ? () {
                        cartProvider.addItem(widget.product, quantity);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '$quantity × ${widget.product.name} добавлен в корзину'),
                          ),
                        );
                      }
                    : null, // 🔹 Кнопка отключается при `quantity = 0`
                style: ElevatedButton.styleFrom(
                  backgroundColor: quantity > 0
                      ? Colors.blueAccent
                      : Colors.grey, // 🔹 Цвет меняется
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Добавить в корзину',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
