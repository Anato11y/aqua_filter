import 'package:aqua_filter/models/category.dart';
import 'package:aqua_filter/widgets/category_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Категории товаров',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 33, 150, 243),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Ошибка загрузки данных'));
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Категорий пока нет'));
          }

          final categories = snapshot.data!.docs.map((doc) {
            return Category.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                double maxWidth = constraints.maxWidth;
                double cardWidth = 180; // Фиксированная ширина карточки
                int crossAxisCount = (maxWidth / cardWidth)
                    .floor(); // Количество карточек в строке

                return GridView.builder(
                  itemCount: categories.length,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent:
                        cardWidth, // Фиксированная ширина карточки
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.75, // Пропорции карточки
                  ),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return CategoryCard(category: category);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
