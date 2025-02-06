import 'package:aqua_filter/models/category.dart';
import 'package:aqua_filter/screens/catalog_screen.dart';
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({super.key, required this.category});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
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
                              const Center(child: Text('Ошибка изображения')),
                          loadingBuilder: (context, child, loadingProgress) {
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
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    maxLines: 3, // Ограничиваем количество строк
                    overflow: TextOverflow.ellipsis, // Добавляем многоточие
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
