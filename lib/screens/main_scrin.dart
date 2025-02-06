import 'package:aqua_filter/screens/cart_screen.dart';
import 'package:aqua_filter/screens/category_screen.dart';
import 'package:aqua_filter/screens/profile_screen.dart';
import 'package:flutter/material.dart';

// Главный экран с навигацией
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const CategoryScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index; // 🔥 Обновляем индекс
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue, // 🔥 Цвет активной кнопки
        unselectedItemColor: Colors.grey, // 🔥 Цвет неактивных кнопок
        showSelectedLabels: true, // Показываем текст активной кнопки
        showUnselectedLabels: true, // Показываем текст неактивных кнопок
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
