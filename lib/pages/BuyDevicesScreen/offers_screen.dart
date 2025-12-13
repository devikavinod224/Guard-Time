import 'dart:async';

import 'package:flutter/material.dart';
import 'package:parents_app/pages/BuyDevicesScreen/order_confirmation_screen.dart';
import 'package:parents_app/utils/api.dart';
import 'package:parents_app/utils/appstate.dart';
import 'package:parents_app/utils/models.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final StreamController<List<OfferModel>> _offerStreamController =
      StreamController<List<OfferModel>>();

  @override
  void initState() {
    fetchOffers();
    super.initState();
  }

  Future<bool> fetchOffers() async {
    try {
      List<OfferModel?> fetchedOffers = [];
      var value = await AppState().fetchOffers();
      if (value) {
        fetchedOffers = AppState().offers!;
      }
      _offerStreamController.add(fetchedOffers
          .where((offer) => offer != null)
          .cast<OfferModel>()
          .toList());
      print(fetchedOffers);
      return true;
    } catch (error) {
      print('Error fetching devices: $error');
      return false;
    }
  }

  @override
  void dispose() {
    _offerStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offers'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Expanded(
          child: StreamBuilder(
            stream: _offerStreamController.stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error fetching offers'));
              } else if (!snapshot.hasData ||
                  snapshot.data == null ||
                  snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No offers available'),
                );
              } else {
                List<OfferModel> offers = snapshot.data!;
                return Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: offers.length,
                    itemBuilder: (context, index) {
                      OfferModel offer = offers[index];
                      return CustomCard(offer: offer);
                    },
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class CustomCard extends StatefulWidget {
  const CustomCard({
    required this.offer,
    super.key,
  });
  final OfferModel offer;

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  double getMonths() {
    // apply string operation and extract number of months from widget.offer.tenure, its format is like "0000/12/00" which is basically "YYYY/MM/DD"

    List<String> tenure = widget.offer.tenure!.split('/');
    String year = tenure[0];
    String month = tenure[1];
    double months = double.parse(year) * 12 + double.parse(month);
    return months;
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "Code: ${response.code}\nDescription: ${response.message}\nMetadata:${response.error.toString()}"),
        backgroundColor: Colors.red,
      ),
    );
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) async {
    print(response.data.toString());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Payment Successfull"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const OrderConfirmationScreen(),
      ),
    );
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${response.walletName}"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<bool> placeOrder(OfferModel offer) async {
    try {
      var temp = await AppState().placeOrder(offer);
      if (temp) {
        Razorpay razorpay = Razorpay();
        var options = {
          'key': '',
          'amount': offer.discountedPrice! * 100,
          'order_id': AppState().order!.orderId!,
          'name': 'Parents App',
          'description': 'For your order purchase',
          'timeout': 600, // in seconds
          'prefill': {
            'contact': '9123456789',
            'email': 'gautambhatejaexample@gmail.com'
          }
        };
        razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
        razorpay.on(
            Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
        razorpay.on(
            Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
        try {
          razorpay.open(options);
        } catch (e) {
          print(e.toString());
        }
      } else {
        if (!mounted) return true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error placing order'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return true;
    } catch (error) {
      print('Error fetching devices: $error');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          clipBehavior: Clip.antiAlias,
          isScrollControlled: true,
          context: context,
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.offer.title!,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          "₹${widget.offer.discountedPrice!.toString()}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "₹${widget.offer.originalPrice!.toString()}",
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Save ₹${(widget.offer.originalPrice! - widget.offer.discountedPrice!).toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.offer.gst != null
                              ? "+ ₹${widget.offer.gst} GST"
                              : "",
                        ),
                      ),
                      if (getMonths() != 0)
                        Expanded(
                          child: Text(
                            "(₹${((widget.offer.discountedPrice!) / getMonths()).toStringAsFixed(2)}/Month)",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "No. of devices: ${widget.offer.tokenCount!}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Benefits',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (String item in widget.offer.benefits!)
                    Column(
                      children: [
                        ListTile(
                          title: Text(item),
                          leading: const Icon(Icons.star_border_purple500),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 0),
                        ),
                        Divider(
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      minimumSize: Size(double.infinity,
                          MediaQuery.of(context).size.height * 0.06),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      AppState().currentOffer = widget.offer;
                      AppState().currentOfferId = widget.offer.id;
                      await placeOrder(widget.offer);
                    },
                    child: const Text(
                      'Buy Now',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Card(
        margin: const EdgeInsets.all(10),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          side: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.offer.title!,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_android,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text("${widget.offer.tokenCount}"),
                      const Text(
                        " Device(s)",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.grey),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "₹${widget.offer.discountedPrice!.toString()}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "₹${widget.offer.originalPrice!.toString()}",
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Save ₹${(widget.offer.originalPrice! - widget.offer.discountedPrice!).toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(widget.offer.gst != null
                        ? "+ ₹${widget.offer.gst} GST"
                        : ""),
                  ),
                  Expanded(
                    child: Text(
                      "(₹${((widget.offer.discountedPrice!) / getMonths()).toStringAsFixed(2)}/Month)",
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
