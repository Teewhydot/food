import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/features/auth/presentation/screens/forgot_password.dart';
import 'package:food/food/features/auth/presentation/screens/login.dart';
import 'package:food/food/features/auth/presentation/screens/sign_up.dart';
import 'package:food/food/features/auth/presentation/screens/verification.dart';
import 'package:food/food/features/home/presentation/screens/add_address.dart';
import 'package:food/food/features/home/presentation/screens/address.dart';
import 'package:food/food/features/home/presentation/screens/edit_profile.dart';
import 'package:food/food/features/home/presentation/screens/food.dart';
import 'package:food/food/features/home/presentation/screens/food_details.dart';
import 'package:food/food/features/home/presentation/screens/personal_info.dart';
import 'package:food/food/features/home/presentation/screens/restaurant_details.dart';
import 'package:food/food/features/home/presentation/screens/search.dart';
import 'package:food/food/features/onboarding/presentation/screens/food_onboarding.dart';
import 'package:food/food/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:food/food/features/payments/presentation/screens/add_card.dart';
import 'package:food/food/features/payments/presentation/screens/payment_method.dart';
import 'package:food/food/features/payments/presentation/screens/status.dart';
import 'package:food/food/features/tracking/presentation/screens/notifications.dart';
import 'package:food/food/features/tracking/presentation/screens/tracking.dart';
import 'package:get/get.dart';

import '../../features/home/domain/entities/food.dart';
import '../../features/home/presentation/screens/home.dart';
import '../../features/payments/presentation/screens/cart.dart';
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
      page: () => const Login(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: Routes.register,
      page: () => const SignUp(),
      transition: _transition,
      transitionDuration: _transitionDuration,
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
    ),
    GetPage(
      name: Routes.search,
      page: () => const Search(),
      transition: _transition,
      transitionDuration: _transitionDuration,
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
      page: () => const RestaurantDetails(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: Routes.otpVerification,
      page: () => const Verification(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: Routes.cart,
      page: () => const Cart(),
      transition: _transition,
      transitionDuration: _transitionDuration,
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
      name: Routes.statusScreen,
      page: () => const PaymentStatus(),
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
      page: () => const ChatScreen(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: Routes.profile,
      page: () => const PersonalInfo(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: Routes.editProfile,
      page: () => const EditProfile(),
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
      page: () => const AddAddress(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: Routes.notifications,
      page: () => const Notifications(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
  ];
}
