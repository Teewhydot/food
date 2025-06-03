import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../home/domain/entities/food.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartLoaded(items: [], totalPrice: 0.0, itemCount: 0));

  void addFood(FoodEntity food) {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      final newItems = List<FoodEntity>.from(currentState.items);
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
    }
  }

  void removeFood(FoodEntity food) {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      final newItems = List<FoodEntity>.from(currentState.items);
      double newTotalPrice =
          currentState.totalPrice - (food.price * food.quantity);
      int newItemCount = currentState.itemCount - 1;

      newItems.remove(food);

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
