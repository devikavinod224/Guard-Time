// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:guard_time/utils/appstate.dart';

class ValueModel {
  String? key;
  int? numValue;
  String? stringValue;
  List<String>? listValue;
  ValueModel({
    this.key,
    this.numValue,
    this.stringValue,
    this.listValue,
  });

  ValueModel copyWith({
    String? key,
    int? numValue,
    String? stringValue,
    List<String>? listValue,
  }) {
    return ValueModel(
      key: key ?? this.key,
      numValue: numValue ?? this.numValue,
      stringValue: stringValue ?? this.stringValue,
      listValue: listValue ?? this.listValue,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'key': key,
      'numValue': numValue,
      'stringValue': stringValue,
      'listValue': listValue,
    };
  }

  factory ValueModel.fromMap(Map<String, dynamic> map) {
    return ValueModel(
      key: map['key'] != null ? map['key'] as String : null,
      numValue: map['numValue'] != null ? map['numValue'] as int : null,
      stringValue:
          map['stringValue'] != null ? map['stringValue'] as String : null,
      listValue: map['listValue'] != null
          ? List<String>.from((map['listValue'] as List<String>))
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ValueModel.fromJson(String source) =>
      ValueModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ValueModel(key: $key, numValue: $numValue, stringValue: $stringValue, listValue: $listValue)';
  }

  @override
  bool operator ==(covariant ValueModel other) {
    if (identical(this, other)) return true;

    return other.key == key &&
        other.numValue == numValue &&
        other.stringValue == stringValue &&
        listEquals(other.listValue, listValue);
  }

  @override
  int get hashCode {
    return key.hashCode ^
        numValue.hashCode ^
        stringValue.hashCode ^
        listValue.hashCode;
  }
}

class PolicyModel {
  String? id;
  String? name;
  List<ApplicationModel>? applications;
  bool? adjustVolumeDisabled;
  bool? installAppsDisabled;
  // bool? factoryResetDisabled;
  bool? mountPhysicalMediaDisabled;
  bool? outgoingCallsDisabled;
  bool? usbFileTransferDisabled;
  // 43 and 45 are in OR for disable external storage
  bool? bluetoothDisabled;
  String? playStoreMode;
  // 1. whitelist --> which means all other apps are disabled
  //2. blacklist --> which means all other apps are enabled only these are disabled.
  // Map<String, String>? advancedSecurityOverrides;
  String? locationMode;
  PolicyModel({
    this.id,
    this.name,
    this.applications,
    this.adjustVolumeDisabled,
    this.installAppsDisabled,
    this.mountPhysicalMediaDisabled,
    this.outgoingCallsDisabled,
    this.usbFileTransferDisabled,
    this.bluetoothDisabled,
    this.playStoreMode,
    this.locationMode,
  });

  PolicyModel copy(PolicyModel other) {
    return PolicyModel(
      id: other.id,
      name: other.name,
      applications: other.applications,
      adjustVolumeDisabled: other.adjustVolumeDisabled,
      installAppsDisabled: other.installAppsDisabled,
      // factoryResetDisabled: other.factoryResetDisabled,
      mountPhysicalMediaDisabled: other.mountPhysicalMediaDisabled,
      outgoingCallsDisabled: other.outgoingCallsDisabled,
      usbFileTransferDisabled: other.usbFileTransferDisabled,
      bluetoothDisabled: other.bluetoothDisabled,
      playStoreMode: other.playStoreMode,
      // advancedSecurityOverrides: other.advancedSecurityOverrides,
      locationMode: other.locationMode,
    );
  }

  PolicyModel copyWith({
    String? id,
    String? name,
    List<ApplicationModel>? applications,
    bool? adjustVolumeDisabled,
    bool? installAppsDisabled,
    bool? mountPhysicalMediaDisabled,
    bool? outgoingCallsDisabled,
    bool? usbFileTransferDisabled,
    bool? bluetoothDisabled,
    String? playStoreMode,
    String? locationMode,
  }) {
    return PolicyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      applications: applications ?? this.applications,
      adjustVolumeDisabled: adjustVolumeDisabled ?? this.adjustVolumeDisabled,
      installAppsDisabled: installAppsDisabled ?? this.installAppsDisabled,
      mountPhysicalMediaDisabled:
          mountPhysicalMediaDisabled ?? this.mountPhysicalMediaDisabled,
      outgoingCallsDisabled:
          outgoingCallsDisabled ?? this.outgoingCallsDisabled,
      usbFileTransferDisabled:
          usbFileTransferDisabled ?? this.usbFileTransferDisabled,
      bluetoothDisabled: bluetoothDisabled ?? this.bluetoothDisabled,
      playStoreMode: playStoreMode ?? this.playStoreMode,
      locationMode: locationMode ?? this.locationMode,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'name': name,
      'applications': applications!.map((x) => x.toMap()).toList(),
      'adjustVolumeDisabled': adjustVolumeDisabled,
      'installAppsDisabled': installAppsDisabled,
      'mountPhysicalMediaDisabled': mountPhysicalMediaDisabled,
      'outgoingCallsDisabled': outgoingCallsDisabled,
      'usbFileTransferDisabled': usbFileTransferDisabled,
      'bluetoothDisabled': bluetoothDisabled,
      'playStoreMode': playStoreMode,
      'locationMode': locationMode,
    };
  }

  factory PolicyModel.fromMap(Map<String, dynamic> map) {
    return PolicyModel(
      id: map['_id'] != null ? map['_id'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      applications: map['applications'] != null
          ? List<ApplicationModel>.from(
              (map['applications'] as List<dynamic>).map<ApplicationModel?>(
                (x) => ApplicationModel.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
      adjustVolumeDisabled: map['adjustVolumeDisabled'] != null
          ? map['adjustVolumeDisabled'] as bool
          : null,
      installAppsDisabled: map['installAppsDisabled'] != null
          ? map['installAppsDisabled'] as bool
          : null,
      mountPhysicalMediaDisabled: map['mountPhysicalMediaDisabled'] != null
          ? map['mountPhysicalMediaDisabled'] as bool
          : null,
      outgoingCallsDisabled: map['outgoingCallsDisabled'] != null
          ? map['outgoingCallsDisabled'] as bool
          : null,
      usbFileTransferDisabled: map['usbFileTransferDisabled'] != null
          ? map['usbFileTransferDisabled'] as bool
          : null,
      bluetoothDisabled: map['bluetoothDisabled'] != null
          ? map['bluetoothDisabled'] as bool
          : null,
      playStoreMode:
          map['playStoreMode'] != null ? map['playStoreMode'] as String : null,
      locationMode:
          map['locationMode'] != null ? map['locationMode'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory PolicyModel.fromJson(String source) =>
      PolicyModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PolicyModel(id: $id, name: $name, applications: $applications, adjustVolumeDisabled: $adjustVolumeDisabled, installAppsDisabled: $installAppsDisabled, mountPhysicalMediaDisabled: $mountPhysicalMediaDisabled, outgoingCallsDisabled: $outgoingCallsDisabled, usbFileTransferDisabled: $usbFileTransferDisabled, bluetoothDisabled: $bluetoothDisabled, playStoreMode: $playStoreMode, locationMode: $locationMode)';
  }

  @override
  bool operator ==(covariant PolicyModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        listEquals(other.applications, applications) &&
        other.adjustVolumeDisabled == adjustVolumeDisabled &&
        other.installAppsDisabled == installAppsDisabled &&
        other.mountPhysicalMediaDisabled == mountPhysicalMediaDisabled &&
        other.outgoingCallsDisabled == outgoingCallsDisabled &&
        other.usbFileTransferDisabled == usbFileTransferDisabled &&
        other.bluetoothDisabled == bluetoothDisabled &&
        other.playStoreMode == playStoreMode &&
        other.locationMode == locationMode;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        applications.hashCode ^
        adjustVolumeDisabled.hashCode ^
        installAppsDisabled.hashCode ^
        mountPhysicalMediaDisabled.hashCode ^
        outgoingCallsDisabled.hashCode ^
        usbFileTransferDisabled.hashCode ^
        bluetoothDisabled.hashCode ^
        playStoreMode.hashCode ^
        locationMode.hashCode;
  }
}

class ApplicationModel {
  String? packageName;
  String? installType;
  bool? disabled;
  ApplicationModel({
    this.packageName,
    this.installType,
    this.disabled,
  });

  ApplicationModel copyWith({
    String? packageName,
    String? installType,
    bool? disabled,
  }) {
    return ApplicationModel(
      packageName: packageName ?? this.packageName,
      installType: installType ?? this.installType,
      disabled: disabled ?? this.disabled,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'packageName': packageName,
      'installType': installType,
      'disabled': disabled,
    };
  }

  factory ApplicationModel.fromMap(Map<String, dynamic> map) {
    return ApplicationModel(
      packageName:
          map['packageName'] != null ? map['packageName'] as String : null,
      installType:
          map['installType'] != null ? map['installType'] as String : null,
      disabled: map['disabled'] != null ? map['disabled'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ApplicationModel.fromJson(String source) =>
      ApplicationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ApplicationModel(packageName: $packageName, installType: $installType, disabled: $disabled)';

  @override
  bool operator ==(covariant ApplicationModel other) {
    if (identical(this, other)) return true;

    return other.packageName == packageName &&
        other.installType == installType &&
        other.disabled == disabled;
  }

  @override
  int get hashCode =>
      packageName.hashCode ^ installType.hashCode ^ disabled.hashCode;
}

class AppModel {
  String? package;
  String? name;
  String? imageLink;
  AppModel({
    this.package,
    this.name,
    this.imageLink,
  });

  AppModel copyWith({
    String? package,
    String? name,
    String? imageLink,
  }) {
    return AppModel(
      package: package ?? this.package,
      name: name ?? this.name,
      imageLink: imageLink ?? this.imageLink,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'package': package,
      'name': name,
      'imageLink': imageLink,
    };
  }

  factory AppModel.fromMap(Map<String, dynamic> map) {
    return AppModel(
      package: map['package'] != null ? map['package'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      imageLink: map['imageLink'] != null ? map['imageLink'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppModel.fromJson(String source) =>
      AppModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'AppModel(package: $package, name: $name, imageLink: $imageLink)';

  @override
  bool operator ==(covariant AppModel other) {
    if (identical(this, other)) return true;

    return other.package == package &&
        other.name == name &&
        other.imageLink == imageLink;
  }

  @override
  int get hashCode => package.hashCode ^ name.hashCode ^ imageLink.hashCode;
}

class DeviceModel {
  List<AppModel>? apps;
  String? id;
  String? name;
  String? brand;
  String? model;
  String? nickname;
  String? qrCode;
  PolicyModel? policy; // Corrected field type
  String? createdOn;
  String? enrolledOn;
  bool? currentlyEnrolled;
  String? otp;
  List<String>? orders;

  DeviceModel(
      {this.id,
      this.name,
      this.brand,
      this.model,
      this.nickname,
      this.qrCode,
      this.policy,
      this.createdOn,
      this.enrolledOn,
      this.currentlyEnrolled,
      this.otp,
      this.apps});

  DeviceModel.copy(DeviceModel other) {
    id = other.id;
    name = other.name;
    brand = other.brand;
    model = other.model;
    nickname = other.nickname;
    qrCode = other.qrCode;
    policy = PolicyModel().copy(other.policy!);
    createdOn = other.createdOn;
    enrolledOn = other.enrolledOn;
    currentlyEnrolled = other.currentlyEnrolled;
    otp = other.otp;
    apps = other.apps;
  }

  DeviceModel copyWith({
    String? id,
    String? name,
    String? brand,
    String? model,
    String? nickname,
    String? qrCode,
    PolicyModel? policy,
    String? createdOn,
    String? enrolledOn,
    bool? currentlyEnrolled,
    String? otp,
    List<AppModel>? apps,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      nickname: nickname ?? this.nickname,
      qrCode: qrCode ?? this.qrCode,
      policy: policy ?? this.policy,
      createdOn: createdOn ?? this.createdOn,
      enrolledOn: enrolledOn ?? this.enrolledOn,
      currentlyEnrolled: currentlyEnrolled ?? this.currentlyEnrolled,
      otp: otp ?? this.otp,
      apps: apps ?? this.apps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'name': name,
      'brand': brand,
      'model': model,
      'nickname': nickname,
      'qrCode': qrCode,
      'policy': policy?.toMap(),
      'createdOn': createdOn,
      'enrolledOn': enrolledOn,
      'currentlyEnrolled': currentlyEnrolled,
      'otp': otp,
      'apps': apps!.map((x) => x.toMap()).toList(),
    };
  }

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      id: map['_id'] != null ? map['_id'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      brand: map['brand'] != null ? map['brand'] as String : null,
      model: map['model'] != null ? map['model'] as String : null,
      nickname: map['nickname'] != null ? map['nickname'] as String : null,
      qrCode: map['qrCode'] != null ? map['qrCode'] as String : null,
      policy: map['policy'] != null
          ? map['policy'] is String
              ? PolicyModel.fromJson(AppState().device!.policy!.toJson())
              : PolicyModel.fromMap(map['policy'] as Map<String, dynamic>)
          : null,
      createdOn: map['createdOn'] != null ? map['createdOn'] as String : null,
      enrolledOn:
          map['enrolledOn'] != null ? map['enrolledOn'] as String : null,
      currentlyEnrolled: map['currentlyEnrolled'] != null
          ? map['currentlyEnrolled'] as bool
          : null,
      otp: map['otp'] != null ? map['otp'] as String : null,
      apps: map['apps'] != null
          ? List<AppModel>.from(
              (map['apps'] as List<dynamic>).map<AppModel?>(
                (x) => AppModel.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DeviceModel.fromJson(String source) =>
      DeviceModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DeviceModel(id: $id, name: $name, brand: $brand, model: $model, nickname: $nickname, qrCode: $qrCode, policy: $policy, createdOn: $createdOn, enrolledOn: $enrolledOn, currentlyEnrolled: $currentlyEnrolled, otp: $otp)';
  }

  @override
  bool operator ==(covariant DeviceModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.brand == brand &&
        other.model == model &&
        other.nickname == nickname &&
        other.qrCode == qrCode &&
        other.policy == policy &&
        other.createdOn == createdOn &&
        other.enrolledOn == enrolledOn &&
        other.currentlyEnrolled == currentlyEnrolled &&
        other.otp == otp &&
        listEquals(other.apps, apps);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        brand.hashCode ^
        model.hashCode ^
        nickname.hashCode ^
        qrCode.hashCode ^
        policy.hashCode ^
        createdOn.hashCode ^
        enrolledOn.hashCode ^
        currentlyEnrolled.hashCode ^
        otp.hashCode ^
        apps.hashCode;
  }
}

class UserModel {
  String? id;
  String? firstName;
  String? lastName;
  String? phone;
  String? email;
  int? tokenCount;
  // List<String>? devicesId;
  List<String>? devices; // Corrected field type
  String? otp;
  DateTime? otpExpires;
  DateTime? otpTimestamp;
  bool? isSignedIn;
  List<String>? orders;
  UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.tokenCount,
    this.devices,
    this.otp,
    this.otpExpires,
    this.otpTimestamp,
    this.isSignedIn,
  });

  UserModel.copy(UserModel other) {
    id = other.id;
    firstName = other.firstName;
    lastName = other.lastName;
    phone = other.phone;
    email = other.email;
    tokenCount = other.tokenCount;
    devices = other.devices;
    otp = other.otp;
    otpExpires = other.otpExpires;
    otpTimestamp = other.otpTimestamp;
    isSignedIn = other.isSignedIn;
  }

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    int? tokenCount,
    List<String>? devices,
    String? otp,
    DateTime? otpExpires,
    DateTime? otpTimestamp,
    bool? isSignedIn,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      tokenCount: tokenCount ?? this.tokenCount,
      devices: devices ?? this.devices,
      otp: otp ?? this.otp,
      otpExpires: otpExpires ?? this.otpExpires,
      otpTimestamp: otpTimestamp ?? this.otpTimestamp,
      isSignedIn: isSignedIn ?? this.isSignedIn,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'tokenCount': tokenCount,
      'devices': devices,
      'otp': otp,
      'otpExpires': otpExpires?.millisecondsSinceEpoch,
      'otpTimestamp': otpTimestamp?.millisecondsSinceEpoch,
      'isSignedIn': isSignedIn,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['_id'] != null ? map['_id'] as String : null,
      firstName: map['firstName'] != null ? map['firstName'] as String : null,
      lastName: map['lastName'] != null ? map['lastName'] as String : null,
      phone: map['phone'] != null ? map['phone'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      tokenCount: map['tokenCount'] != null ? map['tokenCount'] as int : null,
      devices:
          map['devices'] != null ? List<String>.from((map['devices'])) : null,
      otp: map['otp'] != null ? map['otp'] as String : null,
      otpExpires: null,
      otpTimestamp: null,
      isSignedIn: map['isSignedIn'] != null ? map['isSignedIn'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(_id: $id, firstName: $firstName, lastName: $lastName, phone: $phone, email: $email, tokenCount: $tokenCount, devices: $devices, otp: $otp, otpExpires: $otpExpires, otpTimestamp: $otpTimestamp, isSignedIn: $isSignedIn)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.phone == phone &&
        other.email == email &&
        other.tokenCount == tokenCount &&
        listEquals(other.devices, devices) &&
        other.otp == otp &&
        other.otpExpires == otpExpires &&
        other.otpTimestamp == otpTimestamp &&
        other.isSignedIn == isSignedIn;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        phone.hashCode ^
        email.hashCode ^
        tokenCount.hashCode ^
        devices.hashCode ^
        otp.hashCode ^
        otpExpires.hashCode ^
        otpTimestamp.hashCode ^
        isSignedIn.hashCode;
  }
}

class OfferModel {
  String? id;
  String? title;
  String? desc;
  int? tokenCount;
  String? tenure;
  double? originalPrice;
  double? discountedPrice;
  double? gst;
  List<String>? benefits;
  String? validUntil;
  bool? isActive;

  OfferModel({
    this.id,
    this.title,
    this.desc,
    this.tokenCount,
    this.tenure,
    this.originalPrice,
    this.discountedPrice,
    this.gst,
    this.benefits,
    this.validUntil,
    this.isActive,
  });

  OfferModel copyWith({
    String? id,
    String? title,
    String? desc,
    int? tokenCount,
    String? tenure,
    double? originalPrice,
    double? discountedPrice,
    double? gst,
    List<String>? benefits,
    String? validUntil,
    bool? isActive,
  }) {
    return OfferModel(
      id: id ?? this.id,
      title: title ?? this.title,
      desc: desc ?? this.desc,
      tokenCount: tokenCount ?? this.tokenCount,
      tenure: tenure ?? this.tenure,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      gst: gst ?? this.gst,
      benefits: benefits ?? this.benefits,
      validUntil: validUntil ?? this.validUntil,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'title': title,
      'desc': desc,
      'tokenCount': tokenCount,
      'tenure': tenure,
      'originalPrice': originalPrice,
      'discountedPrice': discountedPrice,
      'gst': gst,
      'benefits': benefits,
      'validUntil': validUntil,
      'isActive': isActive,
    };
  }

  factory OfferModel.fromMap(Map<String, dynamic> map) {
    return OfferModel(
      id: map['_id'] != null ? map['_id'] as String : null,
      title: map['title'] != null ? map['title'] as String : null,
      desc: map['desc'] != null ? map['desc'] as String : null,
      tokenCount: map['tokenCount'] != null ? map['tokenCount'] as int : null,
      tenure: map['tenure'] != null ? map['tenure'] as String : null,
      originalPrice: map['originalPrice'] != null
          ? double.parse(map['originalPrice'].toString())
          : null,
      discountedPrice: map['discountedPrice'] != null
          ? double.parse(map['discountedPrice'].toString())
          : null,
      gst: map['gst'] != null ? double.parse(map['gst'].toString()) : null,
      benefits: map['benefits'] != null
          ? List<String>.from((map['benefits'] as List<dynamic>))
          : null,
      validUntil:
          map['validUntil'] != null ? map['validUntil'] as String : null,
      isActive: map['isActive'] != null ? map['isActive'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory OfferModel.fromJson(String source) =>
      OfferModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'OfferModel(_id: $id, title: $title, desc: $desc, tokenCount: $tokenCount, tenure: $tenure, originalPrice: $originalPrice, discountedPrice: $discountedPrice, gst: $gst, benefits: $benefits, validUntil: $validUntil, isActive: $isActive)';
  }

  @override
  bool operator ==(covariant OfferModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.desc == desc &&
        other.tokenCount == tokenCount &&
        other.tenure == tenure &&
        other.originalPrice == originalPrice &&
        other.discountedPrice == discountedPrice &&
        other.gst == gst &&
        listEquals(other.benefits, benefits) &&
        other.validUntil == validUntil &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        desc.hashCode ^
        tokenCount.hashCode ^
        tenure.hashCode ^
        originalPrice.hashCode ^
        discountedPrice.hashCode ^
        gst.hashCode ^
        benefits.hashCode ^
        validUntil.hashCode ^
        isActive.hashCode;
  }
}

class OrderModel {
  String? user;
  String? orderPlacingDate;
  String? orderExpiryDate;
  String? paymentCompleteDate;
  String? orderEndingDate;
  OfferModel? offer;
  int? discountedPrice;
  String? orderStatus;
  String? orderDescription;
  String? paymentStatus;
  String? orderType;
  String? orderId;
  String? orderPlacingTime;
  String? orderExpiryTime;

  OrderModel({
    this.user,
    this.orderPlacingDate,
    this.orderExpiryDate,
    this.paymentCompleteDate,
    this.orderEndingDate,
    this.offer,
    this.discountedPrice,
    this.orderStatus,
    this.orderDescription,
    this.paymentStatus,
    this.orderType,
    this.orderId,
    this.orderPlacingTime,
    this.orderExpiryTime,
  });

  OrderModel copyWith({
    String? user,
    String? orderPlacingDate,
    String? orderExpiryDate,
    String? paymentCompleteDate,
    String? orderEndingDate,
    OfferModel? offer,
    int? discountedPrice,
    String? orderStatus,
    String? orderDescription,
    String? paymentStatus,
    String? orderType,
    String? orderId,
    String? orderPlacingTime,
    String? orderExpiryTime,
  }) {
    return OrderModel(
      user: user ?? this.user,
      orderPlacingDate: orderPlacingDate ?? this.orderPlacingDate,
      orderExpiryDate: orderExpiryDate ?? this.orderExpiryDate,
      paymentCompleteDate: paymentCompleteDate ?? this.paymentCompleteDate,
      orderEndingDate: orderEndingDate ?? this.orderEndingDate,
      offer: offer ?? this.offer,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      orderStatus: orderStatus ?? this.orderStatus,
      orderDescription: orderDescription ?? this.orderDescription,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderType: orderType ?? this.orderType,
      orderId: orderId ?? this.orderId,
      orderPlacingTime: orderPlacingTime ?? this.orderPlacingTime,
      orderExpiryTime: orderExpiryTime ?? this.orderExpiryTime,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user': user,
      'orderPlacingDate': orderPlacingDate,
      'orderExpiryDate': orderExpiryDate,
      'paymentCompleteDate': paymentCompleteDate,
      'orderEndingDate': orderEndingDate,
      'offer': offer?.toMap(),
      'discountedPrice': discountedPrice,
      'orderStatus': orderStatus,
      'orderDescription': orderDescription,
      'paymentStatus': paymentStatus,
      'orderType': orderType,
      'orderId': orderId,
      'orderPlacingTime': orderPlacingTime,
      'orderExpiryTime': orderExpiryTime,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      user: map['user'] != null ? map['user'] as String : null,
      orderPlacingDate: map['orderPlacingDate'] != null
          ? map['orderPlacingDate'] as String
          : null,
      orderExpiryDate: map['orderExpiryDate'] != null
          ? map['orderExpiryDate'] as String
          : null,
      paymentCompleteDate: map['paymentCompleteDate'] != null
          ? map['paymentCompleteDate'] as String
          : null,
      orderEndingDate: map['orderEndingDate'] != null
          ? map['orderEndingDate'] as String
          : null,
      offer: map['offer'] != null
          ? OfferModel.fromMap(map['offer'] as Map<String, dynamic>)
          : null,
      discountedPrice:
          map['discountedPrice'] != null ? map['discountedPrice'] as int : null,
      orderStatus:
          map['orderStatus'] != null ? map['orderStatus'] as String : null,
      orderDescription: map['orderDescription'] != null
          ? map['orderDescription'] as String
          : null,
      paymentStatus:
          map['paymentStatus'] != null ? map['paymentStatus'] as String : null,
      orderType: map['orderType'] != null ? map['orderType'] as String : null,
      orderId: map['orderId'] != null ? map['orderId'] as String : null,
      orderPlacingTime: map['orderPlacingTime'] != null
          ? map['orderPlacingTime'] as String
          : null,
      orderExpiryTime: map['orderExpiryTime'] != null
          ? map['orderExpiryTime'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderModel.fromJson(String source) =>
      OrderModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'OrderModel(user: $user, orderPlacingDate: $orderPlacingDate, orderExpiryDate: $orderExpiryDate, paymentCompleteDate: $paymentCompleteDate, orderEndingDate: $orderEndingDate, offer: $offer, discountedPrice: $discountedPrice, orderStatus: $orderStatus, orderDescription: $orderDescription, paymentStatus: $paymentStatus, orderType: $orderType, orderId: $orderId, orderPlacingTime: $orderPlacingTime, orderExpiryTime: $orderExpiryTime)';
  }

  @override
  bool operator ==(covariant OrderModel other) {
    if (identical(this, other)) return true;

    return other.user == user &&
        other.orderPlacingDate == orderPlacingDate &&
        other.orderExpiryDate == orderExpiryDate &&
        other.paymentCompleteDate == paymentCompleteDate &&
        other.orderEndingDate == orderEndingDate &&
        other.offer == offer &&
        other.discountedPrice == discountedPrice &&
        other.orderStatus == orderStatus &&
        other.orderDescription == orderDescription &&
        other.paymentStatus == paymentStatus &&
        other.orderType == orderType &&
        other.orderId == orderId &&
        other.orderPlacingTime == orderPlacingTime &&
        other.orderExpiryTime == orderExpiryTime;
  }

  @override
  int get hashCode {
    return user.hashCode ^
        orderPlacingDate.hashCode ^
        orderExpiryDate.hashCode ^
        paymentCompleteDate.hashCode ^
        orderEndingDate.hashCode ^
        offer.hashCode ^
        discountedPrice.hashCode ^
        orderStatus.hashCode ^
        orderDescription.hashCode ^
        paymentStatus.hashCode ^
        orderType.hashCode ^
        orderId.hashCode ^
        orderPlacingTime.hashCode ^
        orderExpiryTime.hashCode;
  }
}
