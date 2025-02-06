import 'package:flutter/material.dart';
import 'package:aqua_filter/widgets/product_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aqua_filter/models/product_model.dart';
import 'package:aqua_filter/screens/product_detail_screen.dart'; // Экран деталей

class CatalogScreen extends StatelessWidget {
  final String categoryId;

  const CatalogScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог товаров'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('categoryId', isEqualTo: categoryId.toString())
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Ошибка загрузки данных'));
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('В этой категории пока нет товаров'));
          }

          // Преобразуем Firestore данные в список товаров
          final products = snapshot.data!.docs.map((doc) {
            return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                double maxWidth = constraints.maxWidth;
                double cardWidth = 200; // Фиксированная ширина карточки
                int crossAxisCount = (maxWidth / cardWidth)
                    .floor(); // Количество карточек в строке

                return GridView.builder(
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent:
                        cardWidth, // Фиксированная ширина карточки
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.65, // Пропорции карточки
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(product: product),
                          ),
                        );
                      },
                    );
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
