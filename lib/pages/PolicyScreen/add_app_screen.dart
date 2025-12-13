import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parents_app/controller/home_controller.dart';
import 'package:parents_app/utils/appstate.dart';
import 'package:parents_app/utils/models.dart';

import '../../utils/widgets.dart';

class AddAppScreen extends StatefulWidget {
  const AddAppScreen({Key? key}) : super(key: key);

  @override
  AddAppScreenState createState() => AddAppScreenState();
}

class AddAppScreenState extends State<AddAppScreen> {
  final TextEditingController _editableTextController = TextEditingController();
  final String imageUrl = AppState().apkImage!;
  final String apkName = AppState().apkName!;
  final FocusNode _focusNode = FocusNode();
  HomeController homeController = Get.put(HomeController());
  DeviceModel device = AppState().device!;
  PolicyModel policy = AppState().device!.policy!;

  @override
  void initState() {
    super.initState();
    _editableTextController.text = apkName;
  }

  Future<void> onSave() async {
    // Save button functionality
    AppState().apkName = _editableTextController.text;
    homeController.showLoading();
    ApplicationModel applicationModel = ApplicationModel(
      packageName: AppState().packageName!,
      installType: "AVAILABLE",
      disabled: false,
    );
    AppState().device!.policy!.applications!.add(applicationModel);
    var value = await AppState().updatePolicy();
    if (value == true) {
      AppModel appModel = AppModel(
        name: _editableTextController.text,
        imageLink: AppState().apkImage!,
        package: AppState().packageName!,
      );
      AppState().device!.apps!.add(appModel);
      var temp = await AppState().updateDevice();
      if (temp == false) {
        device.apps!.remove(appModel);
        policy.applications!.remove(applicationModel);
        await AppState().updatePolicy();
        Get.snackbar("Error", "Something went wrong");
      }
    } else {
      policy.applications!.remove(applicationModel);
      Get.snackbar("Error", "Something went wrong");
    }
    homeController.hideLoading();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // When tapped anywhere on the screen, remove the focus from the text field.
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: HeadingText(
            text: "addApp".tr,
            size: 20,
          ),
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 50),
            Container(
              width: 96 * 1,
              height: 96 * 1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: Colors.amber.withOpacity(0.4), width: 2),
                shape: BoxShape.rectangle,
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(imageUrl),
                ),
              ),
            ),
            const SizedBox(height: 50),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                focusNode: _focusNode,
                controller: _editableTextController,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: "appName".tr,
                  labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: Obx(
            () => homeController.isLoading.value == true
                ? const CustomLoadingIndicator(
                    height: 50,
                    width: 50,
                    horizontalPadding: 190,
                    verticalPadding: 10,
                  )
                : MaterialButton(
                    onPressed: () async {
                      await onSave();
                      // Get.offAllNamed(Get.until((route) => 'apps')  );
                      Get.back();
                    },
                    color: Theme.of(context).primaryColor,
                    height: 50,
                    child: HeadingText(
                      text: "save".tr,
                      color: Colors.black,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
