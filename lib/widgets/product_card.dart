import 'package:flutter/material.dart';
import 'package:aqua_filter/models/product_model.dart';
import 'package:provider/provider.dart';
import 'package:aqua_filter/providers/cart_provider.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  /// Флаг, указывающий, что нужно скрыть кнопку «В корзину»
  final bool hideCartButton;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.hideCartButton = false, // По умолчанию кнопка не скрыта
  });

  @override
  ProductCardState createState() => ProductCardState();
}

class ProductCardState extends State<ProductCard> {
  int quantity = 0; // 🔹 Текущее количество

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    quantity = (cartProvider.items[widget.product.id]?['quantity'] ?? 0) as int;
  }

  /// ✅ Метод уменьшения количества
  void _decreaseQuantity() {
    if (quantity > 0) {
      setState(() => quantity--);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.removeItem(widget.product.id);
    }
  }

  /// ✅ Метод увеличения количества
  void _increaseQuantity() {
    setState(() => quantity++);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(widget.product, 1);
  }

  @override
  Widget build(BuildContext context) {
    // Подтягиваем изменения корзины, чтобы счетчик обновлялся
    Provider.of<CartProvider>(context);

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
              // Изображение
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
              // Название
              Text(
                widget.product.name,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Цена
              Text(
                '${widget.product.price.toStringAsFixed(2)} ₽',
                style: const TextStyle(fontSize: 16, color: Colors.green),
              ),
              const SizedBox(height: 8),

              // Если кнопка скрыта
              if (widget.hideCartButton) ...[
                // Показываем «В корзине», только если уже добавлено
                if (quantity > 0)
                  const Text(
                    'В корзине',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  )
                else
                  const SizedBox(), // Пустое место
              ] else ...[
                // Обычная логика с кнопкой и счетчиком
                if (quantity > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _decreaseQuantity,
                        icon: const Icon(Icons.remove, color: Colors.red),
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
                  )
                else
                  ElevatedButton(
                    onPressed: _increaseQuantity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'В КОРЗИНУ',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
