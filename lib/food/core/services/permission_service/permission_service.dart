import 'package:food/food/core/utils/logger.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:permission_handler/permission_handler.dart';

import 'permission_repository.dart';

/// A service to handle various app permissions in a centralized way
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  final PermissionRepository _repository = PermissionRepository();

  /// Check if permission is granted from database first
  Future<bool> isPermissionGranted(Permission permission) async {
    // First check database
    final savedStatus = await _repository.getPermissionStatus(permission);
    if (savedStatus != null) {
      return savedStatus;
    }

    // If not in database, check system status
    final status = await permission.status;
    // Save the current status to database
    await _repository.savePermissionStatus(permission, status.isGranted);
    return status.isGranted;
  }

  /// Request location permission using Geolocator
  Future<bool> requestLocationPermission() async {
    Logger.logBasic('Requesting location permission');

    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Logger.logError('Location services are disabled');
      await _repository.savePermissionStatus(Permission.location, false);
      return false;
    }

    // Check permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Logger.logError('Location permissions are denied');
        await _repository.savePermissionStatus(Permission.location, false);
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Logger.logError('Location permissions are permanently denied');
      await _repository.savePermissionStatus(Permission.location, false);
      return false;
    }

    // Save granted status to database
    await _repository.savePermissionStatus(Permission.location, true);
    Logger.logSuccess('Location permission granted');
    return true;
  }

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    Logger.logBasic('Requesting camera permission');

    final status = await Permission.camera.request();
    final isGranted = status.isGranted;

    // Save status to database
    await _repository.savePermissionStatus(Permission.camera, isGranted);

    if (isGranted) {
      Logger.logSuccess('Camera permission granted');
      return true;
    } else if (status.isPermanentlyDenied) {
      Logger.logError('Camera permission permanently denied');
      return false;
    } else {
      Logger.logError('Camera permission denied: $status');
      return false;
    }
  }

  /// Request storage/media access permission
  /// This handles both legacy storage permissions and modern granular media permissions
  Future<bool> requestStoragePermission() async {
    Logger.logBasic('Requesting storage/media access permission');

    if (GetPlatform.isIOS) {
      return await _requestIOSPhotosPermission();
    } else {
      return await _requestAndroidMediaPermission();
    }
  }

  /// Request iOS photos permission
  Future<bool> _requestIOSPhotosPermission() async {
    final status = await Permission.photos.request();
    final isGranted = status.isGranted;

    await _repository.savePermissionStatus(Permission.photos, isGranted);

    if (isGranted) {
      Logger.logSuccess('iOS Photos permission granted');
      return true;
    } else if (status.isPermanentlyDenied) {
      Logger.logError('iOS Photos permission permanently denied');
      return false;
    } else {
      Logger.logError('iOS Photos permission denied: $status');
      return false;
    }
  }

  /// Request Android media permissions with fallback logic
  Future<bool> _requestAndroidMediaPermission() async {
    // For Android 13+ (API 33+), try granular media permissions first
    
    // Request photos permission (covers images and videos)
    final photosStatus = await Permission.photos.request();
    Logger.logBasic('Photos permission status: $photosStatus');
    
    if (photosStatus.isGranted) {
      Logger.logSuccess('Android Photos permission granted');
      await _repository.savePermissionStatus(Permission.photos, true);
      return true;
    }
    
    // If photos permission denied, try videos permission for video files
    final videosStatus = await Permission.videos.request();
    Logger.logBasic('Videos permission status: $videosStatus');
    
    if (videosStatus.isGranted) {
      Logger.logSuccess('Android Videos permission granted');
      await _repository.savePermissionStatus(Permission.videos, true);
      return true;
    }
    
    // Fallback to legacy storage permission for older devices or when granular permissions fail
    Logger.logBasic('Falling back to legacy storage permission');
    final storageStatus = await Permission.storage.request();
    Logger.logBasic('Storage permission status: $storageStatus');
    
    final isStorageGranted = storageStatus.isGranted;
    await _repository.savePermissionStatus(Permission.storage, isStorageGranted);

    if (isStorageGranted) {
      Logger.logSuccess('Android Storage permission granted');
      return true;
    }
    
    // Check if any permission was permanently denied
    if (storageStatus.isPermanentlyDenied || photosStatus.isPermanentlyDenied || videosStatus.isPermanentlyDenied) {
      Logger.logError('Media permissions permanently denied');
      return false;
    }
    
    Logger.logError('All media permissions denied - Storage: $storageStatus, Photos: $photosStatus, Videos: $videosStatus');
    return false;
  }

  /// Request notification permission
  Future<bool> requestNotificationPermission() async {
    Logger.logBasic('Requesting notification permission');

    final status = await Permission.notification.request();
    final isGranted = status.isGranted;

    // Save status to database
    await _repository.savePermissionStatus(Permission.notification, isGranted);

    if (isGranted) {
      Logger.logSuccess('Notification permission granted');
      return true;
    } else {
      Logger.logError('Notification permission denied: $status');
      return false;
    }
  }

  /// Request audio permission for audio file access
  Future<bool> requestAudioPermission() async {
    Logger.logBasic('Requesting audio permission');

    if (GetPlatform.isIOS) {
      // On iOS, audio files are typically accessed through document picker
      // which doesn't require special permissions
      return true;
    } else {
      // For Android 13+, request audio permission
      final audioStatus = await Permission.audio.request();
      final isGranted = audioStatus.isGranted;

      await _repository.savePermissionStatus(Permission.audio, isGranted);

      if (isGranted) {
        Logger.logSuccess('Audio permission granted');
        return true;
      } else if (audioStatus.isPermanentlyDenied) {
        Logger.logError('Audio permission permanently denied');
        return false;
      } else {
        Logger.logError('Audio permission denied: $audioStatus');
        // Fallback to general storage permission
        return await requestStoragePermission();
      }
    }
  }

  /// Open app settings page
  Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
