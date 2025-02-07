import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  /// ✅ Метод оформления заказа
  void _submitOrder(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // 🔹 Отправка заказа (будущая интеграция с сервером или Firebase)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заказ успешно оформлен!'),
        ),
      );

      // 🔹 Очищаем корзину после успешного заказа
      cartProvider.clearCart();

      // 🔹 Возвращаем пользователя на главную страницу
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
                  final product = cartProvider.items.keys.elementAt(index);
                  final quantity = cartProvider.items[product]!;

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
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _submitOrder(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
