import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aqua_filter/providers/cart_provider.dart';
import 'package:aqua_filter/screens/login_screen.dart';
import 'package:aqua_filter/services/yookassa_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String _deliveryMethod = 'Курьер';
  bool _useBonuses = false;
  double _bonusToUse = 0.0;
  double _userBonusBalance = 0.0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadUserBonuses();
  }

  /// ✅ **Загрузка бонусного баланса пользователя**
  Future<void> _loadUserBonuses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _userBonusBalance =
            (userDoc.data()?['bonusBalance'] as num?)?.toDouble() ?? 0.0;
      });
    }
  }

  /// ✅ **Проверка авторизации**
  Future<bool> _checkAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
      return FirebaseAuth.instance.currentUser != null;
    }
    return true;
  }

  /// ✅ **Оформление заказа**
  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка: Пользователь не авторизован!')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      double totalAmount = cartProvider.totalAmount;
      double bonusUsed = _useBonuses ? _bonusToUse : 0.0;
      double finalAmount = totalAmount - bonusUsed;
      double bonusEarned = totalAmount * 0.05;

      String? paymentUrl;
      if (finalAmount > 0) {
        print('🔹 Запуск оплаты через YooKassa на сумму $finalAmount ₽');
        paymentUrl = await YooKassaService.makePayment(finalAmount, 'RUB');
        if (paymentUrl == null) {
          throw Exception('Ошибка оплаты через YooKassa');
        }
      }

      final orderData = {
        'userId': user.uid,
        'name': _name,
        'phone': _phone,
        'address': _deliveryMethod == 'Курьер' ? _address : 'Самовывоз',
        'deliveryMethod': _deliveryMethod,
        'totalAmount': totalAmount,
        'bonusUsed': bonusUsed,
        'bonusEarned': bonusEarned,
        'finalAmount': finalAmount,
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
      print('✅ Заказ сохранён в orders/${orderRef.id}');

      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userRef.update(
          {'bonusBalance': _userBonusBalance - bonusUsed + bonusEarned});
      print('✅ Бонусы обновлены: -$bonusUsed + $bonusEarned');

      cartProvider.clearCart();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заказ успешно оформлен!')),
      );

      if (paymentUrl != null) {
        print('🔹 Открываем страницу оплаты: $paymentUrl');
        final Uri paymentUri = Uri.parse(paymentUrl);
        if (await launchUrl(paymentUri, mode: LaunchMode.externalApplication)) {
          print('✅ URL открыт успешно');
        } else {
          print('❌ Не удалось открыть ссылку');
        }
      } else {
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      print('❌ Ошибка оформления заказа: $e');
      print(stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка заказа: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            const Text('Выберите способ доставки:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(
              title: const Text('Курьер'),
              leading: Radio(
                value: 'Курьер',
                groupValue: _deliveryMethod,
                onChanged: (value) => setState(() => _deliveryMethod = value!),
              ),
            ),
            ListTile(
              title: const Text('Самовывоз'),
              leading: Radio(
                value: 'Самовывоз',
                groupValue: _deliveryMethod,
                onChanged: (value) => setState(() => _deliveryMethod = value!),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Ваше имя'),
                    validator: (value) =>
                        value!.isNotEmpty ? null : 'Введите имя',
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
                  if (_deliveryMethod == 'Курьер')
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Адрес доставки'),
                      validator: (value) =>
                          value!.isNotEmpty ? null : 'Введите адрес',
                      onSaved: (value) => _address = value!,
                    ),
                ],
              ),
            ),
            SwitchListTile(
              title: Text(
                  'Использовать бонусы (Доступно: ${_userBonusBalance.toStringAsFixed(2)} ₽)'),
              value: _useBonuses,
              onChanged: (bool value) {
                setState(() {
                  _useBonuses = value;
                  _bonusToUse = _useBonuses ? _userBonusBalance : 0.0;
                });
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: _isProcessing
                    ? null
                    : () async {
                        if (await _checkAuth()) _submitOrder();
                      },
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Подтвердить заказ',
                        style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
