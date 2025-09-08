import 'package:food/food/features/file_upload/domain/enums/file_type_enum.dart';

class FileUploadConfig {
  final FileUploadType fileType;
  final int? maxSizeInMB;
  final int? maxSizeInBytes;
  final bool allowMultiple;
  final List<String>? customAllowedExtensions;
  final List<String>? customMimeTypes;
  final String? folder;
  final List<String>? tags;
  final bool validateFileType;
  final bool compressImage;
  final int? imageQuality;
  final double? maxImageWidth;
  final double? maxImageHeight;

  const FileUploadConfig({
    required this.fileType,
    this.maxSizeInMB,
    this.maxSizeInBytes,
    this.allowMultiple = false,
    this.customAllowedExtensions,
    this.customMimeTypes,
    this.folder,
    this.tags,
    this.validateFileType = true,
    this.compressImage = true,
    this.imageQuality = 85,
    this.maxImageWidth = 1920,
    this.maxImageHeight = 1080,
  });

  /// Get the maximum file size in bytes
  int? get effectiveMaxSizeInBytes {
    if (maxSizeInBytes != null) return maxSizeInBytes;
    if (maxSizeInMB != null) return maxSizeInMB! * 1024 * 1024;
    return null;
  }

  /// Get allowed extensions
  List<String> get allowedExtensions {
    if (customAllowedExtensions != null && customAllowedExtensions!.isNotEmpty) {
      return customAllowedExtensions!;
    }
    return fileType.allowedExtensions;
  }

  /// Get allowed MIME types
  List<String> get allowedMimeTypes {
    if (customMimeTypes != null && customMimeTypes!.isNotEmpty) {
      return customMimeTypes!;
    }
    return fileType.mimeTypes;
  }

  /// Check if a file size is valid
  bool isFileSizeValid(int fileSizeInBytes) {
    final maxSize = effectiveMaxSizeInBytes;
    if (maxSize == null) return true;
    return fileSizeInBytes <= maxSize;
  }

  /// Get human-readable file size limit
  String get fileSizeLimitText {
    if (maxSizeInMB != null) {
      return '${maxSizeInMB}MB';
    }
    if (maxSizeInBytes != null) {
      final mb = maxSizeInBytes! / (1024 * 1024);
      if (mb >= 1) {
        return '${mb.toStringAsFixed(1)}MB';
      }
      final kb = maxSizeInBytes! / 1024;
      return '${kb.toStringAsFixed(0)}KB';
    }
    return 'No limit';
  }

  /// Factory constructor for common presets
  factory FileUploadConfig.profilePicture() {
    return const FileUploadConfig(
      fileType: FileUploadType.image,
      maxSizeInMB: 5,
      allowMultiple: false,
      compressImage: true,
      imageQuality: 90,
      maxImageWidth: 800,
      maxImageHeight: 800,
      folder: '/profile-pictures/',
    );
  }

  factory FileUploadConfig.foodImage() {
    return const FileUploadConfig(
      fileType: FileUploadType.image,
      maxSizeInMB: 10,
      allowMultiple: true,
      compressImage: true,
      imageQuality: 85,
      folder: '/food-images/',
      tags: ['food'],
    );
  }

  factory FileUploadConfig.document() {
    return const FileUploadConfig(
      fileType: FileUploadType.document,
      maxSizeInMB: 20,
      allowMultiple: false,
      validateFileType: true,
      folder: '/documents/',
    );
  }

  factory FileUploadConfig.videoUpload() {
    return const FileUploadConfig(
      fileType: FileUploadType.video,
      maxSizeInMB: 100,
      allowMultiple: false,
      validateFileType: true,
      folder: '/videos/',
    );
  }

  FileUploadConfig copyWith({
    FileUploadType? fileType,
    int? maxSizeInMB,
    int? maxSizeInBytes,
    bool? allowMultiple,
    List<String>? customAllowedExtensions,
    List<String>? customMimeTypes,
    String? folder,
    List<String>? tags,
    bool? validateFileType,
    bool? compressImage,
    int? imageQuality,
    double? maxImageWidth,
    double? maxImageHeight,
  }) {
    return FileUploadConfig(
      fileType: fileType ?? this.fileType,
      maxSizeInMB: maxSizeInMB ?? this.maxSizeInMB,
      maxSizeInBytes: maxSizeInBytes ?? this.maxSizeInBytes,
      allowMultiple: allowMultiple ?? this.allowMultiple,
      customAllowedExtensions: customAllowedExtensions ?? this.customAllowedExtensions,
      customMimeTypes: customMimeTypes ?? this.customMimeTypes,
      folder: folder ?? this.folder,
      tags: tags ?? this.tags,
      validateFileType: validateFileType ?? this.validateFileType,
      compressImage: compressImage ?? this.compressImage,
      imageQuality: imageQuality ?? this.imageQuality,
      maxImageWidth: maxImageWidth ?? this.maxImageWidth,
      maxImageHeight: maxImageHeight ?? this.maxImageHeight,
    );
  }
}