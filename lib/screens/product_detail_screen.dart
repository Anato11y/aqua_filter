import 'package:aqua_filter/models/product_model.dart';
import 'package:aqua_filter/screens/cart_screen.dart'; // Импортируем CartScreen
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 0; // ✅ Изначально 0

  void _increaseQuantity() {
    setState(() {
      quantity++;
    });
  }

  void _decreaseQuantity() {
    if (quantity > 0) {
      setState(() {
        quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product.name,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Добавляем иконку корзины справа
          IconButton(
            icon: const Icon(Icons.shopping_cart,
                color: Colors.white), // Иконка корзины
            onPressed: () {
              // Переход на экран CartScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const CartScreen(), // Открываем CartScreen
                ),
              );
            },
          ),
          const SizedBox(width: 8), // Отступ для лучшего визуального оформления
        ],
      ),
      body: Column(
        children: [
          // Контент прокручиваемый
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Изображение
                    Center(
                      child: Image.network(
                        widget.product.imageUrl,
                        height: 250,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Text('Ошибка изображения')),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Название
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // Описание
                    Text(
                      widget.product.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    // Цена
                    Text(
                      'Цена: ${widget.product.price} ₽',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    // Характеристики
                    if (widget.product.characteristics.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Характеристики:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ..._buildCharacteristics(
                              widget.product.characteristics),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Закреплённая панель управления (НЕ скроллится)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 6, spreadRadius: 2),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Выбор количества
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Количество:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _decreaseQuantity,
                          icon: const Icon(Icons.remove, size: 28),
                        ),
                        Text(
                          '$quantity',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: _increaseQuantity,
                          icon: const Icon(Icons.add, size: 28),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Кнопка "Добавить в корзину"
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: quantity > 0
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${widget.product.name} добавлен в корзину ($quantity шт.)'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        : null, // Кнопка неактивна, если quantity = 0
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Добавить в корзину'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor:
                          quantity > 0 ? Colors.blueAccent : Colors.grey,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Метод для отображения характеристик
  List<Widget> _buildCharacteristics(dynamic characteristics) {
    if (characteristics is Map<String, dynamic>) {
      return characteristics.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            '${entry.key}: ${entry.value}',
            style: const TextStyle(fontSize: 16),
          ),
        );
      }).toList();
    } else if (characteristics is List<dynamic>) {
      return characteristics.map((char) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            '• $char',
            style: const TextStyle(fontSize: 16),
          ),
        );
      }).toList();
    }
    return [const Text('Нет характеристик', style: TextStyle(fontSize: 16))];
  }
}
