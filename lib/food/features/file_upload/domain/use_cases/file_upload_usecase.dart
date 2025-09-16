import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:food/food/domain/failures/failures.dart';
import 'package:food/food/features/file_upload/data/repositories/file_upload_repository_impl.dart';
import 'package:food/food/features/file_upload/domain/entities/uploaded_file_entity.dart';

class FileUploadUseCase {
  final repository = FileUploadRepositoryImpl();
  FileUploadUseCase();
  Future<Either<Failure, void>> deleteFile({required String fileId}) async {
    return await repository.deleteFile(fileId: fileId);
  }

  String generateFileUrl({
    required String filePath,
    List<String>? transformations,
  }) {
    return repository.generateFileUrl(
      filePath: filePath,
      transformations: transformations,
    );
  }

  Future<Either<Failure, UploadedFileEntity>> uploadFile({
    required File file,
    String? fileName,
    String? folder,
    List<String>? tags,
    Map<String, dynamic>? customMetadata,
  }) async {
    return await repository.uploadFile(
      file: file,
      fileName: fileName,
      folder: folder,
      tags: tags,
      customMetadata: customMetadata,
    );
  }
}
