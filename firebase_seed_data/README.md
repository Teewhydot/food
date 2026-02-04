# Firebase Seed Data

This directory contains seed data for the food delivery app's Firebase database.

## Files

- `restaurants.json` - Contains 20 Nigerian restaurants with realistic data
- `foods.json` - Contains 102 food items across various categories

## How to Use

### Method 1: Using the Seed Button (Recommended for Development)

1. Run the app in debug mode
2. Navigate to the Home screen
3. You'll see an "Admin Tools" section at the top
4. Click "Seed Database" to populate Firebase with the seed data
5. Click "Clear Data" to remove all data (requires confirmation)

### Method 2: Programmatically

```dart
import 'package:food/food/core/services/firebase_seed_service.dart';

final seedService = FirebaseSeedService();

// Seed all data
await seedService.seedAll();

// Or seed individually
await seedService.seedRestaurants();
await seedService.seedFoods();

// Clear data
await seedService.clearRestaurants();
await seedService.clearFoods();

// Check if database is seeded
final isSeeded = await seedService.isSeeded();
```

## Data Structure

### Restaurants

Each restaurant contains:
- `id`: Unique identifier
- `name`: Restaurant name
- `description`: Description of the restaurant
- `location`: Address in Lagos, Nigeria
- `distance`: Distance from user (km)
- `rating`: Rating (0-5)
- `deliveryTime`: Estimated delivery time
- `deliveryFee`: Delivery fee in Naira
- `imageUrl`: Image URL (using Unsplash)
- `category`: Array of cuisine categories
- `isOpen`: Operating status
- `latitude`: Geographic coordinate
- `longitude`: Geographic coordinate
- `lastUpdated`: Timestamp

### Foods

Each food item contains:
- `id`: Unique identifier
- `name`: Food name
- `description`: Description of the dish
- `price`: Price in Naira
- `rating`: Rating (0-5)
- `imageUrl`: Image URL (using Unsplash)
- `category`: Food category
- `restaurantId`: ID of the restaurant
- `restaurantName`: Name of the restaurant
- `ingredients`: List of ingredients
- `isAvailable`: Availability status
- `preparationTime`: Preparation time
- `calories`: Calorie count
- `quantity`: Default quantity
- `isVegetarian`: Vegetarian flag
- `isVegan`: Vegan flag
- `isGlutenFree`: Gluten-free flag
- `lastUpdated`: Timestamp

## Firebase Collections

The data is seeded to the following Firebase collections:

1. **restaurants** - All restaurant data
   - Each document ID matches the restaurant `id` field

2. **foods** - All food data
   - Each document ID matches the food `id` field
   - Foods are linked to restaurants via `restaurantId`

## Restaurant Categories

The seed data includes restaurants with these categories:
- Nigerian / Local / Traditional
- Chinese / Asian Fusion
- Italian / Pizza / Pasta
- Japanese / Sushi
- Mediterranean / European / Greek
- African Fusion / Ethiopian / Fine Dining
- BBQ / Grill / American
- International / Fusion / Bistro
- Calabar / Seafood / Delta / South-South
- Fast Food / Continental / Breakfast

## Food Categories

The seed data includes foods in these categories:
- Rice Dishes (Jollof, Fried Rice, Coconut Rice, etc.)
- Soups and Swallows (Egusi, Efo Riro, Ogbono, etc.)
- Local Dishes (Asun, Ofada, Suya, Nkwobi, etc.)
- Seafood (Grilled Fish, Croaker, Tilapia, etc.)
- Chinese (Noodles, Dim Sum, Spring Rolls)
- Japanese (Sushi, Ramen, Tempura)
- Italian (Pizza, Pasta, Risotto)
- Burgers
- Salads
- Breakfast
- Pastries
- Snacks
- Desserts
- And more...

## Pricing

All prices are in Nigerian Naira (₦) and reflect realistic 2024 market rates:
- Budget items: ₦1,000 - ₦4,000
- Mid-range items: ₦4,000 - ₦8,000
- Premium items: ₦8,000 - ₦15,000+

## Images

All images are sourced from Unsplash and are free to use. The images match the food types as closely as possible.

## Notes

- The seed button only appears in debug mode (`kDebugMode`)
- Batch writes are used to efficiently upload data to Firebase
- Each batch can handle up to 500 operations
- The `createdAt` field is automatically set by Firebase server timestamp
- Data is compatible with the existing Firebase data source structure

## Troubleshooting

If seeding fails:
1. Check your internet connection
2. Ensure Firebase is properly configured
3. Check Firebase Firestore rules allow write access
4. Look at the console logs for detailed error messages

## Updating Seed Data

To update the seed data:
1. Modify the JSON files in this directory
2. Run `flutter pub get` to ensure assets are updated
3. Use the "Clear Data" button to remove old data
4. Use the "Seed Database" button to upload new data

## Data Sources

Restaurant and food information was researched from:
- Lagos restaurant guides and reviews
- Nigerian cuisine websites
- Current food prices in Nigerian markets (2024)
- Popular Nigerian dishes and their ingredients

Sources:
- [Eat Drink Lagos](https://www.eatdrinklagos.com/)
- [TripAdvisor Lagos Restaurants](https://www.tripadvisor.com/)
- [BusinessDay Nigeria](https://businessday.ng/)
- [National Bureau of Statistics Nigeria](https://www.nigerianstat.gov.ng/)
