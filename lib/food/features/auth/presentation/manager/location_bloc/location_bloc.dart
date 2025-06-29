import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:food/food/core/bloc/app_state.dart';
import 'package:food/food/core/services/permission_service/permission_repository.dart';
import 'package:food/food/core/utils/logger.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  // OpenWeatherMap API key - replace this with your own API key
  final String apiKey =
      "ADD_YOUR_API_KEY_HERE"; // You should use environment variables for API keys

  final PermissionRepository _permissionRepository = PermissionRepository();

  LocationBloc() : super(LocationInitial()) {
    on<LocationRequestedEvent>(_onLocationRequested);
    on<LocationPermissionCheckEvent>(_onPermissionCheck);
  }

  Future<void> _onPermissionCheck(
    LocationPermissionCheckEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());

    try {
      // Check database first for persisted permission status
      final savedStatus = await _permissionRepository.getPermissionStatus(
        Permission.location,
      );

      if (savedStatus == true) {
        // Permission already granted according to our database
        emit(
          LocationPermissionGranted(
            permissionMessage: "Location permission already granted",
          ),
        );
      } else {
        // Need to check system permission status
        emit(
          LocationPermissionRequired(
            permissionMessage: "Location permission required",
          ),
        );
      }
    } catch (e) {
      Logger.logError("Error checking permission: ${e.toString()}");
      emit(
        LocationError(
          errorMessage: "Error checking permission: ${e.toString()}",
        ),
      );
    }
  }

  Future<void> _onLocationRequested(
    LocationRequestedEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());

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
        emit(LocationError(errorMessage: "Location services are disabled"));
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
          emit(LocationError(errorMessage: "Location permissions are denied"));
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
          LocationError(
            errorMessage: "Location permissions are permanently denied",
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

      emit(
        LocationSuccess(
          successMessage: "Location fetched successfully",
          latitude: latitude,
          longitude: longitude,
          address: locationDetails['address'] ?? '',
          city: locationDetails['city'] ?? '',
          country: locationDetails['country'] ?? '',
        ),
      );
    } catch (e) {
      Logger.logError("Error fetching location: ${e.toString()}");
      emit(
        LocationError(errorMessage: "Failed to get location: ${e.toString()}"),
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
