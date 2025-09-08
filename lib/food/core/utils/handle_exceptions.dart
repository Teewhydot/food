import 'package:dartz/dartz.dart';

import '../../domain/failures/failures.dart';
import 'error_handler.dart';

Future<Either<Failure, T>> handleExceptions<T>(
  Future<T> Function() function,
) async {
  return ErrorHandler.handle(function);
}
