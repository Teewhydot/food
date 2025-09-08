import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food/food/features/file_upload/presentation/manager/file_upload_bloc/file_upload_event.dart';
import 'package:food/food/features/file_upload/presentation/manager/file_upload_bloc/file_upload_state.dart';
import 'package:food/food/features/file_upload/domain/use_cases/upload_file_usecase.dart';
import 'package:food/food/features/file_upload/domain/use_cases/delete_file_usecase.dart';

class FileUploadBloc extends Bloc<FileUploadEvent, FileUploadState> {
  final UploadFileUseCase uploadFileUseCase;
  final DeleteFileUseCase deleteFileUseCase;

  FileUploadBloc({
    required this.uploadFileUseCase,
    required this.deleteFileUseCase,
  }) : super(const FileUploadInitial()) {
    on<UploadFileEvent>(_onUploadFile);
    on<DeleteFileEvent>(_onDeleteFile);
    on<ResetFileUploadEvent>(_onResetFileUpload);
  }

  Future<void> _onUploadFile(
    UploadFileEvent event,
    Emitter<FileUploadState> emit,
  ) async {
    emit(const FileUploadLoading());

    final result = await uploadFileUseCase(
      file: event.file,
      fileName: event.fileName,
      folder: event.folder,
      tags: event.tags,
      customMetadata: event.customMetadata,
    );

    result.fold(
      (failure) => emit(FileUploadFailure(failure: failure)),
      (uploadedFile) => emit(FileUploadSuccess(uploadedFile: uploadedFile)),
    );
  }

  Future<void> _onDeleteFile(
    DeleteFileEvent event,
    Emitter<FileUploadState> emit,
  ) async {
    emit(const FileDeletionLoading());

    final result = await deleteFileUseCase(fileId: event.fileId);

    result.fold(
      (failure) => emit(FileDeletionFailure(failure: failure)),
      (_) => emit(const FileDeletionSuccess()),
    );
  }

  void _onResetFileUpload(
    ResetFileUploadEvent event,
    Emitter<FileUploadState> emit,
  ) {
    emit(const FileUploadInitial());
  }
}