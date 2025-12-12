import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guard_time/pages/PolicyScreen/add_app_screen.dart';
import 'package:guard_time/utils/appstate.dart';
import 'package:guard_time/utils/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../controller/home_controller.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => WebViewScreenState();
}

class WebViewScreenState extends State<WebViewScreen> {
  String packageName = '';
  late final WebViewController _controller;
  String apkUrl = "";
  final HomeController homeController = Get.put(HomeController());

  Future<void> onSubmit() async {
    homeController.showLoading();
    debugPrint("on submit");
    debugPrint("apkUrl in web_view_screen: $apkUrl");
    await AppState().getPlayStoreData(apkUrl);
    AppState().packageName = packageName;
    homeController.hideLoading();
  }

  @override
  void initState() {
    super.initState();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setUserAgent("random")
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
            homeController.progress.value = progress / 100;
          },
          onUrlChange: (change) {
            var uri = change.url.toString();
            debugPrint("url from onUrlChange is $uri");
            if (uri.contains("?id=")) {
              final start = uri.indexOf('?id=') + 4;
              final end = uri.length;
              packageName = uri.substring(start, end);
              apkUrl = uri;
              // for (int i = 0; i < AppState().device!.apps!.length; i++) {
              //   if (AppState().device!.apps![i].package == packageName) {
              //     Get.snackbar("Error", "App already exists");
              //     homeController.disableButton();
              //     break;
              //   } else {
              //   }
              // }
              homeController.enableButton();
              debugPrint("package name is $packageName");
            }
          },
          onPageStarted: (String url) async {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
                Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
                ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse('https://play.google.com'));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  @override
  void dispose() {
    _controller.clearCache();
    homeController.disableButton();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // canPop: false,
      onPopInvoked: ((didPop) async {
        if (didPop) {
          return;
        }
        homeController.disableButton();
        var isLastPage = await _controller.canGoBack();
        if (isLastPage == true) {
          _controller.goBack();
          return;
        }
      }),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: HeadingText(
            text: 'apps'.tr,
            size: 20,
          ),
        ),
        bottomNavigationBar: Obx(
          () => homeController.isLoading.value == true
              ? const CustomLoadingIndicator(
                  height: 50,
                  width: 50,
                  horizontalPadding: 175,
                  verticalPadding: 10,
                )
              : MaterialButton(
                  disabledColor: Theme.of(context).disabledColor,
                  onPressed: homeController.buttonEnabled.value == false
                      ? null
                      : () async {
                          await onSubmit();
                          debugPrint("package name is added to app state");
                          Get.off(() => const AddAppScreen());
                        },
                  height: 50,
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.black,
                  child: HeadingText(
                    text: "addApp".tr,
                    color: Colors.black,
                  ),
                ),
        ),
        body: Stack(
          children: [
            if (homeController.progress.value != 1.0)
              LinearProgressIndicator(
                value: homeController.progress.value,
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            WebViewWidget(controller: _controller),
          ],
        ),
      ),
    );
  }
}
