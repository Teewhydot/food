import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/domain/failures/failures.dart';

import '../../../domain/entities/order_entity.dart';
import '../../../domain/use_cases/order_usecase.dart';
import 'order_event.dart';
// import 'order_state.dart'; // Commented out - using BaseState now

/// Migrated OrderBloc to use BaseState<dynamic>
class OrderBloc extends BaseBloC<OrderEvent, BaseState<dynamic>> {
  OrderBloc() : super(const InitialState<dynamic>());
  final orderUseCase = OrderUseCase();

  Stream<Either<Failure, List<OrderEntity>>> streamUserOrders(
    String userId,
  ) async* {
    yield* orderUseCase.streamUserOrders(userId);
  }
}
