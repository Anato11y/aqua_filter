import 'dart:convert';
import 'package:http/http.dart' as http;

class YooKassaService {
  static const String shopId = '1012940'; // ✅ Укажите реальный Shop ID
  static const String secretKey =
      'test_NIdH45IG4f1vMCQaIuvNZ8u9iDMh-wbi41b-BheD8Qo'; // ✅ Укажите реальный Secret Key

  /// ✅ **Метод для создания платежа в YooKassa**
  static Future<String?> makePayment(double amount, String currency) async {
    final String authHeader =
        'Basic ${base64Encode(utf8.encode('$shopId:$secretKey'))}';

    final Uri url = Uri.parse('https://api.yookassa.ru/v3/payments');

    final Map<String, dynamic> body = {
      "amount": {"value": amount.toStringAsFixed(2), "currency": currency},
      "confirmation": {
        "type": "redirect",
        "return_url": "https://ваш-сайт.ру/success" // ✅ Замени на свой URL
      },
      "capture": true,
      "description": "Оплата заказа в AquaFilter",
      "metadata": {"order_id": "12345"},
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
          'Idempotence-Key': DateTime.now().millisecondsSinceEpoch.toString(),
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['confirmation']['confirmation_url'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
