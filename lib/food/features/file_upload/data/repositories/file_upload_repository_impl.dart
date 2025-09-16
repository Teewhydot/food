import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:food/food/domain/failures/failures.dart';
import 'package:food/food/features/file_upload/domain/entities/uploaded_file_entity.dart';
import 'package:food/food/features/file_upload/domain/repositories/file_upload_repository.dart';
import 'package:food/food/features/file_upload/data/remote/data_sources/imagekit_remote_data_source.dart';
import 'package:food/food/features/file_upload/data/models/imagekit_upload_response.dart';
import 'package:food/food/features/file_upload/domain/failures/file_upload_failures.dart';
import 'package:mime/mime.dart';
import 'package:get_it/get_it.dart';

class FileUploadRepositoryImpl implements FileUploadRepository {
  final remoteDataSource = GetIt.instance<FileUploadDataSource>();

  @override
  Future<Either<Failure, UploadedFileEntity>> uploadFile({
    required File file,
    String? fileName,
    String? folder,
    List<String>? tags,
    Map<String, dynamic>? customMetadata,
  }) async {
    try {
      // Generate filename if not provided
      final finalFileName = fileName ?? _generateFileName(file);

      // Create upload request
      final request = ImageKitUploadRequest(
        fileName: finalFileName,
        folder: folder ?? '/food-app/',
        tags: tags ?? [],
        customMetadata: customMetadata ?? {},
      );

      // Upload file
      final response = await remoteDataSource.uploadFile(
        file: file,
        request: request,
      );

      // Convert to domain entity
      final uploadedFile = _mapToUploadedFileEntity(response, file);

      return Right(uploadedFile);
    } on FileUploadFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(FileUploadUnknownFailure(failureMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFile({required String fileId}) async {
    try {
      await remoteDataSource.deleteFile(fileId: fileId);
      return const Right(null);
    } on FileUploadFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(FileUploadUnknownFailure(failureMessage: e.toString()));
    }
  }

  @override
  String generateFileUrl({
    required String filePath,
    List<String>? transformations,
  }) {
    return remoteDataSource.generateUrl(
      filePath: filePath,
      transformations: transformations,
    );
  }

  String _generateFileName(File file) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = file.path.split('.').last.toLowerCase();
    return 'file_$timestamp.$extension';
  }

  UploadedFileEntity _mapToUploadedFileEntity(
    ImageKitUploadResponse response,
    File originalFile,
  ) {
    final mimeType =
        lookupMimeType(originalFile.path) ?? 'application/octet-stream';

    return UploadedFileEntity(
      id: response.fileId,
      name: response.name,
      url: response.url,
      thumbnailUrl: response.thumbnailUrl,
      size: response.size,
      mimeType: mimeType,
      width: response.width,
      height: response.height,
      uploadedAt: DateTime.now(),
      tags: response.tags,
    );
  }
}
