import 'package:equatable/equatable.dart';

class UploadedFileEntity extends Equatable {
  final String url;
  final DateTime uploadedAt;

  const UploadedFileEntity({required this.url, required this.uploadedAt});

  @override
  List<Object?> get props => [url, uploadedAt];

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
      url: url ?? this.url,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}
