import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/utils/logger.dart';

import '../../../domain/entities/cart_entity.dart';
import '../../../domain/use_cases/cart_usecase.dart';
import 'cart_event.dart';

class CartCubit extends Bloc<CartEvent, BaseState<CartEntity>> {
  final CartUseCase _cartUseCase = CartUseCase();
  late StreamSubscription _cartStreamSubscription;

  CartCubit() : super(const LoadingState<CartEntity>()) {
    // Register event handlers
    on<CartStreamStartedEvent>(_onCartStreamStarted);
    on<CartAddFoodEvent>(_onCartAddFood);
    on<CartRemoveFoodEvent>(_onCartRemoveFood);
    on<CartUpdateQuantityEvent>(_onCartUpdateQuantity);
    on<CartClearEvent>(_onCartClear);
    on<CartStreamUpdatedEvent>(_onCartStreamUpdated);

    // Start listening to cart stream immediately
    add(const CartStreamStartedEvent());
  }

  /// Start listening to Firebase cart stream
  Future<void> _onCartStreamStarted(
    CartStreamStartedEvent event,
    Emitter<BaseState<CartEntity>> emit,
  ) async {
    emit(const LoadingState<CartEntity>());

    _cartStreamSubscription = _cartUseCase.getCartStream().listen(
      (result) {
        add(CartStreamUpdatedEvent(cartData: result));
      },
      onError: (error) {
        Logger.logError('Cart stream error: $error');
        emit(
          ErrorState<CartEntity>(errorMessage: 'Failed to load cart: $error'),
        );
      },
    );
  }

  /// Handle cart stream updates
  Future<void> _onCartStreamUpdated(
    CartStreamUpdatedEvent event,
    Emitter<BaseState<CartEntity>> emit,
  ) async {
    final result = event.cartData;
    result.fold(
      (failure) =>
          emit(ErrorState<CartEntity>(errorMessage: failure.failureMessage)),
      (cartEntity) {
        if (cartEntity.isEmpty) {
          emit(const EmptyState<CartEntity>(message: 'Cart is empty'));
        } else {
          emit(
            LoadedState<CartEntity>(
              data: cartEntity,
              lastUpdated: DateTime.now(),
            ),
          );
        }
      },
    );
  }

  /// Add food to cart
  Future<void> _onCartAddFood(
    CartAddFoodEvent event,
    Emitter<BaseState<CartEntity>> emit,
  ) async {
    final result = await _cartUseCase.addFoodToCart(event.food);
    result.fold(
      (failure) {
        Logger.logError(
          'Failed to add food to cart: ${failure.failureMessage}',
        );
        // Don't emit error state here, let the stream handle updates
      },
      (_) {
        Logger.logSuccess('Food ${event.food.name} added to cart successfully');
        // Firebase stream will automatically update the UI
      },
    );
  }

  /// Remove food from cart (decrease quantity by 1)
  Future<void> _onCartRemoveFood(
    CartRemoveFoodEvent event,
    Emitter<BaseState<CartEntity>> emit,
  ) async {
    final result = await _cartUseCase.removeFoodFromCart(event.foodId);
    result.fold(
      (failure) {
        Logger.logError(
          'Failed to remove food from cart: ${failure.failureMessage}',
        );
      },
      (_) {
        Logger.logSuccess('Food removed from cart successfully');
        // Firebase stream will automatically update the UI
      },
    );
  }

  /// Update food quantity
  Future<void> _onCartUpdateQuantity(
    CartUpdateQuantityEvent event,
    Emitter<BaseState<CartEntity>> emit,
  ) async {
    final result = await _cartUseCase.updateFoodQuantity(
      event.foodId,
      event.quantity,
    );
    result.fold(
      (failure) {
        Logger.logError('Failed to update quantity: ${failure.failureMessage}');
      },
      (_) {
        Logger.logSuccess('Quantity updated successfully');
        // Firebase stream will automatically update the UI
      },
    );
  }

  /// Clear cart
  Future<void> _onCartClear(
    CartClearEvent event,
    Emitter<BaseState<CartEntity>> emit,
  ) async {
    final result = await _cartUseCase.clearCart();
    result.fold(
      (failure) {
        Logger.logError('Failed to clear cart: ${failure.failureMessage}');
      },
      (_) {
        Logger.logSuccess('Cart cleared successfully');
        // Firebase stream will automatically update the UI
      },
    );
  }

  /// Get current cart data
  CartEntity? get cartData => state.hasData ? state.data : null;

  /// Check if cart is empty
  bool get isEmpty => cartData?.isEmpty ?? true;

  /// Get total price
  double get totalPrice => cartData?.totalPrice ?? 0.0;

  /// Get item count
  int get itemCount => cartData?.itemCount ?? 0;

  @override
  Future<void> close() {
    _cartStreamSubscription.cancel();
    return super.close();
  }
}
