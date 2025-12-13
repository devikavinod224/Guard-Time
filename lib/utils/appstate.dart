import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:parents_app/utils/api.dart';
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
    if (userPhone == null || userPhone!.length < 3) {
      messageColor = Colors.red;
      message = "Some problem in calling for OTP";
      return false;
    }
    var res = await API().getOtp(userPhone!);
    if (res['statusCode'] != 200) {
      messageColor = Colors.red;
      message = res['message'];
      return false;
    } else {
      messageColor = Colors.green;
      message = res['message'];
      return true;
    }
  }

  Future<int> verifyOtp(String otp) async {
    var res = await API().verifyOtp(userPhone!, otp);
    if (res['statusCode'] >= 205) {
      messageColor = Colors.red;
      message = res['message'];
      return 400;
    } else {
      messageColor = Colors.green;
      message = res['message'];
      if (user == null || user!.email == null || user!.email == "") {
        user = UserModel.fromMap(res['body']);
      } else {
        String userEmail = user!.email ?? "";
        user = UserModel.fromMap(res['body']);
        user!.email = userEmail;
      }
      return res['statusCode'];
    }
  }

  Future<bool> createUser(UserModel newUser) async {
    var res = await API().updateUser(newUser);
    if (res['statusCode'] >= 205) {
      messageColor = Colors.red;
      message = res['message'];
      return false;
    } else {
      messageColor = Colors.green;
      message = "Welcome! ${user!.firstName} ${user!.lastName}";
      user = UserModel.fromMap(res['body']);
      return true;
    }
  }

  Future<bool> createUserByEmail(UserModel newUser) async {
    var res = await API().createUser(newUser);
    if (res['statusCode'] >= 205) {
      messageColor = Colors.red;
      message = res['message'];
      return false;
    } else {
      messageColor = Colors.green;
      message = "Welcome! ${user!.firstName} ${user!.lastName}";
      user = UserModel.fromMap(res['body']);
      return true;
    }
  }

  Future<bool> checkUserExist(String phone, String email) async {
    var res = await API().userExists(phone, email);
    if (res['statusCode'] >= 205) {
      messageColor = Colors.red;
      message = res['message'];
      return false;
    } else {
      messageColor = Colors.green;
      message = "Welcome! ${user!.firstName} ${user!.lastName}";
      user = UserModel.fromJson(res['body']);
      return true;
    }
  }

  Future<bool> getDevices() async {
    var res = await API().getDevices(user!.id!);
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
    var res = await API().updateDevice(user!.id!, device!.id!, device!);
    if (res['statusCode'] == 200) {
      messageColor = Colors.green;
      message = res['message'];
      try {
        device = DeviceModel.fromMap(res['body']);
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
    var res = await API().updatePolicy(
        user!.id!, device!.id!, device!.policy!.id!, device!.policy!);
    if (res['statusCode'] == 200) {
      messageColor = Colors.green;
      message = res['message'];
      try {
        device!.policy = PolicyModel.fromMap(res['body']);
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
    var res = await API().uploadImage(image, imageId);
    if (res['statusCode'] == 200) {
      messageColor = Colors.green;
      message = res['message'];
      try {
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
    var res = await API().getOffers();
    print(res.toString());
    if (res['statusCode'] != 200) {
      messageColor = Colors.red;
      message = res['message'];
      return false;
    } else {
      messageColor = Colors.green;
      message = res['message'];
      try {
        offers = (res['body'] as List<dynamic>)
            .map((e) => OfferModel.fromMap(e))
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

  Future<bool> placeOrder(OfferModel offer) async {
    var res = await API().placeOrder(user!.id!, offer.id!, offer);
    if (res['statusCode'] != 201) {
      messageColor = Colors.red;
      message = res['message'];
      return false;
    } else {
      messageColor = Colors.green;
      message = res['message'];
      try {
        order = OrderModel.fromMap(res['body']);
        order!.orderPlacingTime =
            convertTime(order!.orderPlacingDate.toString());
        order!.orderPlacingDate =
            convertDate(order!.orderPlacingDate.toString());
        order!.orderExpiryTime = convertTime(order!.orderExpiryDate.toString());
        order!.orderExpiryDate = convertDate(order!.orderExpiryDate.toString());

        return true;
      } catch (e) {
        debugPrint(e.toString());
        messageColor = Colors.red;
        message = "Problem parsing device data";
        return false;
      }
    }
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

  // Future<bool> createOrder(Map<String, dynamic> orderData) async {
  //   try {
  //     var res = await API().createOrder(orderData);
  //     razorOrderId = res['id'];
  //     return true;
  //   } catch (e) {
  //     print(e);
  //     return false;
  //   }
  // }

  Future<bool> getOrderHistory() async {
    var res = await API().getOrderHistory(user!.id!);
    if (res['statusCode'] == 200) {
      messageColor = Colors.green;
      message = res['message'];
      orderHistoryList.clear();
      try {
        for (int i = 0; i < res['body']['orders'].length; i++) {
          orderHistoryList.add(OrderModel.fromMap(res['body']['orders'][i]));
        }
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
}
