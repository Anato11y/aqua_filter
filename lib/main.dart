import 'package:aqua_filter/screens/onboarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Импортируем Provider
import 'package:aqua_filter/providers/cart_provider.dart'; // Импортируем CartProvider

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AquaFilterApp());
}

class AquaFilterApp extends StatelessWidget {
  const AquaFilterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => CartProvider()), // Добавляем CartProvider
      ],
      child: MaterialApp(
        title: 'AquaFilter',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const OnboardingScreen(),
      ),
    );
  }
}
