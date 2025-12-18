import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:parents_app/controller/home_controller.dart';
import 'package:parents_app/pages/PolicyScreen/policy_screen.dart';
import 'package:parents_app/utils/appstate.dart';
import 'package:parents_app/utils/image_cache_manager.dart';
import 'package:parents_app/utils/models.dart';
import 'package:parents_app/utils/widgets.dart';
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
  final GlobalKey _two = GlobalKey(); // Kept for tutorial structure but unused
  final GlobalKey _three = GlobalKey();
  bool isDeviceAdded = false;
  final List<String>? deviceIds = AppState().fetchDeviceIds();
  final imageCacheManager = ImageCacheManager();
  
  @override
  void initState() {
    fetchDevices();
    super.initState();
  }

  // Function to fetch devices from the API and add them to the stream
  Future<bool> fetchDevices() async {
    try {
      if (AppState().user == null) return false;
      
      List<DeviceModel?> fetchedDevices = [];
      var value = await AppState().getDevices();
      if (value) {
        fetchedDevices = AppState().devices ?? [];
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

  void addNewDevice() async {
    TextEditingController nameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Device"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "Device Nickname (e.g. Kid's Tablet)"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (nameController.text.isNotEmpty) {
                DeviceModel newDevice = DeviceModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  nickname: nameController.text,
                  brand: "Generic",
                  model: "Device",
                  policy: PolicyModel(
                    id: "policy_${DateTime.now().millisecondsSinceEpoch}",
                    name: "Default Policy",
                    applications: [],
                  ),
                  apps: [],
                );
                
                // Save to currently selected device slot in AppState so updateDevice uses it
                AppState().device = newDevice; 
                
                bool success = await AppState().updateDevice();
                if (success) {
                  fetchDevices();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Device Added Successfully")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text("Failed to add device: ${AppState().message}")),
                  );
                }
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _deviceStreamController.close();
    super.dispose();
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
             // Removed Help and Subscription icons for cleaner UI or kept only useful ones
          ],
        ),
        resizeToAvoidBottomInset: true,
        floatingActionButton: FloatingActionButton(
          onPressed: addNewDevice,
          child: const Icon(Icons.add),
          tooltip: 'Add Device',
        ),
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
                       // Replaced Buy Device with simple text or hidden
                       Center(child: Text("Tap + to add a device", style: TextStyle(color: Colors.grey))),
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
                      if (AppState().deviceIdList != null && index + 1 < AppState().deviceIdList!.length) {
                        deviceImage = ImageCacheManager().getImageForDevice(
                            AppState().deviceIdList![index + 1]);
                      } else {
                        deviceImage =
                            const AssetImage("assets/images/profileIcon.png");
                      }
                      AppState().device = devices[index];
                      DeviceModel? device = AppState().device;
                      
                      return DeviceListTile(
                        key: index == 0 ? _one : null,
                        image: deviceImage,
                        deviceBrand: device!.brand ?? "Generic",
                        deviceModel: device.model ?? "Device",
                        deviceName: device.nickname ?? "My Device",
                        onTap: () async {
                          AppState().device = devices[index];
                          // Check if policy is null and provide default
                          if (AppState().device!.policy == null) {
                             AppState().device!.policy = PolicyModel(name: "Default");
                          }
                          AppState().index = index;
                          await Get.to(() => PolicyScreen(
                              index: index,
                              device: devices[index],
                              policy: devices[index].policy!));

                          setState(() {});
                          // }
                        },
                      );
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
}
