import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food/food/core/utils/logger.dart';

/// Service to seed Firebase with initial restaurant and food data
class FirebaseSeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seed restaurants from JSON asset
  Future<void> seedRestaurants() async {
    try {
      Logger.logBasic('Starting to seed restaurants...');

      // Load JSON file
      final jsonString = await rootBundle.loadString(
        'firebase_seed_data/restaurants.json',
      );
      final Map<String, dynamic> json = jsonDecode(jsonString);
      final List<dynamic> restaurants = json['restaurants'];

      Logger.logBasic('Found ${restaurants.length} restaurants to seed');

      // Batch write to Firebase
      var batch = _firestore.batch();
      int count = 0;

      for (var restaurant in restaurants) {
        final docRef = _firestore.collection('restaurants').doc(restaurant['id']);

        // Convert category list to Firebase format
        final categories = restaurant['category'] as List;

        batch.set(docRef, {
          'name': restaurant['name'],
          'description': restaurant['description'],
          'location': restaurant['location'],
          'distance': restaurant['distance'],
          'rating': restaurant['rating'],
          'deliveryTime': restaurant['deliveryTime'],
          'deliveryFee': restaurant['deliveryFee'],
          'imageUrl': restaurant['imageUrl'],
          'categories': categories, // Store as array
          'category': categories.isNotEmpty ? categories[0] : '', // For backwards compatibility
          'isOpen': restaurant['isOpen'],
          'latitude': restaurant['latitude'],
          'longitude': restaurant['longitude'],
          'lastUpdated': restaurant['lastUpdated'],
          'createdAt': FieldValue.serverTimestamp(),
        });

        count++;

        // Firebase batches are limited to 500 operations
        if (count % 500 == 0) {
          await batch.commit();
          Logger.logBasic('Seeded $count restaurants...');
          batch = _firestore.batch();
        }
      }

      // Commit remaining operations
      if (count % 500 != 0) {
        await batch.commit();
      }

      Logger.logSuccess('Successfully seeded $count restaurants to Firebase');
    } catch (e) {
      Logger.logError('Error seeding restaurants: $e');
      rethrow;
    }
  }

  /// Seed foods from JSON asset
  Future<void> seedFoods() async {
    try {
      Logger.logBasic('Starting to seed foods...');

      // Load JSON file
      final jsonString = await rootBundle.loadString(
        'firebase_seed_data/foods.json',
      );
      final Map<String, dynamic> json = jsonDecode(jsonString);
      final List<dynamic> foods = json['foods'];

      Logger.logBasic('Found ${foods.length} foods to seed');

      // Batch write to Firebase
      var batch = _firestore.batch();
      int count = 0;

      for (var food in foods) {
        final docRef = _firestore.collection('foods').doc(food['id']);

        batch.set(docRef, {
          'name': food['name'],
          'description': food['description'],
          'price': food['price'],
          'rating': food['rating'],
          'imageUrl': food['imageUrl'],
          'category': food['category'],
          'restaurantId': food['restaurantId'],
          'restaurantName': food['restaurantName'],
          'ingredients': food['ingredients'],
          'isAvailable': food['isAvailable'],
          'preparationTime': food['preparationTime'],
          'calories': food['calories'],
          'quantity': food['quantity'],
          'isVegetarian': food['isVegetarian'],
          'isVegan': food['isVegan'],
          'isGlutenFree': food['isGlutenFree'],
          'lastUpdated': food['lastUpdated'],
          'createdAt': FieldValue.serverTimestamp(),
        });

        count++;

        // Firebase batches are limited to 500 operations
        if (count % 500 == 0) {
          await batch.commit();
          Logger.logBasic('Seeded $count foods...');
          batch = _firestore.batch();
        }
      }

      // Commit remaining operations
      if (count % 500 != 0) {
        await batch.commit();
      }

      Logger.logSuccess('Successfully seeded $count foods to Firebase');
    } catch (e) {
      Logger.logError('Error seeding foods: $e');
      rethrow;
    }
  }

  /// Seed both restaurants and foods
  Future<void> seedAll() async {
    Logger.logBasic('Starting full database seed...');
    try {
      await seedRestaurants();
      await Future.delayed(const Duration(seconds: 1)); // Brief pause
      await seedFoods();
      Logger.logSuccess('Database seeding completed successfully!');
    } catch (e) {
      Logger.logError('Error during database seeding: $e');
      rethrow;
    }
  }

  /// Clear all restaurants (use with caution!)
  Future<void> clearRestaurants() async {
    try {
      Logger.logBasic('Clearing all restaurants...');
      final snapshot = await _firestore.collection('restaurants').get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      Logger.logSuccess('Cleared ${snapshot.docs.length} restaurants');
    } catch (e) {
      Logger.logError('Error clearing restaurants: $e');
      rethrow;
    }
  }

  /// Clear all foods (use with caution!)
  Future<void> clearFoods() async {
    try {
      Logger.logBasic('Clearing all foods...');
      final snapshot = await _firestore.collection('foods').get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      Logger.logSuccess('Cleared ${snapshot.docs.length} foods');
    } catch (e) {
      Logger.logError('Error clearing foods: $e');
      rethrow;
    }
  }

  /// Check if database has been seeded
  Future<bool> isSeeded() async {
    try {
      final restaurants = await _firestore.collection('restaurants').limit(1).get();
      final foods = await _firestore.collection('foods').limit(1).get();
      return restaurants.docs.isNotEmpty && foods.docs.isNotEmpty;
    } catch (e) {
      Logger.logError('Error checking seed status: $e');
      return false;
    }
  }
}
