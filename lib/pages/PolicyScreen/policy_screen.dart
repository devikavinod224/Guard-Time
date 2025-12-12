import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guard_time/controller/home_controller.dart';
import 'package:guard_time/pages/ApplicationsScreen/apps_screen.dart';
import 'package:guard_time/pages/HomeScreen/navigation_bar.dart';
import 'package:guard_time/utils/appstate.dart';
import 'package:guard_time/utils/models.dart';
import 'package:guard_time/utils/widgets.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
// import 'package:showcaseview/showcaseview.dart';

class PolicyScreen extends StatefulWidget {
  final DeviceModel? device;
  final PolicyModel? policy;
  final int index;
  const PolicyScreen({
    super.key,
    this.device,
    this.policy,
    required this.index,
  });

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen>
    with WidgetsBindingObserver {
  final HomeController homeController = Get.put(HomeController());
  DeviceModel newDevice = DeviceModel.copy(AppState().device!);
  PolicyModel newPolicy = PolicyModel().copy(AppState().device!.policy!);

  late TutorialCoachMark tutorialCoachMark;
  // final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  final GlobalKey _three = GlobalKey();
  final GlobalKey _four = GlobalKey();

  @override
  void initState() {
    createTutorial();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> onBack() async {
    homeController.showLoading();
    // compare both the device models

    // if their nickname is different, then update the device model in the app state.
    if ((widget.device!.nickname.toString() != newDevice.nickname.toString()) &&
        (widget.policy!.toString() == newPolicy.toString())) {
      AppState().device = newDevice;
      await AppState().updateDevice();
      AppState().devices![widget.index] = AppState().device!;
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppState().message ?? ""),
        backgroundColor: AppState().messageColor,
      ));
    }
    // if their policy is different, then update the policy model in the app state.
    else if ((widget.policy!.toString() != newPolicy.toString()) &&
        (widget.device!.nickname.toString() == newDevice.nickname.toString())) {
      AppState().device!.policy = newPolicy;
      debugPrint("new policy: ${newPolicy.toJson()}");
      await AppState().updatePolicy();
      newDevice.policy = AppState().device!.policy;
      AppState().device = newDevice;
      await AppState().updateDevice();
      AppState().devices![widget.index] = AppState().device!;
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppState().message ?? ""),
        backgroundColor: AppState().messageColor,
      ));
    }
    // if both are different, then update both
    else if ((widget.policy!.toString() != newPolicy.toString()) &&
        (widget.device!.nickname.toString() != newDevice.nickname.toString())) {
      AppState().device!.policy = newPolicy;
      debugPrint("new policy: ${newPolicy.toJson()}");
      await AppState().updatePolicy();
      newDevice.policy = AppState().device!.policy;
      AppState().device = newDevice;
      await AppState().updateDevice();
      AppState().devices![widget.index] = AppState().device!;
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppState().message ?? ""),
        backgroundColor: AppState().messageColor,
      ));
    }
    homeController.hideLoading();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void updateDevicePolicy(PolicyModel policy) {
    setState(() {
      newPolicy = policy;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: ((didPop) {
        if (didPop) {
          return;
        }
        Get.back();
      }),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: HeadingText(
            text: 'policyScreen'.tr,
            size: 20,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Get.offAll(() => const MyHomePage());
            },
          ),
          actions: [
            IconButton(
              color: Colors.white,
              onPressed: () {
                showTutorial();
              },
              icon: const Icon(
                Icons.help_outline,
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          padding: EdgeInsets.zero,
          child: Obx(
            () => homeController.isLoading.value == true
                ? const CustomLoadingIndicator(
                    height: 50,
                    width: 50,
                    horizontalPadding: 190,
                    verticalPadding: 10,
                  )
                : MaterialButton(
                    color: Theme.of(context).primaryColor,
                    height: 50,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(10))),
                    onPressed: () async {
                      await onBack();
                      if (!mounted) {
                        return;
                      }
                      Get.off(() => const MyHomePage());
                    },
                    child: HeadingText(
                      text: 'save'.tr,
                    ),
                  ),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 10),
            CustomCachedImageWidget(imageId: AppState().device!.id!),
            const SizedBox(height: 15),
            EditableTextField(
              key: _two,
              initialValue: newDevice.nickname ?? " ",
              flag: 0,
            ),
            const SizedBox(height: 10),
            if (newDevice.model != null)
              Text(
                '${newDevice.model ?? ""}   ${newDevice.brand ?? ""}',
                style: const TextStyle(fontSize: 16.0),
              ),
            if (newDevice.model != null) const SizedBox(height: 15),
            const Divider(
              color: Colors.grey,
              indent: 32.0,
              endIndent: 32.0,
            ),
            Expanded(
              child: SizedBox(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(() => const AppsScreen());
                        },
                        child: ListTileWidget(
                          key: _three,
                          leadingIcon: Icons.apps,
                          title: 'allowedApps'.tr,
                          subtitle: '',
                          isSwitched: false,
                          switchAvailable: false,
                          subtitleAvailable: false,
                          height: 50,
                        ),
                      ),
                      ListTileWidget(
                        key: _four,
                        leadingIcon: Icons.audiotrack,
                        title: 'disableAudio'.tr,
                        subtitle: 'disableAudioDesc'.tr,
                        isSwitched: newPolicy.adjustVolumeDisabled ?? false,
                        switchAvailable: true,
                        subtitleAvailable: true,
                        onChanged: (value) {
                          setState(() {
                            newPolicy.adjustVolumeDisabled = value;
                            updateDevicePolicy(newPolicy);
                          });
                        },
                      ),
                      ListTileWidget(
                        leadingIcon: Icons.sd_storage,
                        title: 'disableStorage'.tr,
                        subtitle: 'diableStorageDesc'.tr,
                        isSwitched: (newPolicy.usbFileTransferDisabled ==
                                    false ||
                                newPolicy.mountPhysicalMediaDisabled == false)
                            ? false
                            : true,
                        switchAvailable: true,
                        subtitleAvailable: true,
                        onChanged: (value) {
                          setState(() {
                            newPolicy.usbFileTransferDisabled = value;
                            newPolicy.mountPhysicalMediaDisabled = value;
                            updateDevicePolicy(newPolicy);
                          });
                        },
                      ),
                      ListTileWidget(
                        leadingIcon: Icons.call,
                        title: 'disableCalls'.tr,
                        subtitle: 'disableCallsDesc'.tr,
                        isSwitched: newPolicy.outgoingCallsDisabled ?? false,
                        switchAvailable: true,
                        subtitleAvailable: true,
                        onChanged: (value) {
                          setState(() {
                            newPolicy.outgoingCallsDisabled = value;
                            updateDevicePolicy(newPolicy);
                          });
                        },
                      ),
                      ListTileWidget(
                        leadingIcon: Icons.bluetooth_disabled,
                        title: 'disableBlue'.tr,
                        subtitle: 'disableBlueDesc'.tr,
                        isSwitched: newPolicy.bluetoothDisabled ?? false,
                        switchAvailable: true,
                        subtitleAvailable: true,
                        onChanged: (value) {
                          setState(() {
                            newPolicy.bluetoothDisabled = value;
                            updateDevicePolicy(newPolicy);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showTutorial() {
    tutorialCoachMark.show(context: context);
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
    // targets.add(
    //   TargetFocus(
    //     identify: "profileButton",
    //     keyTarget: _one,
    //     color: Colors.cyanAccent,
    //     alignSkip: Alignment.topRight,
    //     enableOverlayTab: true,
    //     contents: [
    //       TargetContent(
    //         align: ContentAlign.bottom,
    //         builder: (context, controller) {
    //           return const Column(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             mainAxisSize: MainAxisSize.min,
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: <Widget>[
    //               Text(
    //                 "Tap here to change profile picture of device",
    //                 style: TextStyle(
    //                   color: Colors.white,
    //                 ),
    //               ),
    //             ],
    //           );
    //         },
    //       ),
    //     ],
    //   ),
    // );

    targets.add(
      TargetFocus(
        identify: "editName",
        keyTarget: _two,
        color: Colors.cyanAccent,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Tap on the edit icon to change the name of your device",
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

    targets.add(
      TargetFocus(
        identify: "openApps",
        keyTarget: _three,
        color: Colors.cyanAccent,
        alignSkip: Alignment.topRight,
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
                    "Open application screen",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Click on this tile to open the application screen",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "switch",
        keyTarget: _four,
        alignSkip: Alignment.topRight,
        color: Colors.cyanAccent,
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
                    "Enable/Disable this feature",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "You can enable or disable any permission from here.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          )
        ],
        shape: ShapeLightFocus.RRect,
        radius: 20,
      ),
    );

    return targets;
  }
}
