import 'package:firebase_core/firebase_core.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guard_time/firebase_options.dart';
import 'package:guard_time/pages/ApplicationsScreen/apps_screen.dart';
import 'package:guard_time/pages/PolicyScreen/add_app_screen.dart';
import 'package:guard_time/pages/PolicyScreen/web_view_screen.dart';
import 'package:guard_time/pages/SplashScreen/splash_screen.dart';
import 'package:guard_time/utils/appstate.dart';
import 'package:guard_time/utils/locale_string.dart';
import 'utils/image_cache_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AppState().initializePersistentVariables();
  
  // Get device IDs once
  final List<String> deviceIds = AppState().fetchDeviceIds();
  
  // ✅ Store in AppState instead of passing to MyApp
  AppState().deviceIdList = deviceIds;
  
  runApp(const MyApp()); // Removed parameter
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Removed deviceIds parameter

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: LocaleString(),
      locale: (AppState().storedLocale == "en_US")
          ? const Locale('en', 'US')
          : (AppState().storedLocale == "hi_IN")
              ? const Locale('hi', 'IN')
              : const Locale('ja', 'JP'),
      navigatorKey: AppState().navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Guard Time',
      themeMode: ThemeMode.light,
      theme: FlexThemeData.light(
          scheme: FlexScheme.greenM3,
          fontFamily: 'Montserrat'),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.greenM3, 
        fontFamily: 'Montserrat',
      ),
      initialRoute: '/splash',
      getPages: [
        GetPage(
          name: '/splash',
          page: () => const SplashScreen(),
        ),
        GetPage(
          name: '/app',
          page: () => const AppsScreen(),
        ),
        GetPage(
          name: '/webView',
          page: () => const WebViewScreen(),
        ),
        GetPage(
          name: '/addApp',
          page: () => const AddAppScreen(),
        ),
      ],
      
      // ✅ FIX: Initialize image cache when context is available
      home: Builder(
        builder: (context) {
          // Schedule image preloading for after first frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // ✅ Get deviceIds from AppState instead of constructor
            final deviceIds = AppState().deviceIdList;
            if (deviceIds != null && deviceIds.isNotEmpty) {
              final imageCacheManager = ImageCacheManager();
              imageCacheManager.preloadImages(deviceIds, context);
            }
          });
          
          return const SplashScreen();
        },
      ),
    );
  }
}