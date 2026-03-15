import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:model_order_test/controllers/order_controllers.dart';
import 'package:model_order_test/service/order_service.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late final OrderControllers controller;

  @override
  void initState() {
    super.initState();

    controller = OrderControllers(
      orderService: OrderService(client: http.Client()),
    );

    controller.addListener(() {
      setState(() {});
    });
  }

  Future<void> _createOrder() async {
    await controller.submitOrder(userId: 1, serviceId: 101);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = controller.status == OrderStatus.loading;
    final isError = controller.status == OrderStatus.error;
    final isSuccess = controller.status == OrderStatus.success;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Order')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading) const CircularProgressIndicator(),

              if (isError && controller.errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],

              if (isSuccess && controller.order != null) ...[
                const SizedBox(height: 16),
                Text('Order ID: ${controller.order!.orderId}'),
                Text('Status: ${controller.order!.status}'),
                if (controller.order!.paymentUrl != null)
                  Text('Payment: ${controller.order!.paymentUrl}'),
              ],

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _createOrder,
                  child: Text(isError ? 'Retry' : 'Create Order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
