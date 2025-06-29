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

  /// Request storage/photos permission
  Future<bool> requestStoragePermission() async {
    Logger.logBasic('Requesting storage permission');

    // Different permissions for different platforms
    Permission storagePermission;

    // Platform-specific permission handling
    if (GetPlatform.isIOS) {
      // iOS uses photos permission
      storagePermission = Permission.photos;
    } else {
      // Android and other platforms use storage permission
      storagePermission = Permission.storage;
    }

    final status = await storagePermission.request();
    final isGranted = status.isGranted;

    // Save status to database
    await _repository.savePermissionStatus(storagePermission, isGranted);

    if (isGranted) {
      Logger.logSuccess('Storage permission granted');
      return true;
    } else if (status.isPermanentlyDenied) {
      Logger.logError('Storage permission permanently denied');
      return false;
    } else {
      Logger.logError('Storage permission denied: $status');
      return false;
    }
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

  /// Open app settings page
  Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
