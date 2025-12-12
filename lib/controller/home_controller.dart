import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var isLoading = false.obs;

  static RxBool isFirstTime = false.obs;

  void isFirsTimeTrue() {
    isFirstTime.value = true;
  }

  void isFirsTimeFalse() {
    isFirstTime.value = false;
  }

  RxDouble progress = 0.0.obs;

  var buttonEnabled = false.obs;

  void enableButton() {
    buttonEnabled.value = true;
  }

  void disableButton() {
    buttonEnabled.value = false;
  }

  void showLoading() {
    isLoading.value = true;
  }

  void hideLoading() {
    isLoading.value = false;
  }

  void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void showMessage(String message) {
    Get.snackbar(
      'Message',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
