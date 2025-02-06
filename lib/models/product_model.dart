// models/product.dart
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> characteristics;
  final String categoryId;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.characteristics,
    required this.categoryId,
  });

  // Преобразование в Map для Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'characteristics': characteristics,
      'categoryId': categoryId, // Добавлено поле categoryId
    };
  }

  // Создание объекта из Map с защитой от null-значений
  factory Product.fromMap(Map<String, dynamic> map, String documentId) {
    return Product(
      id: documentId,
      name: map['name'] ?? 'Без названия',
      categoryId: map['categoryId']?.toString() ?? '',
      imageUrl: map['imageUrl'] ?? 'https://via.placeholder.com/200',
      price: (map['price'] is num)
          ? (map['price'] as num).toDouble()
          : double.tryParse(map['price'].toString()) ?? 0.0,
      description: map['description'] ?? 'Описание отсутствует',
      characteristics: _parseCharacteristics(map['characteristics']),
    );
  }

// Функция для корректного парсинга `characteristics`
  static List<String> _parseCharacteristics(dynamic characteristics) {
    if (characteristics == null) {
      return []; // Если null, возвращаем пустой список
    }

    if (characteristics is List) {
      return List<String>.from(
          characteristics); // Если это уже List<String>, просто возвращаем
    } else if (characteristics is Map<String, dynamic>) {
      return characteristics.entries
          .map((e) => "${e.key}: ${e.value}")
          .toList();
      // Преобразуем Map в List<String>
    }

    return []; // Если формат неизвестен, возвращаем пустой список
  }

// Метод для обработки цены (если в Firestore она записана строкой)
  static double parsePrice(dynamic price) {
    if (price is num) {
      return price.toDouble(); // Если уже число, вернуть как есть
    }
    if (price is String) {
      return double.tryParse(price.replaceAll(" ", "").replaceAll(",", ".")) ??
          0.0;
    }
    return 0.0;
  }
}
