import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:parents_app/utils/api.dart';

class ImageCacheManager {
  static final ImageCacheManager _singleton = ImageCacheManager._internal();

  factory ImageCacheManager() {
    return _singleton;
  }

  ImageCacheManager._internal(); 

  final Map<String, ImageProvider> _imageCache = {};
  Future<bool> preloadImages(List<String> deviceIds, context) async {
    try {
      for (var deviceId in deviceIds) {
        final imageUrl = getImageUrlForDevice(deviceId);
        final imageProvider = CachedNetworkImageProvider(imageUrl);
        await precacheImage(imageProvider, context);
        _imageCache[deviceId] = imageProvider;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  ImageProvider getImageForDevice(String deviceId) {
    if (_imageCache.containsKey(deviceId)) {
      return _imageCache[deviceId]!;
    } else {
      final imageUrl = getImageUrlForDevice(deviceId);
      return CachedNetworkImageProvider(imageUrl);
    }
  }

  String getImageUrlForDevice(String deviceId) {
    return '${API().baseUrl}/image/$deviceId';
  }
}
