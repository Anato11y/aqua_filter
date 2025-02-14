import 'package:aqua_filter/models/category.dart';
import 'package:aqua_filter/screens/catalog_screen.dart';
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final bool isInCart; // Добавляем флаг наличия в корзине

  const CategoryCard({
    super.key,
    required this.category,
    required this.isInCart, // Требуемый параметр
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CatalogScreen(categoryId: category.id),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Stack(
          // Используем Stack для добавления надписи "В корзине"
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12)), // Оставляем закругленные углы
                  child: AspectRatio(
                    aspectRatio: 10 / 8,
                    child: Container(
                      color: Colors.white,
                      child: category.imageUrl.isNotEmpty
                          ? Image.network(
                              category.imageUrl,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                      child: Text('Ошибка изображения')),
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                            )
                          : const Center(child: Text('Нет изображения')),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isInCart
                              ? Colors
                                  .grey // Изменяем цвет текста, если в корзине
                              : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (isInCart) // Если категория в корзине, добавляем надпись
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4), // Паддинг для текста
                  decoration: BoxDecoration(
                    color: Colors.green, // Цвет фона надписи
                    borderRadius: BorderRadius.circular(8), // Закругленные углы
                  ),
                  child: const Text(
                    "В корзине", // Надпись
                    style: TextStyle(
                      color: Colors.white, // Белый текст
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
