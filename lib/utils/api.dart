import 'dart:convert';
import 'dart:io';

import 'package:parents_app/utils/models.dart';
import 'package:http/http.dart' as http;

class API {
  // Private constructor to prevent external instantiation
  API._();

  static final API _instance = API._();

  factory API() => _instance;
  String baseUrl = "https://guardtime-backend.vercel.app/api/user";

  dynamic getHeader([String? username, String password = "password"]) async {
    String credentials = "";

    credentials = "$username:$password";
    String encoded = base64.encode(utf8.encode(credentials));

    dynamic header = {
      'Authorization': 'Basic $encoded',
      // 'Cookie': 'sessionid=$sessionId',
      'Content-Type': 'application/json'
    };
    return header;
  }

  dynamic handleResponse(dynamic res) {
    try {
      if (res.statusCode != 500) {
        var jsonResponse = jsonDecode(res.body);
        // print(jsonResponse);
        jsonResponse['statusCode'] = res.statusCode;
        return jsonResponse;
      } else {
        return {
          'statusCode': 500,
          'message': 'Internal Server Error',
          'body': {}
        };
      }
    } catch (e) {
      return {'statusCode': 500, 'message': 'Server not available', 'body': {}};
    }
  }

  Future<dynamic> createUser(UserModel user) async {
    var url = "$baseUrl/login";
    try {
      var res = await http.post(Uri.parse(url),
          headers: await getHeader(), body: user.toJson());
      return handleResponse(res);
    } catch (e) {
      return {'statusCode': 500, 'message': 'Server not available', 'body': {}};
    }
  }

  Future<dynamic> getOtp(String phone) async {
    var url = "$baseUrl/$phone/otp";
    try {
      var res = await http.get(Uri.parse(url));
      return handleResponse(res);
    } catch (e) {
      return {'statusCode': 500, 'message': 'Server not available', 'body': {}};
    }
  }

  Future<dynamic> verifyOtp(String phone, String otp) async {
    var url = "$baseUrl/$phone/otp";
    try {
      var res = await http.post(
        Uri.parse(url),
        headers: await getHeader(),
        body: jsonEncode({"otp": otp}),
      );
      return handleResponse(res);
    } catch (e) {
      return {'statusCode': 500, 'message': 'Server not available', 'body': {}};
    }
  }

  Future<dynamic> userExists(String phone, String email) async {
    var url = "$baseUrl/userexists";
    try {
      var res = await http.post(
        Uri.parse(url),
        headers: await getHeader(),
        body: jsonEncode({"phone": phone, "email": email}),
      );
      return handleResponse(res);
    } catch (e) {
      return {'statusCode': 500, 'message': 'Server not available', 'body': {}};
    }
  }

  Future<dynamic> getDevices(String userId) async {
    var url = "$baseUrl/$userId/device";
    try {
      var res = await http.get(Uri.parse(url));
      return handleResponse(res);
    } catch (e) {
      return {'statusCode': 500, 'message': 'Server not available', 'body': {}};
    }
  }

  Future<dynamic> getDevice(String userId, String deviceId) async {
    var url = "$baseUrl/$userId/device/$deviceId";
    try {
      var res = await http.get(Uri.parse(url));
      return handleResponse(res);
    } catch (e) {
      return {'statusCode': 500, 'message': 'Server not available', 'body': {}};
    }
  }

  Future<dynamic> updatePolicy(String userId, String deviceId, String policyId,
      PolicyModel policy) async {
    var url = "$baseUrl/$userId/device/$deviceId/policy/$policyId";
    try {
      var res = await http.put(
        Uri.parse(url),
        headers: await getHeader(),
        body: jsonEncode({"policyItself": policy.toMap()}),
      );
      return handleResponse(res);
    } catch (e) {
      return {'statusCode': 500, 'message': 'Server not available', 'body': {}};
    }
  }

  Future<dynamic> updateDevice(
      String userId, String deviceId, DeviceModel device) async {
    var url = "$baseUrl/$userId/device/$deviceId";
    try {
      var res = await http.put(
        Uri.parse(url),
        headers: await getHeader(),
        body: device.toJson(),
      );
      return handleResponse(res);
    } catch (e) {
      return {'statusCode': 500, 'message': 'Server not available', 'body': {}};
    }
  }

  Future<dynamic> updateUser(UserModel user) async {
    var url = "$baseUrl/${user.id}";
    try {
      var res = await http.put(
        Uri.parse(url),
        headers: await getHeader(),
        body: user.toJson(),
      );
      return handleResponse(res);
    } catch (e) {
      return {'statusCode': 500, 'message': 'Server not available', 'body': {}};
    }
  }

  Future<dynamic> getPlayStoreData(String url) async {
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response;
      } else {}
    } catch (e) {
      return {'statusCode': 500, 'message': 'Server not available', 'body': {}};
    }
  }

  Future<dynamic> uploadImage(File image, String imageId) async {
    var url = "$baseUrl/image/$imageId";
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(await http.MultipartFile.fromPath('file', image.path));
      var res = await request.send();
      return {'statusCode': res.statusCode, 'message': 'Success', 'body': {}};
    } catch (e) {
      return {'statusCode': 500, 'message': 'Server not available', 'body': {}};
    }
  }

  Future<dynamic> getOffers() async {
    var url = "$baseUrl/offers";
    try {
      var res = await http.get(Uri.parse(url));
      return handleResponse(res);
    } catch (e) {
      return {'statusCode': 500, 'message': 'Server not available', 'body': {}};
    }
  }

  Future<dynamic> placeOrder(
      String userId, String offerId, OfferModel offer) async {
    var url = "$baseUrl/$userId/offers/$offerId";
    try {
      var res = await http.post(
        Uri.parse(url),
        body: offer.toJson(),
        headers: await getHeader(),
      );
      return handleResponse(res);
    } catch (e) {
      return {'statusCode': 500, 'message': 'Server not available', 'body': {}};
    }
  }

  // Future<dynamic> createOrder(Map<String, dynamic> orderData) async {
  //   String basicAuth = base64Encode(
  //       utf8.encode('${ApiKeys().username}:${ApiKeys().password}'));
  //   try {
  //     var response = await http.post(
  //       Uri.parse('https://api.razorpay.com/v1/orders'),
  //       headers: <String, String>{'authorization': basicAuth},
  //       body: jsonEncode(orderData),
  //     );
  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body);
  //     } else {
  //       return {
  //         'statusCode': response.statusCode,
  //         'message': 'Failed',
  //         'body': {}
  //       };
  //     }
  //   } catch (e) {
  //     return {'statusCode': 500, 'message': 'Server not available', 'body': {}};
  //   }
  // }

  Future<dynamic> getOrderHistory(String userId) async {
    var url = "$baseUrl/$userId/orders";
    try {
      var res = await http.get(Uri.parse(url));
      return handleResponse(res);
    } catch (e) {
      return {'statusCode': 500, 'message': 'Server not available', 'body': {}};
    }
  }
}
