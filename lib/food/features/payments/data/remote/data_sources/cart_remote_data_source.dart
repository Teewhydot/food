import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../domain/entities/cart_entity.dart';
import '../../../../home/domain/entities/food.dart';

abstract class CartRemoteDataSource {
  Stream<CartEntity> getCartStream();
  Future<void> addFoodToCart(FoodEntity food);
  Future<void> removeFoodFromCart(String foodId);
  Future<void> updateFoodQuantity(String foodId, int quantity);
  Future<void> clearCart();
  Future<CartEntity> getCurrentCart();
}

class FirebaseCartRemoteDataSource implements CartRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    return userId;
  }

  CollectionReference get _cartCollection =>
      _firestore.collection('users').doc(_userId).collection('cart_items');

  @override
  Stream<CartEntity> getCartStream() {
    return _cartCollection.snapshots().map((snapshot) {
      final items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return FoodEntity(
          id: data['foodId'] ?? '',
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
          imageUrl: data['imageUrl'] ?? '',
          category: data['category'] ?? '',
          restaurantId: data['restaurantId'] ?? '',
          restaurantName: data['restaurantName'] ?? '',
          ingredients: List<String>.from(data['ingredients'] ?? []),
          isAvailable: data['isAvailable'] ?? true,
          preparationTime: data['preparationTime'] ?? '',
          calories: (data['calories'] as num?)?.toInt() ?? 0,
          quantity: (data['quantity'] as num?)?.toInt() ?? 1,
          isVegetarian: data['isVegetarian'] ?? false,
          isVegan: data['isVegan'] ?? false,
          isGlutenFree: data['isGlutenFree'] ?? false,
          lastUpdated: data['lastUpdated'] ?? DateTime.now().millisecondsSinceEpoch,
        );
      }).toList();

      double totalPrice = 0.0;
      int itemCount = 0;

      for (final item in items) {
        totalPrice += item.price * item.quantity;
        itemCount += 1; // Count unique items, not quantities
      }

      // Round total price to 1 decimal place
      totalPrice = double.parse(totalPrice.toStringAsFixed(1));

      return CartEntity(
        items: items,
        totalPrice: totalPrice,
        itemCount: itemCount,
      );
    });
  }

  @override
  Future<void> addFoodToCart(FoodEntity food) async {
    final docRef = _cartCollection.doc(food.id);
    final doc = await docRef.get();

    if (doc.exists) {
      // If item exists, increment quantity
      final currentData = doc.data() as Map<String, dynamic>;
      final currentQuantity = (currentData['quantity'] as num?)?.toInt() ?? 1;
      await docRef.update({
        'quantity': currentQuantity + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // If item doesn't exist, add new item with quantity 1
      await docRef.set({
        'foodId': food.id,
        'name': food.name,
        'description': food.description,
        'price': food.price,
        'rating': food.rating,
        'imageUrl': food.imageUrl,
        'category': food.category,
        'restaurantId': food.restaurantId,
        'restaurantName': food.restaurantName,
        'ingredients': food.ingredients,
        'isAvailable': food.isAvailable,
        'preparationTime': food.preparationTime,
        'calories': food.calories,
        'quantity': 1, // Always start with quantity 1
        'isVegetarian': food.isVegetarian,
        'isVegan': food.isVegan,
        'isGlutenFree': food.isGlutenFree,
        'lastUpdated': food.lastUpdated,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> removeFoodFromCart(String foodId) async {
    final docRef = _cartCollection.doc(foodId);
    final doc = await docRef.get();

    if (doc.exists) {
      final currentData = doc.data() as Map<String, dynamic>;
      final currentQuantity = (currentData['quantity'] as num?)?.toInt() ?? 1;

      if (currentQuantity > 1) {
        // Decrease quantity by 1
        await docRef.update({
          'quantity': currentQuantity - 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Remove item completely if quantity is 1
        await docRef.delete();
      }
    }
  }

  @override
  Future<void> updateFoodQuantity(String foodId, int quantity) async {
    final docRef = _cartCollection.doc(foodId);

    if (quantity <= 0) {
      await docRef.delete();
    } else {
      await docRef.update({
        'quantity': quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> clearCart() async {
    final batch = _firestore.batch();
    final snapshot = await _cartCollection.get();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  @override
  Future<CartEntity> getCurrentCart() async {
    final snapshot = await _cartCollection.get();
    final items = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return FoodEntity(
        id: data['foodId'] ?? '',
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        price: (data['price'] as num?)?.toDouble() ?? 0.0,
        rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
        imageUrl: data['imageUrl'] ?? '',
        category: data['category'] ?? '',
        restaurantId: data['restaurantId'] ?? '',
        restaurantName: data['restaurantName'] ?? '',
        ingredients: List<String>.from(data['ingredients'] ?? []),
        isAvailable: data['isAvailable'] ?? true,
        preparationTime: data['preparationTime'] ?? '',
        calories: (data['calories'] as num?)?.toInt() ?? 0,
        quantity: (data['quantity'] as num?)?.toInt() ?? 1,
        isVegetarian: data['isVegetarian'] ?? false,
        isVegan: data['isVegan'] ?? false,
        isGlutenFree: data['isGlutenFree'] ?? false,
        lastUpdated: data['lastUpdated'] ?? DateTime.now().millisecondsSinceEpoch,
      );
    }).toList();

    double totalPrice = 0.0;
    int itemCount = 0;

    for (final item in items) {
      totalPrice += item.price * item.quantity;
      itemCount += 1;
    }

    // Round total price to 1 decimal place
    totalPrice = double.parse(totalPrice.toStringAsFixed(1));

    return CartEntity(
      items: items,
      totalPrice: totalPrice,
      itemCount: itemCount,
    );
  }
}