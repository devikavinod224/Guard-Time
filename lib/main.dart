import 'package:firebase_core/firebase_core.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parents_app/firebase_options.dart';
import 'package:parents_app/pages/ApplicationsScreen/apps_screen.dart';
import 'package:parents_app/pages/PolicyScreen/add_app_screen.dart';
import 'package:parents_app/pages/PolicyScreen/web_view_screen.dart';
import 'package:parents_app/pages/SplashScreen/splash_screen.dart';
import 'package:parents_app/utils/appstate.dart';
import 'package:parents_app/utils/locale_string.dart';
import 'utils/image_cache_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AppState().initializePersistentVariables();
  final List<String> deviceIds = AppState().fetchDeviceIds();

  if (deviceIds.isNotEmpty) {
    final imageCacheManager = ImageCacheManager();
    // Use addPostFrameCallback to ensure the context is available
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        imageCacheManager.preloadImages(
            deviceIds, AppState().navigatorKey.currentContext);
      },
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: LocaleString(),
      // locale: const Locale('en', 'US'),
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
          // scheme: FlexScheme.dellGenoa,
          scheme: FlexScheme.greenM3,
          fontFamily: 'Montserrat'
          // #304D38
          ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.greenM3, fontFamily: 'Montserrat',
        // #88B696,
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
    );
  }
}
