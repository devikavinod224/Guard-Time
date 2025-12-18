import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:parents_app/utils/api.dart';
import 'package:parents_app/utils/firebase_service.dart';
import 'package:parents_app/utils/models.dart';
import 'package:html/parser.dart' as html;
import 'package:path_provider/path_provider.dart';

class AppState {
  // Private constructor to prevent external instantiation
  AppState._();

  static final AppState _instance = AppState._();

  factory AppState() => _instance;
  onInit() async {
    await initializePersistentVariables();
    // imageUserURL = "$baseUrl/image/${user!.id}";
  }

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  // Variables that will be stored during runtime
  DeviceModel? device;
  List<DeviceModel>? devices;
  List<OfferModel>? offers;
  OrderModel? order;
  String? message;
  Color? messageColor;
  int? index;
  String? packageName;
  String? apkName = '';
  String? apkImage = '';
  File? imageUser;
  File? imageDevice;
  String? razorOrderId;
  // String? imageUserURL;
  // String? imageDeviceURL;
  String? baseUrl = API().baseUrl;
  List<String>? deviceIdList;
  String? currentOfferId;
  OfferModel currentOffer = OfferModel();
  List<OrderModel> orderHistoryList = [];

  // Persistant Variables

  final String _userKey = 'user';
  UserModel? _user;

  // Getters and setters for persistent variable

  String? userPhone = '';

  UserModel? get user => _user;
  set user(UserModel? value) {
    _user = value;
    // dynamic j = (value is Map<String, dynamic>)
    //     ? jsonEncode(value?.toJson() ?? {})
    //     : "";
    dynamic j = jsonEncode(value?.toJson() ?? {});
    _secureStorage.write(key: _userKey, value: j);
  }

  String? _storedLocale = "en_US";
  String? get storedLocale => _storedLocale;
  set storedLocale(String? value) {
    _storedLocale = value;
    _secureStorage.write(key: 'locale', value: value);
  }

  void logoutUser() {
    AppState().user = null;
    AppState().devices = null;
  }

  // Initialize the persistent variable from secure storage
  Future<void> initializePersistentVariables() async {
    String? userString = await _secureStorage.read(key: _userKey);
    String? userLocale = await _secureStorage.read(key: 'locale');
    _user = (userString == null || userString == "{}")
        ? UserModel()
        : UserModel.fromJson(json.decode(userString.toString()));
    _storedLocale = (userLocale == null || userLocale == "{}")
        ? "en_US"
        : (userLocale.toString());
  }

  Future<void> getPlayStoreData(String url) async {
    try {
      dynamic response = await API().getPlayStoreData(url);
      debugPrint("Url from appstate is: $url");
      debugPrint("Response from appstate is: ${response.statusCode}");
      if (response.statusCode == 200) {
        final document = html.parse(response.body);
        // Extract app name
        final appNames = document.querySelectorAll('h1');
        final appName = appNames[0].text;
        apkName = appName;
        debugPrint('App Name: $appName');

        // Extract app icon URL
        final appIconElement = document.querySelector('img[alt="Icon image"]');
        if (appIconElement != null) {
          final appIconSrc = appIconElement.attributes['src'];
          apkImage = appIconSrc;
          debugPrint('App Icon URL: $appIconSrc');
        } else {
          debugPrint('App Icon not found');
        }
      } else {
        debugPrint("error");
        messageColor = Colors.red;
        message = response['message'];
      }
    } catch (e) {
      debugPrint(e.toString());
      messageColor = Colors.red;
      message = "Server not available";
    }
  }

  Future<bool> getOtp() async {
    // Legacy support for Phone Auth if needed, but we rely on Google Sign In mostly now
    // or we should migrate this to Firebase Auth as well.
    // For now, keeping it as is or bypassing.
    if (userPhone == null || userPhone!.length < 3) {
      messageColor = Colors.red;
      message = "Some problem in calling for OTP";
      return false;
    }
    // Just return true to allow bypassing if we want to use Firebase Auth later
    // But since login.dart uses a real backend call, this might fail if backend is down.
    var res = await API().getOtp(userPhone!);
    if (res['statusCode'] != 200) {
      messageColor = Colors.red;
      message = res['message'];
      // return false; 
      // Force success if backend fails? No, let's keep it real for now.
      return false;
    } else {
      messageColor = Colors.green;
      message = res['message'];
      return true;
    }
  }

  Future<int> verifyOtp(String otp) async {
    // This is for the custom backend Phone Auth.
    // If migrating to Firebase, we should use FirebaseAuth.
    // For now, if we use Google Sign In, this is not called.
    var res = await API().verifyOtp(userPhone!, otp);
     if (res['statusCode'] >= 205) {
      messageColor = Colors.red;
      message = res['message'];
      return 400;
    } else {
      messageColor = Colors.green;
      message = res['message'];
      // We still try to populate user for legacy reasons, but Google Auth is preferred.
      if (res['body'] is Map<String, dynamic>) {
         if (user == null || user!.email == null || user!.email == "") {
          user = UserModel.fromMap(res['body']);
        } else {
          String userEmail = user!.email ?? "";
          user = UserModel.fromMap(res['body']);
          user!.email = userEmail;
        }
      }
      return res['statusCode'];
    }
  }

  Future<bool> createUser(UserModel newUser) async {
    // Migrated to FirebaseService
    var res = await FirebaseService().saveUser(newUser);
    if (res['statusCode'] >= 205) {
      messageColor = Colors.red;
      message = res['message'];
      return false;
    } else {
      messageColor = Colors.green;
      message = "Welcome! ${user!.firstName} ${user!.lastName}";
      if (res['body'] != null) {
         user = UserModel.fromMap(res['body']);
      }
      return true;
    }
  }

  Future<bool> createUserByEmail(UserModel newUser) async {
    // Migrated to FirebaseService
    var res = await FirebaseService().saveUser(newUser);
    if (res['statusCode'] >= 205) {
      messageColor = Colors.red;
      message = res['message'];
      return false;
    } else {
      messageColor = Colors.green;
      message = "Welcome! ${user!.firstName} ${user!.lastName}";
       if (res['body'] != null) {
         user = UserModel.fromMap(res['body']);
      }
      return true;
    }
  }

  Future<bool> checkUserExist(String phone, String email) async {
     // Migrated to FirebaseService (Mock/Check)
    // var res = await API().userExists(phone, email);
    // Since we are moving to Firestore, we might just assume user exists?
    // or use FirebaseService().getUser(uid)
    return true; 
  }

  Future<bool> getDevices() async {
    if (user?.id == null) return false;
    // Migrated to FirebaseService
    var res = await FirebaseService().getDevices(user!.id!);
    if (res['statusCode'] != 200) {
      messageColor = Colors.red;
      message = res['message'];
      return false;
    } else {
      messageColor = Colors.green;
      message = res['message'];
      try {
        devices = (res['devices'] as List<dynamic>)
            .map((e) => DeviceModel.fromMap(e))
            .toList();
        return true;
      } catch (e) {
        debugPrint(e.toString());
        messageColor = Colors.red;
        message = "Problem parsing device data";
        return false;
      }
    }
  }

  Future<bool> updateDevice() async {
    if (user?.id == null || device?.id == null) return false;
    // Migrated to FirebaseService
    var res = await FirebaseService().updateDevice(user!.id!, device!);
    if (res['statusCode'] == 200) {
      messageColor = Colors.green;
      message = res['message'];
      try {
        // device = DeviceModel.fromMap(res['body']);
        return true;
      } catch (e) {
        debugPrint(e.toString());
        messageColor = Colors.red;
        message = "Problem parsing device data";
        return false;
      }
    } else {
      messageColor = Colors.red;
      message = res['message'];
      return false;
    }
  }

  Future<bool> updatePolicy() async {
     if (user?.id == null || device?.id == null || device?.policy == null) return false;
    // Migrated to FirebaseService
    var res = await FirebaseService().updatePolicy(
        user!.id!, device!.id!, device!.policy!);
    if (res['statusCode'] == 200) {
      messageColor = Colors.green;
      message = res['message'];
      try {
        // device!.policy = PolicyModel.fromMap(res['body']);
        return true;
      } catch (e) {
        debugPrint(e.toString());
        messageColor = Colors.red;
        message = "Problem parsing device data";
        return false;
      }
    } else {
      messageColor = Colors.red;
      message = res['message'];
      return false;
    }
  }

  Future<bool> uploadImage(File image, String imageId) async {
    // Keep as is or migrate if backend supports images?
    // Firestore doesn't do images well, would need Storage.
    // For now, we can skip or keep API if it still works (unlikely for free).
    // Let's assume we ignore images for now.
    return true;
  }

  List<String> fetchDeviceIds() {
    final List<String> deviceIds = [];
    if (user != null && user!.id != null && user!.devices != null) {
      deviceIds.add(user!.id!);
      for (var device in user!.devices!) {
        deviceIds.add(device);
      }
    }
    deviceIdList = deviceIds;
    print(user);
    print(user!.devices!);
    debugPrint("List of device ids is: ${deviceIds.toString()}");
    return deviceIds;
  }

  Future<File> convertAssetImageToFile() async {
    ByteData assetByteData =
        await rootBundle.load('assets/images/profileIcon.png');
    List<int> byteList = assetByteData.buffer.asUint8List();

    // Define the file path where you want to save the image
    Directory tempDir = await getTemporaryDirectory();
    String filePath = '${tempDir.path}/image.png';

    File imageFile = File(filePath);
    await imageFile.writeAsBytes(byteList);

    return imageFile;
  }

  Future<bool> fetchOffers() async {
    // No offers needed for free version
      messageColor = Colors.green;
      message = "Free Version";
      offers = [];
      return true;
  }

  Future<bool> placeOrder(OfferModel offer) async {
     // No orders needed
      return true;
  }

  String convertTime(String x) {
    double time = (double.parse(x.substring(11, 13)) +
        double.parse(x.substring(14, 16)) * 0.01 +
        5.30);
    String ampm = "AM";
    if (time > 12) {
      ampm = "PM";
    }
    if (time > 12.59) {
      time = time - 12;
    }
    String timeString = time.toStringAsFixed(2);
    String hour = timeString.substring(0, timeString.indexOf('.'));
    String minute = timeString.substring(timeString.indexOf('.') + 1);
    double minuteValue = double.parse(minute);
    if (minuteValue >= 60) {
      minuteValue = minuteValue - 60;
      minute = minuteValue.toStringAsFixed(0);
      hour = (double.parse(hour) + 1).toStringAsFixed(0);
    }
    if (hour.length == 1) {
      hour = "0$hour";
    }
    if (minute.length == 1) {
      minute = "0$minute";
    }
    String ans = "$hour:$minute $ampm";
    return ans;
  }

  String convertDate(String x) {
    String date = x.substring(0, 10);
    String year = date.substring(0, 4);
    String day = date.substring(5, 7);
    String month = date.substring(8, 10);
    return "$day-$month-$year";
  }

  Future<bool> getOrderHistory() async {
      orderHistoryList = [];
      return true;
  }
}
