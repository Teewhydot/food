import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageKitConfig {
  static final ImageKitConfig _instance = ImageKitConfig._internal();
  factory ImageKitConfig() => _instance;
  ImageKitConfig._internal();

  /// ImageKit public key
  String get publicKey => dotenv.env['IMAGEKIT_PUBLIC_KEY'] ?? '';
  
  /// ImageKit private key (used for server-side operations)
  String get privateKey => dotenv.env['IMAGEKIT_PRIVATE_KEY'] ?? '';
  
  /// ImageKit URL endpoint
  String get urlEndpoint => dotenv.env['IMAGEKIT_URL_ENDPOINT'] ?? '';

  /// Default upload directory
  String get defaultFolder => dotenv.env['IMAGEKIT_DEFAULT_FOLDER'] ?? '/food-app/';

  /// Maximum file size (5MB default)
  int get maxFileSizeInBytes => int.tryParse(dotenv.env['IMAGEKIT_MAX_FILE_SIZE'] ?? '') ?? 5 * 1024 * 1024;

  /// Allowed file types
  List<String> get allowedFileTypes => [
    // Images
    'image/jpeg',
    'image/jpg', 
    'image/png',
    'image/webp',
    'image/gif',
    'image/bmp',
    'image/svg+xml',
    
    // Documents
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'text/plain',
    'text/csv',
    
    // Videos
    'video/mp4',
    'video/mpeg',
    'video/quicktime',
    'video/x-msvideo',
    'video/webm',
    
    // Audio
    'audio/mpeg',
    'audio/wav',
    'audio/mp3',
    'audio/ogg',
    
    // Archives
    'application/zip',
    'application/x-rar-compressed',
    'application/x-7z-compressed',
    
    // Others
    'application/json',
    'application/xml',
  ];

  /// Validate if configuration is complete
  bool get isConfigured => 
    publicKey.isNotEmpty && 
    privateKey.isNotEmpty && 
    urlEndpoint.isNotEmpty;

  /// Get authentication parameters for ImageKit
  Map<String, String> getAuthParams() {
    if (!isConfigured) {
      throw ImageKitConfigException('ImageKit configuration is incomplete');
    }

    return {
      'publicKey': publicKey,
      'urlEndpoint': urlEndpoint,
    };
  }
}

class ImageKitConfigException implements Exception {
  final String message;
  
  const ImageKitConfigException(this.message);

  @override
  String toString() => 'ImageKitConfigException: $message';
}