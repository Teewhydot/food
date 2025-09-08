import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:food/food/domain/failures/failures.dart';
import 'package:food/food/features/file_upload/domain/use_cases/upload_file_usecase.dart';
import 'package:food/food/features/file_upload/domain/use_cases/generate_file_url_usecase.dart';

class GenerateLinkFromUploadedFileUseCase {
  final UploadFileUseCase uploadFileUseCase;
  final GenerateFileUrlUseCase generateFileUrlUseCase;

  GenerateLinkFromUploadedFileUseCase({
    required this.uploadFileUseCase,
    required this.generateFileUrlUseCase,
  });

  /// Main feature: Upload a file and generate a public URL with optional transformations
  Future<Either<Failure, String>> call({
    required File file,
    String? fileName,
    String? folder,
    List<String>? tags,
    Map<String, dynamic>? customMetadata,
    List<String>? transformations,
  }) async {
    // Step 1: Upload the file
    final uploadResult = await uploadFileUseCase(
      file: file,
      fileName: fileName,
      folder: folder,
      tags: tags,
      customMetadata: customMetadata,
    );

    return uploadResult.fold(
      // Return failure if upload failed
      (failure) => Left(failure),
      // Generate URL if upload succeeded
      (uploadedFile) {
        final url = generateFileUrlUseCase(
          filePath: uploadedFile.url.split('/').last, // Extract file path from URL
          transformations: transformations,
        );
        return Right(url);
      },
    );
  }
}