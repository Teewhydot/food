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
    GetPage(name: Routes.search, page: () => const Search()),
    GetPage(name: Routes.food, page: () => const Food()),
    GetPage(name: Routes.foodDetails, page: () => const FoodDetails()),
    GetPage(
      name: Routes.restaurantDetails,
      page: () => const RestaurantDetails(),
    ),
    GetPage(name: Routes.cart, page: () => const Cart()),
    GetPage(name: Routes.paymentMethod, page: () => const PaymentMethod()),
    GetPage(name: Routes.addCard, page: () => const AddCard()),
    GetPage(name: Routes.statusScreen, page: () => const PaymentStatus()),
    GetPage(name: Routes.tracking, page: () => const TrackingOrder()),
    GetPage(name: Routes.callScreen, page: () => const CallScreen()),
    GetPage(name: Routes.chatScreen, page: () => const ChatScreen()),
    GetPage(name: Routes.profile, page: () => const PersonalInfo()),
    GetPage(name: Routes.editProfile, page: () => const EditProfile()),
    GetPage(name: Routes.address, page: () => const Address()),
    GetPage(name: Routes.addAddress, page: () => const AddAddress()),
    GetPage(name: Routes.notifications, page: () => const Notifications()),
  ];
}
