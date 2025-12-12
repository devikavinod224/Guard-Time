import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImageController extends GetxController {
  // Create an Rx<YourImageProviderType> variable
  Rx<ImageProvider> imageProvider =
      Rx<ImageProvider>(const AssetImage('assets/images/profileIcon.png'));

  // A method to update the image provider
  void setImageProvider(ImageProvider newImageProvider) {
    imageProvider.value = newImageProvider;
  }
}
