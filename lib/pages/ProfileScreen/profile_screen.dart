import 'dart:async';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:parents_app/controller/auth_controller.dart';
import 'package:parents_app/controller/home_controller.dart';
import 'package:parents_app/pages/AuthScreen/login.dart';
import 'package:parents_app/pages/BuyDevicesScreen/offers_screen.dart';
import 'package:parents_app/pages/ProfileScreen/history_screen.dart';
import 'package:parents_app/pages/SplashScreen/splash_screen.dart';
import 'package:parents_app/utils/appstate.dart';
import 'package:parents_app/utils/models.dart';
import 'package:parents_app/utils/widgets.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  String langValue = "EN";
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final StreamController<List<DeviceModel>> _deviceStreamController =
      StreamController<List<DeviceModel>>();
  UserModel dummyUser = UserModel.copy(AppState().user!);
  final controller = Get.put(HomeController());
  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  final GlobalKey _three = GlobalKey();
  final GlobalKey _four = GlobalKey();
  final GlobalKey _five = GlobalKey();
  late TutorialCoachMark tutorialCoachMark;
  @override
  void initState() {
    super.initState();
    // AppState().imageUserURL =
    //     "${AppState().baseUrl}/image/${AppState().user!.id}";
    // print("Updated user image url is: ${AppState().imageUserURL}");
    fetchDevices();
    _firstNameController.text = AppState().user!.firstName ?? "";
    _lastNameController.text = AppState().user!.lastName ?? "";
    _phoneController.text = AppState().user!.phone ?? "";
    _emailController.text = AppState().user!.email ?? "";
  }

  void onHistoryTap() async {
    var value = await AppState().getOrderHistory();
    if (value) {
      if (!mounted) return;
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const HistoryScreen()));
    } else {
      Get.snackbar("Error", "Error fetching order history");
    }
  }

  Future<void> fetchDevices() async {
    try {
      List<DeviceModel?> fetchedDevices = [];
      if (AppState().devices == null) {
        await AppState().getDevices();
        fetchedDevices = AppState().devices ?? [];
      } else {
        fetchedDevices = AppState().devices!;
      }
      _deviceStreamController.add(
        fetchedDevices
            .where((device) => device != null)
            .cast<DeviceModel>()
            .toList(),
      );
    } catch (error) {
      debugPrint('Error fetching devices: $error');
    }
  }

  @override
  void dispose() {
    _deviceStreamController
        .close(); // Close the stream controller when the widget is disposed
    super.dispose();
  }

  void logoutUser() {
    AppState().logoutUser();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const SplashScreen(),
      ),
      ModalRoute.withName('/splash'),
    );
  }

  void onSave() async {
    controller.showLoading();
    AppState().user!.firstName = _firstNameController.text.trim();
    AppState().user!.lastName = _lastNameController.text.trim();
    var value = await AppState().createUser(AppState().user!);
    if (!value) {
      AppState().user = dummyUser;
      Get.showSnackbar(
        const GetSnackBar(
          message: "Unable to update the profile",
          title: "Error",
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      Get.showSnackbar(
        const GetSnackBar(
          message: "Profile updated successfully",
          title: "Success",
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
    controller.hideLoading();
  }

  void showTutorial() {
    tutorialCoachMark.show(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: HeadingText(text: 'profile'.tr, size: 20),
        actions: [
          Row(
            children: [
              const Icon(Icons.language, color: Colors.white),
              const SizedBox(width: 5),
              DropdownButton(
                dropdownColor: Theme.of(context).primaryColor,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                iconEnabledColor: Colors.white,
                underline: Container(color: Colors.white, height: 1),
                key: _one,
                value: langValue,
                items: <String>["EN", "HI", "JA"].map<DropdownMenuItem<String>>(
                  (String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  langValue = value.toString();
                  if (value == 'EN') {
                    var locale = const Locale('en', 'US');
                    Get.updateLocale(locale);
                    AppState().storedLocale = locale.toString();
                  } else if (value == 'HI') {
                    var locale = const Locale('hi', 'IN');
                    Get.updateLocale(locale);
                    AppState().storedLocale = locale.toString();
                  } else if (value == 'JA') {
                    var locale = const Locale('ja', 'JP');
                    Get.updateLocale(locale);
                    AppState().storedLocale = locale.toString();
                  }
                },
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              createTutorial();
              showTutorial();
            },
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 32,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // const AvatarWithCameraIcon(index: 0),
                      CustomCachedImageWidget(
                        imageId: AppState().user!.id ?? "",
                        key: _two,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: _three,
                        style: const TextStyle(fontSize: 16),
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          hintText: 'fname'.tr,
                          hintStyle: const TextStyle(fontSize: 16),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        style: const TextStyle(fontSize: 16),
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          hintText: 'lname'.tr,
                          hintStyle: const TextStyle(fontSize: 16),
                        ),
                        validator: (value) {
                          if (value != null && value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      if (AppState().user!.phone != null &&
                          AppState().user!.phone!.isNotEmpty)
                        EditableTextField(
                          initialValue: AppState().user!.phone ?? " ",
                          flag: 1,
                        ),
                      if (AppState().user!.phone == null ||
                          AppState().user!.phone!.isEmpty)
                        LinkPhoneOrEmail(
                          text: 'linkPhone'.tr,
                          onPressed: () {
                            Get.off(() => const LoginPage());
                            setState(() {});
                          },
                        ),
                      const SizedBox(height: 16),
                      if (AppState().user!.email != null &&
                          AppState().user!.email!.isNotEmpty &&
                          AppState().user!.email != "NA")
                        EditableTextField(
                          initialValue: AppState().user!.email ?? " ",
                          flag: 2,
                        ),
                      if (AppState().user!.email == null ||
                          AppState().user!.email!.isEmpty ||
                          AppState().user!.email == "NA")
                        LinkPhoneOrEmail(
                          text: 'linkEmail'.tr,
                          onPressed: () async {
                            var controller = Get.put(AuthController());
                            var value = await controller.signInWithGoogle();
                            if (value) {
                              Get.snackbar(
                                "Success",
                                "Email verified successfully",
                              );
                            } else {
                              // Get.snackbar(
                              //     "Error", "Error signing in with Google");
                              Get.snackbar(
                                "Error",
                                AppState().message.toString(),
                              );
                            }
                          },
                        ),
                      const SizedBox(height: 16),
                      Obx(
                        () => controller.isLoading.value
                            ? const Center(child: CircularProgressIndicator())
                            : MaterialButton(
                                key: _four,
                                onPressed: () {
                                  onSave();
                                },
                                minWidth: double.infinity,
                                color: Theme.of(context).primaryColor,
                                child: Text("save".tr),
                              ),
                      ),
                      const Divider(thickness: 2),
                      // const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              StreamBuilder<List<DeviceModel>>(
                stream: _deviceStreamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show a loading indicator while fetching data
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    // Handle errors here
                    return Center(
                      child: Text('${"errorStream"}.tr: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // Show a message when there is no data
                    return Column(
                      children: [
                        const SizedBox(height: 10),
                        Center(child: Text('noDevice'.tr)),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SubscriptionScreen(),
                              ),
                            );
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Theme.of(context).primaryColor,
                            ),
                            height: MediaQuery.of(context).size.height * 0.05,
                            // width: MediaQuery.of(context).size.width * 0.4,
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 30),
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
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      // physics: const BouncingScrollPhysics(),
                      itemCount: devices.length,
                      // itemCount: 50,
                      itemBuilder: (context, index) {
                        AppState().device = devices[index];
                        DeviceModel? device = AppState().device;
                        return ListTileWidget(
                          verticalPadding: 8,
                          leadingIcon: Icons.phone_android,
                          title: device!.nickname ?? "no value",
                          // title: "hello",
                          subtitle: '',
                          isSwitched: false,
                          switchAvailable: false,
                          subtitleAvailable: false,
                          height: 50,
                          isDelete: true,
                        );
                      },
                    );
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 32,
                ),
                child: Column(
                  children: [
                    const Divider(thickness: 2),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        onHistoryTap();
                      },
                      icon: const Icon(Icons.history),
                      label: Text("History".tr),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    const Divider(thickness: 2),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    ElevatedButton.icon(
                      key: _five,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => CustomDialog(
                            header: "logout".tr,
                            body: "areYouSure".tr,
                            yesLogic: () {
                              logoutUser();
                            },
                            noLogic: () => Navigator.of(context).pop(false),
                          ),
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: Text("logout".tr),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // ),
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
      onSkip: () {
        return true;
      },
    );
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        identify: "language icon",
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
                    "Tap here to change the language of the application.",
                    style: TextStyle(color: Colors.white),
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
        identify: "profile button",
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
                    "Tap here to change your profile picture.",
                    style: TextStyle(color: Colors.white),
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
        identify: "name tile",
        keyTarget: _three,
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
                    "Tap here to modify your personal fields.",
                    style: TextStyle(color: Colors.white),
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
        identify: "save button",
        keyTarget: _four,
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
                    "Tap here to save your modified changes.",
                    style: TextStyle(color: Colors.white),
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
        identify: "logout button",
        keyTarget: _five,
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
                    "Tap here to logout from the application.",
                    style: TextStyle(color: Colors.white),
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
