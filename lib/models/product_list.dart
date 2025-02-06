import 'package:aqua_filter/models/product_model.dart';

List<Product> productList = [
  Product(
    id: '1',
    name: 'Фильтр для кухни AquaPro',
    description: 'Эффективная система фильтрации воды.',
    price: 199.99,
    imageUrl: 'assets/products/filter1.png',
    characteristics: ['Тип: Кухня', 'Производительность: 10 л/мин'],
    categoryId: "LlTrdlk18f6OYjhkO9l7",
  ),
  Product(
    id: '2',
    name: 'Сменный картридж AquaClean',
    description: 'Сменный картридж для фильтров.',
    price: 49.99,
    imageUrl: 'assets/products/cartridge1.png',
    characteristics: ['Материал: PP-вата', 'Срок службы: 6 месяцев'],
    categoryId: "LlTrdlk18f6OYjhkO9l7",
  ),
  // Добавьте больше товаров...
];
