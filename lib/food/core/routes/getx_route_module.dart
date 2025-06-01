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
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

import '../../features/home/presentation/screens/home.dart';
import '../../features/payments/presentation/screens/cart.dart';
import '../../features/tracking/presentation/screens/call_screen.dart';
import '../../features/tracking/presentation/screens/chat_screen.dart';

class GetXRouteModule {
  static const Transition _transition = Transition.rightToLeft;
  static final List<GetPage> routes = [
    GetPage(
      name: Routes.initial,
      page: () => const SplashScreen(),
      transition: _transition,
    ),
    GetPage(
      name: Routes.onboarding,
      page: () => const FoodOnboarding(),
      transition: _transition,
    ),
    GetPage(
      name: Routes.login,
      page: () => const Login(),
      transition: _transition,
    ),
    GetPage(
      name: Routes.register,
      page: () => const SignUp(),
      transition: _transition,
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPassword(),
      transition: _transition,
    ),
    GetPage(
      name: Routes.home,
      page: () => const Home(),
      transition: _transition,
    ),
    GetPage(
      name: Routes.search,
      page: () => const Search(),
      transition: _transition,
    ),
    GetPage(
      name: Routes.food,
      page: () => const Food(),
      transition: _transition,
    ),
    GetPage(
      name: Routes.foodDetails,
      page: () => const FoodDetails(),
      transition: _transition,
    ),
    GetPage(
      name: Routes.restaurantDetails,
      page: () => const RestaurantDetails(),
      transition: _transition,
    ),
    GetPage(
      name: Routes.otpVerification,
      page: () => const Verification(),
      transition: _transition,
    ),
    GetPage(
      name: Routes.cart,
      page: () => const Cart(),
      transition: _transition,
    ),
    GetPage(
      name: Routes.paymentMethod,
      page: () => const PaymentMethod(),
      transition: _transition,
    ),
    GetPage(
      name: Routes.addCard,
      page: () => const AddCard(),
      transition: _transition,
    ),
    GetPage(
      name: Routes.statusScreen,
      page: () => const PaymentStatus(),
      transition: _transition,
    ),
    GetPage(
      name: Routes.tracking,
      page: () => const TrackingOrder(),
      transition: _transition,
    ),
    GetPage(
      name: Routes.callScreen,
      page: () => const CallScreen(),
      transition: _transition,
    ),
    GetPage(
      name: Routes.chatScreen,
      page: () => const ChatScreen(),
      transition: _transition,
    ),
    GetPage(
      name: Routes.profile,
      page: () => const PersonalInfo(),
      transition: _transition,
    ),
    GetPage(
      name: Routes.editProfile,
      page: () => const EditProfile(),
      transition: _transition,
    ),
    GetPage(
      name: Routes.address,
      page: () => const Address(),
      transition: _transition,
    ),
    GetPage(
      name: Routes.addAddress,
      page: () => const AddAddress(),
      transition: _transition,
    ),
    GetPage(
      name: Routes.notifications,
      page: () => const Notifications(),
      transition: _transition,
    ),
  ];
}
