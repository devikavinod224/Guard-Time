import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:guard_time/controller/auth_controller.dart';
import 'package:guard_time/pages/AuthScreen/otp_verification_screen.dart';
import 'package:guard_time/pages/HomeScreen/navigation_bar.dart';
import 'package:guard_time/utils/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/appstate.dart';

class LoginPage extends StatefulWidget {
  final String? mobileNumber;
  const LoginPage({super.key, this.mobileNumber});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    var controller = Get.put(AuthController());
    return Scaffold(
      // backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.07,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.08,
                ),
                child: Center(
                  // child: ClipOval(
                  child: CircleAvatar(
                    radius: 100,
                    foregroundImage: AssetImage(
                      Get.isDarkMode
                          ? 'assets/images/TeenCareIcon.png'
                          : 'assets/images/TeenCareIcon.png',
                    ),
                  ),
                  // ),
                ),
              ),
              Text(
                "Welcome to Teen Care",
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Text(
                "Digital protection for your child",
                style: Theme.of(context).textTheme.bodyLarge!,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
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
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Center(
                child: isLoading == true
                    ? CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      )
                    : Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.05,
                        ),
                        child: MaterialButton(
                          minWidth: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.07,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: Theme.of(context).primaryColor,
                          onPressed: () => onSubmit(),
                          child: Text("getOtp".tr),
                        ),
                      ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.015,
              ),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.labelSmall,
                  children: [
                    const TextSpan(text: 'By continuing, you agree with our '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchUrl(
                              Uri.parse('https://your-privacy-policy-url.com'));
                        },
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Terms of Use',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchUrl(
                              Uri.parse('https://your-terms-of-use-url.com'));
                        },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              const Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("OR"),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Obx(
                () => controller.isLoading.value
                    ? const CircularProgressIndicator()
                    // : Center(
                    //     child: MaterialButton(
                    //       onPressed: () async {
                    //         var value = await controller.signInWithGoogle();
                    //         if (value) {
                    //           Get.to(() => const MyHomePage());
                    //         } else {
                    //           Get.snackbar(
                    //               "Error", "Error signing in with Google");
                    //         }
                    //       },
                    //       padding: const EdgeInsets.all(10),
                    //       color: Theme.of(context).primaryColor,
                    //       shape: const CircleBorder(),
                    //       child: Icon(
                    //         MdiIcons.google,
                    //         color: Theme.of(context).dialogBackgroundColor,
                    //       ),
                    //     ),
                    //   ),
                    : Center(
                        child: ElevatedButtonCustomized(
                          text: "Sign in with Google",
                          color: Theme.of(context).primaryColor,
                          
                          onPressed: () async {
                            var value = await controller.signInWithGoogle();
                            if (value) {
                              Get.to(() => const MyHomePage());
                            } else {
                              Get.snackbar(
                                  "Error", "Error signing in with Google");
                            }
                          },
                          icon: Icon(MdiIcons.google,
                              color: Theme.of(context).dialogBackgroundColor),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
