import 'package:bloc/bloc.dart';
import 'package:food/food/core/utils/logger.dart';
import 'package:meta/meta.dart';

import '../../../../home/domain/entities/food.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartLoaded(items: [], totalPrice: 0.0, itemCount: 0));

  void addFood(FoodEntity food) {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      final newItems = List<FoodEntity>.from(currentState.items);
      final index = newItems.indexWhere((item) => item.id == food.id);
      // First deduct the current total of that particular food from currentState.price
      final totalPriceMinusCurrentFoodTotalPrice =
          currentState.totalPrice - (food.price * food.quantity);
      if (index != -1) {
        // If the food item already exists, update its quantity
        newItems[index].quantity += 1;

        Logger.logBasic(
          "Current total price: ${currentState.totalPrice} Food price: ${food.price}, "
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
        emit(
          CartLoaded(
            items: newItems,
            totalPrice: newTotalPrice,
            itemCount: currentState.itemCount,
          ),
        );
        Logger.logSuccess(
          "Food item ${food.name} updated in cart. Current total Price: ${currentState.totalPrice}  New total price: $newTotalPrice",
        );
        Logger.logSuccess(
          "Food item ${food.name} updated in cart. New quantity: ${newItems[index].quantity}  New total price: $newTotalPrice",
        );
      } else {
        double newTotalPrice =
            currentState.totalPrice + (food.price * food.quantity);
        int newItemCount = currentState.itemCount + 1;
        newItems.add(food);
        emit(
          CartLoaded(
            items: newItems,
            totalPrice: newTotalPrice,
            itemCount: newItemCount,
          ),
        );
        Logger.logSuccess(
          "Food item ${food.name} updated in cart. Current total Price: ${currentState.totalPrice}  New total price: $newTotalPrice",
        );
        Logger.logSuccess(
          "Food item ${food.name} added to cart. Total items: $newItemCount  Price per item: ${food.price}  Total price: $newTotalPrice",
        );
      }
    }
  }

  void removeFood(FoodEntity food) {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      final newItems = List<FoodEntity>.from(currentState.items);
      final index = newItems.indexWhere((item) => item.id == food.id);

      if (index != -1) {
        final existingFood = newItems[index];
        if (existingFood.quantity > 1) {
          // Decrease quantity
          newItems[index].quantity -= 1;
          double newTotalPrice = currentState.totalPrice - existingFood.price;
          emit(
            CartLoaded(
              items: newItems,
              totalPrice: newTotalPrice,
              itemCount: currentState.itemCount,
            ),
          );
        } else {
          // Remove item completely
          double newTotalPrice = currentState.totalPrice - existingFood.price;
          newItems.removeAt(index);
          int newItemCount = currentState.itemCount - 1;
          emit(
            CartLoaded(
              items: newItems,
              totalPrice: newTotalPrice,
              itemCount: newItemCount,
            ),
          );
        }
      }
    }
  }
}
