import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aqua_filter/widgets/product_card.dart';
import 'package:aqua_filter/models/product_model.dart';
import 'package:aqua_filter/screens/product_detail_screen.dart';
import 'package:aqua_filter/screens/cart_screen.dart';
import 'package:aqua_filter/screens/category_screen.dart';
import 'package:aqua_filter/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:aqua_filter/providers/filter_provider.dart';

class CatalogScreen extends StatelessWidget {
  final String categoryId;

  const CatalogScreen({super.key, required this.categoryId});

  void _onItemTapped(BuildContext context, int index) {
    Widget screen;
    switch (index) {
      case 0:
        screen = const CategoryScreen();
        break;
      case 1:
        screen = const CartScreen();
        break;
      case 2:
        screen = const ProfileScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterProvider = Provider.of<FilterProvider>(context);
    final waterAnalysis = filterProvider.waterAnalysis;

    // Если категория — «Установки ионообменные» или «Установки фильтрации безреагентные»,
    // убираем кнопку "В корзину".
    final bool hideCartButton = (categoryId == 'Установки ионообменные' ||
        categoryId == 'Установки фильтрации безреагентные');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Каталог категории',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 33, 150, 243),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('categoryId', isEqualTo: categoryId)
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

          // Преобразуем документы Firestore в список Product
          final products = snapshot.data!.docs.map((doc) {
            return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).where((product) {
            double efficiency = product.efficiency;
            double systemPerformance = waterAnalysis.systemPerformance;

            // 🔹 Фильтрация товаров по производительности
            if (categoryId == 'Установки ионообменные') {
              if (systemPerformance > efficiency ||
                  efficiency > systemPerformance * 1.5) {
                return false;
              }
            } else if (categoryId == 'Фильтры грубой очистки') {
              if (systemPerformance > efficiency ||
                  efficiency > systemPerformance * 5) {
                return false;
              }
            } else if (categoryId == 'Установки фильтрации безреагентные') {
              if (systemPerformance > efficiency ||
                  efficiency > systemPerformance * 1.3) {
                return false;
              }
            }
            return true;
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                double maxWidth = constraints.maxWidth;
                double cardWidth = 200;
                (maxWidth / cardWidth).floor();

                return GridView.builder(
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: cardWidth,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.55,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      hideCartButton: hideCartButton,
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) => _onItemTapped(context, index),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Категории',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Корзина',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
