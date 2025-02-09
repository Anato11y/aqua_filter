import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:aqua_filter/providers/user_provider.dart' as user_model;
import 'package:aqua_filter/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user =
        Provider.of<user_model.UserProvider>(context, listen: false).user;

    if (user == null) {
      // ✅ Перенаправляем пользователя на страницу авторизации
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    print('🔹 Загружаем данные пользователя: ${user.uid}');

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Личный кабинет', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Загружаем данные профиля пользователя
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                print('❌ Ошибка: Данные профиля не найдены в `users`');
                return const Center(
                    child: Text('Ошибка загрузки данных профиля'));
              }

              final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
              final bonusBalance =
                  (userData['bonusBalance'] as num?)?.toDouble() ?? 0.0;
              final displayName = userData['displayName'] ?? 'Имя не указано';

              print('✅ Данные пользователя загружены: $userData');

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Информация о пользователе',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Email: ${user.email}'),
                        Text('Имя: $displayName'),
                        const SizedBox(height: 8),
                        Text(
                          'Баланс бонусов: ${bonusBalance.toStringAsFixed(2)} ₽',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'История заказов:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // ✅ Загружаем историю заказов
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId',
                      isEqualTo: user.uid) // 🔹 Загружаем заказы по `userId`
                  .orderBy('date', descending: true) // 🔹 Сортируем по дате
                  .snapshots(),
              builder: (context, orderSnapshot) {
                if (orderSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (orderSnapshot.hasError) {
                  print('❌ Ошибка загрузки заказов: ${orderSnapshot.error}');
                  return const Center(child: Text('Ошибка загрузки заказов'));
                }

                if (!orderSnapshot.hasData ||
                    orderSnapshot.data!.docs.isEmpty) {
                  print('⚠️ Нет заказов для пользователя ${user.uid}');
                  return const Center(child: Text('У вас пока нет заказов'));
                }

                final orders = orderSnapshot.data!.docs;

                print(
                    '✅ Найдено ${orders.length} заказов для пользователя ${user.uid}');

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index].data() as Map<String, dynamic>;
                    final orderId = orders[index].id;
                    final totalAmount = order['totalAmount'] ?? 0;
                    final bonusEarned = order['bonusEarned'] ?? 0;
                    final orderDate = order['date'] != null
                        ? (order['date'] as Timestamp).toDate().toString()
                        : 'Дата неизвестна';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text('Заказ #$orderId - ${totalAmount} ₽'),
                        subtitle: Text('Бонусы начислены: ${bonusEarned} ₽'),
                        trailing: Text(orderDate),
                        onTap: () {
                          _showOrderDetails(context, order);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ **Метод для показа деталей заказа**
  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) {
        final items =
            (order['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
                [];

        return AlertDialog(
          title: const Text('Детали заказа'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Сумма: ${order['totalAmount']} ₽'),
              Text('Бонусов начислено: ${order['bonusEarned']} ₽'),
              const Divider(),
              const Text('Товары:'),
              ...items.map((item) => ListTile(
                    title: Text(item['name']),
                    subtitle: Text('${item['price']} ₽ x ${item['quantity']}'),
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }
}
