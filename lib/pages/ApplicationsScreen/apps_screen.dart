// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guard_time/pages/PolicyScreen/web_view_screen.dart';
import 'package:guard_time/utils/appstate.dart';
import 'package:guard_time/utils/models.dart';
import 'package:guard_time/utils/widgets.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../controller/home_controller.dart';

class AppsScreen extends StatefulWidget {
  const AppsScreen({super.key});

  @override
  AppsScreenState createState() => AppsScreenState();
}

class AppsScreenState extends State<AppsScreen> {
  // final StreamController<List<AppModel>> _applicationStreamController =
  //     StreamController<List<AppModel>>();
  final StreamController<List<AppModel>> _deviceStreamController =
      StreamController<List<AppModel>>();
  HomeController homeController = Get.put(HomeController());
  List<ApplicationModel> dummyApplications = [];
  List<AppModel> dummyApps = [];
  bool isTrue = false;

  late TutorialCoachMark tutorialCoachMark;
  final GlobalKey _three = GlobalKey();
  final GlobalKey _four = GlobalKey();

  @override
  void initState() {
    debugPrint("on init ");
    // fetchApplications();
    fetchDevices();
    createTutorial();
    super.initState();
  }

  void handleDeleteClick(index, context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('confirmDeletion'.tr),
        content: Text('confirmDeletionDesc'.tr),
        actions: [
          TextButton(
            onPressed: () {
              // Get.back();
              Navigator.pop(context);
            },
            child: Text('no'.tr),
          ),
          TextButton(
            onPressed: () async {
              homeController.showLoading();
              dummyApplications = AppState().device!.policy!.applications!;
              dummyApps = AppState().device!.apps!;
              AppState().device!.policy!.applications!.removeAt(index);
              var value = await AppState().updatePolicy();
              if (value) {
                AppState().device!.apps!.removeAt(index);
                var temp = await AppState().updateDevice();
                if (temp == false) {
                  AppState().device!.policy!.applications = dummyApplications;
                  AppState().updatePolicy();
                  AppState().device!.apps = dummyApps;
                  Get.snackbar("Error", "Something went wrong");
                  debugPrint("error in update device");
                }
              } else {
                AppState().device!.policy!.applications = dummyApplications;
                Get.snackbar("Error", "Something went wrong");
                debugPrint("error in update policy");
              }
              homeController.hideLoading();
              // fetchApplications();
              fetchDevices();
              // Get.back(closeOverlays: true);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: Text('yes'.tr),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  Future<void> fetchDevices() async {
    print("fetch Devices");
    try {
      List<AppModel>? fetchedDevices = [];
      await AppState().updateDevice();
      fetchedDevices = AppState().device!.apps;
      // Add the fetched device to the stream
      if (fetchedDevices != null) {
        _deviceStreamController.add(fetchedDevices.cast<AppModel>().toList());
      }
    } catch (error) {
      // Handle errors or show a message to the user
      print('Error fetching devices: $error');
    }
  }

  Future<void> onSave() async {
    homeController.showLoading();
    await AppState().updatePolicy();
    homeController.hideLoading();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        Get.back();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: HeadingText(
            text: "application".tr,
            size: 20,
          ),
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Get.back();
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
                      await onSave();
                      if (!mounted) {
                        return;
                      }
                      Get.snackbar(
                        "Saved",
                        "Successfully",
                        backgroundColor: Colors.green.shade400,
                        snackPosition: SnackPosition.BOTTOM,
                        barBlur: 0.8,
                      );
                    },
                    child: HeadingText(
                      text: 'save'.tr,
                      color: Colors.black,
                    ),
                  ),
          ),
        ),
        floatingActionButton: MaterialButton(
          key: _three,
          color: Theme.of(context).primaryColor,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(16),
          onPressed: () {
            Get.to(() => const WebViewScreen());
          },
          child: const Icon(Icons.add),
        ),
        resizeToAvoidBottomInset: true,
        body: RefreshIndicator(
          onRefresh: () async {
            await fetchDevices();
          },
          child: Stack(
            children: [
              if (homeController.isLoading.value)
                Container(
                  height: MediaQuery.of(context).size.height,
                  color:
                      Theme.of(context).scaffoldBackgroundColor.withOpacity(1),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTileWidget(
                      leadingIcon: Icons.install_mobile,
                      title: 'disableApps'.tr,
                      subtitle: 'disableAppDesc'.tr,
                      isSwitched:
                          (AppState().device!.policy!.installAppsDisabled) ??
                              false,
                      switchAvailable: true,
                      subtitleAvailable: true,
                      onChanged: (value) {
                        setState(() {
                          AppState().device!.policy!.installAppsDisabled =
                              value;
                          if (value == true) {
                            AppState().device!.policy!.playStoreMode =
                                "WHITELIST";
                          } else {
                            AppState().device!.policy!.playStoreMode =
                                "BLACKLIST";
                          }
                          // updateDevicePolicy(newPolicy);
                        });
                      },
                    ),
                    const Divider(thickness: 3),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: StreamBuilder<List<AppModel>>(
                        // stream: _applicationStreamController.stream,
                        stream: _deviceStreamController.stream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // Show a loading indicator while fetching data
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return ListView(
                              children: [
                                const SizedBox(height: 50),
                                Center(
                                  child: Text(
                                    'Error in stream builder snapshot (in home screen): ${snapshot.error}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data == null ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text('No Applications available.'));
                          } else {
                            List<AppModel> applications = snapshot.data!;
                            List<ApplicationModel> policyApplications =
                                AppState().device!.policy!.applications!;
                            return ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: applications.length,
                              itemBuilder: (context, index) {
                                final application = applications[index];
                                final policyApplication =
                                    policyApplications[index];
                                return Card(
                                  key: index == 0 ? _four : null,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 26),
                                  color: Get.isDarkMode
                                      ? Colors.grey.shade900
                                      : Colors.grey.shade100,
                                  shape: ContinuousRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    side: const BorderSide(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          fit: FlexFit.loose,
                                          child: Row(
                                            children: [
                                              Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                                child: application.imageLink ==
                                                        null
                                                    ? Image.asset(
                                                        'assets/images/placeholder.png',
                                                        height: 96 * 0.55,
                                                        width: 96 * 0.55)
                                                    : Image.network(
                                                        application.imageLink!,
                                                        height: 96 * 0.55,
                                                        width: 96 * 0.55),
                                              ),
                                              Flexible(
                                                fit: FlexFit.loose,
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        application.name ??
                                                            'unknown'.tr,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                    "disableApp"
                                                                        .tr),
                                                                Center(
                                                                  child: Switch(
                                                                    // key: _two,
                                                                    value: policyApplication
                                                                            .disabled ??
                                                                        false,
                                                                    onChanged:
                                                                        (value) async {
                                                                      setState(
                                                                          () {
                                                                        policyApplication.disabled =
                                                                            value;
                                                                      });
                                                                      AppState()
                                                                          .device!
                                                                          .policy!
                                                                          .applications![
                                                                              index]
                                                                          .disabled = value;
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text("deleteApp"
                                                                    .tr),
                                                                Center(
                                                                  child:
                                                                      IconButton(
                                                                    // key: _one,
                                                                    icon:
                                                                        const Icon(
                                                                      Icons
                                                                          .delete,
                                                                      color: Colors
                                                                          .red,
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      handleDeleteClick(
                                                                          index,
                                                                          context);
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      // ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ).paddingAll(8),
                                        ),
                                      ]),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
      onFinish: () {
        print("finish");
      },
      onClickTarget: (target) {
        print('onClickTarget: $target');
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        print("target: $target");
        print(
            "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      },
      onClickOverlay: (target) {
        print('onClickOverlay: $target');
      },
      onSkip: () {
        print("skip");
        return true;
      },
    );
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        identify: "tile",
        keyTarget: _four,
        alignSkip: Alignment.topRight,
        color: Colors.cyanAccent,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                // crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    padding: const EdgeInsets.only(top: 5.0),
                    child: const Text(
                      "Tap on the switch to disable the application for your child",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const VerticalDivider(thickness: 2, color: Colors.white),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    padding: const EdgeInsets.only(top: 5.0),
                    child: const Text(
                      "Tap on the delete icon to remove the application from the list",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          )
        ],
        shape: ShapeLightFocus.RRect,
      ),
    );
    targets.add(
      TargetFocus(
        identify: "addApps",
        keyTarget: _three,
        color: Colors.cyanAccent,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.left,
            builder: (context, controller) {
              return const Column(
                // mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Add applications",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Tap here to add more applications for your child",
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
    return targets;
  }
}
