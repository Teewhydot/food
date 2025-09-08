import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:food/food/features/file_upload/domain/enums/file_type_enum.dart';
import 'package:food/food/core/services/permission_service/permission_service.dart';

/// Simple file upload service that handles all file selection logic
class FileUploadService {
  static final FileUploadService _instance = FileUploadService._internal();
  factory FileUploadService() => _instance;
  FileUploadService._internal();

  final ImagePicker _imagePicker = ImagePicker();
  final PermissionService _permissionService = PermissionService();

  /// Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final hasPermission = await _permissionService.requestCameraPermission();
      if (!hasPermission) throw Exception('Camera permission denied');

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      return pickedFile != null ? File(pickedFile.path) : null;
    } catch (e) {
      throw Exception('Failed to pick image from camera: $e');
    }
  }

  /// Pick image from gallery
  Future<File?> pickImageFromGallery({bool allowMultiple = false}) async {
    try {
      final hasPermission = await _permissionService.requestStoragePermission();
      if (!hasPermission) throw Exception('Storage permission denied');

      if (allowMultiple) {
        final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
        return pickedFiles.isNotEmpty ? File(pickedFiles.first.path) : null;
      } else {
        final XFile? pickedFile = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
        return pickedFile != null ? File(pickedFile.path) : null;
      }
    } catch (e) {
      throw Exception('Failed to pick image from gallery: $e');
    }
  }

  /// Pick multiple images from gallery
  Future<List<File>> pickMultipleImagesFromGallery() async {
    try {
      final hasPermission = await _permissionService.requestStoragePermission();
      if (!hasPermission) throw Exception('Storage permission denied');

      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      return pickedFiles.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      throw Exception('Failed to pick multiple images: $e');
    }
  }

  /// Pick video from camera
  Future<File?> pickVideoFromCamera() async {
    try {
      final hasPermission = await _permissionService.requestCameraPermission();
      if (!hasPermission) throw Exception('Camera permission denied');

      final XFile? pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 10),
      );
      
      return pickedFile != null ? File(pickedFile.path) : null;
    } catch (e) {
      throw Exception('Failed to pick video from camera: $e');
    }
  }

  /// Pick video from gallery
  Future<File?> pickVideoFromGallery() async {
    try {
      final hasPermission = await _permissionService.requestStoragePermission();
      if (!hasPermission) throw Exception('Storage permission denied');

      final XFile? pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 10),
      );
      
      return pickedFile != null ? File(pickedFile.path) : null;
    } catch (e) {
      throw Exception('Failed to pick video from gallery: $e');
    }
  }

  /// Pick any file
  Future<File?> pickFile({
    FileUploadType fileType = FileUploadType.any,
    bool allowMultiple = false,
    List<String>? allowedExtensions,
  }) async {
    try {
      // Request appropriate permission based on file type
      if (fileType == FileUploadType.audio) {
        final hasPermission = await _permissionService.requestAudioPermission();
        if (!hasPermission) throw Exception('Audio permission denied');
      } else {
        final hasPermission = await _permissionService.requestStoragePermission();
        if (!hasPermission) throw Exception('Storage permission denied');
      }

      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: _getFilePickerType(fileType),
        allowedExtensions: allowedExtensions ?? _getAllowedExtensions(fileType),
        allowMultiple: allowMultiple,
        withData: false,
        withReadStream: false,
      );

      return result != null && result.files.isNotEmpty 
          ? File(result.files.first.path!) 
          : null;
    } catch (e) {
      throw Exception('Failed to pick file: $e');
    }
  }

  /// Pick multiple files
  Future<List<File>> pickMultipleFiles({
    FileUploadType fileType = FileUploadType.any,
    List<String>? allowedExtensions,
  }) async {
    try {
      // Request appropriate permission based on file type
      if (fileType == FileUploadType.audio) {
        final hasPermission = await _permissionService.requestAudioPermission();
        if (!hasPermission) throw Exception('Audio permission denied');
      } else {
        final hasPermission = await _permissionService.requestStoragePermission();
        if (!hasPermission) throw Exception('Storage permission denied');
      }

      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: _getFilePickerType(fileType),
        allowedExtensions: allowedExtensions ?? _getAllowedExtensions(fileType),
        allowMultiple: true,
        withData: false,
        withReadStream: false,
      );

      return result != null 
          ? result.paths.map((path) => File(path!)).toList()
          : [];
    } catch (e) {
      throw Exception('Failed to pick multiple files: $e');
    }
  }

  /// Validate file size and type
  bool validateFile(File file, {
    int? maxSizeInMB,
    int? maxSizeInBytes,
    List<String>? allowedExtensions,
    bool validateFileType = true,
  }) {
    try {
      // Check file size
      final fileSize = file.lengthSync();
      final maxSize = maxSizeInBytes ?? (maxSizeInMB != null ? maxSizeInMB * 1024 * 1024 : null);
      
      if (maxSize != null && fileSize > maxSize) {
        throw Exception('File size exceeds limit');
      }

      // Check file extension if validation is enabled
      if (validateFileType && allowedExtensions != null) {
        final fileName = file.path.split('/').last;
        final extension = fileName.split('.').last.toLowerCase();
        if (!allowedExtensions.contains(extension)) {
          throw Exception('File type .$extension is not allowed');
        }
      }

      return true;
    } catch (e) {
      throw Exception('File validation failed: $e');
    }
  }

  /// Get file picker type for different file types
  FileType _getFilePickerType(FileUploadType fileType) {
    switch (fileType) {
      case FileUploadType.image:
        return FileType.image;
      case FileUploadType.document:
        return FileType.custom;
      case FileUploadType.video:
        return FileType.video;
      case FileUploadType.audio:
        return FileType.audio;
      case FileUploadType.any:
        return FileType.any;
    }
  }

  /// Get allowed extensions for different file types
  List<String>? _getAllowedExtensions(FileUploadType fileType) {
    if (fileType == FileUploadType.any) return null;
    if (fileType == FileUploadType.document) return fileType.allowedExtensions;
    return null;
  }
}