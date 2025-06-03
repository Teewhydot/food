import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../home/domain/entities/food.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitial());
  final int _itemCount = 0;
  int get itemCount => _itemCount;
  double _totalPrice = 0.0;
  final List<FoodEntity> _cartItems = [];
  List<FoodEntity> get cartItems => _cartItems;
  double get totalPrice => _totalPrice;

  void addFood(FoodEntity food) {
    _totalPrice += (food.price * food.quantity);
    _cartItems.add(food);
  }

  void removeFood(FoodEntity food) {
    _totalPrice -= (food.price * food.quantity);
    _cartItems.remove(food);
  }
}
