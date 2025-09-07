/// Custom exception for geocoding-related errors
class GeocodingException implements Exception {
  final String message;
  final String? code;
  final Object? originalException;
  final StackTrace? stackTrace;
  final bool isRetryable;

  const GeocodingException({
    required this.message,
    this.code,
    this.originalException,
    this.stackTrace,
    this.isRetryable = true,
  });

  @override
  String toString() {
    if (code != null) {
      return 'GeocodingException($code): $message';
    }
    return 'GeocodingException: $message';
  }
}

/// Exception for invalid coordinates
class InvalidCoordinatesException extends GeocodingException {
  final double latitude;
  final double longitude;

  const InvalidCoordinatesException({
    required this.latitude,
    required this.longitude,
    super.message = 'Invalid coordinates provided',
    super.code = 'invalid_coordinates',
    super.originalException,
    super.stackTrace,
    super.isRetryable = false,
  });

  @override
  String toString() {
    return 'InvalidCoordinatesException: $message (lat: $latitude, lon: $longitude)';
  }
}

/// Exception for when geocoding service is unavailable
class GeocodingServiceUnavailableException extends GeocodingException {
  const GeocodingServiceUnavailableException({
    super.message = 'Geocoding service is currently unavailable',
    super.code = 'service_unavailable',
    super.originalException,
    super.stackTrace,
    super.isRetryable = true,
  });
}

/// Exception for network-related geocoding errors
class GeocodingNetworkException extends GeocodingException {
  const GeocodingNetworkException({
    super.message = 'Network error occurred during geocoding',
    super.code = 'network_error',
    super.originalException,
    super.stackTrace,
    super.isRetryable = true,
  });
}

/// Exception for API timeout errors
class GeocodingTimeoutException extends GeocodingException {
  final Duration timeout;

  const GeocodingTimeoutException({
    required this.timeout,
    super.message = 'Geocoding request timed out',
    super.code = 'timeout',
    super.originalException,
    super.stackTrace,
    super.isRetryable = true,
  });

  @override
  String toString() {
    return 'GeocodingTimeoutException: $message (timeout: ${timeout.inSeconds}s)';
  }
}

/// Exception for API rate limiting errors
class GeocodingRateLimitException extends GeocodingException {
  const GeocodingRateLimitException({
    super.message = 'Geocoding API rate limit exceeded',
    super.code = 'rate_limit_exceeded',
    super.originalException,
    super.stackTrace,
    super.isRetryable = false,
  });
}

/// Exception for permission-related geocoding errors
class GeocodingPermissionException extends GeocodingException {
  const GeocodingPermissionException({
    super.message = 'Permission denied for geocoding service',
    super.code = 'permission_denied',
    super.originalException,
    super.stackTrace,
    super.isRetryable = false,
  });
}