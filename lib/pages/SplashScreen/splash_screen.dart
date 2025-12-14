import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parents_app/pages/AuthScreen/login.dart';
import 'package:parents_app/pages/HomeScreen/navigation_bar.dart';
import 'package:parents_app/utils/appstate.dart';
import 'package:parents_app/utils/models.dart';
import 'package:parents_app/utils/image_cache_manager.dart';

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
    try {
      // Check if user data exists in Flutter Secure Storage
      await AppState().initializePersistentVariables();
      
      // Update Locale based on stored preference
      if (AppState().storedLocale != null) {
          if (AppState().storedLocale == "hi_IN") {
               Get.updateLocale(const Locale('hi', 'IN'));
          } else if (AppState().storedLocale == "ja_JP") { 
               Get.updateLocale(const Locale('ja', 'JP'));
          } else {
               Get.updateLocale(const Locale('en', 'US'));
          }
      }

      UserModel? userData = AppState().user;
      debugPrint("User data (from splash screen): ${userData?.toJson().toString()}");
      debugPrint("Stored locale: ${AppState().storedLocale}");

      if (userData != null && userData.id != null && userData.id!.length > 3) {
        // Preload images before navigating
        final deviceIds = AppState().fetchDeviceIds();
        if (deviceIds.isNotEmpty) {
           await ImageCacheManager().preloadImages(deviceIds, context);
        }
        Get.off(() => const MyHomePage());
      } else {
        Get.off(() => const LoginPage());
      }
    } catch (e) {
      debugPrint("Initialization error in Splash Screen: $e");
      // Fallback to login in case of any init error
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
