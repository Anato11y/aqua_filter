import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aqua_filter/providers/cart_provider.dart';
import 'package:aqua_filter/screens/login_screen.dart';
import 'package:aqua_filter/screens/profile_screen.dart';
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
    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка: Ваша корзина пуста!')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final double totalAmount = cartProvider.totalAmount;
      final double bonusUsed = _useBonuses ? _bonusToUse : 0.0;
      final double finalAmount = totalAmount - bonusUsed;
      final double bonusEarned = totalAmount * 0.05;

      // Генерация ссылки оплаты, если finalAmount > 0
      String? paymentUrl;
      if (finalAmount > 0) {
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

      // Сохраняем заказ с авто-генерируемым ID
      await FirebaseFirestore.instance.collection('orders').add(orderData);

      // Обновляем бонусный баланс пользователя
      final double newBonusBalance =
          _userBonusBalance - bonusUsed + bonusEarned;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'bonusBalance': newBonusBalance});

      cartProvider.clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Заказ оформлен! Начислено бонусов: ${bonusEarned.toStringAsFixed(2)} ₽')),
      );

      if (paymentUrl != null) {
        final Uri paymentUri = Uri.parse(paymentUrl);
        await launchUrl(paymentUri, mode: LaunchMode.externalApplication);
      }

      Navigator.pop(context); // Закрываем CheckoutScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    } catch (e) {
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
        child: Form(
          key: _formKey,
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
                  onChanged: (value) =>
                      setState(() => _deliveryMethod = value!),
                ),
              ),
              ListTile(
                title: const Text('Самовывоз'),
                leading: Radio(
                  value: 'Самовывоз',
                  groupValue: _deliveryMethod,
                  onChanged: (value) =>
                      setState(() => _deliveryMethod = value!),
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Ваше имя'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Введите имя' : null,
                onSaved: (value) => _name = value ?? '',
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Телефон'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.length < 10) {
                    return 'Введите корректный номер';
                  }
                  return null;
                },
                onSaved: (value) => _phone = value ?? '',
              ),
              if (_deliveryMethod == 'Курьер')
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Адрес доставки'),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Введите адрес' : null,
                  onSaved: (value) => _address = value ?? '',
                ),
              const SizedBox(height: 10),
              Text(
                'Доступные бонусы: ${_userBonusBalance.toStringAsFixed(2)} ₽',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SwitchListTile(
                title: const Text('Использовать бонусы'),
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
                  onPressed: _isProcessing
                      ? null
                      : () async {
                          if (await _checkAuth()) {
                            _submitOrder();
                          }
                        },
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Подтвердить заказ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
