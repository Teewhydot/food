import 'dart:io';
// import 'package:mime/mime.dart'; // Commented out since file type validation is disabled
import 'package:food/food/features/file_upload/data/models/imagekit_upload_response.dart';
import 'package:food/food/core/services/imagekit/imagekit_config.dart';
import 'package:food/food/features/file_upload/domain/failures/file_upload_failures.dart';

abstract class ImageKitRemoteDataSource {
  Future<ImageKitUploadResponse> uploadFile({
    required File file,
    required ImageKitUploadRequest request,
  });

  Future<void> deleteFile({required String fileId});

  String generateUrl({
    required String filePath,
    List<String>? transformations,
  });
}

class ImageKitRemoteDataSourceImpl implements ImageKitRemoteDataSource {
  final ImageKitConfig config;

  ImageKitRemoteDataSourceImpl({required this.config});

  @override
  Future<ImageKitUploadResponse> uploadFile({
    required File file,
    required ImageKitUploadRequest request,
  }) async {
    try {
      // Validate configuration
      if (!config.isConfigured) {
        throw FileUploadConfigFailure();
      }

      // Validate file exists
      if (!file.existsSync()) {
        throw FileUploadValidationFailure(
          failureMessage: 'File does not exist',
        );
      }

      // Validate file size
      final fileSize = file.lengthSync();
      if (fileSize > config.maxFileSizeInBytes) {
        throw FileUploadValidationFailure(
          failureMessage: 'File size exceeds maximum allowed size of ${config.maxFileSizeInBytes} bytes',
        );
      }

      // Validate file type (optional - comment out to allow all types)
      // final mimeType = lookupMimeType(file.path);
      // if (mimeType == null || !config.allowedFileTypes.contains(mimeType)) {
      //   throw FileUploadValidationFailure(
      //     failureMessage: 'File type $mimeType is not allowed',
      //   );
      // }

      // For now, return a mock response as ImageKit integration requires additional HTTP setup
      // This will be completed when integrating with actual ImageKit SDK
      return ImageKitUploadResponse(
        fileId: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        name: request.fileName,
        url: '${config.urlEndpoint}${request.folder}${request.fileName}',
        thumbnailUrl: '${config.urlEndpoint}/tr:w-300,h-200${request.folder}${request.fileName}',
        height: 1080,
        width: 1920,
        size: fileSize,
        filePath: '${request.folder}${request.fileName}',
        tags: request.tags,
        isPrivateFile: false,
        customCoordinates: '',
        metadata: request.customMetadata,
      );
    } on FileUploadFailure {
      rethrow;
    } catch (e) {
      if (e.toString().contains('network') || e.toString().contains('connection')) {
        throw FileUploadNetworkFailure(failureMessage: e.toString());
      } else if (e.toString().contains('server') || e.toString().contains('5')) {
        throw FileUploadServerFailure(failureMessage: e.toString());
      } else {
        throw FileUploadUnknownFailure(failureMessage: e.toString());
      }
    }
  }

  @override
  Future<void> deleteFile({required String fileId}) async {
    try {
      if (!config.isConfigured) {
        throw FileUploadConfigFailure();
      }

      // Mock deletion - will be implemented with actual ImageKit API
      await Future.delayed(const Duration(milliseconds: 500));
    } on FileUploadFailure {
      rethrow;
    } catch (e) {
      if (e.toString().contains('network') || e.toString().contains('connection')) {
        throw FileUploadNetworkFailure(failureMessage: e.toString());
      } else if (e.toString().contains('server') || e.toString().contains('5')) {
        throw FileUploadServerFailure(failureMessage: e.toString());
      } else {
        throw FileUploadUnknownFailure(failureMessage: e.toString());
      }
    }
  }

  @override
  String generateUrl({
    required String filePath,
    List<String>? transformations,
  }) {
    final baseUrl = config.urlEndpoint;
    
    // Remove leading slash from filePath if it exists
    final cleanFilePath = filePath.startsWith('/') ? filePath.substring(1) : filePath;
    
    if (transformations != null && transformations.isNotEmpty) {
      final transformationString = transformations.join(',');
      return '$baseUrl/tr:$transformationString/$cleanFilePath';
    }
    
    return '$baseUrl/$cleanFilePath';
  }
}