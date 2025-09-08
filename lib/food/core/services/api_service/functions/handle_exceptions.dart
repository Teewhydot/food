import 'package:dartz/dartz.dart';
import '../../../../domain/failures/failures.dart';
import '../../../utils/error_handler.dart';

/// Legacy function - use ErrorHandler.handle() instead
@Deprecated('Use ErrorHandler.handle() instead')
Future<Either<Failure, T>> runAndHandleExceptions<T>(
  Future<T> Function() function,
) async {
  return ErrorHandler.handle(function);
}
