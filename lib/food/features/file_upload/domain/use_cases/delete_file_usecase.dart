import 'package:dartz/dartz.dart';
import 'package:food/food/domain/failures/failures.dart';
import 'package:food/food/features/file_upload/domain/repositories/file_upload_repository.dart';

class DeleteFileUseCase {
  final FileUploadRepository repository;

  DeleteFileUseCase({required this.repository});

  Future<Either<Failure, void>> call({required String fileId}) async {
    return await repository.deleteFile(fileId: fileId);
  }
}