import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StripeService {
  static const String publishableKey =
      "YOUR_PUBLISHABLE_KEY"; // ✅ Укажи свой ключ
  static const String secretKey =
      "YOUR_SECRET_KEY"; // ✅ Укажи свой секретный ключ
  static const String apiUrl = "https://api.stripe.com/v1/payment_intents";

  static void init() {
    Stripe.publishableKey = publishableKey;
  }

  static Future<void> makePayment(double amount, String currency) async {
    try {
      // ✅ 1. Создать Payment Intent
      final paymentIntent = await createPaymentIntent(amount, currency);

      // ✅ 2. Открыть UI для оплаты
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Aqua Filter Store',
        ),
      );

      // ✅ 3. Открываем форму оплаты
      await Stripe.instance.presentPaymentSheet();
      debugPrint("✅ Платеж успешно выполнен!");
    } catch (e) {
      debugPrint("❌ Ошибка платежа: $e");
    }
  }

  // Метод создания Payment Intent через Stripe API
  static Future<Map<String, dynamic>> createPaymentIntent(
      double amount, String currency) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': (amount * 100)
              .toInt()
              .toString(), // Stripe принимает суммы в центах
          'currency': currency,
          'payment_method_types[]': 'card',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("❌ Ошибка создания Payment Intent: $e");
      return {'error': 'Не удалось создать Payment Intent'};
    }
  }
}
