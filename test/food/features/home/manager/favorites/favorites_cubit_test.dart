import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';
import 'package:food/food/features/home/manager/favorites/favorites_cubit.dart';
import 'package:food/food/features/home/manager/favorites/favorites_state.dart';
import 'package:food/food/features/home/domain/use_cases/favorites_usecase.dart';
import 'package:food/food/features/home/domain/entities/food.dart';
import 'package:food/food/features/home/domain/entities/restaurant.dart';
import 'package:food/food/features/home/domain/entities/restaurant_food_category.dart';
import 'package:food/food/domain/failures/failures.dart';

import 'favorites_cubit_test.mocks.dart';

@GenerateMocks([
  FavoritesUseCase,
  FirebaseAuth,
  User,
])
void main() {
  late FavoritesCubit favoritesCubit;
  late MockFavoritesUseCase mockFavoritesUseCase;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;

  setUp(() {
    mockFavoritesUseCase = MockFavoritesUseCase();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    
    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test_user_id');
    
    favoritesCubit = FavoritesCubit(mockFavoritesUseCase, auth: mockFirebaseAuth);
  });

  tearDown(() {
    favoritesCubit.close();
  });

  group('FavoritesCubit', () {
    const userId = 'test_user_id';
    const foodId = 'test_food_id';
    const restaurantId = 'test_restaurant_id';

    final testFood = FoodEntity(
      id: foodId,
      name: 'Test Food',
      description: 'Test Description',
      price: 10.99,
      rating: 4.5,
      imageUrl: 'https://example.com/food.jpg',
      category: 'fast_food',
      restaurantId: restaurantId,
      restaurantName: 'Test Restaurant',
      ingredients: ['ingredient1', 'ingredient2'],
      isAvailable: true,
      preparationTime: '30 min',
      calories: 500,
      quantity: 1,
      isVegetarian: false,
      isVegan: false,
      isGlutenFree: false,
      lastUpdated: DateTime.now().millisecondsSinceEpoch,
    );

    final testRestaurant = Restaurant(
      id: restaurantId,
      name: 'Test Restaurant',
      description: 'Test Description',
      location: '123 Main St',
      distance: 2.5,
      rating: 4.5,
      deliveryTime: '30 min',
      deliveryFee: 2.99,
      imageUrl: 'https://example.com/restaurant.jpg',
      category: [RestaurantFoodCategory(category: 'fast_food', imageUrl: '', foods: [])],
      isOpen: true,
      latitude: 40.7128,
      longitude: -74.0060,
      lastUpdated: DateTime.now().millisecondsSinceEpoch,
    );

    final testFailure = ServerFailure(failureMessage: 'Test error message');

    test('initial state should be FavoritesState.initial()', () {
      expect(favoritesCubit.state, equals(FavoritesState.initial()));
    });

    group('loadFavorites', () {
      blocTest<FavoritesCubit, FavoritesState>(
        'should emit loading state and then success state when data is loaded successfully',
        build: () {
          when(mockFavoritesUseCase.getFavoriteFoods(userId))
              .thenAnswer((_) async => Right([testFood]));
          when(mockFavoritesUseCase.getFavoriteRestaurants(userId))
              .thenAnswer((_) async => Right([testRestaurant]));
          return favoritesCubit;
        },
        act: (cubit) => cubit.loadFavorites(userId),
        expect: () => [
          FavoritesState.initial().copyWith(isLoading: true),
          FavoritesState.initial().copyWith(favoriteFoods: [testFood]),
          FavoritesState.initial().copyWith(
            favoriteFoods: [testFood],
            favoriteRestaurants: [testRestaurant],
            isLoading: false,
          ),
        ],
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'should emit loading state and then error state when getFavoriteFoods fails',
        build: () {
          when(mockFavoritesUseCase.getFavoriteFoods(userId))
              .thenAnswer((_) async => Left(testFailure));
          when(mockFavoritesUseCase.getFavoriteRestaurants(userId))
              .thenAnswer((_) async => Right([testRestaurant]));
          return favoritesCubit;
        },
        act: (cubit) => cubit.loadFavorites(userId),
        expect: () => [
          FavoritesState.initial().copyWith(isLoading: true),
          FavoritesState.initial().copyWith(
            isLoading: false,
            errorMessage: 'Test error message',
          ),
        ],
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'should emit loading state and then error state when getFavoriteRestaurants fails',
        build: () {
          when(mockFavoritesUseCase.getFavoriteFoods(userId))
              .thenAnswer((_) async => Right([testFood]));
          when(mockFavoritesUseCase.getFavoriteRestaurants(userId))
              .thenAnswer((_) async => Left(testFailure));
          return favoritesCubit;
        },
        act: (cubit) => cubit.loadFavorites(userId),
        expect: () => [
          FavoritesState.initial().copyWith(isLoading: true),
          FavoritesState.initial().copyWith(favoriteFoods: [testFood]),
          FavoritesState.initial().copyWith(
            favoriteFoods: [testFood],
            isLoading: false,
            errorMessage: 'Test error message',
          ),
        ],
      );
    });

    group('toggleFoodFavorite', () {
      blocTest<FavoritesCubit, FavoritesState>(
        'should emit success message when toggle is successful',
        build: () {
          when(mockFavoritesUseCase.toggleFoodFavorite(userId, foodId))
              .thenAnswer((_) async => const Right(null));
          return favoritesCubit;
        },
        act: (cubit) => cubit.toggleFoodFavorite(foodId),
        expect: () => [
          FavoritesState.initial().copyWith(
            successMessage: 'Favorites updated successfully',
          ),
        ],
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'should emit error message when toggle fails',
        build: () {
          when(mockFavoritesUseCase.toggleFoodFavorite(userId, foodId))
              .thenAnswer((_) async => Left(testFailure));
          return favoritesCubit;
        },
        act: (cubit) => cubit.toggleFoodFavorite(foodId),
        expect: () => [
          FavoritesState.initial().copyWith(
            errorMessage: 'Test error message',
          ),
        ],
      );
    });

    group('toggleRestaurantFavorite', () {
      blocTest<FavoritesCubit, FavoritesState>(
        'should emit success message when toggle is successful',
        build: () {
          when(mockFavoritesUseCase.toggleRestaurantFavorite(userId, restaurantId))
              .thenAnswer((_) async => const Right(null));
          return favoritesCubit;
        },
        act: (cubit) => cubit.toggleRestaurantFavorite(restaurantId),
        expect: () => [
          FavoritesState.initial().copyWith(
            successMessage: 'Favorites updated successfully',
          ),
        ],
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'should emit error message when toggle fails',
        build: () {
          when(mockFavoritesUseCase.toggleRestaurantFavorite(userId, restaurantId))
              .thenAnswer((_) async => Left(testFailure));
          return favoritesCubit;
        },
        act: (cubit) => cubit.toggleRestaurantFavorite(restaurantId),
        expect: () => [
          FavoritesState.initial().copyWith(
            errorMessage: 'Test error message',
          ),
        ],
      );
    });

    group('addFoodToFavorites', () {
      blocTest<FavoritesCubit, FavoritesState>(
        'should emit success message when add is successful',
        build: () {
          when(mockFavoritesUseCase.addFoodToFavorites(userId, foodId))
              .thenAnswer((_) async => const Right(null));
          return favoritesCubit;
        },
        act: (cubit) => cubit.addFoodToFavorites(foodId),
        expect: () => [
          FavoritesState.initial().copyWith(
            successMessage: 'Added to favorites',
          ),
        ],
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'should emit error message when add fails',
        build: () {
          when(mockFavoritesUseCase.addFoodToFavorites(userId, foodId))
              .thenAnswer((_) async => Left(testFailure));
          return favoritesCubit;
        },
        act: (cubit) => cubit.addFoodToFavorites(foodId),
        expect: () => [
          FavoritesState.initial().copyWith(
            errorMessage: 'Test error message',
          ),
        ],
      );
    });

    group('removeFoodFromFavorites', () {
      blocTest<FavoritesCubit, FavoritesState>(
        'should emit success message when remove is successful',
        build: () {
          when(mockFavoritesUseCase.removeFoodFromFavorites(userId, foodId))
              .thenAnswer((_) async => const Right(null));
          return favoritesCubit;
        },
        act: (cubit) => cubit.removeFoodFromFavorites(foodId),
        expect: () => [
          FavoritesState.initial().copyWith(
            successMessage: 'Removed from favorites',
          ),
        ],
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'should emit error message when remove fails',
        build: () {
          when(mockFavoritesUseCase.removeFoodFromFavorites(userId, foodId))
              .thenAnswer((_) async => Left(testFailure));
          return favoritesCubit;
        },
        act: (cubit) => cubit.removeFoodFromFavorites(foodId),
        expect: () => [
          FavoritesState.initial().copyWith(
            errorMessage: 'Test error message',
          ),
        ],
      );
    });

    group('addRestaurantToFavorites', () {
      blocTest<FavoritesCubit, FavoritesState>(
        'should emit success message when add is successful',
        build: () {
          when(mockFavoritesUseCase.addRestaurantToFavorites(userId, restaurantId))
              .thenAnswer((_) async => const Right(null));
          return favoritesCubit;
        },
        act: (cubit) => cubit.addRestaurantToFavorites(restaurantId),
        expect: () => [
          FavoritesState.initial().copyWith(
            successMessage: 'Added to favorites',
          ),
        ],
      );
    });

    group('removeRestaurantFromFavorites', () {
      blocTest<FavoritesCubit, FavoritesState>(
        'should emit success message when remove is successful',
        build: () {
          when(mockFavoritesUseCase.removeRestaurantFromFavorites(userId, restaurantId))
              .thenAnswer((_) async => const Right(null));
          return favoritesCubit;
        },
        act: (cubit) => cubit.removeRestaurantFromFavorites(restaurantId),
        expect: () => [
          FavoritesState.initial().copyWith(
            successMessage: 'Removed from favorites',
          ),
        ],
      );
    });

    group('clearAllFavorites', () {
      blocTest<FavoritesCubit, FavoritesState>(
        'should emit loading and then success state when clear is successful',
        build: () {
          when(mockFavoritesUseCase.clearAllFavorites(userId))
              .thenAnswer((_) async => const Right(null));
          return favoritesCubit;
        },
        act: (cubit) => cubit.clearAllFavorites(),
        expect: () => [
          FavoritesState.initial().copyWith(isLoading: true),
          FavoritesState.initial().copyWith(
            isLoading: false,
            favoriteFoods: [],
            favoriteRestaurants: [],
            favoriteFoodIds: [],
            favoriteRestaurantIds: [],
            successMessage: 'All favorites cleared',
          ),
        ],
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'should emit loading and then error state when clear fails',
        build: () {
          when(mockFavoritesUseCase.clearAllFavorites(userId))
              .thenAnswer((_) async => Left(testFailure));
          return favoritesCubit;
        },
        act: (cubit) => cubit.clearAllFavorites(),
        expect: () => [
          FavoritesState.initial().copyWith(isLoading: true),
          FavoritesState.initial().copyWith(
            isLoading: false,
            errorMessage: 'Test error message',
          ),
        ],
      );
    });

    group('getFavoritesStats', () {
      final testStats = {
        'totalFavoriteFoods': 5,
        'totalFavoriteRestaurants': 3,
        'totalFavorites': 8,
      };

      blocTest<FavoritesCubit, FavoritesState>(
        'should emit stats when get stats is successful',
        build: () {
          when(mockFavoritesUseCase.getFavoritesStats(userId))
              .thenAnswer((_) async => Right(testStats));
          return favoritesCubit;
        },
        act: (cubit) => cubit.getFavoritesStats(),
        expect: () => [
          FavoritesState.initial().copyWith(
            favoritesStats: testStats,
          ),
        ],
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'should emit error message when get stats fails',
        build: () {
          when(mockFavoritesUseCase.getFavoritesStats(userId))
              .thenAnswer((_) async => Left(testFailure));
          return favoritesCubit;
        },
        act: (cubit) => cubit.getFavoritesStats(),
        expect: () => [
          FavoritesState.initial().copyWith(
            errorMessage: 'Test error message',
          ),
        ],
      );
    });

    group('isFoodFavorite', () {
      test('should return true when food is in favorites', () {
        final state = FavoritesState.initial().copyWith(
          favoriteFoodIds: [foodId],
        );
        favoritesCubit.emit(state);

        final result = favoritesCubit.isFoodFavorite(foodId);

        expect(result, isTrue);
      });

      test('should return false when food is not in favorites', () {
        final state = FavoritesState.initial().copyWith(
          favoriteFoodIds: [],
        );
        favoritesCubit.emit(state);

        final result = favoritesCubit.isFoodFavorite(foodId);

        expect(result, isFalse);
      });
    });

    group('isRestaurantFavorite', () {
      test('should return true when restaurant is in favorites', () {
        final state = FavoritesState.initial().copyWith(
          favoriteRestaurantIds: [restaurantId],
        );
        favoritesCubit.emit(state);

        final result = favoritesCubit.isRestaurantFavorite(restaurantId);

        expect(result, isTrue);
      });

      test('should return false when restaurant is not in favorites', () {
        final state = FavoritesState.initial().copyWith(
          favoriteRestaurantIds: [],
        );
        favoritesCubit.emit(state);

        final result = favoritesCubit.isRestaurantFavorite(restaurantId);

        expect(result, isFalse);
      });
    });

    group('clearMessages', () {
      blocTest<FavoritesCubit, FavoritesState>(
        'should clear error and success messages',
        build: () => favoritesCubit,
        seed: () => FavoritesState.initial().copyWith(
          errorMessage: 'Error message',
          successMessage: 'Success message',
        ),
        act: (cubit) => cubit.clearMessages(),
        expect: () => [
          FavoritesState.initial().copyWith(
            errorMessage: null,
            successMessage: null,
          ),
        ],
      );
    });
  });
}