import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:guard_time/controller/home_controller.dart';
import 'package:guard_time/pages/BuyDevicesScreen/offers_screen.dart';
import 'package:guard_time/pages/PolicyScreen/policy_screen.dart';
import 'package:guard_time/utils/appstate.dart';
import 'package:guard_time/utils/image_cache_manager.dart';
import 'package:guard_time/utils/models.dart';
import 'package:guard_time/utils/widgets.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StreamController<List<DeviceModel>> _deviceStreamController =
      StreamController<List<DeviceModel>>();
  // final homeController = Get.put(HomeController());
  late TutorialCoachMark tutorialCoachMark;
  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  final GlobalKey _three = GlobalKey();
  bool isDeviceAdded = false;
  final List<String>? deviceIds = AppState().fetchDeviceIds();
  final imageCacheManager = ImageCacheManager();
  @override
  void initState() {
    fetchDevices();
    createTutorial();
    imageCacheManager.preloadImages(
        deviceIds!, AppState().navigatorKey.currentContext);
    if (HomeController.isFirstTime.value) {
      showTutorial();
    }
    super.initState();
  }

  // Function to fetch devices from the API and add them to the stream
  Future<bool> fetchDevices() async {
    try {
      List<DeviceModel?> fetchedDevices = [];
      var value = await AppState().getDevices();
      if (value) {
        fetchedDevices = AppState().devices!;
      }
      _deviceStreamController.add(fetchedDevices
          .where((device) => device != null)
          .cast<DeviceModel>()
          .toList());
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  void dispose() {
    _deviceStreamController.close();
    super.dispose();
  }

  void showTutorial() {
    tutorialCoachMark.show(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => CustomDialog(
            header: "confirmation".tr,
            body: "confirmExit".tr,
            yesLogic: () => SystemNavigator.pop(),
            noLogic: () => Navigator.of(context).pop(false),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          titleSpacing: 20,
          title: Text(
              "${'helloMessage'.tr}, ${AppState().user!.firstName} ${AppState().user!.lastName ?? ""}"),
          actions: [
            IconButton(
              onPressed: () {
                createTutorial();
                showTutorial();
              },
              icon: const Icon(
                Icons.help_outline,
              ),
            ),
            IconButton(
              key: _two,
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ));
              },
              icon: const Icon(
                Icons.attach_money_rounded,
              ),
            ),
          ],
        ),
        resizeToAvoidBottomInset: true,
        body: RefreshIndicator(
          onRefresh: fetchDevices,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            child: StreamBuilder<List<DeviceModel>>(
              stream: _deviceStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return ListView(
                    children: [
                      const SizedBox(height: 50),
                      Center(
                        child: Text(
                          '${'errorStream'.tr}: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // Show a message when there is no data
                  return ListView(
                    children: [
                      const SizedBox(height: 50),
                      Center(child: Text('noDevice'.tr)),
                      const SizedBox(height: 20),
                      Center(
                        child: Image.asset(
                          // 'assets/images/loginImage.jpg',
                          Get.isDarkMode
                              ? 'assets/images/no_data_dark_mode.png'
                              : 'assets/images/no_data_light_mode.png',
                          height: 150,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 50),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const SubscriptionScreen(),
                          ));
                        },
                        child: Container(
                          key: _three,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).primaryColor,
                          ),
                          height: MediaQuery.of(context).size.height * 0.06,
                          width: MediaQuery.of(context).size.width * 0.4,
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            "buyDevice".tr,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Display the list of devices
                  List<DeviceModel> devices = snapshot.data!;
                  isDeviceAdded = true;
                  return ListView.builder(
                    itemCount: devices.length,
                    // itemCount: 50,
                    itemBuilder: (context, index) {
                      ImageProvider<Object> deviceImage;
                      if (index + 1 < AppState().deviceIdList!.length) {
                        deviceImage = ImageCacheManager().getImageForDevice(
                            AppState().deviceIdList![index + 1]);
                      } else {
                        deviceImage =
                            const AssetImage("assets/images/profileIcon.png");
                      }
                      AppState().device = devices[index];
                      DeviceModel? device = AppState().device;
                      if (index == 0) {
                        return DeviceListTile(
                          key: _one,
                          image: deviceImage,
                          deviceBrand: device!.brand ?? "",
                          deviceModel: device.model ?? "",
                          deviceName: device.nickname ?? "",
                          onTap: () async {
                            AppState().device = devices[index];
                            AppState().device!.policy = device.policy;
                            AppState().index = index;
                            await Get.to(() => PolicyScreen(
                                index: index,
                                device: devices[index],
                                policy: devices[index].policy));

                            setState(() {});
                            // }
                          },
                        );
                      } else {
                        return DeviceListTile(
                          image: deviceImage,
                          deviceBrand: device!.brand ?? "",
                          deviceModel: device.model ?? "",
                          deviceName: device.nickname ?? "",
                          onTap: () async {
                            AppState().device = devices[index];
                            AppState().device!.policy = device.policy;
                            AppState().index = index;
                            await Get.to(() => PolicyScreen(
                                index: index,
                                device: devices[index],
                                policy: devices[index].policy));

                            setState(() {});
                            // }
                          },
                        );
                      }
                    },
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  void createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.red,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.5,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {},
      onClickTarget: (target) {},
      onClickTargetWithTapPosition: (target, tapDetails) {},
      onClickOverlay: (target) {},
      onSkip: () {
        return true;
      },
    );
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];
    if (isDeviceAdded) {
      targets.add(
        TargetFocus(
          identify: "device tile",
          keyTarget: _one,
          color: Colors.cyanAccent,
          alignSkip: Alignment.bottomRight,
          shape: ShapeLightFocus.RRect,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Tap here to edit the properties of the device",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    }
    targets.add(
      TargetFocus(
        identify: "dollar",
        keyTarget: _two,
        color: Colors.cyanAccent,
        alignSkip: Alignment.bottomRight,
        shape: ShapeLightFocus.Circle,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Tap here to buy subsciption of the application",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    return targets;
  }
}
