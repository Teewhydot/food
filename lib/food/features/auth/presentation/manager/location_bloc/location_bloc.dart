import 'dart:convert';

import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/services/permission_service/permission_repository.dart';
import 'package:food/food/core/utils/logger.dart';
import 'package:food/food/features/auth/domain/entities/location_data.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';

part 'location_event.dart';
// part 'location_state.dart'; // Commented out - using BaseState now

/// Migrated LocationBloc to use BaseState<LocationData> (converted from BLoC to Cubit for simplicity)
class LocationBloc extends BaseCubit<BaseState<LocationData>> {
  // OpenWeatherMap API key - replace this with your own API key
  final String apiKey =
      "ADD_YOUR_API_KEY_HERE"; // You should use environment variables for API keys

  final PermissionRepository _permissionRepository = PermissionRepository();

  LocationBloc() : super(const InitialState<LocationData>());

  void checkLocationPermission() async {
    emit(const LoadingState<LocationData>(message: 'Checking location permissions...'));

    try {
      // Check database first for persisted permission status
      final savedStatus = await _permissionRepository.getPermissionStatus(
        Permission.location,
      );

      if (savedStatus == true) {
        // Permission already granted according to our database
        emit(
          const SuccessState<LocationData>(
            successMessage: "Location permission already granted",
          ),
        );
      } else {
        // Need to check system permission status
        emit(
          const ErrorState<LocationData>(
            errorMessage: "Location permission required",
            errorCode: 'permission_required',
            isRetryable: true,
          ),
        );
      }
    } catch (e) {
      Logger.logError("Error checking permission: ${e.toString()}");
      emit(
        ErrorState<LocationData>(
          errorMessage: "Error checking permission: ${e.toString()}",
          errorCode: 'permission_check_failed',
          isRetryable: true,
        ),
      );
    }
  }

  Future<void> requestLocation() async {
    emit(const LoadingState<LocationData>(message: 'Getting your location...'));

    try {
      // Check location permissions
      bool serviceEnabled;
      LocationPermission permission;

      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Save permission status to database
        await _permissionRepository.savePermissionStatus(
          Permission.location,
          false,
        );
        emit(
          const ErrorState<LocationData>(
            errorMessage: "Location services are disabled",
            errorCode: 'location_services_disabled',
            isRetryable: true,
          ),
        );
        return;
      }

      // Check location permissions
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Save permission status to database
          await _permissionRepository.savePermissionStatus(
            Permission.location,
            false,
          );
          emit(
            const ErrorState<LocationData>(
              errorMessage: "Location permissions are denied",
              errorCode: 'permission_denied',
              isRetryable: true,
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Save permission status to database
        await _permissionRepository.savePermissionStatus(
          Permission.location,
          false,
        );
        emit(
          const ErrorState<LocationData>(
            errorMessage: "Location permissions are permanently denied",
            errorCode: 'permission_denied_forever',
            isRetryable: false,
          ),
        );
        return;
      }

      // Save granted status to database
      await _permissionRepository.savePermissionStatus(
        Permission.location,
        true,
      );

      // Get current position
      Logger.logBasic("Fetching current location...");
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final double latitude = position.latitude;
      final double longitude = position.longitude;

      Logger.logSuccess("Location fetched: $latitude, $longitude");

      // Get address details from reverse geocoding using OpenWeatherMap
      final locationDetails = await _getAddressFromLatLng(latitude, longitude);

      final locationData = LocationData(
        latitude: latitude,
        longitude: longitude,
        address: locationDetails['address'] ?? '',
        city: locationDetails['city'] ?? '',
        country: locationDetails['country'] ?? '',
      );

      emit(
        LoadedState<LocationData>(
          data: locationData,
          lastUpdated: DateTime.now(),
        ),
      );
      
      // Also emit success state for notification
      emit(
        const SuccessState<LocationData>(
          successMessage: "Location fetched successfully",
        ),
      );
    } catch (e) {
      Logger.logError("Error fetching location: ${e.toString()}");
      emit(
        ErrorState<LocationData>(
          errorMessage: "Failed to get location: ${e.toString()}",
          errorCode: 'location_fetch_failed',
          isRetryable: true,
        ),
      );
    }
  }

  Future<Map<String, String>> _getAddressFromLatLng(
    double latitude,
    double longitude,
  ) async {
    try {
      // First try using the geocoding package
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          latitude,
          longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          return {
            'address': '${place.street}, ${place.subLocality}',
            'city': place.locality ?? '',
            'country': place.country ?? '',
          };
        }
      } catch (e) {
        Logger.logError("Error with local geocoding: ${e.toString()}");
        // Fall back to API if local geocoding fails
      }

      // Use OpenWeatherMap API for reverse geocoding as fallback
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/geo/1.0/reverse?lat=$latitude&lon=$longitude&limit=1&appid=$apiKey',
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return {
            'address': data[0]['name'] ?? '',
            'city': data[0]['state'] ?? '',
            'country': data[0]['country'] ?? '',
          };
        }
      }

      // If OpenWeatherMap fails, try another provider or return empty values
      return {
        'address': 'Unknown Address',
        'city': 'Unknown City',
        'country': 'Unknown Country',
      };
    } catch (e) {
      Logger.logError("Error getting address details: ${e.toString()}");
      return {'address': 'Error getting address', 'city': '', 'country': ''};
    }
  }
}
