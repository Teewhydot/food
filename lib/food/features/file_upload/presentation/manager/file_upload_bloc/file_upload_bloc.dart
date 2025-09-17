import 'dart:io';

import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/features/file_upload/domain/use_cases/file_upload_usecase.dart';

class FileUploadCubit extends BaseCubit<BaseState<dynamic>> {
  FileUploadCubit() : super(const InitialState<dynamic>());

  final uploadFileUseCase = FileUploadUseCase();

  Future<void> uploadFile(String userId, File file) async {
    emit(const LoadingState<dynamic>(message: 'Uploading file...'));

    final result = await uploadFileUseCase.uploadFile(
      userId: userId,
      file: file,
    );

    result.fold(
      (failure) => emit(ErrorState(errorMessage: failure.failureMessage)),
      (uploadedFile) =>
          emit(SuccessState(successMessage: 'File uploaded successfully')),
    );
  }

  Future<void> deleteFile(String fileId, userId) async {
    emit(const LoadingState<dynamic>(message: 'Deleting file...'));

    final result = await uploadFileUseCase.deleteFile(
      fileId: fileId,
      userId: userId,
    );

    result.fold(
      (failure) => emit(ErrorState(errorMessage: failure.failureMessage)),
      (_) =>
          emit(const SuccessState(successMessage: 'File deleted successfully')),
    );
  }
}
