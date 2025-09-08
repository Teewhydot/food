import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/core/services/imagekit/imagekit_config.dart';
import 'package:food/food/features/file_upload/data/models/imagekit_upload_response.dart';
import 'package:food/food/features/file_upload/data/remote/data_sources/imagekit_remote_data_source.dart';
import 'package:food/food/features/file_upload/domain/failures/file_upload_failures.dart';
import 'package:mocktail/mocktail.dart';

class MockImageKitConfig extends Mock implements ImageKitConfig {}

class MockFile extends Mock implements File {}

class MockImageKitRemoteDataSource extends Mock
    implements ImageKitRemoteDataSource {}

void main() {
  group('ImageKitRemoteDataSource', () {
    late ImageKitRemoteDataSource dataSource;
    late MockImageKitConfig mockConfig;
    late MockFile mockFile;

    setUp(() {
      mockConfig = MockImageKitConfig();
      mockFile = MockFile();
      dataSource = ImageKitRemoteDataSourceImpl(config: mockConfig);
    });

    setUpAll(() {
      registerFallbackValue(File(''));
    });

    group('uploadFile', () {
      const mockRequest = ImageKitUploadRequest(
        fileName: 'test.jpg',
        folder: '/food-app/',
        tags: ['food', 'test'],
      );

      test('should upload file successfully', () async {
        // Arrange
        when(() => mockConfig.isConfigured).thenReturn(true);
        when(() => mockConfig.maxFileSizeInBytes).thenReturn(10 * 1024 * 1024);
        when(
          () => mockConfig.allowedFileTypes,
        ).thenReturn(['image/jpeg', 'image/png']);
        when(() => mockFile.existsSync()).thenReturn(true);
        when(() => mockFile.lengthSync()).thenReturn(256000);
        when(() => mockFile.path).thenReturn('/path/to/test.jpg');

        // Act
        final result = await dataSource.uploadFile(
          file: mockFile,
          request: mockRequest,
        );

        // Assert
        expect(result, isA<ImageKitUploadResponse>());
        verify(() => mockConfig.isConfigured).called(1);
        verify(() => mockFile.existsSync()).called(1);
      });

      test(
        'should throw FileUploadConfigFailure when ImageKit is not configured',
        () async {
          // Arrange
          when(() => mockConfig.isConfigured).thenReturn(false);

          // Act & Assert
          expect(
            () => dataSource.uploadFile(file: mockFile, request: mockRequest),
            throwsA(isA<FileUploadConfigFailure>()),
          );
        },
      );

      test(
        'should throw FileUploadValidationFailure when file does not exist',
        () async {
          // Arrange
          when(() => mockConfig.isConfigured).thenReturn(true);
          when(() => mockFile.existsSync()).thenReturn(false);

          // Act & Assert
          expect(
            () => dataSource.uploadFile(file: mockFile, request: mockRequest),
            throwsA(isA<FileUploadValidationFailure>()),
          );
        },
      );

      test(
        'should throw FileUploadValidationFailure when file is too large',
        () async {
          // Arrange
          when(() => mockConfig.isConfigured).thenReturn(true);
          when(
            () => mockConfig.maxFileSizeInBytes,
          ).thenReturn(1024); // 1KB limit
          when(() => mockFile.existsSync()).thenReturn(true);
          when(() => mockFile.lengthSync()).thenReturn(2048); // 2KB file

          // Act & Assert
          expect(
            () => dataSource.uploadFile(file: mockFile, request: mockRequest),
            throwsA(isA<FileUploadValidationFailure>()),
          );
        },
      );

      test('should validate file type', () async {
        // Arrange
        when(() => mockConfig.isConfigured).thenReturn(true);
        when(() => mockConfig.maxFileSizeInBytes).thenReturn(10 * 1024 * 1024);
        when(
          () => mockConfig.allowedFileTypes,
        ).thenReturn(['image/jpeg', 'image/png']);
        when(() => mockFile.existsSync()).thenReturn(true);
        when(() => mockFile.lengthSync()).thenReturn(1024);
        when(() => mockFile.path).thenReturn('/path/to/test.txt'); // .txt file

        const invalidRequest = ImageKitUploadRequest(fileName: 'test.txt');

        // Act & Assert
        expect(
          () => dataSource.uploadFile(file: mockFile, request: invalidRequest),
          throwsA(isA<FileUploadValidationFailure>()),
        );
      });
    });

    group('deleteFile', () {
      test('should delete file successfully', () async {
        // Arrange
        when(() => mockConfig.isConfigured).thenReturn(true);
        const fileId = 'test_file_id';

        // Act & Assert
        expect(() => dataSource.deleteFile(fileId: fileId), returnsNormally);
      });

      test(
        'should throw FileUploadConfigFailure when ImageKit is not configured',
        () async {
          // Arrange
          when(() => mockConfig.isConfigured).thenReturn(false);

          // Act & Assert
          expect(
            () => dataSource.deleteFile(fileId: 'test_id'),
            throwsA(isA<FileUploadConfigFailure>()),
          );
        },
      );
    });

    group('generateUrl', () {
      test('should generate URL with transformations', () async {
        // Arrange
        when(
          () => mockConfig.urlEndpoint,
        ).thenReturn('https://ik.imagekit.io/test');

        const filePath = '/food-app/test.jpg';
        const transformations = ['w-300', 'h-200', 'q-80'];

        // Act
        final result = dataSource.generateUrl(
          filePath: filePath,
          transformations: transformations,
        );

        // Assert
        expect(result, contains('https://ik.imagekit.io/test'));
        expect(result, contains('tr:w-300,h-200,q-80'));
        expect(result, contains('/food-app/test.jpg'));
      });

      test('should generate URL without transformations', () async {
        // Arrange
        when(
          () => mockConfig.urlEndpoint,
        ).thenReturn('https://ik.imagekit.io/test');

        const filePath = '/food-app/test.jpg';

        // Act
        final result = dataSource.generateUrl(filePath: filePath);

        // Assert
        expect(result, equals('https://ik.imagekit.io/test/food-app/test.jpg'));
      });
    });
  });
}
