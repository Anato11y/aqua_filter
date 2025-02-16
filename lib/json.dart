import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadDataToFirestore() async {
  try {
    // Шаг 1: Загрузка данных из JSON-файла
    final String response = await rootBundle.loadString('assets/products.json');
    final List<dynamic> data = json.decode(response);

    // Шаг 2: Подключение к Firestore
    final db = FirebaseFirestore.instance;

    // Шаг 3: Загрузка данных в коллекцию "products"
    for (var product in data) {
      try {
        // Генерируем уникальный ID документа или используем существующий
        if (product['id'] == null || product['id'].toString().isEmpty) {
          product['id'] = db.collection('products').doc().id;
        }

        // Добавляем товар в Firestore
        await db.collection('products').doc(product['id']).set(product);
        print('Товар успешно добавлен: ${product['name']}');
      } catch (e) {
        print('Ошибка при добавлении товара "${product['name']}": $e');
      }
    }

    print('Загрузка данных завершена!');
  } catch (e) {
    print('Общая ошибка: $e');
  }
}
