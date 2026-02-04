import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';
import 'package:food/food/features/home/manager/user_profile/enhanced_user_profile_cubit.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:food/food/features/payments/presentation/screens/status.dart';
import 'package:get/utils.dart';
import 'package:get_it/get_it.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../components/texts.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/logger.dart';
import '../manager/cart/cart_cubit.dart';
import '../manager/paystack_bloc/paystack_payment_bloc.dart';
import '../manager/paystack_bloc/paystack_payment_event.dart';
import '../manager/paystack_bloc/paystack_payment_state.dart';
import '../manager/flutterwave_bloc/flutterwave_payment_bloc.dart';
import '../manager/flutterwave_bloc/flutterwave_payment_event.dart';
import '../manager/flutterwave_bloc/flutterwave_payment_state.dart';
import 'paystack_webview_screen.dart';
import 'flutterwave_webview_screen.dart';

class PaymentMethod extends StatefulWidget {
  const PaymentMethod({super.key});

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  final nav = GetIt.instance<NavigationService>();

  String selectedMethod = "Paystack";

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      appBarWidget: Row(
        children: [
          BackWidget(color: kGreyColor),
          20.horizontalSpace,
          FText(
            text: "Payment Method",
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
      customScroll: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          30.verticalSpace,
          FText(
            text: "Select Payment Method",
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: kTextColorDark,
          ),
          20.verticalSpace,
          _buildPaymentMethodCard(
            name: "Paystack",
            description: "Pay securely with your card via Paystack",
            icon: Ionicons.card_outline,
            color: const Color(0xFF00C3F7),
            isSelected: selectedMethod == "Paystack",
            onTap: () {
              setState(() {
                selectedMethod = "Paystack";
              });
            },
          ),
          16.verticalSpace,
          _buildPaymentMethodCard(
            name: "Flutterwave",
            description: "Pay securely with your card via Flutterwave",
            icon: Ionicons.wallet_outline,
            color: const Color(0xFFf5a623),
            isSelected: selectedMethod == "Flutterwave",
            onTap: () {
              setState(() {
                selectedMethod = "Flutterwave";
              });
            },
          ),
          40.verticalSpace,
          _buildPaymentDetails(),
        ],
      ).paddingSymmetric(horizontal: AppConstants.defaultPadding),
    );
  }

  void _processPayment() {
    final cartState = context.read<CartCubit>().state;
    if (!cartState.hasData) {
      DFoodUtils.showSnackBar(
        "Cart is empty. Please add items to your cart before proceeding.",
        kErrorColor,
      );
      return;
    }

    final user = context.read<UserProfileCubit>().state.data;
    if (user == null) {
      DFoodUtils.showSnackBar(
        "Please log in to continue with payment.",
        kErrorColor,
      );
      return;
    }

    if (selectedMethod == "Paystack") {
      _processPaystackPayment(cartState, user);
    } else if (selectedMethod == "Flutterwave") {
      _processFlutterwavePayment(cartState, user);
    }
  }

  void _processPaystackPayment(dynamic cartState, UserProfileEntity user) {
    final amount = cartState.data?.totalPrice ?? 0.0;

    // Log cart state data for debugging
    Logger.logBasic('💳 Payment Screen Cart Access:');
    Logger.logBasic('  HasData: ${cartState.hasData}');
    Logger.logBasic('  Items Length: ${cartState.data?.items?.length ?? 0}');
    Logger.logBasic('  Total Price: ${cartState.data?.totalPrice ?? 0.0}');
    Logger.logBasic('  State Type: ${cartState.runtimeType}');

    if (cartState.hasData && cartState.data?.items?.isNotEmpty == true) {
      Logger.logBasic('  Cart Items Available:');
      for (int i = 0; i < (cartState.data?.items?.length ?? 0); i++) {
        final item = cartState.data!.items[i];
        Logger.logBasic('    Item $i: ${item.name} x${item.quantity}');
        Logger.logBasic('      ImageURL: ${item.imageUrl}');
      }
    } else {
      Logger.logBasic('  No cart items available or cart state has no data');
    }

    // Show loading dialog
    DFoodUtils.showDialogContainer(
      context: context,
      child: BlocListener<PaystackPaymentBloc, PaystackPaymentState>(
        listener: (context, state) {
          if (state is PaystackPaymentInitialized) {
            nav.goBack(); // Close loading dialog

            // Check if authorizationUrl is available
            final authUrl = state.transaction.authorizationUrl;
            if (authUrl != null && authUrl.isNotEmpty) {
              _launchPaystackPayment(authUrl, state.transaction.reference);
            } else {
              // Handle error case where authorization URL is missing
              DFoodUtils.showSnackBar(
                "Failed to initiate payment. Please try again.",
                kErrorColor,
              );
            }
          } else if (state is PaystackPaymentVerified) {
            nav.goBack(); // Close loading dialog
            if (state.transaction.isSuccess) {
              // Payment successful
              nav.navigateAndReplace(
                Routes.statusScreen,
                arguments: PaymentStatusEnum.success,
              );
            } else {
              DFoodUtils.showSnackBar(
                "Payment failed. Please try again.",
                kErrorColor,
              );
            }
          } else if (state is PaystackPaymentError) {
            nav.goBack(); // Close loading dialog
            DFoodUtils.showSnackBar(state.message, kErrorColor);
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [CircularProgressIndicator(color: kWhiteColor)],
        ),
      ),
    );

    // Initialize Paystack payment
    context.read<PaystackPaymentBloc>().add(
      InitializePaystackPaymentEvent(
        orderId: "temp_order", // Will be replaced with actual reference
        amount: amount,
        email: user.email,
        metadata: {
          'userId': user.id,
          'userName':
              '${user.firstName} ${user.lastName}'.trim().isEmpty
                  ? user.email.split('@')[0]
                  : '${user.firstName} ${user.lastName}'.trim(),
          'orderItemsCount': cartState.data?.items?.length ?? 0,
          'items':
              cartState.data?.items
                  ?.map(
                    (item) => {
                      'id': item.id,
                      'name': item.name,
                      'description': item.description,
                      'price': item.price,
                      'quantity': item.quantity,
                      'imageUrl': item.imageUrl,
                      'restaurantId': item.restaurantId,
                      'restaurantName': item.restaurantName,
                      'category': item.category,
                      'preparationTime': item.preparationTime ?? '15-30 mins',
                      'ingredients': item.ingredients,
                      'totalPrice': item.price * item.quantity,
                    },
                  )
                  .toList() ??
              [],
          'subtotal': cartState.data?.totalPrice ?? 0.0,
          'deliveryFee':
              500.0, // Default delivery fee - can be calculated dynamically
          'tax': 0.0, // No tax for now
          'total': amount,
        },
      ),
    );
  }

  Future<void> _launchPaystackPayment(
    String authorizationUrl,
    String reference,
  ) async {
    // Navigate to in-app webview for payment
    // Use the Paystack reference as the orderId
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => PaystackWebviewScreen(
              authorizationUrl: authorizationUrl,
              reference: reference,
              orderId: reference, // Use reference as orderId
              onPaymentCompleted: () {
                // Payment completed - verify the payment
                _verifyPayment(reference);
              },
              onPaymentCancelled: () {
                // Payment cancelled - show message
                DFoodUtils.showSnackBar(
                  "Payment was cancelled. Please try again if needed.",
                  kErrorColor,
                );
              },
            ),
      ),
    );
  }

  void _processFlutterwavePayment(dynamic cartState, UserProfileEntity user) {
    final amount = cartState.data?.totalPrice ?? 0.0;
    final orderId = "temp_order_${DateTime.now().millisecondsSinceEpoch}";

    // Show loading dialog
    DFoodUtils.showDialogContainer(
      context: context,
      child: BlocListener<FlutterwavePaymentBloc, FlutterwavePaymentState>(
        listener: (context, state) {
          if (state is FlutterwavePaymentInitialized) {
            nav.goBack(); // Close loading dialog

            // Check if authorizationUrl is available
            final authUrl = state.transaction.authorizationUrl;
            if (authUrl != null && authUrl.isNotEmpty) {
              _launchFlutterwavePayment(authUrl, state.transaction.reference, orderId);
            } else {
              // Handle error case where authorization URL is missing
              DFoodUtils.showSnackBar(
                "Failed to initiate payment. Please try again.",
                kErrorColor,
              );
            }
          } else if (state is FlutterwavePaymentVerified) {
            nav.goBack(); // Close loading dialog
            if (state.transaction.isSuccess) {
              // Payment successful
              nav.navigateAndReplace(
                Routes.statusScreen,
                arguments: PaymentStatusEnum.success,
              );
            } else {
              DFoodUtils.showSnackBar(
                "Payment failed. Please try again.",
                kErrorColor,
              );
            }
          } else if (state is FlutterwavePaymentError) {
            nav.goBack(); // Close loading dialog
            DFoodUtils.showSnackBar(state.message, kErrorColor);
          }
        },
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: kWhiteColor),
            SizedBox(height: 16),
            FText(text: "Initializing payment...", color: kWhiteColor),
          ],
        ),
      ),
    );

    // Initialize Flutterwave payment
    context.read<FlutterwavePaymentBloc>().add(
      InitializeFlutterwavePaymentEvent(
        orderId: orderId,
        amount: amount,
        email: user.email,
        metadata: {
          'userId': user.id,
          'userName': '${user.firstName} ${user.lastName}',
          'phoneNumber': user.phoneNumber,
          'redirectUrl': 'https://example.com/success',
          // Add cart items
          'items': cartState.data?.items?.map((item) => {
                'name': item.name,
                'quantity': item.quantity,
                'price': item.price,
                'imageUrl': item.imageUrl,
              }).toList() ??
              [],
          'subtotal': cartState.data?.totalPrice ?? 0.0,
          'deliveryFee': 500.0,
          'tax': 0.0,
          'total': amount,
        },
      ),
    );
  }

  Future<void> _launchFlutterwavePayment(
    String authorizationUrl,
    String reference,
    String orderId,
  ) async {
    // Navigate to in-app webview for payment
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FlutterwaveWebviewScreen(
          authorizationUrl: authorizationUrl,
          reference: reference,
          orderId: orderId,
          onPaymentCompleted: () {
            // Payment completed - verify the payment
            _verifyFlutterwavePayment(reference);
          },
          onPaymentCancelled: () {
            // Payment cancelled - show message
            DFoodUtils.showSnackBar(
              "Payment was cancelled. Please try again if needed.",
              kErrorColor,
            );
          },
        ),
      ),
    );
  }

  void _verifyFlutterwavePayment(String reference) {
    // Show loading dialog
    DFoodUtils.showDialogContainer(
      context: context,
      child: BlocListener<FlutterwavePaymentBloc, FlutterwavePaymentState>(
        listener: (context, state) {
          if (state is FlutterwavePaymentVerified) {
            nav.goBack(); // Close loading dialog
            if (state.transaction.isSuccess) {
              // Payment successful
              nav.navigateAndReplace(
                Routes.statusScreen,
                arguments: PaymentStatusEnum.success,
              );
            } else {
              // Payment failed
              DFoodUtils.showSnackBar(
                "Payment verification failed",
                kErrorColor,
              );
            }
          } else if (state is FlutterwavePaymentError) {
            nav.goBack(); // Close loading dialog
            DFoodUtils.showSnackBar(state.message, kErrorColor);
          }
        },
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: kWhiteColor),
            SizedBox(height: 16),
            FText(text: "Verifying payment...", color: kWhiteColor),
          ],
        ),
      ),
    );

    // Verify payment
    context.read<FlutterwavePaymentBloc>().add(
      VerifyFlutterwavePaymentEvent(
        reference: reference,
        orderId: '', // Will be extracted from reference by the backend
      ),
    );
  }

  void _verifyPayment(String reference) {
    // Show loading dialog
    DFoodUtils.showDialogContainer(
      context: context,
      child: BlocListener<PaystackPaymentBloc, PaystackPaymentState>(
        listener: (context, state) {
          if (state is PaystackPaymentVerified) {
            nav.goBack(); // Close loading dialog
            if (state.transaction.isSuccess) {
              // Payment successful
              nav.navigateAndReplace(
                Routes.statusScreen,
                arguments: PaymentStatusEnum.success,
              );
            } else {
              // Payment failed
              DFoodUtils.showSnackBar(
                "Payment verification failed",
                kErrorColor,
              );
            }
          } else if (state is PaystackPaymentError) {
            nav.goBack(); // Close loading dialog
            DFoodUtils.showSnackBar(state.message, kErrorColor);
          }
        },
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: kWhiteColor),
            SizedBox(height: 16),
            FText(text: "Verifying payment...", color: kWhiteColor),
          ],
        ),
      ),
    );

    // Verify payment
    context.read<PaystackPaymentBloc>().add(
      VerifyPaystackPaymentEvent(
        reference: reference,
        orderId: '', // Will be extracted from reference by the backend
      ),
    );
  }

  Widget _buildOrderSummary() {
    return BlocBuilder<CartCubit, dynamic>(
      builder: (context, cartState) {
        if (!cartState.hasData) {
          return Container();
        }

        final cart = cartState.data;
        return FoodContainer(
          width: 1.sw,
          color: kGreyColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FText(
                text: "Order Summary",
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              15.verticalSpace,
              ...cart.items
                  .take(3)
                  .map(
                    (item) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: FText(
                              text: "${item.name} x${item.quantity}",
                              fontSize: 14,
                              color: kTextColorDark,
                            ),
                          ),
                          FText(
                            text:
                                "\$${(item.price * item.quantity).toStringAsFixed(1)}",
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                  ),
              if (cart.items.length > 3)
                FText(
                  text: "+ ${cart.items.length - 3} more items",
                  fontSize: 12,
                  color: kTextColorLight,
                ),
              Divider(color: kGreyColor),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FText(
                    text: "Total",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  FText(
                    text: "\$${cart.totalPrice.toStringAsFixed(1)}",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kPrimaryColor,
                  ),
                ],
              ),
            ],
          ).paddingAll(16),
        ).paddingOnly(right: AppConstants.defaultPadding);
      },
    );
  }

  Widget _buildPaymentMethodCard({
    required String name,
    required String description,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16).r,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : kWhiteColor,
          borderRadius: BorderRadius.circular(12).r,
          border: Border.all(
            color: isSelected ? color : kContainerColor.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12).r,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            16.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FText(
                    text: name,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextColorDark,
                  ),
                  4.verticalSpace,
                  FText(
                    text: description,
                    fontSize: 13,
                    color: kContainerColor,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Ionicons.checkmark_circle,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetails() {
    if (selectedMethod == "Paystack" || selectedMethod == "Flutterwave") {
      return SizedBox(
        width: 1.sw,
        child: FButton(
          onPressed: _processPayment,
          buttonText: "Proceed to Pay",
        ),
      );
    }
    return Container();
  }
}
