import 'package:flutter/material.dart';
import 'package:aqua_filter/providers/user_provider.dart'
    as user_model; // Используем алиас
import 'package:provider/provider.dart'; // Провайдер пользователя

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user =
        Provider.of<user_model.UserProvider>(context, listen: false).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Личный кабинет'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Информация о пользователе
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Информация о пользователе',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (user != null) Text('Email: ${user.email}'),
                    if (user != null)
                      Text(
                          'Имя: ${user.name ?? 'Не указано'}'), // Используем поле name
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Бонусная система
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Бонусы',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (user != null)
                      Text(
                          'Баланс бонусов: ${user.bonusBalance ?? 0} баллов'), // Используем bonusBalance
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // История покупок
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'История покупок',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (user != null && user.purchaseHistory.isNotEmpty)
                      for (final purchase in user.purchaseHistory)
                        ListTile(
                          title: Text(purchase.productName),
                          subtitle:
                              Text('${purchase.date} - ${purchase.price} ₽'),
                        ),
                    if (user != null && user.purchaseHistory.isEmpty)
                      const Center(child: Text('Пока нет покупок')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
