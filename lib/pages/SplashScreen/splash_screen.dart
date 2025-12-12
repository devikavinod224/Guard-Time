import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guard_time/pages/AuthScreen/login.dart';
import 'package:guard_time/pages/HomeScreen/navigation_bar.dart';
import 'package:guard_time/utils/appstate.dart';
import 'package:guard_time/utils/models.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkUserLoggedIn();
  }

  void checkUserLoggedIn() async {
    // Check if user data exists in Flutter Secure Storage
    await AppState().initializePersistentVariables();
    UserModel? userData = AppState().user;
    debugPrint(
        "This is the user data (from splash screen): ${userData!.toJson().toString()}");
    debugPrint(AppState().storedLocale.toString());

    if (userData.id != null && userData.id!.length > 3) {
      Get.off(() => const MyHomePage());
    } else {
      Get.off(() => const LoginPage());
    }
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
