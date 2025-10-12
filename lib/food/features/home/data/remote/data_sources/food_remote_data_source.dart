import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food/food/core/network/dio_client.dart';
import 'package:food/food/core/utils/logger.dart';

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

class GolangFoodRemoteDataSource implements FoodRemoteDataSource {
  final _dioClient = DioClient();

  FoodEntity _parseFood(Map<String, dynamic> data) {
    return FoodEntity(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      rating: (data['rating'] ?? 0).toDouble(),
      imageUrl: data['image_url'] ?? '',
      category: data['category'] ?? '',
      restaurantId: data['restaurant_id'] ?? '',
      restaurantName: data['restaurant_name'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      isAvailable: data['is_available'] ?? true,
      preparationTime: data['prep_time'] ?? '',
      calories: (data['calories'] ?? 0) as int,
      quantity: (data['quantity'] ?? 1) as int,
      isVegetarian: data['is_vegetarian'] ?? false,
      isVegan: data['is_vegan'] ?? false,
      isGlutenFree: data['is_gluten_free'] ?? false,
      lastUpdated: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<FoodEntity>> getAllFoods() async {
    Logger.logBasic('GolangFoodRemoteDataSource.getAllFoods() called');
    Logger.logBasic('Making GET request to /api/v1/foods');
    final res = await _dioClient.get(
      "/api/v1/foods",
      queryParameters: {"limit": 100, "offset": 0},
    );
    Logger.logBasic('GET request successful, parsing response');
    final data = res.data['data'] as List;
    final foods = data.map((item) => _parseFood(item)).toList();
    Logger.logSuccess('Parsed ${foods.length} foods');
    return foods;
  }

  @override
  Future<FoodEntity> getFoodById(String id) async {
    Logger.logBasic('GolangFoodRemoteDataSource.getFoodById() called');
    Logger.logBasic('Making GET request to /api/v1/foods/$id');
    final res = await _dioClient.get("/api/v1/foods/$id");
    Logger.logBasic('GET request successful, parsing response');
    final food = _parseFood(res.data);
    Logger.logSuccess('Food parsed successfully');
    return food;
  }

  @override
  Future<List<FoodEntity>> getPopularFoods() async {
    Logger.logBasic('GolangFoodRemoteDataSource.getPopularFoods() called');
    Logger.logBasic('Making GET request to /api/v1/foods/popular');
    final res = await _dioClient.get(
      "/api/v1/foods/popular",
      queryParameters: {"limit": 10},
    );
    Logger.logBasic('GET request successful, parsing response');
    final data = res.data as List;
    final foods = data.map((item) => _parseFood(item)).toList();
    Logger.logSuccess('Parsed ${foods.length} popular foods');
    return foods;
  }

  @override
  Future<List<FoodEntity>> getRecommendedFoods() async {
    Logger.logBasic('GolangFoodRemoteDataSource.getRecommendedFoods() called');
    Logger.logBasic('Making GET request to /api/v1/foods/recommended');
    final res = await _dioClient.get(
      "/api/v1/foods/recommended",
      queryParameters: {"limit": 10},
    );
    Logger.logBasic('GET request successful, parsing response');
    final data = res.data as List;
    final foods = data.map((item) => _parseFood(item)).toList();
    Logger.logSuccess('Parsed ${foods.length} recommended foods');
    return foods;
  }

  @override
  Future<List<FoodEntity>> getFoodsByCategory(String category) async {
    Logger.logBasic('GolangFoodRemoteDataSource.getFoodsByCategory() called');
    Logger.logBasic('Making GET request to /api/v1/foods/category/$category');
    final res = await _dioClient.get(
      "/api/v1/foods/category/$category",
      queryParameters: {"limit": 50},
    );
    Logger.logBasic('GET request successful, parsing response');
    final data = res.data['data'] as List;
    final foods = data.map((item) => _parseFood(item)).toList();
    Logger.logSuccess('Parsed ${foods.length} foods in category');
    return foods;
  }

  @override
  Future<List<FoodEntity>> getFoodsByRestaurant(String restaurantId) async {
    Logger.logBasic('GolangFoodRemoteDataSource.getFoodsByRestaurant() called');
    Logger.logBasic('Making GET request to /api/v1/foods/restaurant/$restaurantId');
    final res = await _dioClient.get(
      "/api/v1/foods/restaurant/$restaurantId",
      queryParameters: {"limit": 50},
    );
    Logger.logBasic('GET request successful, parsing response');
    final data = res.data['data'] as List;
    final foods = data.map((item) => _parseFood(item)).toList();
    Logger.logSuccess('Parsed ${foods.length} foods for restaurant');
    return foods;
  }

  @override
  Future<List<FoodEntity>> searchFoods(String query) async {
    Logger.logBasic('GolangFoodRemoteDataSource.searchFoods() called');
    Logger.logBasic('Making GET request to /api/v1/foods/search');
    final res = await _dioClient.get(
      "/api/v1/foods/search",
      queryParameters: {"query": query, "limit": 50},
    );
    Logger.logBasic('GET request successful, parsing response');
    final data = res.data['data'] as List;
    final foods = data.map((item) => _parseFood(item)).toList();
    Logger.logSuccess('Parsed ${foods.length} food search results');
    return foods;
  }
}
