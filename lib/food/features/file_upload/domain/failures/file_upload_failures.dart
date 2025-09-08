import 'package:food/food/domain/failures/failures.dart';

abstract class FileUploadFailure extends Failure {
  FileUploadFailure({required super.failureMessage});
}

class FileUploadConfigFailure extends FileUploadFailure {
  FileUploadConfigFailure({
    super.failureMessage = 'ImageKit configuration is incomplete',
  });
}

class FileUploadValidationFailure extends FileUploadFailure {
  FileUploadValidationFailure({
    required super.failureMessage,
  });
}

class FileUploadNetworkFailure extends FileUploadFailure {
  FileUploadNetworkFailure({
    super.failureMessage = 'Network error occurred during file upload',
  });
}

class FileUploadServerFailure extends FileUploadFailure {
  FileUploadServerFailure({
    super.failureMessage = 'Server error occurred during file upload',
  });
}

class FileUploadUnknownFailure extends FileUploadFailure {
  FileUploadUnknownFailure({
    super.failureMessage = 'Unknown error occurred during file upload',
  });
}