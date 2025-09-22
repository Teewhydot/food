import 'package:food/food/core/middleware/auth_middleware.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:food/food/features/auth/presentation/screens/enhanced_login_screen.dart';
import 'package:food/food/features/auth/presentation/screens/forgot_password.dart';
import 'package:food/food/features/auth/presentation/screens/location.dart';
import 'package:food/food/features/auth/presentation/screens/sign_up.dart';
import 'package:food/food/features/home/domain/entities/address.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';
import 'package:food/food/features/home/presentation/screens/add_address.dart';
import 'package:food/food/features/home/presentation/screens/address.dart';
import 'package:food/food/features/home/presentation/screens/edit_profile.dart';
import 'package:food/food/features/home/presentation/screens/food.dart';
import 'package:food/food/features/home/presentation/screens/food_details.dart';
import 'package:food/food/features/home/presentation/screens/menu.dart';
import 'package:food/food/features/home/presentation/screens/personal_info.dart';
import 'package:food/food/features/home/presentation/screens/restaurant_details.dart';
import 'package:food/food/features/home/presentation/screens/search.dart';
import 'package:food/food/features/onboarding/presentation/screens/food_onboarding.dart';
import 'package:food/food/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:food/food/features/payments/presentation/screens/add_card.dart';
import 'package:food/food/features/payments/presentation/screens/flutterwave_card_form_screen.dart';
import 'package:food/food/features/payments/presentation/screens/payment_method.dart';
import 'package:food/food/features/payments/presentation/screens/status.dart';
import 'package:food/food/features/tracking/presentation/screens/notifications.dart';
import 'package:food/food/features/tracking/presentation/screens/orders.dart';
import 'package:food/food/features/tracking/presentation/screens/tracking.dart';
import 'package:get/get.dart';

import '../../features/home/domain/entities/food.dart';
import '../../features/home/domain/entities/restaurant.dart';
import '../../features/home/presentation/screens/home.dart';
import '../../features/payments/presentation/screens/cart.dart';
import '../../features/testing/presentation/screens/firebase_test_screen.dart';
import '../../features/tracking/domain/entities/chat_entity.dart';
import '../../features/tracking/presentation/screens/call_screen.dart';
import '../../features/tracking/presentation/screens/chat_screen.dart';

class GetXRouteModule {
  static const Transition _transition = Transition.rightToLeft;
  static const Duration _transitionDuration = Duration(milliseconds: 300);
  static final List<GetPage> routes = [
    GetPage(
      name: Routes.initial,
      page: () => const SplashScreen(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: Routes.onboarding,
      page: () => const FoodOnboarding(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      transition: _transition,
      transitionDuration: _transitionDuration,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.emailVerification,
      page: () => const EmailVerificationScreen(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: Routes.register,
      page: () => const SignUp(),
      transition: _transition,
      transitionDuration: _transitionDuration,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPassword(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: Routes.home,
      page: () => const Home(),
      transition: _transition,
      transitionDuration: _transitionDuration,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.search,
      page: () => const Search(),
      transition: _transition,
      transitionDuration: _transitionDuration,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.food,
      page: () => const Food(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: Routes.foodDetails,
      arguments: FoodEntity, // Specify the type of argument expected
      page:
          () => FoodDetails(
            foodEntity:
                Get.arguments as FoodEntity, // Cast the argument to FoodEntity
          ),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: Routes.restaurantDetails,
      arguments: Restaurant, // Specify the type of argument expected,
      page:
          () => RestaurantDetails(
            restaurant:
                Get.arguments as Restaurant, // Cast the argument to Restaurant
          ),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    // GetPage(
    //   name: Routes.otpVerification,
    //   page: () => const Verification(),
    //   transition: _transition,
    //   transitionDuration: _transitionDuration,
    // ),
    GetPage(
      name: Routes.cart,
      page: () => const Cart(),
      transition: _transition,
      transitionDuration: _transitionDuration,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.paymentMethod,
      page: () => const PaymentMethod(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: Routes.addCard,
      page: () => const AddCard(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: Routes.flutterwaveCardForm,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return FlutterwaveCardFormScreen(
          amount: args['amount'] as double,
          orderId: args['orderId'] as String,
        );
      },
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: Routes.statusScreen,
      page: () => PaymentStatus(status: Get.arguments as PaymentStatusEnum),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: Routes.tracking,
      page: () => const TrackingOrder(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: Routes.callScreen,
      page: () => const CallScreen(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: Routes.chatScreen,
      page:
          () => ChatScreen(
            chat:
                Get.arguments as ChatEntity, // Cast the argument to ChatEntity
          ),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: Routes.personalInfo,
      page: () => const PersonalInfo(),
      transition: _transition,
      transitionDuration: _transitionDuration,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.editProfile,
      page: () => EditProfile(userProfile: Get.arguments as UserProfileEntity),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: Routes.address,
      page: () => const Address(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: Routes.addAddress,
      arguments: AddressEntity,
      page: () => AddAddress(addressEntity: Get.arguments as AddressEntity),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: Routes.notifications,
      page: () => const Notifications(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: Routes.orderHistory,
      page: () => const Orders(),
      transition: _transition,
      transitionDuration: _transitionDuration,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.menu,
      page: () => const Menu(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: Routes.location,
      page: () => const Location(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: Routes.firebaseTest,
      page: () => const FirebaseTestScreen(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
  ];
}
