import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guard_time/utils/appstate.dart';
import 'package:guard_time/utils/models.dart';
import 'package:guard_time/utils/widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool isHistoryFetched = false;
  List<OrderModel> orderHistory = AppState().orderHistoryList;

  @override
  void initState() {
    for (int i = 0; i < orderHistory.length; i++) {
      print("${orderHistory[i].orderStatus}  ${orderHistory[i].paymentStatus}");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const HeadingText(
          text: "Payment History",
          size: 20,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: orderHistory.length,
                itemBuilder: (context, index) {
                  return HistoryTileWidget(
                    fText: orderHistory[index].paymentStatus.toString(),
                    sText: orderHistory[index].orderStatus.toString(),
                    tText: AppState().convertDate(
                        orderHistory[index].orderPlacingDate.toString()),
                    price: orderHistory[index].discountedPrice.toString(),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

class HistoryTileWidget extends StatefulWidget {
  const HistoryTileWidget({
    super.key,
    required this.fText,
    required this.sText,
    required this.tText,
    required this.price,
    this.isLower = false,
  });
  final String fText;
  final String sText;
  final String tText;
  final String price;
  final bool isLower;

  @override
  State<HistoryTileWidget> createState() => _HistoryTileWidgetState();
}

class _HistoryTileWidgetState extends State<HistoryTileWidget> {
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    Color selectedColor = Theme.of(context).colorScheme.primary;
    Color unselectedColor = Theme.of(context).colorScheme.outlineVariant;
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isSelected ? selectedColor : unselectedColor,
              width: 2,
            ),
            left: BorderSide(
              color: isSelected ? selectedColor : unselectedColor,
              width: 2,
            ),
            right: BorderSide(
              color: isSelected ? selectedColor : unselectedColor,
              width: 2,
            ),
            bottom: widget.isLower
                ? BorderSide(
                    color: isSelected ? selectedColor : unselectedColor,
                    width: 2,
                  )
                : isSelected
                    ? BorderSide(
                        color: selectedColor,
                        width: 2,
                      )
                    : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Icon(Icons.arrow_forward_rounded),
            SizedBox(width: MediaQuery.of(context).size.width * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.fText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.sText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.tText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "₹ ${widget.price}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
