import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  static const String paystackApiUrl = 'https://api.paystack.co/';

  Future<bool> initiatePayment({
    String? cardNumber,
    String? cvc,
    int? expiryMonth,
    int? expiryYear,
    int? amount,
    String? email,
    String? publicKey,
  }) async {
    final String apiUrl = '${paystackApiUrl}transaction/initialize';

    Map<String, String> headers = {
      'Authorization': 'Bearer $publicKey',
      'Content-Type': 'application/json',
    };

    Map<String, dynamic> body = {
      'email': email,
      'amount': amount,
      'card': {
        'number': cardNumber,
        'cvv': cvc,
        'expiry_month': expiryMonth,
        'expiry_year': expiryYear,
      },
    };

    final response = await http.post(paystackApiUrl as Uri,
        headers: headers, body: json.encode(body));

    if (response.statusCode == 200) {
      // Parse the response JSON and check the payment status
      Map<String, dynamic> responseBody = json.decode(response.body);
      bool paymentStatus = responseBody['status'];
      return paymentStatus;
    } else {
      throw Exception('Failed to initiate payment');
    }
  }
}
