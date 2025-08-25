import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDummyDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedDatabase() async {
    try {
      await _seedUsers();
      await _seedRestaurants();
      await _seedRestaurantCategories();
      await _seedFoods();
      await _seedOrders();
      await _seedPayments();
      await _seedSavedCards();
      await _seedChats();
      await _seedMessages();
      await _seedNotifications();
    } catch (e) {
      throw Exception('Error seeding database: $e');
    }
  }

  Future<void> clearDatabase() async {
    try {
      await _clearCollection('users');
      await _clearCollection('restaurants');
      await _clearCollection('foods');
      await _clearCollection('orders');
      await _clearCollection('payments');
      await _clearCollection('chats');
      await _clearCollection('notifications');
    } catch (e) {
      throw Exception('Error clearing database: $e');
    }
  }

  Future<void> _clearCollection(String collectionName) async {
    final snapshot = await _firestore.collection(collectionName).get();
    final batch = _firestore.batch();
    
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }

  Future<void> _seedUsers() async {
    final users = [
      {
        'uid': 'user_001',
        'email': 'john.doe@example.com',
        'displayName': 'John Doe',
        'phoneNumber': '+1234567890',
        'photoURL': 'https://api.dicebear.com/7.x/avataaars/svg?seed=john',
        'addresses': [
          {
            'id': 'addr_001',
            'type': 'home',
            'street': '123 Main Street',
            'city': 'New York',
            'state': 'NY',
            'zipCode': '10001',
            'country': 'USA',
            'latitude': 40.7128,
            'longitude': -74.0060,
            'isDefault': true
          },
          {
            'id': 'addr_002',
            'type': 'work',
            'street': '456 Business Ave',
            'city': 'New York',
            'state': 'NY',
            'zipCode': '10002',
            'country': 'USA',
            'latitude': 40.7260,
            'longitude': -73.9897,
            'isDefault': false
          }
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'uid': 'user_002',
        'email': 'jane.smith@example.com',
        'displayName': 'Jane Smith',
        'phoneNumber': '+1234567891',
        'photoURL': 'https://api.dicebear.com/7.x/avataaars/svg?seed=jane',
        'addresses': [
          {
            'id': 'addr_003',
            'type': 'home',
            'street': '789 Oak Drive',
            'city': 'Los Angeles',
            'state': 'CA',
            'zipCode': '90001',
            'country': 'USA',
            'latitude': 34.0522,
            'longitude': -118.2437,
            'isDefault': true
          }
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'uid': 'delivery_001',
        'email': 'mike.johnson@delivery.com',
        'displayName': 'Mike Johnson',
        'phoneNumber': '+1234567892',
        'photoURL': 'https://api.dicebear.com/7.x/avataaars/svg?seed=mike',
        'role': 'delivery',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'uid': 'delivery_002',
        'email': 'sarah.wilson@delivery.com',
        'displayName': 'Sarah Wilson',
        'phoneNumber': '+1234567893',
        'photoURL': 'https://api.dicebear.com/7.x/avataaars/svg?seed=sarah',
        'role': 'delivery',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }
    ];

    for (final user in users) {
      await _firestore.collection('users').doc(user['uid'] as String).set(user);
    }
  }

  Future<void> _seedRestaurants() async {
    final restaurants = [
      {
        'id': 'rest_001',
        'name': 'Burger Palace',
        'description': 'Best burgers in town with fresh ingredients',
        'location': 'Downtown Manhattan',
        'distance': 2.5,
        'rating': 4.5,
        'deliveryTime': '25-35 min',
        'deliveryFee': 3.99,
        'imageUrl': 'https://images.unsplash.com/photo-1571091718767-18b5b1457add',
        'category': 'Fast Food',
        'isOpen': true,
        'latitude': 40.7128,
        'longitude': -74.0060,
        'cuisine': ['American', 'Fast Food'],
        'priceRange': '\$\$',
        'workingHours': {
          'monday': '10:00-22:00',
          'tuesday': '10:00-22:00',
          'wednesday': '10:00-22:00',
          'thursday': '10:00-22:00',
          'friday': '10:00-23:00',
          'saturday': '11:00-23:00',
          'sunday': '11:00-21:00'
        },
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'rest_002',
        'name': 'Pizza Heaven',
        'description': 'Authentic Italian pizzas with wood-fired oven',
        'location': 'Brooklyn Heights',
        'distance': 3.2,
        'rating': 4.7,
        'deliveryTime': '30-40 min',
        'deliveryFee': 4.99,
        'imageUrl': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38',
        'category': 'Italian',
        'isOpen': true,
        'latitude': 40.6950,
        'longitude': -73.9936,
        'cuisine': ['Italian', 'Pizza'],
        'priceRange': '\$\$\$',
        'workingHours': {
          'monday': '11:00-23:00',
          'tuesday': '11:00-23:00',
          'wednesday': '11:00-23:00',
          'thursday': '11:00-23:00',
          'friday': '11:00-00:00',
          'saturday': '11:00-00:00',
          'sunday': '12:00-22:00'
        },
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'rest_003',
        'name': 'Sushi Master',
        'description': 'Fresh sushi and Japanese cuisine',
        'location': 'Upper East Side',
        'distance': 4.1,
        'rating': 4.8,
        'deliveryTime': '35-45 min',
        'deliveryFee': 5.99,
        'imageUrl': 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351',
        'category': 'Japanese',
        'isOpen': true,
        'latitude': 40.7736,
        'longitude': -73.9566,
        'cuisine': ['Japanese', 'Sushi'],
        'priceRange': '\$\$\$\$',
        'workingHours': {
          'monday': '12:00-22:00',
          'tuesday': '12:00-22:00',
          'wednesday': '12:00-22:00',
          'thursday': '12:00-22:00',
          'friday': '12:00-23:00',
          'saturday': '12:00-23:00',
          'sunday': '12:00-21:00'
        },
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'rest_004',
        'name': 'Taco Fiesta',
        'description': 'Authentic Mexican street food',
        'location': 'Queens',
        'distance': 5.5,
        'rating': 4.6,
        'deliveryTime': '20-30 min',
        'deliveryFee': 2.99,
        'imageUrl': 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47',
        'category': 'Mexican',
        'isOpen': true,
        'latitude': 40.7282,
        'longitude': -73.7949,
        'cuisine': ['Mexican', 'Street Food'],
        'priceRange': '\$',
        'workingHours': {
          'monday': '10:00-23:00',
          'tuesday': '10:00-23:00',
          'wednesday': '10:00-23:00',
          'thursday': '10:00-23:00',
          'friday': '10:00-00:00',
          'saturday': '10:00-00:00',
          'sunday': '11:00-22:00'
        },
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'rest_005',
        'name': 'Curry House',
        'description': 'Traditional Indian cuisine with exotic spices',
        'location': 'Greenwich Village',
        'distance': 1.8,
        'rating': 4.4,
        'deliveryTime': '25-35 min',
        'deliveryFee': 3.49,
        'imageUrl': 'https://images.unsplash.com/photo-1585937421612-70a008356fbe',
        'category': 'Indian',
        'isOpen': true,
        'latitude': 40.7336,
        'longitude': -74.0027,
        'cuisine': ['Indian', 'Curry'],
        'priceRange': '\$\$',
        'workingHours': {
          'monday': '11:00-22:30',
          'tuesday': '11:00-22:30',
          'wednesday': '11:00-22:30',
          'thursday': '11:00-22:30',
          'friday': '11:00-23:00',
          'saturday': '11:00-23:00',
          'sunday': '12:00-22:00'
        },
        'createdAt': FieldValue.serverTimestamp(),
      }
    ];

    for (final restaurant in restaurants) {
      await _firestore
          .collection('restaurants')
          .doc(restaurant['id'] as String)
          .set(restaurant);
    }
  }

  Future<void> _seedRestaurantCategories() async {
    final categories = {
      'rest_001': [
        {'name': 'Burgers', 'order': 1},
        {'name': 'Sides', 'order': 2},
        {'name': 'Beverages', 'order': 3},
        {'name': 'Desserts', 'order': 4}
      ],
      'rest_002': [
        {'name': 'Pizza', 'order': 1},
        {'name': 'Appetizers', 'order': 2},
        {'name': 'Salads', 'order': 3},
        {'name': 'Desserts', 'order': 4}
      ],
      'rest_003': [
        {'name': 'Sushi', 'order': 1},
        {'name': 'Sashimi', 'order': 2},
        {'name': 'Rolls', 'order': 3},
        {'name': 'Beverages', 'order': 4}
      ],
      'rest_004': [
        {'name': 'Tacos', 'order': 1},
        {'name': 'Burritos', 'order': 2},
        {'name': 'Sides', 'order': 3},
        {'name': 'Beverages', 'order': 4}
      ],
      'rest_005': [
        {'name': 'Main Course', 'order': 1},
        {'name': 'Appetizers', 'order': 2},
        {'name': 'Bread', 'order': 3},
        {'name': 'Desserts', 'order': 4}
      ]
    };

    for (final restaurantId in categories.keys) {
      final restaurantCategories = categories[restaurantId]!;
      for (int i = 0; i < restaurantCategories.length; i++) {
        await _firestore
            .collection('restaurants')
            .doc(restaurantId)
            .collection('categories')
            .doc('cat_${restaurantId}_$i')
            .set(restaurantCategories[i]);
      }
    }
  }

  Future<void> _seedFoods() async {
    final foods = [
      {
        'id': 'food_001',
        'name': 'Classic Beef Burger',
        'description': 'Juicy beef patty with lettuce, tomato, onion, and special sauce',
        'price': 12.99,
        'rating': 4.6,
        'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd',
        'category': 'Burgers',
        'restaurantId': 'rest_001',
        'restaurantName': 'Burger Palace',
        'ingredients': ['Beef', 'Lettuce', 'Tomato', 'Onion', 'Cheese', 'Bun'],
        'isAvailable': true,
        'preparationTime': '15 min',
        'calories': 650,
        'isVegetarian': false,
        'isVegan': false,
        'isGlutenFree': false,
        'spicyLevel': 0,
        'allergens': ['Gluten', 'Dairy'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'food_002',
        'name': 'Chicken Deluxe Burger',
        'description': 'Crispy chicken breast with coleslaw and mayo',
        'price': 11.99,
        'rating': 4.5,
        'imageUrl': 'https://images.unsplash.com/photo-1606755962773-d324e0a13086',
        'category': 'Burgers',
        'restaurantId': 'rest_001',
        'restaurantName': 'Burger Palace',
        'ingredients': ['Chicken', 'Coleslaw', 'Mayo', 'Pickles', 'Bun'],
        'isAvailable': true,
        'preparationTime': '12 min',
        'calories': 580,
        'isVegetarian': false,
        'isVegan': false,
        'isGlutenFree': false,
        'spicyLevel': 1,
        'allergens': ['Gluten', 'Eggs'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'food_003',
        'name': 'Margherita Pizza',
        'description': 'Fresh mozzarella, tomato sauce, and basil',
        'price': 14.99,
        'rating': 4.7,
        'imageUrl': 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002',
        'category': 'Pizza',
        'restaurantId': 'rest_002',
        'restaurantName': 'Pizza Heaven',
        'ingredients': ['Mozzarella', 'Tomato Sauce', 'Basil', 'Pizza Dough'],
        'isAvailable': true,
        'preparationTime': '20 min',
        'calories': 800,
        'isVegetarian': true,
        'isVegan': false,
        'isGlutenFree': false,
        'spicyLevel': 0,
        'allergens': ['Gluten', 'Dairy'],
        'sizes': ['Small', 'Medium', 'Large'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'food_004',
        'name': 'Pepperoni Pizza',
        'description': 'Classic pepperoni with mozzarella cheese',
        'price': 16.99,
        'rating': 4.8,
        'imageUrl': 'https://images.unsplash.com/photo-1628840042765-356cda07504e',
        'category': 'Pizza',
        'restaurantId': 'rest_002',
        'restaurantName': 'Pizza Heaven',
        'ingredients': ['Pepperoni', 'Mozzarella', 'Tomato Sauce', 'Pizza Dough'],
        'isAvailable': true,
        'preparationTime': '20 min',
        'calories': 950,
        'isVegetarian': false,
        'isVegan': false,
        'isGlutenFree': false,
        'spicyLevel': 1,
        'allergens': ['Gluten', 'Dairy'],
        'sizes': ['Small', 'Medium', 'Large'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'food_005',
        'name': 'California Roll',
        'description': 'Crab, avocado, and cucumber roll',
        'price': 8.99,
        'rating': 4.6,
        'imageUrl': 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351',
        'category': 'Sushi',
        'restaurantId': 'rest_003',
        'restaurantName': 'Sushi Master',
        'ingredients': ['Crab', 'Avocado', 'Cucumber', 'Rice', 'Nori'],
        'isAvailable': true,
        'preparationTime': '10 min',
        'calories': 255,
        'isVegetarian': false,
        'isVegan': false,
        'isGlutenFree': true,
        'spicyLevel': 0,
        'allergens': ['Shellfish'],
        'pieces': 8,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'food_006',
        'name': 'Salmon Nigiri',
        'description': 'Fresh salmon over seasoned rice',
        'price': 6.99,
        'rating': 4.9,
        'imageUrl': 'https://images.unsplash.com/photo-1583623025817-d180a2221d0a',
        'category': 'Sushi',
        'restaurantId': 'rest_003',
        'restaurantName': 'Sushi Master',
        'ingredients': ['Salmon', 'Rice', 'Wasabi'],
        'isAvailable': true,
        'preparationTime': '5 min',
        'calories': 120,
        'isVegetarian': false,
        'isVegan': false,
        'isGlutenFree': true,
        'spicyLevel': 0,
        'allergens': ['Fish'],
        'pieces': 2,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'food_007',
        'name': 'Beef Tacos',
        'description': 'Three soft tacos with seasoned beef, lettuce, cheese, and salsa',
        'price': 9.99,
        'rating': 4.5,
        'imageUrl': 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47',
        'category': 'Tacos',
        'restaurantId': 'rest_004',
        'restaurantName': 'Taco Fiesta',
        'ingredients': ['Beef', 'Lettuce', 'Cheese', 'Salsa', 'Tortilla'],
        'isAvailable': true,
        'preparationTime': '8 min',
        'calories': 450,
        'isVegetarian': false,
        'isVegan': false,
        'isGlutenFree': false,
        'spicyLevel': 2,
        'allergens': ['Gluten', 'Dairy'],
        'quantity': 3,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'food_008',
        'name': 'Chicken Tikka Masala',
        'description': 'Tender chicken in creamy tomato curry sauce',
        'price': 15.99,
        'rating': 4.7,
        'imageUrl': 'https://images.unsplash.com/photo-1565557623262-b51c2513a641',
        'category': 'Main Course',
        'restaurantId': 'rest_005',
        'restaurantName': 'Curry House',
        'ingredients': ['Chicken', 'Tomato', 'Cream', 'Spices', 'Rice'],
        'isAvailable': true,
        'preparationTime': '25 min',
        'calories': 680,
        'isVegetarian': false,
        'isVegan': false,
        'isGlutenFree': true,
        'spicyLevel': 2,
        'allergens': ['Dairy'],
        'servingSize': 'Regular',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'food_009',
        'name': 'French Fries',
        'description': 'Crispy golden fries with sea salt',
        'price': 3.99,
        'rating': 4.4,
        'imageUrl': 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877',
        'category': 'Sides',
        'restaurantId': 'rest_001',
        'restaurantName': 'Burger Palace',
        'ingredients': ['Potatoes', 'Salt', 'Oil'],
        'isAvailable': true,
        'preparationTime': '5 min',
        'calories': 320,
        'isVegetarian': true,
        'isVegan': true,
        'isGlutenFree': true,
        'spicyLevel': 0,
        'allergens': [],
        'sizes': ['Small', 'Medium', 'Large'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'food_010',
        'name': 'Chocolate Milkshake',
        'description': 'Thick and creamy chocolate shake',
        'price': 5.99,
        'rating': 4.6,
        'imageUrl': 'https://images.unsplash.com/photo-1572490122747-3968b75cc699',
        'category': 'Beverages',
        'restaurantId': 'rest_001',
        'restaurantName': 'Burger Palace',
        'ingredients': ['Milk', 'Chocolate', 'Ice Cream', 'Whipped Cream'],
        'isAvailable': true,
        'preparationTime': '3 min',
        'calories': 480,
        'isVegetarian': true,
        'isVegan': false,
        'isGlutenFree': true,
        'spicyLevel': 0,
        'allergens': ['Dairy'],
        'sizes': ['Regular', 'Large'],
        'createdAt': FieldValue.serverTimestamp(),
      }
    ];

    for (final food in foods) {
      await _firestore.collection('foods').doc(food['id'] as String).set(food);
    }
  }

  Future<void> _seedOrders() async {
    final orders = [
      {
        'id': 'order_001',
        'userId': 'user_001',
        'restaurantId': 'rest_001',
        'restaurantName': 'Burger Palace',
        'items': [
          {
            'foodId': 'food_001',
            'foodName': 'Classic Beef Burger',
            'price': 12.99,
            'quantity': 2,
            'total': 25.98,
            'specialInstructions': 'No onions please'
          },
          {
            'foodId': 'food_009',
            'foodName': 'French Fries',
            'price': 3.99,
            'quantity': 1,
            'total': 3.99,
            'specialInstructions': ''
          }
        ],
        'subtotal': 29.97,
        'deliveryFee': 3.99,
        'tax': 2.70,
        'total': 36.66,
        'deliveryAddress': '123 Main Street, New York, NY 10001',
        'paymentMethod': 'card',
        'status': 'delivered',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'deliveredAt': FieldValue.serverTimestamp(),
        'deliveryPersonName': 'Mike Johnson',
        'deliveryPersonPhone': '+1234567892',
        'trackingUrl': 'https://track.example.com/order_001',
        'notes': 'Leave at door'
      },
      {
        'id': 'order_002',
        'userId': 'user_001',
        'restaurantId': 'rest_002',
        'restaurantName': 'Pizza Heaven',
        'items': [
          {
            'foodId': 'food_003',
            'foodName': 'Margherita Pizza',
            'price': 14.99,
            'quantity': 1,
            'total': 14.99,
            'specialInstructions': 'Extra cheese'
          }
        ],
        'subtotal': 14.99,
        'deliveryFee': 4.99,
        'tax': 1.80,
        'total': 21.78,
        'deliveryAddress': '123 Main Street, New York, NY 10001',
        'paymentMethod': 'cash',
        'status': 'onTheWay',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'deliveryPersonName': 'Sarah Wilson',
        'deliveryPersonPhone': '+1234567893',
        'trackingUrl': 'https://track.example.com/order_002',
        'notes': 'Call when arriving'
      },
      {
        'id': 'order_003',
        'userId': 'user_002',
        'restaurantId': 'rest_003',
        'restaurantName': 'Sushi Master',
        'items': [
          {
            'foodId': 'food_005',
            'foodName': 'California Roll',
            'price': 8.99,
            'quantity': 2,
            'total': 17.98,
            'specialInstructions': ''
          },
          {
            'foodId': 'food_006',
            'foodName': 'Salmon Nigiri',
            'price': 6.99,
            'quantity': 3,
            'total': 20.97,
            'specialInstructions': 'Extra wasabi'
          }
        ],
        'subtotal': 38.95,
        'deliveryFee': 5.99,
        'tax': 4.04,
        'total': 48.98,
        'deliveryAddress': '789 Oak Drive, Los Angeles, CA 90001',
        'paymentMethod': 'paypal',
        'status': 'preparing',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'notes': 'Include chopsticks'
      }
    ];

    for (final order in orders) {
      await _firestore.collection('orders').doc(order['id'] as String).set(order);
    }
  }

  Future<void> _seedPayments() async {
    final payments = [
      {
        'transactionId': 'txn_abc123xyz',
        'paymentMethodId': 'card_001',
        'amount': 36.66,
        'currency': 'USD',
        'metadata': {
          'orderId': 'order_001',
          'userId': 'user_001',
          'description': 'Payment for order at Burger Palace'
        },
        'status': 'succeeded',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'transactionId': 'txn_def456uvw',
        'paymentMethodId': 'paypal_001',
        'amount': 48.98,
        'currency': 'USD',
        'metadata': {
          'orderId': 'order_003',
          'userId': 'user_002',
          'description': 'Payment for order at Sushi Master'
        },
        'status': 'succeeded',
        'createdAt': FieldValue.serverTimestamp(),
      }
    ];

    for (int i = 0; i < payments.length; i++) {
      await _firestore.collection('payments').doc('pay_00${i + 1}').set(payments[i]);
    }
  }

  Future<void> _seedSavedCards() async {
    final savedCards = [
      {
        'id': 'card_001',
        'cardName': 'Personal Card',
        'cardType': 'visa',
        'lastFourDigits': '4242',
        'mExp': 12,
        'yExp': 2025,
        'isDefault': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'card_002',
        'cardName': 'Business Card',
        'cardType': 'mastercard',
        'lastFourDigits': '5555',
        'mExp': 6,
        'yExp': 2026,
        'isDefault': false,
        'createdAt': FieldValue.serverTimestamp(),
      }
    ];

    for (final card in savedCards) {
      await _firestore
          .collection('users')
          .doc('user_001')
          .collection('saved_cards')
          .doc(card['id'] as String)
          .set(card);
    }
  }

  Future<void> _seedChats() async {
    final chats = [
      {
        'id': 'chat_001',
        'participants': ['user_001', 'delivery_001'],
        'orderId': 'order_001',
        'lastMessage': 'Your order has been delivered',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'participantDetails': {
          'user_001': {
            'id': 'user_001',
            'name': 'John Doe',
            'imageUrl': 'https://api.dicebear.com/7.x/avataaars/svg?seed=john'
          },
          'delivery_001': {
            'id': 'delivery_001',
            'name': 'Mike Johnson',
            'imageUrl': 'https://api.dicebear.com/7.x/avataaars/svg?seed=mike'
          }
        }
      },
      {
        'id': 'chat_002',
        'participants': ['user_001', 'delivery_002'],
        'orderId': 'order_002',
        'lastMessage': 'On my way with your order',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'participantDetails': {
          'user_001': {
            'id': 'user_001',
            'name': 'John Doe',
            'imageUrl': 'https://api.dicebear.com/7.x/avataaars/svg?seed=john'
          },
          'delivery_002': {
            'id': 'delivery_002',
            'name': 'Sarah Wilson',
            'imageUrl': 'https://api.dicebear.com/7.x/avataaars/svg?seed=sarah'
          }
        }
      }
    ];

    for (final chat in chats) {
      await _firestore.collection('chats').doc(chat['id'] as String).set(chat);
    }
  }

  Future<void> _seedMessages() async {
    final messagesChat1 = [
      {
        'id': 'msg_001',
        'senderId': 'delivery_001',
        'receiverId': 'user_001',
        'content': "Hi, I've picked up your order and I'm on my way",
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': true,
        'type': 'text'
      },
      {
        'id': 'msg_002',
        'senderId': 'user_001',
        'receiverId': 'delivery_001',
        'content': 'Great! Please leave it at the door',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': true,
        'type': 'text'
      },
      {
        'id': 'msg_003',
        'senderId': 'delivery_001',
        'receiverId': 'user_001',
        'content': "Will do! I'm about 5 minutes away",
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': true,
        'type': 'text'
      },
      {
        'id': 'msg_004',
        'senderId': 'delivery_001',
        'receiverId': 'user_001',
        'content': 'Your order has been delivered',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': true,
        'type': 'text'
      }
    ];

    final messagesChat2 = [
      {
        'id': 'msg_005',
        'senderId': 'delivery_002',
        'receiverId': 'user_001',
        'content': 'Hello! I have your pizza order',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': true,
        'type': 'text'
      },
      {
        'id': 'msg_006',
        'senderId': 'delivery_002',
        'receiverId': 'user_001',
        'content': 'On my way with your order',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'text'
      }
    ];

    for (final message in messagesChat1) {
      await _firestore
          .collection('chats')
          .doc('chat_001')
          .collection('messages')
          .doc(message['id'] as String)
          .set(message);
    }

    for (final message in messagesChat2) {
      await _firestore
          .collection('chats')
          .doc('chat_002')
          .collection('messages')
          .doc(message['id'] as String)
          .set(message);
    }
  }

  Future<void> _seedNotifications() async {
    final notifications = [
      {
        'id': 'notif_001',
        'userId': 'user_001',
        'title': 'Order Confirmed',
        'body': 'Your order from Burger Palace has been confirmed',
        'type': 'order_status',
        'data': {
          'orderId': 'order_001',
          'status': 'confirmed'
        },
        'isRead': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'notif_002',
        'userId': 'user_001',
        'title': 'Order Delivered',
        'body': 'Your order from Burger Palace has been delivered',
        'type': 'order_status',
        'data': {
          'orderId': 'order_001',
          'status': 'delivered'
        },
        'isRead': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'notif_003',
        'userId': 'user_001',
        'title': 'Special Offer',
        'body': 'Get 20% off on your next order from Pizza Heaven',
        'type': 'promotion',
        'data': {
          'restaurantId': 'rest_002',
          'discountCode': 'PIZZA20'
        },
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'notif_004',
        'userId': 'user_002',
        'title': 'Order Confirmed',
        'body': 'Your order from Sushi Master has been confirmed',
        'type': 'order_status',
        'data': {
          'orderId': 'order_003',
          'status': 'confirmed'
        },
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      }
    ];

    for (final notification in notifications) {
      await _firestore
          .collection('notifications')
          .doc(notification['id'] as String)
          .set(notification);
    }
  }

  Future<Map<String, int>> getDatabaseStats() async {
    final stats = <String, int>{};
    
    final collections = [
      'users',
      'restaurants', 
      'foods',
      'orders',
      'payments',
      'chats',
      'notifications'
    ];

    for (final collection in collections) {
      final snapshot = await _firestore.collection(collection).get();
      stats[collection] = snapshot.docs.length;
    }

    return stats;
  }
}