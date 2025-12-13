import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parents_app/controller/home_controller.dart';
import 'package:parents_app/pages/HomeScreen/navigation_bar.dart';
import 'package:parents_app/utils/appstate.dart';
import 'package:parents_app/utils/models.dart';
import 'package:parents_app/utils/widgets.dart';

class SignupScreen extends StatefulWidget {
  final String phoneNumber;
  const SignupScreen({super.key, required this.phoneNumber});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool isLoading = false;
  @override
  void initState() {
    phoneController.text = widget.phoneNumber;
    super.initState();
  }

  bool isButtonEnabled = false;

  void _checkButtonState() {
    setState(() {
      if (firstNameController.text.length >= 2) {
        isButtonEnabled = true;
      } else {
        isButtonEnabled = false;
      }
    });
  }

  void _navigateToHomeScreen() {
    Get.offAll(() => const MyHomePage());
  }

  Future<void> storeUserData() async {
    UserModel newUser = UserModel(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      devices: [],
      email: "",
      phone: phoneController.text.trim(),
      id: AppState().user == null ? "" : AppState().user!.id.toString(),
      otpExpires: DateTime.now(),
      otpTimestamp: DateTime.now(),
      isSignedIn: true,
    );
    File imageFile = await AppState().convertAssetImageToFile();
    await AppState().uploadImage(imageFile, AppState().user!.id.toString());

    AppState().user = newUser;
    await AppState().createUser(newUser).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppState().message.toString()),
        backgroundColor: AppState().messageColor,
      ));
      if (value) {
        HomeController.isFirstTime.value = true;
        _navigateToHomeScreen();
      } else {}
      return;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: HeadingText(
          text: "createAcc".tr,
          size: 20,
        ),
      ),
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/profileIcon.png',
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                HeadingText(
                  text: "${"helloMessage".tr}! ${firstNameController.text}",
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: firstNameController,
                  onChanged: (text) {
                    _checkButtonState();
                  },
                  decoration: InputDecoration(
                    label: Text("fname".tr),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 2) {
                      return 'First name is required (at least 2 characters)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    label: Text("lname".tr),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    label: Text("phoneNo".tr),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabled: false,
                  ),
                ),
                const SizedBox(height: 60),
                Center(
                  child: isLoading == true
                      ? CircularProgressIndicator(
                          color: Theme.of(context).primaryColor)
                      : ElevatedButtonCustomized(
                          onPressed: isButtonEnabled
                              ? () async {
                                  isLoading = true;
                                  setState(() {});
                                  await storeUserData();
                                  isLoading = false;
                                  setState(() {});
                                }
                              : null,
                          text: 'singUp'.tr,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                          color: Theme.of(context).primaryColor,
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
