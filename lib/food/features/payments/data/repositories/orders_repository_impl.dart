import 'package:dartz/dartz.dart';
import 'package:food/food/core/utils/handle_exceptions.dart';
import 'package:food/food/domain/failures/failures.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/utils/error_handler.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../remote/data_sources/order_remote_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final orderDataSource = GetIt.instance<OrderRemoteDataSource>();

  @override
  Stream<Either<Failure, List<OrderEntity>>> streamUserOrders(String userId) {
    return ErrorHandler.handleStream(
      () => orderDataSource.streamUserOrders(userId),
      operationName: 'watchUserOrders',
    );
  }

  @override
  Stream<Either<Failure, OrderEntity?>> streamOrderById(String orderId) {
    return ErrorHandler.handleStream(
      () => orderDataSource.streamOrderById(orderId),
      operationName: 'streamOrderById',
    );
  }

  @override
  Future<Either<Failure, void>> cancelOrder(String orderId) {
    return handleExceptions(() async {
      await orderDataSource.cancelOrder(orderId);
    });
  }
}
