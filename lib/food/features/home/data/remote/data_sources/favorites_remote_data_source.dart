import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/food.dart';
import '../../../domain/entities/restaurant.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<FoodEntity>> getFavoriteFoods(String userId);
  Future<List<Restaurant>> getFavoriteRestaurants(String userId);
  Future<void> addFoodToFavorites(String userId, String foodId);
  Future<void> removeFoodFromFavorites(String userId, String foodId);
  Future<void> addRestaurantToFavorites(String userId, String restaurantId);
  Future<void> removeRestaurantFromFavorites(String userId, String restaurantId);
  Future<bool> isFoodFavorite(String userId, String foodId);
  Future<bool> isRestaurantFavorite(String userId, String restaurantId);
  Future<void> toggleFoodFavorite(String userId, String foodId);
  Future<void> toggleRestaurantFavorite(String userId, String restaurantId);
  Stream<List<String>> watchFavoriteFoodIds(String userId);
  Stream<List<String>> watchFavoriteRestaurantIds(String userId);
  Future<void> clearAllFavorites(String userId);
  Future<Map<String, dynamic>> getFavoritesStats(String userId);
}

class FirebaseFavoritesRemoteDataSource implements FavoritesRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<FoodEntity>> getFavoriteFoods(String userId) async {
    // Get favorite food IDs
    final favoritesDoc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc('foods')
        .get();

    if (!favoritesDoc.exists) return [];

    final data = favoritesDoc.data();
    final favoriteIds = List<String>.from(data?['items'] ?? []);

    if (favoriteIds.isEmpty) return [];

    // Get food details for favorite IDs
    final foodDocs = await _firestore
        .collection('foods')
        .where(FieldPath.documentId, whereIn: favoriteIds)
        .get();

    return foodDocs.docs.map((doc) => _foodFromFirestore(doc)).toList();
  }

  @override
  Future<List<Restaurant>> getFavoriteRestaurants(String userId) async {
    // Get favorite restaurant IDs
    final favoritesDoc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc('restaurants')
        .get();

    if (!favoritesDoc.exists) return [];

    final data = favoritesDoc.data();
    final favoriteIds = List<String>.from(data?['items'] ?? []);

    if (favoriteIds.isEmpty) return [];

    // Get restaurant details for favorite IDs
    final restaurantDocs = await _firestore
        .collection('restaurants')
        .where(FieldPath.documentId, whereIn: favoriteIds)
        .get();

    return restaurantDocs.docs.map((doc) => _restaurantFromFirestore(doc)).toList();
  }

  @override
  Future<void> addFoodToFavorites(String userId, String foodId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc('foods')
        .set({
      'items': FieldValue.arrayUnion([foodId]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> removeFoodFromFavorites(String userId, String foodId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc('foods')
        .update({
      'items': FieldValue.arrayRemove([foodId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> addRestaurantToFavorites(String userId, String restaurantId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc('restaurants')
        .set({
      'items': FieldValue.arrayUnion([restaurantId]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> removeRestaurantFromFavorites(String userId, String restaurantId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc('restaurants')
        .update({
      'items': FieldValue.arrayRemove([restaurantId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<bool> isFoodFavorite(String userId, String foodId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc('foods')
        .get();

    if (!doc.exists) return false;

    final data = doc.data();
    final favoriteIds = List<String>.from(data?['items'] ?? []);
    return favoriteIds.contains(foodId);
  }

  @override
  Future<bool> isRestaurantFavorite(String userId, String restaurantId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc('restaurants')
        .get();

    if (!doc.exists) return false;

    final data = doc.data();
    final favoriteIds = List<String>.from(data?['items'] ?? []);
    return favoriteIds.contains(restaurantId);
  }

  @override
  Stream<List<String>> watchFavoriteFoodIds(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc('foods')
        .snapshots()
        .map((doc) {
      if (!doc.exists) return <String>[];
      final data = doc.data();
      return List<String>.from(data?['items'] ?? []);
    });
  }

  @override
  Stream<List<String>> watchFavoriteRestaurantIds(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc('restaurants')
        .snapshots()
        .map((doc) {
      if (!doc.exists) return <String>[];
      final data = doc.data();
      return List<String>.from(data?['items'] ?? []);
    });
  }

  @override
  Future<void> clearAllFavorites(String userId) async {
    final batch = _firestore.batch();
    
    // Clear favorite foods
    final foodsRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc('foods');
    batch.delete(foodsRef);

    // Clear favorite restaurants
    final restaurantsRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc('restaurants');
    batch.delete(restaurantsRef);

    await batch.commit();
  }

  @override
  Future<void> toggleFoodFavorite(String userId, String foodId) async {
    final isFavorite = await isFoodFavorite(userId, foodId);
    if (isFavorite) {
      await removeFoodFromFavorites(userId, foodId);
    } else {
      await addFoodToFavorites(userId, foodId);
    }
  }

  @override
  Future<void> toggleRestaurantFavorite(String userId, String restaurantId) async {
    final isFavorite = await isRestaurantFavorite(userId, restaurantId);
    if (isFavorite) {
      await removeRestaurantFromFavorites(userId, restaurantId);
    } else {
      await addRestaurantToFavorites(userId, restaurantId);
    }
  }

  @override
  Future<Map<String, dynamic>> getFavoritesStats(String userId) async {
    final favoriteFoods = await getFavoriteFoods(userId);
    final favoriteRestaurants = await getFavoriteRestaurants(userId);
    
    return {
      'totalFavoriteFoods': favoriteFoods.length,
      'totalFavoriteRestaurants': favoriteRestaurants.length,
      'totalFavorites': favoriteFoods.length + favoriteRestaurants.length,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  FoodEntity _foodFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
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
  }

  Restaurant _restaurantFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
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
      category: [],
      isOpen: data['isOpen'] ?? true,
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      lastUpdated: 1,
    );
  }
}