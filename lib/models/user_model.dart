class UserModel {
  final String id;
  final String name;
  final String email;
  double bonusBalance;
  List<Map<String, dynamic>> orderHistory;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.bonusBalance = 0.0,
    this.orderHistory = const [],
  });

  // 🔹 Конвертация в JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'bonusBalance': bonusBalance,
      'orderHistory': orderHistory,
    };
  }

  // 🔹 Создание объекта из JSON
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      bonusBalance: map['bonusBalance']?.toDouble() ?? 0.0,
      orderHistory: List<Map<String, dynamic>>.from(map['orderHistory'] ?? []),
    );
  }
}
