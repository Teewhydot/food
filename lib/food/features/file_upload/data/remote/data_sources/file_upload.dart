import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:food/food/features/file_upload/domain/entities/uploaded_file_entity.dart';

import '../../../../../domain/failures/failures.dart';

abstract class FileUploadDataSource {
  Future<UploadedFileEntity> uploadFile({required File file});

  Future<void> deleteFile({required String fileId});

  Future<Either<Failure, String>> generateUrl({
    required String filePath,
    List<String>? transformations,
  });
}

class FirebaseFileUploadImpl implements FileUploadDataSource {
  @override
  Future<void> deleteFile({required String fileId}) {
    // TODO: implement deleteFile
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, String>> generateUrl({
    required String filePath,
    List<String>? transformations,
  }) {
    // TODO: implement generateUrl
    throw UnimplementedError();
  }

  @override
  Future<UploadedFileEntity> uploadFile({required File file}) {
    // TODO: implement uploadFile
    throw UnimplementedError();
  }
}
