// Commented out - migrated to BaseState<List<Restaurant>> system
// import '../../../domain/entities/restaurant.dart';
// import '../../../domain/entities/restaurant_food_category.dart';
// 
// abstract class RestaurantState {
//   const RestaurantState();
// }
// 
// class RestaurantInitial extends RestaurantState {}
// 
// class RestaurantLoading extends RestaurantState {}
// 
// class RestaurantsLoaded extends RestaurantState {
//   final List<Restaurant> restaurants;
// 
//   const RestaurantsLoaded(this.restaurants);
// }
// 
// class RestaurantLoaded extends RestaurantState {
//   final Restaurant restaurant;
// 
//   const RestaurantLoaded(this.restaurant);
// }
// 
// class RestaurantMenuLoaded extends RestaurantState {
//   final List<RestaurantFoodCategory> categories;
// 
//   const RestaurantMenuLoaded(this.categories);
// }
// 
// class RestaurantError extends RestaurantState {
//   final String message;
// 
//   const RestaurantError(this.message);
// }
