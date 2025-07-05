import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/entities/food.dart';

abstract class FoodRemoteDataSource {
  Future<List<FoodEntity>> getAllFoods();
  Future<List<FoodEntity>> getPopularFoods();
  Future<List<FoodEntity>> getFoodsByCategory(String category);
  Future<FoodEntity> getFoodById(String id);
  Future<List<FoodEntity>> searchFoods(String query);
  Future<List<FoodEntity>> getFoodsByRestaurant(String restaurantId);
  Future<List<FoodEntity>> getRecommendedFoods();
}

class FirebaseFoodRemoteDataSource implements FoodRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<FoodEntity>> getAllFoods() async {
    final snapshot =
        await _firestore
            .collection('foods')
            .orderBy('createdAt', descending: true)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return FoodEntity(
        id: doc.id,
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        price: data['price']?.toDouble() ?? 0.0,
        rating: data['rating']?.toDouble() ?? 0.0,
        imageUrl: data['imageUrl'] ?? '',
        category: data['category'] ?? '',
        restaurantId: data['restaurantId'] ?? '',
        restaurantName: data['restaurantName'] ?? '',
        ingredients: List<String>.from(data['ingredients'] ?? []),
        isAvailable: data['isAvailable'] ?? true,
        preparationTime: data['preparationTime'] ?? '',
        calories: data['calories']?.toInt() ?? 0,
        quantity: data['quantity']?.toInt() ?? 0,
        isVegetarian: data['isVegetarian'] ?? false,
        isVegan: data['isVegan'] ?? false,
        isGlutenFree: data['isGlutenFree'] ?? false,
        lastUpdated: 1,
      );
    }).toList();
  }

  @override
  Future<List<FoodEntity>> getPopularFoods() async {
    final snapshot =
        await _firestore
            .collection('foods')
            .where('rating', isGreaterThanOrEqualTo: 4.0)
            .orderBy('rating', descending: true)
            .limit(10)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return FoodEntity(
        id: doc.id,
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        price: data['price']?.toDouble() ?? 0.0,
        rating: data['rating']?.toDouble() ?? 0.0,
        imageUrl: data['imageUrl'] ?? '',
        category: data['category'] ?? '',
        restaurantId: data['restaurantId'] ?? '',
        restaurantName: data['restaurantName'] ?? '',
        ingredients: List<String>.from(data['ingredients'] ?? []),
        isAvailable: data['isAvailable'] ?? true,
        preparationTime: data['preparationTime'] ?? '',
        calories: data['calories']?.toInt() ?? 0,
        isVegetarian: data['isVegetarian'] ?? false,
        isVegan: data['isVegan'] ?? false,
        isGlutenFree: data['isGlutenFree'] ?? false,
        quantity: data['quantity'] ?? 0,
        lastUpdated: 1,
      );
    }).toList();
  }

  @override
  Future<List<FoodEntity>> getFoodsByCategory(String category) async {
    final snapshot =
        await _firestore
            .collection('foods')
            .where('category', isEqualTo: category)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return FoodEntity(
        id: doc.id,
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        price: data['price']?.toDouble() ?? 0.0,
        rating: data['rating']?.toDouble() ?? 0.0,
        imageUrl: data['imageUrl'] ?? '',
        category: data['category'] ?? '',
        restaurantId: data['restaurantId'] ?? '',
        restaurantName: data['restaurantName'] ?? '',
        ingredients: List<String>.from(data['ingredients'] ?? []),
        isAvailable: data['isAvailable'] ?? true,
        preparationTime: data['preparationTime'] ?? '',
        calories: data['calories']?.toInt() ?? 0,
        isVegetarian: data['isVegetarian'] ?? false,
        isVegan: data['isVegan'] ?? false,
        quantity: data['quantity'] ?? 0,
        isGlutenFree: data['isGlutenFree'] ?? false,
        lastUpdated: 1,
      );
    }).toList();
  }

  @override
  Future<FoodEntity> getFoodById(String id) async {
    final doc = await _firestore.collection('foods').doc(id).get();

    if (!doc.exists) {
      throw Exception('Food not found');
    }

    final data = doc.data()!;
    return FoodEntity(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: data['price']?.toDouble() ?? 0.0,
      rating: data['rating']?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      restaurantId: data['restaurantId'] ?? '',
      restaurantName: data['restaurantName'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      isAvailable: data['isAvailable'] ?? true,
      preparationTime: data['preparationTime'] ?? '',
      calories: data['calories']?.toInt() ?? 0,
      quantity: data['quantity'] ?? 0,
      isVegetarian: data['isVegetarian'] ?? false,
      isVegan: data['isVegan'] ?? false,
      isGlutenFree: data['isGlutenFree'] ?? false,
      lastUpdated: 1,
    );
  }

  @override
  Future<List<FoodEntity>> searchFoods(String query) async {
    final lowercaseQuery = query.toLowerCase();
    final snapshot = await _firestore.collection('foods').orderBy('name').get();

    return snapshot.docs
        .where((doc) {
          final data = doc.data();
          final name = (data['name'] ?? '').toString().toLowerCase();
          final category = (data['category'] ?? '').toString().toLowerCase();
          final description =
              (data['description'] ?? '').toString().toLowerCase();
          final restaurantName =
              (data['restaurantName'] ?? '').toString().toLowerCase();

          return name.contains(lowercaseQuery) ||
              category.contains(lowercaseQuery) ||
              description.contains(lowercaseQuery) ||
              restaurantName.contains(lowercaseQuery);
        })
        .map((doc) {
          final data = doc.data();
          return FoodEntity(
            id: doc.id,
            name: data['name'] ?? '',
            description: data['description'] ?? '',
            price: data['price']?.toDouble() ?? 0.0,
            rating: data['rating']?.toDouble() ?? 0.0,
            imageUrl: data['imageUrl'] ?? '',
            category: data['category'] ?? '',
            restaurantId: data['restaurantId'] ?? '',
            restaurantName: data['restaurantName'] ?? '',
            ingredients: List<String>.from(data['ingredients'] ?? []),
            isAvailable: data['isAvailable'] ?? true,
            preparationTime: data['preparationTime'] ?? '',
            calories: data['calories']?.toInt() ?? 0,
            quantity: data['quantity'] ?? 0,
            isVegetarian: data['isVegetarian'] ?? false,
            isVegan: data['isVegan'] ?? false,
            isGlutenFree: data['isGlutenFree'] ?? false,
            lastUpdated: 1,
          );
        })
        .toList();
  }

  @override
  Future<List<FoodEntity>> getFoodsByRestaurant(String restaurantId) async {
    final snapshot =
        await _firestore
            .collection('foods')
            .where('restaurantId', isEqualTo: restaurantId)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return FoodEntity(
        id: doc.id,
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        price: data['price']?.toDouble() ?? 0.0,
        rating: data['rating']?.toDouble() ?? 0.0,
        imageUrl: data['imageUrl'] ?? '',
        category: data['category'] ?? '',
        restaurantId: data['restaurantId'] ?? '',
        restaurantName: data['restaurantName'] ?? '',
        ingredients: List<String>.from(data['ingredients'] ?? []),
        isAvailable: data['isAvailable'] ?? true,
        preparationTime: data['preparationTime'] ?? '',
        calories: data['calories']?.toInt() ?? 0,
        quantity: data['quantity'] ?? 0,
        isVegetarian: data['isVegetarian'] ?? false,
        isVegan: data['isVegan'] ?? false,
        isGlutenFree: data['isGlutenFree'] ?? false,
        lastUpdated: 1,
      );
    }).toList();
  }

  @override
  Future<List<FoodEntity>> getRecommendedFoods() async {
    // For now, we'll return popular foods as recommendations
    // In production, this would use user preferences, order history, etc.
    final snapshot =
        await _firestore
            .collection('foods')
            .where('rating', isGreaterThanOrEqualTo: 4.5)
            .orderBy('rating', descending: true)
            .limit(6)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return FoodEntity(
        id: doc.id,
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        price: data['price']?.toDouble() ?? 0.0,
        rating: data['rating']?.toDouble() ?? 0.0,
        imageUrl: data['imageUrl'] ?? '',
        category: data['category'] ?? '',
        restaurantId: data['restaurantId'] ?? '',
        restaurantName: data['restaurantName'] ?? '',
        ingredients: List<String>.from(data['ingredients'] ?? []),
        isAvailable: data['isAvailable'] ?? true,
        preparationTime: data['preparationTime'] ?? '',
        calories: data['calories']?.toInt() ?? 0,
        quantity: data['quantity'] ?? 0,
        isVegetarian: data['isVegetarian'] ?? false,
        isVegan: data['isVegan'] ?? false,
        isGlutenFree: data['isGlutenFree'] ?? false,
        lastUpdated: 1,
      );
    }).toList();
  }
}
