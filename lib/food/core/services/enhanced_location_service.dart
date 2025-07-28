import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class EnhancedLocationService {
  static final EnhancedLocationService _instance = EnhancedLocationService._internal();
  factory EnhancedLocationService() => _instance;
  EnhancedLocationService._internal();

  Position? _currentPosition;
  String? _currentAddress;
  StreamSubscription<Position>? _positionSubscription;
  final StreamController<Position> _positionController = StreamController<Position>.broadcast();

  Stream<Position> get positionStream => _positionController.stream;
  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;

  Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Open app settings to allow user to grant permission
        await openAppSettings();
        return false;
      }

      return permission == LocationPermission.whileInUse || 
             permission == LocationPermission.always;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting location permission: $e');
      }
      return false;
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeLimit,
  }) async {
    try {
      if (!await isLocationServiceEnabled()) {
        throw Exception('Location services are disabled');
      }

      if (!await requestLocationPermission()) {
        throw Exception('Location permission denied');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: timeLimit ?? const Duration(seconds: 15),
      );

      _currentPosition = position;
      _positionController.add(position);
      
      // Get address for current position
      await _updateCurrentAddress(position);

      return position;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current position: $e');
      }
      return null;
    }
  }

  Future<void> _updateCurrentAddress(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        _currentAddress = _formatAddress(placemark);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting address from coordinates: $e');
      }
    }
  }

  String _formatAddress(Placemark placemark) {
    final components = <String>[];
    
    if (placemark.street?.isNotEmpty == true) {
      components.add(placemark.street!);
    }
    if (placemark.subLocality?.isNotEmpty == true) {
      components.add(placemark.subLocality!);
    }
    if (placemark.locality?.isNotEmpty == true) {
      components.add(placemark.locality!);
    }
    if (placemark.administrativeArea?.isNotEmpty == true) {
      components.add(placemark.administrativeArea!);
    }
    if (placemark.country?.isNotEmpty == true) {
      components.add(placemark.country!);
    }

    return components.join(', ');
  }

  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        return _formatAddress(placemarks.first);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting address from coordinates: $e');
      }
    }
    return null;
  }

  Future<List<Location>?> getCoordinatesFromAddress(String address) async {
    try {
      return await locationFromAddress(address);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting coordinates from address: $e');
      }
      return null;
    }
  }

  void startLocationTracking({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
    Duration interval = const Duration(seconds: 30),
  }) {
    _positionSubscription?.cancel();

    final locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _currentPosition = position;
        _positionController.add(position);
        _updateCurrentAddress(position);
      },
      onError: (error) {
        if (kDebugMode) {
          print('Error in location tracking: $error');
        }
      },
    );
  }

  void stopLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  double calculateDistanceInKm(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    final distanceInMeters = calculateDistance(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
    return distanceInMeters / 1000; // Convert to kilometers
  }

  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()}m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)}km';
    }
  }

  Future<bool> isLocationAccurate(Position position) async {
    // Consider location accurate if accuracy is better than 100 meters
    return position.accuracy <= 100;
  }

  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting last known position: $e');
      }
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    double radiusInKm = 5.0,
    required List<Map<String, dynamic>> places,
  }) async {
    final nearbyPlaces = <Map<String, dynamic>>[];

    for (final place in places) {
      final placeLat = place['latitude'] as double?;
      final placeLng = place['longitude'] as double?;

      if (placeLat != null && placeLng != null) {
        final distance = calculateDistanceInKm(
          latitude,
          longitude,
          placeLat,
          placeLng,
        );

        if (distance <= radiusInKm) {
          final placeWithDistance = Map<String, dynamic>.from(place);
          placeWithDistance['distance'] = distance;
          placeWithDistance['formattedDistance'] = formatDistance(distance * 1000);
          nearbyPlaces.add(placeWithDistance);
        }
      }
    }

    // Sort by distance
    nearbyPlaces.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    return nearbyPlaces;
  }

  Future<Map<String, dynamic>?> getCurrentLocationDetails() async {
    final position = await getCurrentPosition();
    if (position == null) return null;

    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy,
      'altitude': position.altitude,
      'heading': position.heading,
      'speed': position.speed,
      'timestamp': position.timestamp,
      'address': _currentAddress,
    };
  }

  void dispose() {
    _positionSubscription?.cancel();
    _positionController.close();
  }
}