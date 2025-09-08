import 'package:flutter/material.dart';

enum FileUploadType {
  image,
  document,
  video,
  audio,
  any;

  String get displayName {
    switch (this) {
      case FileUploadType.image:
        return 'Image';
      case FileUploadType.document:
        return 'Document';
      case FileUploadType.video:
        return 'Video';
      case FileUploadType.audio:
        return 'Audio';
      case FileUploadType.any:
        return 'Any File';
    }
  }

  List<String> get allowedExtensions {
    switch (this) {
      case FileUploadType.image:
        return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg'];
      case FileUploadType.document:
        return ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'csv'];
      case FileUploadType.video:
        return ['mp4', 'avi', 'mov', 'wmv', 'flv', 'mkv', 'webm'];
      case FileUploadType.audio:
        return ['mp3', 'wav', 'ogg', 'aac', 'wma', 'flac', 'm4a'];
      case FileUploadType.any:
        return [];
    }
  }

  List<String> get mimeTypes {
    switch (this) {
      case FileUploadType.image:
        return [
          'image/jpeg',
          'image/jpg',
          'image/png',
          'image/gif',
          'image/bmp',
          'image/webp',
          'image/svg+xml',
        ];
      case FileUploadType.document:
        return [
          'application/pdf',
          'application/msword',
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          'application/vnd.ms-excel',
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          'application/vnd.ms-powerpoint',
          'application/vnd.openxmlformats-officedocument.presentationml.presentation',
          'text/plain',
          'text/csv',
        ];
      case FileUploadType.video:
        return [
          'video/mp4',
          'video/mpeg',
          'video/quicktime',
          'video/x-msvideo',
          'video/webm',
          'video/x-flv',
          'video/x-matroska',
        ];
      case FileUploadType.audio:
        return [
          'audio/mpeg',
          'audio/wav',
          'audio/mp3',
          'audio/ogg',
          'audio/aac',
          'audio/x-ms-wma',
          'audio/flac',
          'audio/mp4',
        ];
      case FileUploadType.any:
        return [];
    }
  }

  IconData get icon {
    switch (this) {
      case FileUploadType.image:
        return Icons.image;
      case FileUploadType.document:
        return Icons.description;
      case FileUploadType.video:
        return Icons.video_library;
      case FileUploadType.audio:
        return Icons.audio_file;
      case FileUploadType.any:
        return Icons.file_present;
    }
  }
}