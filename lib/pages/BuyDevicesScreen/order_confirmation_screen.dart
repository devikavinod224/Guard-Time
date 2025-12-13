import 'package:flutter/material.dart';
import 'package:parents_app/pages/BuyDevicesScreen/order_screen.dart';
import 'package:parents_app/utils/appstate.dart';

class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key});

  @override
  OrderConfirmationScreenState createState() => OrderConfirmationScreenState();
}

class OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    placeOrder();
  }

  void placeOrder() async {
    var value = await AppState().placeOrder(AppState().currentOffer);
    if (value) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment Successfull"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error placing order'),
          backgroundColor: Colors.red,
        ),
      );
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const OrderScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
