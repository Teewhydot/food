import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/utils/logger.dart';

import '../../../domain/entities/cart_entity.dart';
import '../../../../home/domain/entities/food.dart';

part 'cart_state.dart';

/// Migrated CartCubit to use BaseState<CartEntity>
class CartCubit extends BaseCubit<BaseState<CartEntity>> {
  CartCubit() : super(
    LoadedState<CartEntity>(
      data: const CartEntity(items: [], totalPrice: 0.0, itemCount: 0),
      lastUpdated: DateTime.now(),
    ),
  );

  void addFood(FoodEntity food) {
    if (state.hasData) {
      final currentCart = state.data!;
      final newItems = List<FoodEntity>.from(currentCart.items);
      final index = newItems.indexWhere((item) => item.id == food.id);
      // First deduct the current total of that particular food from currentState.price
      final totalPriceMinusCurrentFoodTotalPrice =
          currentCart.totalPrice - (food.price * food.quantity);
      if (index != -1) {
        // If the food item already exists, update its quantity
        newItems[index].quantity += 1;

        Logger.logBasic(
          "Current total price: ${currentCart.totalPrice} Food price: ${food.price}, "
          "Food quantity: ${food.quantity}, "
          "Total price minus current food total price: $totalPriceMinusCurrentFoodTotalPrice",
        );
        // The  totalPriceMinusCurrentFoodTotalPrice is the total price
        // of all foods in the cart minus the total price of the food that will be increased
        // in quantity.
        // Next i calculate the new total price of all foods by adding the sum above totalPriceMinusCurrentFoodTotalPrice to the
        // total price of the food that
        // will be increased in quantity.
        double newTotalPrice =
            totalPriceMinusCurrentFoodTotalPrice +
            (food.price * newItems[index].quantity);
        
        final newCart = CartEntity(
          items: newItems,
          totalPrice: newTotalPrice,
          itemCount: currentCart.itemCount,
        );
        
        emit(
          LoadedState<CartEntity>(
            data: newCart,
            lastUpdated: DateTime.now(),
          ),
        );
        
        Logger.logSuccess(
          "Food item ${food.name} updated in cart. Current total Price: ${currentCart.totalPrice}  New total price: $newTotalPrice",
        );
        Logger.logSuccess(
          "Food item ${food.name} updated in cart. New quantity: ${newItems[index].quantity}  New total price: $newTotalPrice",
        );
      } else {
        double newTotalPrice =
            currentCart.totalPrice + (food.price * food.quantity);
        int newItemCount = currentCart.itemCount + 1;
        newItems.add(food);
        
        final newCart = CartEntity(
          items: newItems,
          totalPrice: newTotalPrice,
          itemCount: newItemCount,
        );
        
        emit(
          LoadedState<CartEntity>(
            data: newCart,
            lastUpdated: DateTime.now(),
          ),
        );
        
        Logger.logSuccess(
          "Food item ${food.name} updated in cart. Current total Price: ${currentCart.totalPrice}  New total price: $newTotalPrice",
        );
        Logger.logSuccess(
          "Food item ${food.name} added to cart. Total items: $newItemCount  Price per item: ${food.price}  Total price: $newTotalPrice",
        );
      }
    }
  }

  void removeFood(FoodEntity food) {
    if (state.hasData) {
      final currentCart = state.data!;
      final newItems = List<FoodEntity>.from(currentCart.items);
      final index = newItems.indexWhere((item) => item.id == food.id);

      if (index != -1) {
        final existingFood = newItems[index];
        if (existingFood.quantity > 1) {
          // Decrease quantity
          newItems[index].quantity -= 1;
          double newTotalPrice = currentCart.totalPrice - existingFood.price;
          
          final newCart = CartEntity(
            items: newItems,
            totalPrice: newTotalPrice,
            itemCount: currentCart.itemCount,
          );
          
          emit(
            LoadedState<CartEntity>(
              data: newCart,
              lastUpdated: DateTime.now(),
            ),
          );
        } else {
          // Remove item completely
          double newTotalPrice = currentCart.totalPrice - existingFood.price;
          newItems.removeAt(index);
          int newItemCount = currentCart.itemCount - 1;
          
          final newCart = CartEntity(
            items: newItems,
            totalPrice: newTotalPrice,
            itemCount: newItemCount,
          );
          
          if (newCart.isEmpty) {
            emit(const EmptyState<CartEntity>(message: 'Cart is empty'));
          } else {
            emit(
              LoadedState<CartEntity>(
                data: newCart,
                lastUpdated: DateTime.now(),
              ),
            );
          }
        }
      }
    }
  }
  
  /// Clear all items from cart
  void clearCart() {
    emit(
      LoadedState<CartEntity>(
        data: const CartEntity(items: [], totalPrice: 0.0, itemCount: 0),
        lastUpdated: DateTime.now(),
      ),
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
}
