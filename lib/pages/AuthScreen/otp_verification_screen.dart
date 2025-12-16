import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:parents_app/pages/AuthScreen/login.dart';
import 'package:parents_app/pages/AuthScreen/signup_screen.dart';
import 'package:parents_app/pages/HomeScreen/navigation_bar.dart';
import 'package:parents_app/utils/appstate.dart';
import 'package:parents_app/utils/image_cache_manager.dart';
import 'package:parents_app/utils/widgets.dart';

class VerificationScreen extends StatefulWidget {
  final String mobNumber;
  const VerificationScreen({super.key, required this.mobNumber});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool isLoading = false;
  String otpCode = "";
  @override
  void initState() {
    isLoading = false;
    super.initState();
  }

  void submitOtp(String otp, context) async {
    try {
      isLoading = true;
      setState(() {});

      if (AppState().userPhone == null || AppState().userPhone!.isEmpty) {
        AppState().userPhone = widget.mobNumber;
      }

      int responseCode = await AppState().verifyOtp(otp);
      isLoading = false;
      setState(() {});
      if (responseCode > 201) {
        // error
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("enterCorrectOtp".tr),
            backgroundColor: Theme.of(context).colorScheme.error));
      } else if (responseCode == 201) {
        // new user so navigate to signup screen
        Get.to(() => SignupScreen(phoneNumber: widget.mobNumber));
      } else if (responseCode == 200) {
        // user already exists so navigate to home screen
        final List<String>? deviceIds = await AppState().fetchDeviceIds();
        if (deviceIds != null && deviceIds.isNotEmpty) {
          final imageCacheManager = ImageCacheManager();
          // Use addPostFrameCallback to ensure the context is available
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await imageCacheManager.preloadImages(deviceIds, context);
          });
        }
        Get.offAll(() => const MyHomePage());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Something went wrong".tr),
            backgroundColor: Theme.of(context).colorScheme.error));
      }
    } catch (e) {
      isLoading = false;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("An error occurred: $e"),
          backgroundColor: Theme.of(context).colorScheme.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: HeadingText(
          text: "otpVerification".tr,
          size: 20,
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // const Text("We texted you a code \n\nPlease enter it below"),
              Text("${"textedCode".tr} \n\n${"pleaseEnter".tr}"),
              const SizedBox(height: 30),
              OtpTextField(
                autoFocus: true,
                keyboardType: TextInputType.number,
                numberOfFields: 6,
                focusedBorderColor: Theme.of(context).primaryColor,
                //set to true to show as box or false to show as dash
                showFieldAsBox: true,
                //runs when a code is typed in
                onCodeChanged: (String code) {
                  //handle validation or checks here
                  otpCode = code;
                },
                //runs when every textfield is filled
                onSubmit: (String verificationCode) {
                  otpCode = verificationCode;
                  submitOtp(verificationCode, context);
                },
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Get.offAll(() => LoginPage(
                        mobileNumber: widget.mobNumber,
                      ));
                },
                child: Text(
                  "+91 ${widget.mobNumber}, ${"notPhone".tr}",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Center(
                child: isLoading == true
                    ? CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      )
                    : ElevatedButtonCustomized(
                        text: "verifyOtp".tr,
                        color: Theme.of(context).primaryColor,
                        onPressed: () {
                          submitOtp(otpCode, context);
                        }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
