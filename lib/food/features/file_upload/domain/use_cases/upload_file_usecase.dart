import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:food/food/domain/failures/failures.dart';
import 'package:food/food/features/file_upload/domain/entities/uploaded_file_entity.dart';
import 'package:food/food/features/file_upload/domain/repositories/file_upload_repository.dart';

class UploadFileUseCase {
  final FileUploadRepository repository;

  UploadFileUseCase({required this.repository});

  Future<Either<Failure, UploadedFileEntity>> call({
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