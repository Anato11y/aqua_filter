class User {
  final String? email; // Email пользователя
  final String? name; // Имя пользователя
  final int? bonusBalance; // Баланс бонусов (добавляем это поле)
  final List<Purchase> purchaseHistory; // История покупок

  User({
    this.email,
    this.name,
    this.bonusBalance, // Добавляем bonusBalance как необязательное поле
    this.purchaseHistory = const [],
  });
}

class Purchase {
  final String productName; // Название товара
  final double price; // Цена товара
  final DateTime date; // Дата покупки

  Purchase({
    required this.productName,
    required this.price,
    required this.date,
  });
}
