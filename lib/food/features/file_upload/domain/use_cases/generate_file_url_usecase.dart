import 'package:food/food/features/file_upload/domain/repositories/file_upload_repository.dart';

class GenerateFileUrlUseCase {
  final FileUploadRepository repository;

  GenerateFileUrlUseCase({required this.repository});

  String call({
    required String filePath,
    List<String>? transformations,
  }) {
    return repository.generateFileUrl(
      filePath: filePath,
      transformations: transformations,
    );
  }
}