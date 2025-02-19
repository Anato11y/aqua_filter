import 'package:aqua_filter/models/category.dart';
import 'package:aqua_filter/screens/water_analysis_screen.dart';
import 'package:aqua_filter/widgets/category_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:aqua_filter/providers/filter_provider.dart';
import 'package:aqua_filter/providers/cart_provider.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});
  @override
  CategoryScreenState createState() => CategoryScreenState();
}

class CategoryScreenState extends State<CategoryScreen> {
  bool _ignoreFilters = false;

  void _resetToDefault() {
    final filterProvider = Provider.of<FilterProvider>(context, listen: false);
    filterProvider.resetFilters();
    setState(() {
      _ignoreFilters = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filterProvider = Provider.of<FilterProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Категории товаров',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.science, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WaterAnalysisScreen()),
              );
              if (result == true) {
                setState(() {
                  _ignoreFilters = false;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetToDefault,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .orderBy('order', descending: false)
            .snapshots(),
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
          final categories = snapshot.data!.docs
              .map((doc) => Category.fromMap(doc.data(), doc.id))
              .toList();
          final filteredCategories =
              (!_ignoreFilters && filterProvider.hasActiveFilters)
                  ? filterProvider.applyFilters(categories)
                  : categories;
          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemCount: filteredCategories.length,
            itemBuilder: (context, index) {
              final category = filteredCategories[index];
              final isCategoryInCart =
                  cartProvider.isCategoryInCart(category.id);
              return CategoryCard(
                category: category,
                isInCart: isCategoryInCart,
              );
            },
          );
        },
      ),
    );
  }
}
