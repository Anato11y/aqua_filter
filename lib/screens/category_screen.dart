import 'package:aqua_filter/models/category.dart' as model;
import 'package:aqua_filter/widgets/category_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aqua_filter/screens/water_analysis_screen.dart';
import 'package:provider/provider.dart';
import 'package:aqua_filter/providers/filter_provider.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final filterProvider = Provider.of<FilterProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Категории товаров',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 33, 150, 243),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // 🔹 Кнопка открытия анализа воды
          IconButton(
            icon: const Icon(Icons.filter_alt, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const WaterAnalysisScreen()),
              );
            },
          ),
          // 🔹 Кнопка сброса фильтров
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              filterProvider.resetFilters();
            },
          ),
        ],
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
            return model.Category.fromMap(
                doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          // 🔹 Применение фильтрации
          final filteredCategories = filterProvider.applyFilters(categories);

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                double maxWidth = constraints.maxWidth;
                double cardWidth = 180; // Фиксированная ширина карточки
                int crossAxisCount = (maxWidth / cardWidth)
                    .floor(); // Количество карточек в строке

                return GridView.builder(
                  itemCount: filteredCategories.length,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: cardWidth,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
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
