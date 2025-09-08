import 'package:equatable/equatable.dart';

class ImageKitUploadResponse extends Equatable {
  final String fileId;
  final String name;
  final String url;
  final String thumbnailUrl;
  final int height;
  final int width;
  final int size;
  final String filePath;
  final List<String> tags;
  final bool isPrivateFile;
  final String customCoordinates;
  final Map<String, dynamic> metadata;

  const ImageKitUploadResponse({
    required this.fileId,
    required this.name,
    required this.url,
    required this.thumbnailUrl,
    required this.height,
    required this.width,
    required this.size,
    required this.filePath,
    required this.tags,
    required this.isPrivateFile,
    required this.customCoordinates,
    required this.metadata,
  });

  factory ImageKitUploadResponse.fromJson(Map<String, dynamic> json) {
    return ImageKitUploadResponse(
      fileId: json['fileId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      height: json['height'] as int? ?? 0,
      width: json['width'] as int? ?? 0,
      size: json['size'] as int? ?? 0,
      filePath: json['filePath'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isPrivateFile: json['isPrivateFile'] as bool? ?? false,
      customCoordinates: json['customCoordinates'] as String? ?? '',
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileId': fileId,
      'name': name,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'height': height,
      'width': width,
      'size': size,
      'filePath': filePath,
      'tags': tags,
      'isPrivateFile': isPrivateFile,
      'customCoordinates': customCoordinates,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
    fileId,
    name,
    url,
    thumbnailUrl,
    height,
    width,
    size,
    filePath,
    tags,
    isPrivateFile,
    customCoordinates,
    metadata,
  ];
}

class ImageKitUploadRequest extends Equatable {
  final String fileName;
  final String folder;
  final List<String> tags;
  final bool useUniqueFileName;
  final Map<String, dynamic> customMetadata;

  const ImageKitUploadRequest({
    required this.fileName,
    this.folder = '/food-app/',
    this.tags = const [],
    this.useUniqueFileName = true,
    this.customMetadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'folder': folder,
      'tags': tags.join(','),
      'useUniqueFileName': useUniqueFileName,
      'customMetadata': customMetadata,
    };
  }

  @override
  List<Object?> get props => [
    fileName,
    folder,
    tags,
    useUniqueFileName,
    customMetadata,
  ];
}