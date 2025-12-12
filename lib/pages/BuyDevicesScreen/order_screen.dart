import 'package:flutter/material.dart';
import 'package:guard_time/utils/appstate.dart';
import 'package:guard_time/utils/models.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  OrderModel order = AppState().order ?? OrderModel();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Screen'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Order Placing Date: ${order.orderPlacingDate}"),
          Text("Order Placing Time: ${order.orderPlacingTime}"),
          Text("Order Status: ${order.orderStatus}"),
          Text("Order Description: ${order.orderDescription}"),
          Text("Order Expiry Date: ${order.orderExpiryDate}"),
          Text("Order Expiry Time: ${order.orderExpiryTime}"),
          // Text("Order Benefits: ${order.offer!.benefits![0]}"),
        ],
      ),
    );
  }
}
