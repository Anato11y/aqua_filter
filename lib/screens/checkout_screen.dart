import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aqua_filter/providers/cart_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _phone = '';
  String _address = '';

  /// ✅ Метод оформления заказа (теперь данные идут в `orders`)
  Future<void> _submitOrder(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // ❌ Если не авторизован, отправляем на страницу входа
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // 🔹 Считаем сумму заказа
    double totalAmount = cartProvider.totalAmount;
    double bonusEarned = totalAmount * 0.05; // 5% бонусов

    // 🔹 Формируем данные заказа
    Map<String, dynamic> orderData = {
      'userId': user.uid,
      'name': _name, // ✅ Теперь имя сохраняется
      'phone': _phone,
      'address': _address,
      'totalAmount': totalAmount,
      'bonusEarned': bonusEarned,
      'date': FieldValue.serverTimestamp(),
      'items': cartProvider.items.entries.map((entry) {
        return {
          'productId': entry.key,
          'name': entry.value['product'].name,
          'price': entry.value['product'].price,
          'quantity': entry.value['quantity'],
        };
      }).toList(),
    };

    try {
      // ✅ Сохраняем заказ в `orders`
      final orderRef =
          await FirebaseFirestore.instance.collection('orders').add(orderData);
      print('✅ Заказ успешно сохранен в orders/${orderRef.id}');

      // ✅ Обновляем баланс бонусов пользователя в `users`
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userRef.set({
        'bonusBalance': FieldValue.increment(bonusEarned),
      }, SetOptions(merge: true));

      print('✅ Бонусы обновлены: +$bonusEarned');

      // 🔹 Очищаем корзину после оформления заказа
      cartProvider.clearCart();

      // 🔹 Показываем успешное сообщение
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заказ успешно оформлен!')),
      );

      // 🔹 Возвращаем пользователя на главную страницу
      Navigator.pop(context);
    } catch (e) {
      print('❌ Ошибка оформления заказа: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка оформления заказа: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Оформление заказа',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ваш заказ:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: cartProvider.items.length,
                itemBuilder: (context, index) {
                  final productId = cartProvider.items.keys.elementAt(index);
                  final cartItem = cartProvider.items[productId]!;
                  final product = cartItem['product'];
                  final quantity = cartItem['quantity'];

                  return ListTile(
                    leading: Image.network(
                      product.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(product.name),
                    subtitle: Text(
                        '${product.price.toStringAsFixed(2)} ₽ x $quantity'),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Контактные данные',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Ваше имя'),
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : 'Введите имя',
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Телефон'),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value != null && value.length >= 10
                        ? null
                        : 'Введите корректный номер',
                    onSaved: (value) => _phone = value!,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Адрес доставки'),
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : 'Введите адрес',
                    onSaved: (value) => _address = value!,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width *
                        0.8, // 80% ширины экрана
                    child: ElevatedButton(
                      onPressed: () => _submitOrder(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text(
                        'Подтвердить заказ',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
