import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:food/food/features/file_upload/domain/use_cases/file_upload_usecase.dart';
import 'package:food/food/features/file_upload/domain/repositories/file_upload_repository.dart';
import 'package:food/food/features/file_upload/domain/entities/uploaded_file_entity.dart';
import 'package:food/food/features/file_upload/domain/failures/file_upload_failures.dart';

class MockFileUploadRepository extends Mock implements FileUploadRepository {}
class MockFile extends Mock implements File {}

void main() {
  group('UploadFileUseCase', () {
    late UploadFileUseCase useCase;
    late MockFileUploadRepository mockRepository;
    late MockFile mockFile;

    setUp(() {
      mockRepository = MockFileUploadRepository();
      mockFile = MockFile();
      useCase = UploadFileUseCase(repository: mockRepository);
    });

    setUpAll(() {
      registerFallbackValue(MockFile());
    });

    test('should return UploadedFileEntity when repository call succeeds', () async {
      // Arrange
      final mockUploadedFile = UploadedFileEntity(
        id: 'test_id',
        name: 'test.jpg',
        url: 'https://test.com/test.jpg',
        thumbnailUrl: 'https://test.com/thumb.jpg',
        size: 1024,
        mimeType: 'image/jpeg',
        width: 100,
        height: 100,
        uploadedAt: DateTime.now(),
        tags: ['test'],
      );

      when(() => mockRepository.uploadFile(
        file: any(named: 'file'),
        fileName: any(named: 'fileName'),
        folder: any(named: 'folder'),
        tags: any(named: 'tags'),
        customMetadata: any(named: 'customMetadata'),
      )).thenAnswer((_) async => Right(mockUploadedFile));

      // Act
      final result = await useCase.call(
        file: mockFile,
        fileName: 'test.jpg',
        folder: '/uploads/',
        tags: ['test'],
        customMetadata: {'key': 'value'},
      );

      // Assert
      expect(result, isA<Right<dynamic, UploadedFileEntity>>());
      result.fold(
        (failure) => fail('Expected success, got failure: $failure'),
        (uploadedFile) {
          expect(uploadedFile, equals(mockUploadedFile));
        },
      );

      verify(() => mockRepository.uploadFile(
        file: mockFile,
        fileName: 'test.jpg',
        folder: '/uploads/',
        tags: ['test'],
        customMetadata: {'key': 'value'},
      )).called(1);
    });

    test('should return failure when repository call fails', () async {
      // Arrange
      final failure = FileUploadNetworkFailure();
      when(() => mockRepository.uploadFile(
        file: any(named: 'file'),
        fileName: any(named: 'fileName'),
        folder: any(named: 'folder'),
        tags: any(named: 'tags'),
        customMetadata: any(named: 'customMetadata'),
      )).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.call(file: mockFile);

      // Assert
      expect(result, isA<Left<dynamic, dynamic>>());
    });

    test('should pass correct parameters to repository', () async {
      // Arrange
      final mockUploadedFile = UploadedFileEntity(
        id: 'test_id',
        name: 'test.jpg',
        url: 'https://test.com/test.jpg',
        thumbnailUrl: 'https://test.com/thumb.jpg',
        size: 1024,
        mimeType: 'image/jpeg',
        width: 100,
        height: 100,
        uploadedAt: DateTime.now(),
        tags: ['test'],
      );

      when(() => mockRepository.uploadFile(
        file: any(named: 'file'),
        fileName: any(named: 'fileName'),
        folder: any(named: 'folder'),
        tags: any(named: 'tags'),
        customMetadata: any(named: 'customMetadata'),
      )).thenAnswer((_) async => Right(mockUploadedFile));

      // Act
      await useCase.call(
        file: mockFile,
        fileName: 'custom.jpg',
        folder: '/custom-folder/',
        tags: ['tag1', 'tag2'],
        customMetadata: {'category': 'food'},
      );

      // Assert
      verify(() => mockRepository.uploadFile(
        file: mockFile,
        fileName: 'custom.jpg',
        folder: '/custom-folder/',
        tags: ['tag1', 'tag2'],
        customMetadata: {'category': 'food'},
      )).called(1);
    });
  });
}