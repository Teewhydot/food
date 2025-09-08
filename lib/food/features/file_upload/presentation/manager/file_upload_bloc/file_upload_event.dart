import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class FileUploadEvent extends Equatable {
  const FileUploadEvent();

  @override
  List<Object?> get props => [];
}

class UploadFileEvent extends FileUploadEvent {
  final File file;
  final String? fileName;
  final String? folder;
  final List<String>? tags;
  final Map<String, dynamic>? customMetadata;

  const UploadFileEvent({
    required this.file,
    this.fileName,
    this.folder,
    this.tags,
    this.customMetadata,
  });

  @override
  List<Object?> get props => [
    file,
    fileName,
    folder,
    tags,
    customMetadata,
  ];
}

class DeleteFileEvent extends FileUploadEvent {
  final String fileId;

  const DeleteFileEvent({required this.fileId});

  @override
  List<Object?> get props => [fileId];
}

class ResetFileUploadEvent extends FileUploadEvent {
  const ResetFileUploadEvent();
}