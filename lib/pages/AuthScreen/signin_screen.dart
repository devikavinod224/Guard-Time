import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:parents_app/pages/AuthScreen/otp_verification_screen.dart';
import 'package:parents_app/utils/appstate.dart';
import 'package:parents_app/utils/widgets.dart';

class SignInScreen extends StatefulWidget {
  final String? mobileNumber;
  const SignInScreen({super.key, this.mobileNumber});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    isLoading = false;
    if (widget.mobileNumber != null) {
      phoneController.text = widget.mobileNumber.toString();
    }
    super.initState();
  }

  void onSubmit() async {
    isLoading = true;
    setState(() {});

    AppState().userPhone = phoneController.text.trim();
    await AppState().getOtp().then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppState().message.toString()),
        backgroundColor: AppState().messageColor,
      ));
      isLoading = false;
      if (value) {
        setState(() {});
        Get.offAll(
            () => VerificationScreen(mobNumber: phoneController.text.trim()));
      }
    });
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: HeadingText(
          text: "phoneSignIn".tr,
          size: 20,
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  // child: ClipOval(
                  child: Image.asset(
                    // 'assets/images/loginImage.jpg',
                    Get.isDarkMode
                        ? 'assets/images/oie_transparent.png'
                        : 'assets/images/oie_transparent_light_mode.png',
                    height: 150,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                  // ),
                ),
                const SizedBox(height: 30),
                HeadingText(text: "${"helloMessage".tr}!", color: Colors.white),
                const SizedBox(height: 10),
                Text("enterMob".tr),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: IntlPhoneField(
                    onSubmitted: (p0) => phoneController.text = p0.toString(),
                    initialCountryCode: 'IN',
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: "phoneNo".tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: isLoading == true
                      ? CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        )
                      : ElevatedButtonCustomized(
                          text: "getOtp".tr,
                          color: Theme.of(context).primaryColor,
                          onPressed: () => onSubmit(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
