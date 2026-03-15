import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:model_order_test/api/api.dart';
import 'package:model_order_test/models/order.dart';

class OrderService {
  final http.Client client;

  OrderService({required this.client});

  Future<Order> createOrder({
    required int userId,
    required int serviceId,
  }) async {
    final uri = Uri.parse('https://example.com/api/orders');
    try {
      final response = await client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'userId': userId, 'serviceId': serviceId}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json =
            jsonDecode(response.body) as Map<String, dynamic>;
        return Order.fromJson(json);
      }

      if (response.statusCode >= 400) {
        String errorMessage = 'Failed to create order';
        try {
          final Map<String, dynamic> json =
              jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = json['message'] as String? ?? errorMessage;
        } catch (_) {}
        throw ApiException(message: errorMessage);
      }

      throw ApiException(message: 'Server error');
    } on SocketException {
      throw ApiException(message: 'No internet connection');
    } on TimeoutException {
      throw ApiException(message: 'Try again');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Failed order');
    }
  }
}
