import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:food/food/domain/failures/failures.dart';
import 'package:food/food/features/file_upload/data/repositories/file_upload_repository_impl.dart';
import 'package:food/food/features/file_upload/domain/entities/uploaded_file_entity.dart';

class FileUploadUseCase {
  final fileUploadRepo = FileUploadRepositoryImpl();
  Future<Either<Failure, void>> deleteFile({
    required String userId,
    required String fileId,
  }) async {
    return await fileUploadRepo.deleteFile(fileId: fileId);
  }

  Future<Either<Failure, String>> generateFileUrl({
    required String filePath,
    List<String>? transformations,
  }) {
    return fileUploadRepo.generateFileUrl(
      filePath: filePath,
      transformations: transformations,
    );
  }

  Future<Either<Failure, UploadedFileEntity>> uploadFile({
    required String userId,
    required File file,
  }) async {
    return await fileUploadRepo.uploadFile(
      userId: userId, // Replace with actual user ID retrieval logic
      file: file,
    );
  }
}
