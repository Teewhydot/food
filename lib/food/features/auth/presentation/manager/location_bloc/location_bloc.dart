import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/services/floor_db_service/location/location_database_service.dart';
import 'package:food/food/core/services/permission_service/permission_repository.dart';
import 'package:food/food/core/utils/logger.dart';
import 'package:food/food/features/auth/domain/entities/location_data.dart';
import 'package:food/food/features/geocoding/domain/use_cases/geocoding_usecase.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';

part 'location_event.dart';
// part 'location_state.dart'; // Commented out - using BaseState now

/// Migrated LocationBloc to use BaseState\<LocationData> (converted from BLoC to Cubit for simplicity)
/// Updated to use new GeocodingUseCase instead of deprecated GeocodingService
class LocationBloc extends BaseCubit<BaseState<LocationData>> {
  final GeocodingUseCase _geocodingUseCase = GetIt.instance<GeocodingUseCase>();
  final PermissionRepository _permissionRepository = PermissionRepository();
  final LocationDatabaseService _locationDatabaseService = LocationDatabaseService();

  LocationBloc() : super(const InitialState<LocationData>());

  /// Load cached location data if available and valid
  Future<void> loadCachedLocation() async {
    try {
      final cachedLocation = await _locationDatabaseService.getCachedLocation();

      if (cachedLocation != null) {
        Logger.logSuccess(
          "Loaded cached location: ${cachedLocation.city}, ${cachedLocation.country}",
        );
        emit(
          LoadedState<LocationData>(
            data: cachedLocation,
            lastUpdated: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      Logger.logWarning("Error loading cached location: ${e.toString()}");
    }
  }

  /// Request fresh location data (forces new location fetch)
  Future<void> requestFreshLocation() async {
    await _requestLocationData(forceFresh: true);
  }

  /// Request location data (checks cache first unless forced)
  Future<void> requestLocation({bool forceFresh = false}) async {
    // If not forcing fresh and we already have loaded data, don't request again
    if (!forceFresh && state is LoadedState<LocationData>) {
      return;
    }

    // Check cache first unless forcing fresh
    if (!forceFresh) {
      final cachedLocation = await _locationDatabaseService.getCachedLocation();
      if (cachedLocation != null) {
        Logger.logSuccess(
          "Using cached location: ${cachedLocation.city}, ${cachedLocation.country}",
        );
        emit(
          LoadedState<LocationData>(
            data: cachedLocation,
            lastUpdated: DateTime.now(),
          ),
        );
        return;
      }
    }

    // No valid cache or forced fresh - request new location
    await _requestLocationData(forceFresh: forceFresh);
  }

  void checkLocationPermission() async {
    emit(
      const LoadingState<LocationData>(
        message: 'Checking location permissions...',
      ),
    );

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
          ),
        );
      }
    } catch (e) {
      Logger.logError("Error checking permission: ${e.toString()}");
      emit(
        ErrorState<LocationData>(
          errorMessage: "Error checking permission: ${e.toString()}",
          errorCode: 'permission_check_failed',
        ),
      );
    }
  }

  Future<void> _requestLocationData({bool forceFresh = false}) async {
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
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );

      final double latitude = position.latitude;
      final double longitude = position.longitude;

      Logger.logSuccess("Location fetched: $latitude, $longitude");

      // Get address details using the new GeocodingUseCase
      emit(
        const LoadingState<LocationData>(message: 'Getting address details...'),
      );

      try {
        final geocodingResult = await _geocodingUseCase
            .getAddressFromCoordinates(
              latitude: latitude,
              longitude: longitude,
            );
        Logger.logSuccess(
          "Location fetched: ${geocodingResult.city}, ${geocodingResult.country}",
        );

        final locationData = LocationData(
          latitude: latitude,
          longitude: longitude,
          address: geocodingResult.address,
          city: geocodingResult.city,
          country: geocodingResult.country,
        );

        // Cache the location data for future use
        await _locationDatabaseService.cacheLocation(locationData);

        emit(
          LoadedState<LocationData>(
            data: locationData,
            lastUpdated: DateTime.now(),
          ),
        );
      } catch (geocodingError) {
        Logger.logWarning(
          "Geocoding failed, using coordinates only: ${geocodingError.toString()}",
        );

        // Still provide location data even if geocoding fails
        final locationData = LocationData(
          latitude: latitude,
          longitude: longitude,
          address: 'Address unavailable',
          city: 'City unavailable',
          country: 'Country unavailable',
        );

        // Cache the location data even if geocoding failed
        await _locationDatabaseService.cacheLocation(locationData);

        emit(
          LoadedState<LocationData>(
            data: locationData,
            lastUpdated: DateTime.now(),
          ),
        );
      }
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
}
