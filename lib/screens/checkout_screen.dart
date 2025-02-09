import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aqua_filter/providers/cart_provider.dart';
import 'package:aqua_filter/screens/login_screen.dart';

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

  /// ✅ **Метод проверки авторизации**
  Future<bool> _checkAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('❌ Пользователь не авторизован! Перенаправляем на `AuthScreen`.');
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );

      return FirebaseAuth.instance.currentUser != null;
    }
    return true;
  }

  /// ✅ **Метод оформления заказа**
  Future<void> _submitOrder(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('❌ Ошибка: Оформление заказа без авторизации невозможно.');
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      double totalAmount = cartProvider.totalAmount;
      double bonusEarned = totalAmount * 0.05; // 5% от суммы заказа

      final orderData = {
        'userId': user.uid,
        'name': _name,
        'phone': _phone,
        'address': _address,
        'totalAmount': totalAmount,
        'bonusEarned': bonusEarned,
        'date': Timestamp.now(),
        'items': cartProvider.items.values.map((item) {
          return {
            'name': item['product'].name,
            'productId': item['product'].id,
            'price': item['product'].price,
            'quantity': item['quantity'],
          };
        }).toList(),
      };

      final orderRef =
          await FirebaseFirestore.instance.collection('orders').add(orderData);
      print('✅ Заказ сохранён в `orders/${orderRef.id}`');

      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userData = await userRef.get();
      double currentBonus =
          (userData['bonusBalance'] as num?)?.toDouble() ?? 0.0;
      double newBonusBalance = currentBonus + bonusEarned;

      await userRef.update({'bonusBalance': newBonusBalance});
      print('✅ Бонусы обновлены: +$bonusEarned (Итого: $newBonusBalance)');

      cartProvider.clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Заказ успешно оформлен!')),
      );

      Navigator.pop(context);
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
        iconTheme: const IconThemeData(color: Colors.white),
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
                  final product =
                      cartProvider.items.values.elementAt(index)['product'];
                  final quantity =
                      cartProvider.items.values.elementAt(index)['quantity'];

                  return ListTile(
                    leading: Image.network(
                      product.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported),
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
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (await _checkAuth()) {
                          _submitOrder(context);
                        }
                      },
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

/////////////////////
