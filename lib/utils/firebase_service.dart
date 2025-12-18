import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parents_app/utils/models.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get _usersCollection => _firestore.collection('users');

  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  /// Create or Update User in Firestore
  Future<Map<String, dynamic>> saveUser(UserModel user) async {
    try {
      if (user.id == null) return {'statusCode': 400, 'message': 'User ID is null'};
      
      await _usersCollection.doc(user.id).set(user.toJson(), SetOptions(merge: true));
      
      // Fetch the latest data to ensure sync
      DocumentSnapshot doc = await _usersCollection.doc(user.id).get();
      return {
        'statusCode': 200,
        'message': 'User saved successfully',
        'body': doc.data() as Map<String, dynamic>
      };
    } catch (e) {
      return {'statusCode': 500, 'message': 'Error saving user: $e'};
    }
  }

  /// Get User by ID
  Future<Map<String, dynamic>> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return {
          'statusCode': 200,
          'body': doc.data() as Map<String, dynamic>
        };
      }
      return {'statusCode': 404, 'message': 'User not found'};
    } catch (e) {
      return {'statusCode': 500, 'message': 'Error fetching user: $e'};
    }
  }

  /// Check if user exists (mocking the API behavior)
  Future<Map<String, dynamic>> checkUserExists(String phone) async {
    try {
      // Allow any user for now or implement phone query if needed
      // returning a structure that AppState expects for "user exists" logic
      return {'statusCode': 404, 'message': 'User check skipped for Firestore'}; 
    } catch (e) {
      return {'statusCode': 500, 'message': e.toString()};
    }
  }

  // --- DEVICE MANAGEMENT ---

  /// Get all devices for a user
  Future<Map<String, dynamic>> getDevices(String userId) async {
    try {
      QuerySnapshot snapshot = await _usersCollection.doc(userId).collection('devices').get();
      List<Map<String, dynamic>> devices = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      return {
        'statusCode': 200,
        'devices': devices,
        'message': 'Devices fetched successfully'
      };
    } catch (e) {
      return {'statusCode': 500, 'message': 'Error fetching devices: $e'};
    }
  }

  /// Add or Update a Device
  Future<Map<String, dynamic>> updateDevice(String userId, DeviceModel device) async {
    try {
      if (device.id == null) return {'statusCode': 400, 'message': 'Device ID is null'};
      
      await _usersCollection.doc(userId).collection('devices').doc(device.id).set(device.toMap(), SetOptions(merge: true));
      
      return {
        'statusCode': 200,
        'message': 'Device updated successfully',
        'body': device.toMap()
      };
    } catch (e) {
      return {'statusCode': 500, 'message': 'Error updating device: $e'};
    }
  }

  /// Update Device Policy
  Future<Map<String, dynamic>> updatePolicy(String userId, String deviceId, PolicyModel policy) async {
    try {
       // Save policy inside the device document or separate subcollection? 
       // Keeping it inside device for simplicity as per model structure
       await _usersCollection.doc(userId).collection('devices').doc(deviceId).update({
         'policy': policy.toMap()
       });

       return {
         'statusCode': 200,
         'message': 'Policy updated successfully',
         'body': policy.toMap()
       };
    } catch (e) {
      return {'statusCode': 500, 'message': 'Error updating policy: $e'};
    }
  }
}
