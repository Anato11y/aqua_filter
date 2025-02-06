import 'package:aqua_filter/screens/onboarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart'; // Импорт пакета flutter

import 'firebase_options.dart'; // Импорт сгенерированного файла/ Импорт сгенерированного файла

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
    return MaterialApp(
      title: 'AquaFilter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const OnboardingScreen(),
    );
  }
}
