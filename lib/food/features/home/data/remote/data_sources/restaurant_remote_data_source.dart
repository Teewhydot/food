import 'dart:math' show asin, cos, sqrt, sin, pi;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food/food/core/network/dio_client.dart';
import 'package:food/food/core/utils/logger.dart';

import '../../../domain/entities/food.dart';
import '../../../domain/entities/restaurant.dart';
import '../../../domain/entities/restaurant_food_category.dart';

abstract class RestaurantRemoteDataSource {
  Future<List<Restaurant>> getRestaurants();
  Future<List<Restaurant>> getNearbyRestaurants(
    double latitude,
    double longitude,
  );
  Future<List<Restaurant>> getPopularRestaurants();
  Future<Restaurant> getRestaurantById(String id);
  Future<List<Restaurant>> searchRestaurants(String query);
  Future<List<RestaurantFoodCategory>> getRestaurantMenu(String restaurantId);
  Future<List<Restaurant>> getRestaurantsByCategory(String category);
}

class FirebaseRestaurantRemoteDataSource implements RestaurantRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Helper method to parse category data from Firebase
  /// Since Firebase stores category as a simple String like "Fast Food",
  /// we create a RestaurantFoodCategory object from it
  List<RestaurantFoodCategory> _parseCategories(dynamic categoryData) {
    if (categoryData == null) return [];
    
    if (categoryData is String && categoryData.isNotEmpty) {
      // Create a simple category with just the name
      return [RestaurantFoodCategory(category: categoryData, imageUrl: '', foods: [])];
    }
    
    if (categoryData is List) {
      return categoryData
          .map((item) {
            if (item is String && item.isNotEmpty) {
              return RestaurantFoodCategory(category: item, imageUrl: '', foods: []);
            } else if (item is Map<String, dynamic>) {
              return RestaurantFoodCategory(
                category: item['category'] ?? '',
                imageUrl: item['imageUrl'] ?? '',
                foods: item['foods'] != null && item['foods'] is List
                    ? (item['foods'] as List)
                        .map((food) => food is Map<String, dynamic> 
                            ? FoodEntity.fromMap(food) 
                            : null)
                        .where((food) => food != null)
                        .cast<FoodEntity>()
                        .toList()
                    : [],
              );
            }
            return null;
          })
          .where((cat) => cat != null)
          .cast<RestaurantFoodCategory>()
          .toList();
    }
    
    return [];
  }

  @override
  Future<List<Restaurant>> getRestaurants() async {
    final snapshot =
        await _firestore
            .collection('restaurants')
            .orderBy('createdAt', descending: true)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Restaurant(
        id: doc.id,
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        location: data['location'] ?? '',
        distance: data['distance']?.toDouble() ?? 0.0,
        rating: data['rating']?.toDouble() ?? 0.0,
        deliveryTime: data['deliveryTime'] ?? '',
        deliveryFee: data['deliveryFee']?.toDouble() ?? 0.0,
        imageUrl: data['imageUrl'] ?? '',
        category: _parseCategories(data['categories']),
        isOpen: data['isOpen'] ?? true,
        latitude: data['latitude']?.toDouble() ?? 0.0,
        longitude: data['longitude']?.toDouble() ?? 0.0,
        lastUpdated: 1,
      );
    }).toList();
  }

  @override
  Future<List<Restaurant>> getNearbyRestaurants(
    double latitude,
    double longitude,
  ) async {
    // For simplicity, we'll get all restaurants and filter by distance
    // In production, you'd use geoqueries or a dedicated service
    final restaurants = await getRestaurants();

    // Filter restaurants within 10km radius
    return restaurants.where((restaurant) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          restaurant.latitude,
          restaurant.longitude,
        );
        return distance <= 10.0;
      }).toList()
      ..sort((a, b) => a.distance.compareTo(b.distance));
  }

  @override
  Future<List<Restaurant>> getPopularRestaurants() async {
    final snapshot =
        await _firestore
            .collection('restaurants')
            .where('rating', isGreaterThanOrEqualTo: 4.0)
            .orderBy('rating', descending: true)
            .limit(10)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Restaurant(
        id: doc.id,
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        location: data['location'] ?? '',
        distance: data['distance']?.toDouble() ?? 0.0,
        rating: data['rating']?.toDouble() ?? 0.0,
        deliveryTime: data['deliveryTime'] ?? '',
        deliveryFee: data['deliveryFee']?.toDouble() ?? 0.0,
        imageUrl: data['imageUrl'] ?? '',
        category: _parseCategories(data['categories']),
        isOpen: data['isOpen'] ?? true,
        latitude: data['latitude']?.toDouble() ?? 0.0,
        longitude: data['longitude']?.toDouble() ?? 0.0,
        lastUpdated: 1,
      );
    }).toList();
  }

  @override
  Future<Restaurant> getRestaurantById(String id) async {
    final doc = await _firestore.collection('restaurants').doc(id).get();

    if (!doc.exists) {
      throw Exception('Restaurant not found');
    }

    final data = doc.data()!;
    return Restaurant(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      distance: data['distance']?.toDouble() ?? 0.0,
      rating: data['rating']?.toDouble() ?? 0.0,
      deliveryTime: data['deliveryTime'] ?? '',
      deliveryFee: data['deliveryFee']?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      isOpen: data['isOpen'] ?? true,
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      lastUpdated: 1,
    );
  }

  @override
  Future<List<Restaurant>> searchRestaurants(String query) async {
    final lowercaseQuery = query.toLowerCase();
    final snapshot =
        await _firestore.collection('restaurants').orderBy('name').get();

    return snapshot.docs
        .where((doc) {
          final data = doc.data();
          final name = (data['name'] ?? '').toString().toLowerCase();
          final category = (data['category'] ?? '').toString().toLowerCase();
          final description =
              (data['description'] ?? '').toString().toLowerCase();

          return name.contains(lowercaseQuery) ||
              category.contains(lowercaseQuery) ||
              description.contains(lowercaseQuery);
        })
        .map((doc) {
          final data = doc.data();
          return Restaurant(
            id: doc.id,
            name: data['name'] ?? '',
            description: data['description'] ?? '',
            location: data['location'] ?? '',
            distance: data['distance']?.toDouble() ?? 0.0,
            rating: data['rating']?.toDouble() ?? 0.0,
            deliveryTime: data['deliveryTime'] ?? '',
            deliveryFee: data['deliveryFee']?.toDouble() ?? 0.0,
            imageUrl: data['imageUrl'] ?? '',
            category: _parseCategories(data['categories']),
            isOpen: data['isOpen'] ?? true,
            latitude: data['latitude']?.toDouble() ?? 0.0,
            longitude: data['longitude']?.toDouble() ?? 0.0,
            lastUpdated: 1,
          );
        })
        .toList();
  }

  @override
  Future<List<RestaurantFoodCategory>> getRestaurantMenu(
    String restaurantId,
  ) async {
    final snapshot =
        await _firestore
            .collection('restaurants')
            .doc(restaurantId)
            .collection('categories')
            .orderBy('order')
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return RestaurantFoodCategory(
        category: data['category'] ?? '',
        imageUrl: data['imageUrl'] ?? '',
        foods:
            data['foods'] != null && data['foods'] is List
                ? (data['foods'] as List)
                    .map((food) => food is Map<String, dynamic> 
                        ? FoodEntity.fromMap(food) 
                        : null)
                    .where((food) => food != null)
                    .cast<FoodEntity>()
                    .toList()
                : [],
      );
    }).toList();
  }

  @override
  Future<List<Restaurant>> getRestaurantsByCategory(String category) async {
    final snapshot =
        await _firestore
            .collection('restaurants')
            .where('category', isEqualTo: category)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Restaurant(
        id: doc.id,
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        location: data['location'] ?? '',
        distance: data['distance']?.toDouble() ?? 0.0,
        rating: data['rating']?.toDouble() ?? 0.0,
        deliveryTime: data['deliveryTime'] ?? '',
        deliveryFee: data['deliveryFee']?.toDouble() ?? 0.0,
        imageUrl: data['imageUrl'] ?? '',
        category: _parseCategories(data['categories']),
        isOpen: data['isOpen'] ?? true,
        latitude: data['latitude']?.toDouble() ?? 0.0,
        longitude: data['longitude']?.toDouble() ?? 0.0,
        lastUpdated: 1,
      );
    }).toList();
  }

  // Helper method to calculate distance between two coordinates
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }
}

class GolangRestaurantRemoteDataSource implements RestaurantRemoteDataSource {
  final _dioClient = DioClient();

  Restaurant _parseRestaurant(Map<String, dynamic> data) {
    return Restaurant(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      location: data['address'] ?? '',
      distance: (data['distance'] ?? 0).toDouble(),
      rating: (data['rating'] ?? 0).toDouble(),
      deliveryTime: data['delivery_time'] ?? '',
      deliveryFee: (data['delivery_fee'] ?? 0).toDouble(),
      imageUrl: data['image_url'] ?? '',
      category: data['category'] is String
          ? [RestaurantFoodCategory(category: data['category'], imageUrl: '', foods: [])]
          : [],
      isOpen: data['is_open'] ?? true,
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      lastUpdated: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<Restaurant>> getRestaurants() async {
    Logger.logBasic('GolangRestaurantRemoteDataSource.getRestaurants() called');
    Logger.logBasic('Making GET request to /api/v1/restaurants');
    final res = await _dioClient.get(
      "/api/v1/restaurants",
      queryParameters: {"limit": 100, "offset": 0},
    );
    Logger.logBasic('GET request successful, parsing response');
    final data = res.data['data'] as List;
    final restaurants = data.map((item) => _parseRestaurant(item)).toList();
    Logger.logSuccess('Parsed ${restaurants.length} restaurants');
    return restaurants;
  }

  @override
  Future<Restaurant> getRestaurantById(String id) async {
    Logger.logBasic('GolangRestaurantRemoteDataSource.getRestaurantById() called');
    Logger.logBasic('Making GET request to /api/v1/restaurants/$id');
    final res = await _dioClient.get("/api/v1/restaurants/$id");
    Logger.logBasic('GET request successful, parsing response');
    final restaurant = _parseRestaurant(res.data);
    Logger.logSuccess('Restaurant parsed successfully');
    return restaurant;
  }

  @override
  Future<List<Restaurant>> getPopularRestaurants() async {
    Logger.logBasic('GolangRestaurantRemoteDataSource.getPopularRestaurants() called');
    Logger.logBasic('Making GET request to /api/v1/restaurants/popular');
    final res = await _dioClient.get(
      "/api/v1/restaurants/popular",
      queryParameters: {"limit": 10},
    );
    Logger.logBasic('GET request successful, parsing response');
    final data = res.data as List;
    final restaurants = data.map((item) => _parseRestaurant(item)).toList();
    Logger.logSuccess('Parsed ${restaurants.length} popular restaurants');
    return restaurants;
  }

  @override
  Future<List<Restaurant>> getNearbyRestaurants(
    double latitude,
    double longitude,
  ) async {
    Logger.logBasic('GolangRestaurantRemoteDataSource.getNearbyRestaurants() called');
    Logger.logBasic('Making GET request to /api/v1/restaurants/nearby');
    final res = await _dioClient.get(
      "/api/v1/restaurants/nearby",
      queryParameters: {
        "lat": latitude,
        "lng": longitude,
        "radius": 5,
        "limit": 20,
      },
    );
    Logger.logBasic('GET request successful, parsing response');
    final data = res.data as List;
    final restaurants = data.map((item) => _parseRestaurant(item)).toList();
    Logger.logSuccess('Parsed ${restaurants.length} nearby restaurants');
    return restaurants;
  }

  @override
  Future<List<Restaurant>> searchRestaurants(String query) async {
    Logger.logBasic('GolangRestaurantRemoteDataSource.searchRestaurants() called');
    Logger.logBasic('Making GET request to /api/v1/restaurants/search');
    final res = await _dioClient.get(
      "/api/v1/restaurants/search",
      queryParameters: {"query": query, "limit": 50},
    );
    Logger.logBasic('GET request successful, parsing response');
    final data = res.data['data'] as List;
    final restaurants = data.map((item) => _parseRestaurant(item)).toList();
    Logger.logSuccess('Parsed ${restaurants.length} search results');
    return restaurants;
  }

  @override
  Future<List<Restaurant>> getRestaurantsByCategory(String category) async {
    Logger.logBasic('GolangRestaurantRemoteDataSource.getRestaurantsByCategory() called');
    Logger.logBasic('Making GET request to /api/v1/restaurants/category/$category');
    final res = await _dioClient.get(
      "/api/v1/restaurants/category/$category",
      queryParameters: {"limit": 50},
    );
    Logger.logBasic('GET request successful, parsing response');
    final data = res.data['data'] as List;
    final restaurants = data.map((item) => _parseRestaurant(item)).toList();
    Logger.logSuccess('Parsed ${restaurants.length} restaurants in category');
    return restaurants;
  }

  @override
  Future<List<RestaurantFoodCategory>> getRestaurantMenu(
    String restaurantId,
  ) async {
    Logger.logBasic('GolangRestaurantRemoteDataSource.getRestaurantMenu() called');
    Logger.logBasic('Making GET request to /api/v1/restaurants/$restaurantId/menu');
    final res = await _dioClient.get("/api/v1/restaurants/$restaurantId/menu");
    Logger.logBasic('GET request successful, parsing response');
    final data = res.data as List;
    final menu = data.map((item) {
      return RestaurantFoodCategory(
        category: item['category'] ?? '',
        imageUrl: item['image_url'] ?? '',
        foods: (item['foods'] as List? ?? [])
            .map((food) => FoodEntity.fromMap(food))
            .toList(),
      );
    }).toList();
    Logger.logSuccess('Parsed ${menu.length} menu categories');
    return menu;
  }
}
