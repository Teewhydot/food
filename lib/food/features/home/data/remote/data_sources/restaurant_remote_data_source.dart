import 'dart:math' show asin, cos, sqrt, sin, pi;

import 'package:cloud_firestore/cloud_firestore.dart';

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
        category: data['category'] ?? '',
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
        category: data['category'] ?? '',
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
            category: data['category'] ?? '',
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
            data['foods'] != null
                ? (data['foods'] as List)
                    .map((food) => FoodEntity.fromMap(food))
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
        category: data['category'] ?? '',
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
