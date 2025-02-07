import 'package:aqua_filter/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:aqua_filter/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    _checkUserAuthStatus(); // ✅ Проверяем авторизацию
  }

  /// Проверяет, авторизован ли пользователь
  void _checkUserAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // Анимация заставки
    final user = FirebaseAuth.instance.currentUser;

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => user != null
              ? const HomeScreen()
              : const AuthScreen(), // ✅ Переключение на нужный экран
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', width: 150),
              const SizedBox(height: 20),
              const Text(
                'AquaFilter',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
