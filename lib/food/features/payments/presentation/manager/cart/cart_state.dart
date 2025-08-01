part of 'cart_cubit.dart';

@immutable
abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<FoodEntity> items;
  final double totalPrice;
  final int itemCount;

  CartLoaded({
    required this.items,
    required this.totalPrice,
    required this.itemCount,
  });
}

class CartError extends CartState implements AppErrorState {
  @override
  final String errorMessage;

  CartError({required this.errorMessage});
}
