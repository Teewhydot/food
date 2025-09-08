import 'package:equatable/equatable.dart';
import 'package:food/food/features/file_upload/domain/entities/uploaded_file_entity.dart';
import 'package:food/food/domain/failures/failures.dart';

abstract class FileUploadState extends Equatable {
  const FileUploadState();

  @override
  List<Object?> get props => [];
}

class FileUploadInitial extends FileUploadState {
  const FileUploadInitial();
}

class FileUploadLoading extends FileUploadState {
  const FileUploadLoading();
}

class FileUploadSuccess extends FileUploadState {
  final UploadedFileEntity uploadedFile;

  const FileUploadSuccess({required this.uploadedFile});

  @override
  List<Object?> get props => [uploadedFile];
}

class FileUploadFailure extends FileUploadState {
  final Failure failure;

  const FileUploadFailure({required this.failure});

  @override
  List<Object?> get props => [failure];
}

class FileDeletionLoading extends FileUploadState {
  const FileDeletionLoading();
}

class FileDeletionSuccess extends FileUploadState {
  const FileDeletionSuccess();
}

class FileDeletionFailure extends FileUploadState {
  final Failure failure;

  const FileDeletionFailure({required this.failure});

  @override
  List<Object?> get props => [failure];
}