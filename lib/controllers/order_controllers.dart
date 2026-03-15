import 'package:flutter/material.dart';
import 'package:model_order_test/api/api.dart';
import 'package:model_order_test/models/order.dart';
import 'package:model_order_test/service/order_service.dart';

enum OrderStatus { initial, loading, success, error }

class OrderControllers extends ChangeNotifier {
  final OrderService orderService;

  OrderControllers({required this.orderService});

  OrderStatus status = OrderStatus.initial;
  String? errorMessage;
  Order? order;

  Future<void> submitOrder({
    required int userId,
    required int serviceId,
  }) async {
    status = OrderStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      final createdOrder = await orderService.createOrder(
        userId: userId,
        serviceId: serviceId,
      );

      order = createdOrder;
      status = OrderStatus.success;
    } on ApiException catch (error) {
      errorMessage = error.message;
      status = OrderStatus.error;
    } catch (_) {
      errorMessage = 'Unknown error occurred';
      status = OrderStatus.error;
    }
    notifyListeners();
  }
}
