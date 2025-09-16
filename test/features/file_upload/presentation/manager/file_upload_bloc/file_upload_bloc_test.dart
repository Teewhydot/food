import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/features/file_upload/domain/entities/uploaded_file_entity.dart';
import 'package:food/food/features/file_upload/domain/failures/file_upload_failures.dart'
    as domain;
import 'package:food/food/features/file_upload/domain/use_cases/delete_file_usecase.dart';
import 'package:food/food/features/file_upload/domain/use_cases/file_upload_usecase.dart';
import 'package:food/food/features/file_upload/presentation/manager/file_upload_bloc/file_upload_bloc.dart';
import 'package:food/food/features/file_upload/presentation/manager/file_upload_bloc/file_upload_event.dart';
import 'package:food/food/features/file_upload/presentation/manager/file_upload_bloc/file_upload_state.dart';
import 'package:mocktail/mocktail.dart';

class MockUploadFileUseCase extends Mock implements UploadFileUseCase {}

class MockDeleteFileUseCase extends Mock implements DeleteFileUseCase {}

class MockFile extends Mock implements File {}

void main() {
  group('FileUploadBloc', () {
    late FileUploadCubit fileUploadBloc;
    late MockUploadFileUseCase mockUploadFileUseCase;
    late MockDeleteFileUseCase mockDeleteFileUseCase;
    late MockFile mockFile;

    setUp(() {
      mockUploadFileUseCase = MockUploadFileUseCase();
      mockDeleteFileUseCase = MockDeleteFileUseCase();
      mockFile = MockFile();
      fileUploadBloc = FileUploadCubit(
        uploadFileUseCase: mockUploadFileUseCase,
        deleteFileUseCase: mockDeleteFileUseCase,
      );
    });

    setUpAll(() {
      registerFallbackValue(MockFile());
    });

    test('initial state is FileUploadInitial', () {
      expect(fileUploadBloc.state, const FileUploadInitial());
    });

    group('UploadFileEvent', () {
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

      blocTest<FileUploadCubit, FileUploadState>(
        'emits [FileUploadLoading, FileUploadSuccess] when upload succeeds',
        build: () {
          when(
            () => mockUploadFileUseCase.call(
              file: any(named: 'file'),
              fileName: any(named: 'fileName'),
              folder: any(named: 'folder'),
              tags: any(named: 'tags'),
              customMetadata: any(named: 'customMetadata'),
            ),
          ).thenAnswer((_) async => Right(mockUploadedFile));
          return fileUploadBloc;
        },
        act: (bloc) => bloc.add(UploadFileEvent(file: mockFile)),
        expect:
            () => [
              const FileUploadLoading(),
              FileUploadSuccess(uploadedFile: mockUploadedFile),
            ],
        verify: (_) {
          verify(
            () => mockUploadFileUseCase.call(
              file: mockFile,
              fileName: null,
              folder: null,
              tags: null,
              customMetadata: null,
            ),
          ).called(1);
        },
      );

      blocTest<FileUploadCubit, FileUploadState>(
        'emits [FileUploadLoading, FileUploadFailure] when upload fails',
        build: () {
          final failure = domain.FileUploadNetworkFailure();
          when(
            () => mockUploadFileUseCase.call(
              file: any(named: 'file'),
              fileName: any(named: 'fileName'),
              folder: any(named: 'folder'),
              tags: any(named: 'tags'),
              customMetadata: any(named: 'customMetadata'),
            ),
          ).thenAnswer((_) async => Left(failure));
          return fileUploadBloc;
        },
        act: (bloc) => bloc.add(UploadFileEvent(file: mockFile)),
        expect: () => [isA<FileUploadLoading>(), isA<FileUploadFailure>()],
      );

      blocTest<FileUploadCubit, FileUploadState>(
        'passes correct parameters to use case',
        build: () {
          when(
            () => mockUploadFileUseCase.call(
              file: any(named: 'file'),
              fileName: any(named: 'fileName'),
              folder: any(named: 'folder'),
              tags: any(named: 'tags'),
              customMetadata: any(named: 'customMetadata'),
            ),
          ).thenAnswer((_) async => Right(mockUploadedFile));
          return fileUploadBloc;
        },
        act:
            (bloc) => bloc.add(
              UploadFileEvent(
                file: mockFile,
                fileName: 'custom.jpg',
                folder: '/custom/',
                tags: ['tag1', 'tag2'],
                customMetadata: {'key': 'value'},
              ),
            ),
        expect:
            () => [
              const FileUploadLoading(),
              FileUploadSuccess(uploadedFile: mockUploadedFile),
            ],
        verify: (_) {
          verify(
            () => mockUploadFileUseCase.call(
              file: mockFile,
              fileName: 'custom.jpg',
              folder: '/custom/',
              tags: ['tag1', 'tag2'],
              customMetadata: {'key': 'value'},
            ),
          ).called(1);
        },
      );
    });

    group('DeleteFileEvent', () {
      blocTest<FileUploadCubit, FileUploadState>(
        'emits [FileDeletionLoading, FileDeletionSuccess] when deletion succeeds',
        build: () {
          when(
            () => mockDeleteFileUseCase.call(fileId: any(named: 'fileId')),
          ).thenAnswer((_) async => const Right(null));
          return fileUploadBloc;
        },
        act: (bloc) => bloc.add(const DeleteFileEvent(fileId: 'test_id')),
        expect:
            () => [const FileDeletionLoading(), const FileDeletionSuccess()],
        verify: (_) {
          verify(() => mockDeleteFileUseCase.call(fileId: 'test_id')).called(1);
        },
      );

      blocTest<FileUploadCubit, FileUploadState>(
        'emits [FileDeletionLoading, FileDeletionFailure] when deletion fails',
        build: () {
          final failure = domain.FileUploadServerFailure();
          when(
            () => mockDeleteFileUseCase.call(fileId: any(named: 'fileId')),
          ).thenAnswer((_) async => Left(failure));
          return fileUploadBloc;
        },
        act: (bloc) => bloc.add(const DeleteFileEvent(fileId: 'test_id')),
        expect: () => [isA<FileDeletionLoading>(), isA<FileDeletionFailure>()],
      );
    });

    group('ResetFileUploadEvent', () {
      blocTest<FileUploadCubit, FileUploadState>(
        'emits FileUploadInitial when reset is triggered',
        build: () => fileUploadBloc,
        act: (bloc) => bloc.add(const ResetFileUploadEvent()),
        expect: () => [const FileUploadInitial()],
      );
    });

    tearDown(() {
      fileUploadBloc.close();
    });
  });
}
