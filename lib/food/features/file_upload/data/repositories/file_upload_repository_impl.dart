import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:food/food/core/utils/error_handler.dart';
import 'package:food/food/domain/failures/failures.dart';
import 'package:food/food/features/file_upload/data/remote/data_sources/file_upload.dart';
import 'package:food/food/features/file_upload/domain/entities/uploaded_file_entity.dart';
import 'package:food/food/features/file_upload/domain/repositories/file_upload_repository.dart';
import 'package:get_it/get_it.dart';

class FileUploadRepositoryImpl implements FileUploadRepository {
  final remoteDataSource = GetIt.instance<FileUploadDataSource>();

  @override
  Future<Either<Failure, UploadedFileEntity>> uploadFile({
    required String userId,
    required File file,
    String? fileName,
    String? folder,
    List<String>? tags,
    Map<String, dynamic>? customMetadata,
  }) async {
    return ErrorHandler.handle(
      () async => await remoteDataSource.uploadFile(userId: userId, file: file),
      operationName: "File Upload",
    );
  }

  @override
  Future<Either<Failure, void>> deleteFile({required String fileId}) async {
    return ErrorHandler.handle(
      () async => await remoteDataSource.deleteFile(fileId: fileId),
      operationName: "File Deletion",
    );
  }

  @override
  Future<Either<Failure, String>> generateFileUrl({
    required String filePath,
    List<String>? transformations,
  }) async {
    return ErrorHandler.handle(
      () async => await remoteDataSource.generateUrl(
        filePath: filePath,
        transformations: transformations,
      ),
      operationName: "Generate File URL",
    );
  }
}
