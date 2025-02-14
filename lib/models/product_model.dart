// models/product.dart

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> characteristics;
  final String categoryId;
  final double efficiency;
  bool isHidden; // 🔹 Добавляем флаг

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.characteristics,
    required this.categoryId,
    required this.efficiency,
    this.isHidden = false, // 🔹 По умолчанию товар видимый
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
      'categoryId': categoryId,
    };
  }

  // Создание объекта из Map с защитой от null-значений
  factory Product.fromMap(Map<String, dynamic> map, String documentId) {
    return Product(
      id: documentId,
      name: map['name'] ?? 'Без названия',
      categoryId: map['categoryId']?.toString() ?? 'unknown', // ✅ Исправлено
      imageUrl: map['imageUrl'] ?? 'https://via.placeholder.com/200',
      price: parsePrice(map['price']),
      description: map['description'] ?? 'Описание отсутствует',
      characteristics: _parseCharacteristics(map['characteristics']),
      efficiency: (map['efficiency'] as num?)?.toDouble() ?? 0.0,
      isHidden: map['isHidden'] ?? false, // 🔹 Загружаем из Firestore
    );
  }

  // Функция для корректного парсинга `characteristics`
  static List<String> _parseCharacteristics(dynamic characteristics) {
    if (characteristics == null) return [];
    if (characteristics is List) return List<String>.from(characteristics);
    if (characteristics is Map<String, dynamic>) {
      return characteristics.entries
          .map((e) => "${e.key}: ${e.value}")
          .toList();
    }
    return [];
  }

  // Метод для обработки цены (если в Firestore она записана строкой)
  static double parsePrice(dynamic price) {
    if (price is num) return price.toDouble();
    if (price is String) {
      return double.tryParse(price.replaceAll(" ", "").replaceAll(",", ".")) ??
          0.0;
    }
    return 0.0;
  }
}
