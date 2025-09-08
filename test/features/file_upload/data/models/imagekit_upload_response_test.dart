import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/features/file_upload/data/models/imagekit_upload_response.dart';

void main() {
  group('ImageKitUploadResponse', () {
    const mockResponseJson = {
      'fileId': 'test_file_id_123',
      'name': 'test_image.jpg',
      'url': 'https://ik.imagekit.io/test/test_image.jpg',
      'thumbnailUrl': 'https://ik.imagekit.io/test/tr:n-thumbnail/test_image.jpg',
      'height': 1080,
      'width': 1920,
      'size': 256000,
      'filePath': '/food-app/test_image.jpg',
      'tags': ['food', 'test'],
      'isPrivateFile': false,
      'customCoordinates': '0,0,100,100',
      'metadata': {'category': 'food_image', 'user_id': '123'}
    };

    const mockResponse = ImageKitUploadResponse(
      fileId: 'test_file_id_123',
      name: 'test_image.jpg',
      url: 'https://ik.imagekit.io/test/test_image.jpg',
      thumbnailUrl: 'https://ik.imagekit.io/test/tr:n-thumbnail/test_image.jpg',
      height: 1080,
      width: 1920,
      size: 256000,
      filePath: '/food-app/test_image.jpg',
      tags: ['food', 'test'],
      isPrivateFile: false,
      customCoordinates: '0,0,100,100',
      metadata: {'category': 'food_image', 'user_id': '123'},
    );

    test('should create instance from JSON correctly', () {
      // Act
      final result = ImageKitUploadResponse.fromJson(mockResponseJson);

      // Assert
      expect(result, equals(mockResponse));
      expect(result.fileId, equals('test_file_id_123'));
      expect(result.name, equals('test_image.jpg'));
      expect(result.url, contains('imagekit.io'));
      expect(result.size, equals(256000));
      expect(result.tags, hasLength(2));
      expect(result.metadata, isA<Map<String, dynamic>>());
    });

    test('should convert to JSON correctly', () {
      // Act
      final result = mockResponse.toJson();

      // Assert
      expect(result, equals(mockResponseJson));
      expect(result['fileId'], equals('test_file_id_123'));
      expect(result['tags'], isA<List<String>>());
      expect(result['metadata'], isA<Map<String, dynamic>>());
    });

    test('should handle empty/null values gracefully', () {
      // Arrange
      const emptyJson = <String, dynamic>{};

      // Act
      final result = ImageKitUploadResponse.fromJson(emptyJson);

      // Assert
      expect(result.fileId, isEmpty);
      expect(result.name, isEmpty);
      expect(result.url, isEmpty);
      expect(result.height, equals(0));
      expect(result.width, equals(0));
      expect(result.size, equals(0));
      expect(result.tags, isEmpty);
      expect(result.isPrivateFile, isFalse);
      expect(result.metadata, isEmpty);
    });

    test('should support equality comparison', () {
      // Arrange
      const response1 = ImageKitUploadResponse(
        fileId: 'test',
        name: 'test.jpg',
        url: 'https://test.com/test.jpg',
        thumbnailUrl: 'https://test.com/thumb.jpg',
        height: 100,
        width: 100,
        size: 1000,
        filePath: '/test.jpg',
        tags: ['test'],
        isPrivateFile: false,
        customCoordinates: '',
        metadata: {},
      );

      const response2 = ImageKitUploadResponse(
        fileId: 'test',
        name: 'test.jpg',
        url: 'https://test.com/test.jpg',
        thumbnailUrl: 'https://test.com/thumb.jpg',
        height: 100,
        width: 100,
        size: 1000,
        filePath: '/test.jpg',
        tags: ['test'],
        isPrivateFile: false,
        customCoordinates: '',
        metadata: {},
      );

      // Assert
      expect(response1, equals(response2));
      expect(response1.hashCode, equals(response2.hashCode));
    });
  });

  group('ImageKitUploadRequest', () {
    test('should create upload request with default values', () {
      // Arrange
      const request = ImageKitUploadRequest(fileName: 'test.jpg');

      // Assert
      expect(request.fileName, equals('test.jpg'));
      expect(request.folder, equals('/food-app/'));
      expect(request.tags, isEmpty);
      expect(request.useUniqueFileName, isTrue);
      expect(request.customMetadata, isEmpty);
    });

    test('should create upload request with custom values', () {
      // Arrange
      const request = ImageKitUploadRequest(
        fileName: 'custom.png',
        folder: '/custom-folder/',
        tags: ['tag1', 'tag2'],
        useUniqueFileName: false,
        customMetadata: {'key': 'value'},
      );

      // Assert
      expect(request.fileName, equals('custom.png'));
      expect(request.folder, equals('/custom-folder/'));
      expect(request.tags, hasLength(2));
      expect(request.useUniqueFileName, isFalse);
      expect(request.customMetadata, hasLength(1));
    });

    test('should convert to JSON correctly', () {
      // Arrange
      const request = ImageKitUploadRequest(
        fileName: 'test.jpg',
        folder: '/test/',
        tags: ['tag1', 'tag2'],
        useUniqueFileName: true,
        customMetadata: {'category': 'food'},
      );

      // Act
      final json = request.toJson();

      // Assert
      expect(json['fileName'], equals('test.jpg'));
      expect(json['folder'], equals('/test/'));
      expect(json['tags'], equals('tag1,tag2'));
      expect(json['useUniqueFileName'], isTrue);
      expect(json['customMetadata'], equals({'category': 'food'}));
    });

    test('should support equality comparison', () {
      // Arrange
      const request1 = ImageKitUploadRequest(
        fileName: 'test.jpg',
        tags: ['tag1'],
      );
      
      const request2 = ImageKitUploadRequest(
        fileName: 'test.jpg',
        tags: ['tag1'],
      );

      // Assert
      expect(request1, equals(request2));
      expect(request1.hashCode, equals(request2.hashCode));
    });
  });
}