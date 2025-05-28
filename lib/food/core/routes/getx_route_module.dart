import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/features/auth/presentation/screens/forgot_password.dart';
import 'package:food/food/features/auth/presentation/screens/login.dart';
import 'package:food/food/features/auth/presentation/screens/sign_up.dart';
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

import '../../features/home/presentation/screens/home.dart';
import '../../features/payments/presentation/screens/cart.dart';
import '../../features/tracking/presentation/screens/call_screen.dart';
import '../../features/tracking/presentation/screens/chat_screen.dart';

class GetXRouteModule {
  static final List<GetPage> routes = [
    GetPage(name: Routes.initial, page: () => const SplashScreen()),
    GetPage(name: Routes.onboarding, page: () => const FoodOnboarding()),
    GetPage(name: Routes.login, page: () => const Login()),
    GetPage(name: Routes.register, page: () => const SignUp()),
    GetPage(name: Routes.forgotPassword, page: () => const ForgotPassword()),
    GetPage(name: Routes.home, page: () => const Home()),
    GetPage(
      name: Routes.search,
      page: () => const Search(), // Replace with actual search screen
    ),
    GetPage(
      name: Routes.food,
      page: () => const Food(), // Replace with actual food screen
    ),
    GetPage(
      name: Routes.foodDetails,
      page:
          () => const FoodDetails(), // Replace with actual food details screen
    ),
    GetPage(
      name: Routes.restaurantDetails,
      page:
          () =>
              const RestaurantDetails(), // Replace with actual restaurant details screen
    ),
    GetPage(
      name: Routes.cart,
      page: () => const Cart(), // Replace with actual cart screen
    ),
    GetPage(
      name: Routes.paymentMethod,
      page:
          () =>
              const PaymentMethod(), // Replace with actual payment method screen
    ),
    GetPage(
      name: Routes.addCard,
      page: () => const AddCard(), //R Replace with actual add card screen
    ),
    GetPage(
      name: Routes.statusScreen,
      page: () => const PaymentStatus(), // Replace with actual status screen
    ),
    GetPage(
      name: Routes.tracking,
      page: () => const TrackingOrder(), // Replace with actual tracking screen
    ),
    GetPage(
      name: Routes.callScreen,
      page: () => const CallScreen(), // Replace with actual call screen
    ),
    GetPage(
      name: Routes.chatScreen,
      page: () => const ChatScreen(), // Replace with actual chat screen
    ),
    GetPage(
      name: Routes.profile,
      page: () => const PersonalInfo(), // Replace with actual profile screen
    ),
    GetPage(
      name: Routes.editProfile,
      page:
          () => const EditProfile(), // Replace with actual edit profile screen
    ),
    GetPage(
      name: Routes.address,
      page: () => const Address(), // Replace with actual address screen
    ),
    GetPage(
      name: Routes.addAddress,
      page: () => const AddAddress(), // Replace with actual add address screen
    ),
    GetPage(
      name: Routes.notifications,
      page:
          () =>
              const Notifications(), // Replace with actual notifications screen
    ),
  ];
}
