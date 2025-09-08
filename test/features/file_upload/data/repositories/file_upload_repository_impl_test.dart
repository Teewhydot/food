import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:food/food/features/file_upload/data/repositories/file_upload_repository_impl.dart';
import 'package:food/food/features/file_upload/data/remote/data_sources/imagekit_remote_data_source.dart';
import 'package:food/food/features/file_upload/data/models/imagekit_upload_response.dart';
import 'package:food/food/features/file_upload/domain/entities/uploaded_file_entity.dart';
import 'package:food/food/features/file_upload/domain/failures/file_upload_failures.dart';

class MockImageKitRemoteDataSource extends Mock implements ImageKitRemoteDataSource {}
class MockFile extends Mock implements File {}

void main() {
  group('FileUploadRepositoryImpl', () {
    late FileUploadRepositoryImpl repository;
    late MockImageKitRemoteDataSource mockRemoteDataSource;
    late MockFile mockFile;

    setUp(() {
      mockRemoteDataSource = MockImageKitRemoteDataSource();
      mockFile = MockFile();
      repository = FileUploadRepositoryImpl(remoteDataSource: mockRemoteDataSource);
    });

    setUpAll(() {
      registerFallbackValue(MockFile());
      registerFallbackValue(const ImageKitUploadRequest(fileName: 'test.jpg'));
    });

    group('uploadFile', () {
      const mockResponse = ImageKitUploadResponse(
        fileId: 'test_file_id',
        name: 'test.jpg',
        url: 'https://ik.imagekit.io/test/test.jpg',
        thumbnailUrl: 'https://ik.imagekit.io/test/tr:n-thumbnail/test.jpg',
        height: 1080,
        width: 1920,
        size: 256000,
        filePath: '/food-app/test.jpg',
        tags: ['food', 'test'],
        isPrivateFile: false,
        customCoordinates: '',
        metadata: {},
      );

      test('should return UploadedFileEntity when upload succeeds', () async {
        // Arrange
        when(() => mockFile.path).thenReturn('/path/to/test.jpg');
        when(() => mockRemoteDataSource.uploadFile(
          file: any(named: 'file'),
          request: any(named: 'request'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await repository.uploadFile(
          file: mockFile,
          fileName: 'test.jpg',
          tags: ['food'],
        );

        // Assert
        expect(result, isA<Right<dynamic, UploadedFileEntity>>());
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (uploadedFile) {
            expect(uploadedFile.id, equals('test_file_id'));
            expect(uploadedFile.name, equals('test.jpg'));
            expect(uploadedFile.url, contains('imagekit.io'));
            expect(uploadedFile.size, equals(256000));
            expect(uploadedFile.tags, contains('food'));
          },
        );

        verify(() => mockRemoteDataSource.uploadFile(
          file: mockFile,
          request: any(named: 'request'),
        )).called(1);
      });

      test('should return failure when upload fails', () async {
        // Arrange
        when(() => mockFile.path).thenReturn('/path/to/test.jpg');
        when(() => mockRemoteDataSource.uploadFile(
          file: any(named: 'file'),
          request: any(named: 'request'),
        )).thenThrow(FileUploadNetworkFailure());

        // Act
        final result = await repository.uploadFile(
          file: mockFile,
          fileName: 'test.jpg',
        );

        // Assert
        expect(result, isA<Left<dynamic, dynamic>>());
      });

      test('should generate filename when not provided', () async {
        // Arrange
        when(() => mockFile.path).thenReturn('/path/to/image.jpg');
        when(() => mockRemoteDataSource.uploadFile(
          file: any(named: 'file'),
          request: any(named: 'request'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await repository.uploadFile(file: mockFile);

        // Assert
        expect(result, isA<Right<dynamic, UploadedFileEntity>>());
        
        final capturedRequest = verify(() => mockRemoteDataSource.uploadFile(
          file: mockFile,
          request: captureAny(named: 'request'),
        )).captured.single as ImageKitUploadRequest;
        
        expect(capturedRequest.fileName, contains('file_'));
        expect(capturedRequest.fileName, endsWith('.jpg'));
      });
    });

    group('deleteFile', () {
      test('should return success when deletion succeeds', () async {
        // Arrange
        when(() => mockRemoteDataSource.deleteFile(fileId: any(named: 'fileId')))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.deleteFile(fileId: 'test_file_id');

        // Assert
        expect(result, isA<Right<dynamic, void>>());
        verify(() => mockRemoteDataSource.deleteFile(fileId: 'test_file_id')).called(1);
      });

      test('should return failure when deletion fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.deleteFile(fileId: any(named: 'fileId')))
            .thenThrow(FileUploadServerFailure());

        // Act
        final result = await repository.deleteFile(fileId: 'test_file_id');

        // Assert
        expect(result, isA<Left<dynamic, dynamic>>());
      });
    });

    group('generateFileUrl', () {
      test('should return URL from remote data source', () {
        // Arrange
        const filePath = '/food-app/test.jpg';
        const transformations = ['w-300', 'h-200'];
        const expectedUrl = 'https://ik.imagekit.io/test/tr:w-300,h-200/food-app/test.jpg';
        
        when(() => mockRemoteDataSource.generateUrl(
          filePath: filePath,
          transformations: transformations,
        )).thenReturn(expectedUrl);

        // Act
        final result = repository.generateFileUrl(
          filePath: filePath,
          transformations: transformations,
        );

        // Assert
        expect(result, equals(expectedUrl));
        verify(() => mockRemoteDataSource.generateUrl(
          filePath: filePath,
          transformations: transformations,
        )).called(1);
      });
    });
  });
}