import 'package:flutter/material.dart';
import 'package:guard_time/utils/widgets.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class QRScreen extends StatefulWidget {
  final String qrCode;
  final String? otp;
  const QRScreen({super.key, required this.qrCode, this.otp});

  @override
  QRScreenState createState() => QRScreenState();
}

class QRScreenState extends State<QRScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const HeadingText(
          text: 'Device nickname',
          size: 20,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(100.0),
              child: PrettyQrView.data(
                data: widget.qrCode, // replace with your data

                errorCorrectLevel: QrErrorCorrectLevel.M,
                decoration: PrettyQrDecoration(
                  // image: PrettyQrDecorationImage(
                  //     image: AssetImage('assets/images/profileIcon.png')),
                  shape: PrettyQrSmoothSymbol(
                    color: Theme.of(context).primaryColor,
                    roundFactor: 0.5,
                  ),
                ),
              ),
            ),
            Text(
              "OTP: [${widget.otp}]",
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
