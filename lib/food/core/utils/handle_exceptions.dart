import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/exceptions/custom_exceptions.dart';
import '../../domain/failures/failures.dart';

Future<Either<Failure, T>> handleExceptions<T>(
  Future<T> Function() function,
) async {
  try {
    final result = await function();
    return Right(result);
  } on ServerException catch (_) {
    return Left(ServerFailure(failureMessage: 'Server Failure'));
  } on TimeoutException catch (_) {
    return Left(TimeoutFailure(failureMessage: 'Request Timed Out'));
  } on SocketException catch (_) {
    return Left(NoInternetFailure(failureMessage: 'No Internet'));
  } on UnknownException catch (e) {
    return Left(UnknownFailure(failureMessage: e.toString()));
  } on FirebaseAuthException catch (e) {
    return Left(UnknownFailure(failureMessage: e.code));
  } catch (e) {
    return Left(UnknownFailure(failureMessage: e.toString()));
  }
}
