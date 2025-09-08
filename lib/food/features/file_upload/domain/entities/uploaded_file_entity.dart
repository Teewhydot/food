import 'package:equatable/equatable.dart';

class UploadedFileEntity extends Equatable {
  final String id;
  final String name;
  final String url;
  final String thumbnailUrl;
  final int size;
  final String mimeType;
  final int width;
  final int height;
  final DateTime uploadedAt;
  final List<String> tags;

  const UploadedFileEntity({
    required this.id,
    required this.name,
    required this.url,
    required this.thumbnailUrl,
    required this.size,
    required this.mimeType,
    required this.width,
    required this.height,
    required this.uploadedAt,
    required this.tags,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    url,
    thumbnailUrl,
    size,
    mimeType,
    width,
    height,
    uploadedAt,
    tags,
  ];

  /// Check if the file is an image
  bool get isImage => mimeType.startsWith('image/');

  /// Get file extension from name
  String get extension => name.split('.').last.toLowerCase();

  /// Get human readable file size
  String get humanReadableSize {
    const units = ['B', 'KB', 'MB', 'GB'];
    double bytes = size.toDouble();
    int unitIndex = 0;
    
    while (bytes >= 1024 && unitIndex < units.length - 1) {
      bytes /= 1024;
      unitIndex++;
    }
    
    return '${bytes.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  /// Create a copy with updated properties
  UploadedFileEntity copyWith({
    String? id,
    String? name,
    String? url,
    String? thumbnailUrl,
    int? size,
    String? mimeType,
    int? width,
    int? height,
    DateTime? uploadedAt,
    List<String>? tags,
  }) {
    return UploadedFileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      size: size ?? this.size,
      mimeType: mimeType ?? this.mimeType,
      width: width ?? this.width,
      height: height ?? this.height,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      tags: tags ?? this.tags,
    );
  }
}