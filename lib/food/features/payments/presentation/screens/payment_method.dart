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
import 'package:food/food/features/payments/domain/entities/payment_method_entity.dart';
import 'package:food/food/features/payments/presentation/screens/status.dart';
import 'package:food/food/features/payments/presentation/widgets/payment_type_widget.dart';
import 'package:food/generated/assets.dart';
import 'package:get/utils.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../components/texts.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/utils/app_utils.dart';
import '../manager/cart/cart_cubit.dart';
import '../manager/paystack_bloc/paystack_payment_bloc.dart';
import '../manager/paystack_bloc/paystack_payment_event.dart';
import '../manager/paystack_bloc/paystack_payment_state.dart';

class PaymentMethod extends StatefulWidget {
  const PaymentMethod({super.key});

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  final nav = GetIt.instance<NavigationService>();

  List<PaymentMethodEntity> methods = [
    PaymentMethodEntity(
      id: 'paystack',
      name: 'Paystack',
      type: 'card',
      iconUrl: Assets.svgsMastercard,
    ),
    PaymentMethodEntity(
      id: 'flutterwave',
      name: 'Flutterwave',
      type: 'card',
      iconUrl: Assets.svgsVisa,
    ),
  ];
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
        children: [
          30.verticalSpace,
          _buildOrderSummary(),
          30.verticalSpace,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 10,
              children: [
                ...methods.map((method) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMethod = method.name;
                      });
                    },
                    child: PaymentTypeWidget(
                      image: method.iconUrl,
                      title: method.name,
                      width: 24,
                      height: 24,
                      isSelected: selectedMethod == method.name,
                    ),
                  );
                }),
              ],
            ),
          ),
          30.verticalSpace,
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

    final user = context.read<EnhancedUserProfileCubit>().state.data;
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
      DFoodUtils.showSnackBar(
        "Flutterwave payment is not implemented yet.",
        kErrorColor,
      );
    }
  }

  void _processPaystackPayment(dynamic cartState, UserProfileEntity user) {
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    final amount = cartState.data?.totalPrice ?? 0.0;

    // Show loading dialog
    DFoodUtils.showDialogContainer(
      context: context,
      child: BlocListener<PaystackPaymentBloc, PaystackPaymentState>(
        listener: (context, state) {
          if (state is PaystackPaymentInitialized) {
            nav.goBack(); // Close loading dialog
            _launchPaystackPayment(
              state.transaction.authorizationUrl!,
              state.transaction.reference,
            );
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
          children: [
            CircularProgressIndicator(color: kPrimaryColor),
            20.verticalSpace,
            FText(
              text: "Initializing payment...",
              fontSize: 16,
              color: kTextColorDark,
            ),
          ],
        ),
      ),
    );

    // Initialize Paystack payment
    context.read<PaystackPaymentBloc>().add(
      InitializePaystackPaymentEvent(
        orderId: orderId,
        amount: amount,
        email: user.email ?? '',
        metadata: {
          'userId': user.id,
          'orderItems': cartState.data?.items?.length ?? 0,
        },
      ),
    );
  }

  Future<void> _launchPaystackPayment(
    String authorizationUrl,
    String reference,
  ) async {
    final Uri url = Uri.parse(authorizationUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);

      // Show dialog to verify payment after user returns
      _showPaymentVerificationDialog(reference);
    } else {
      DFoodUtils.showSnackBar(
        "Could not launch payment page. Please try again.",
        kErrorColor,
      );
    }
  }

  void _showPaymentVerificationDialog(String reference) {
    DFoodUtils.showDialogContainer(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FText(
            text: "Payment Status",
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          20.verticalSpace,
          FText(
            text: "Have you completed the payment?",
            fontSize: 16,
            textAlign: TextAlign.center,
          ),
          30.verticalSpace,
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    nav.goBack(); // Close dialog
                    _verifyPayment(reference);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: FText(
                    text: "Yes, Verify",
                    color: kWhiteColor,
                    fontSize: 14,
                  ),
                ),
              ),
              10.horizontalSpace,
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    nav.goBack(); // Close dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreyColor,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: FText(
                    text: "Cancel",
                    color: kBlackColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _verifyPayment(String reference) {
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();

    // Show loading dialog
    DFoodUtils.showDialogContainer(
      context: context,
      child: BlocListener<PaystackPaymentBloc, PaystackPaymentState>(
        listener: (context, state) {
          if (state is PaystackPaymentVerified) {
            nav.goBack(); // Close loading dialog
            if (state.transaction.isSuccess) {
              nav.navigateAndReplace(
                Routes.statusScreen,
                arguments: PaymentStatusEnum.success,
              );
            } else {
              DFoodUtils.showSnackBar(
                "Payment verification failed. Please try again.",
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
          children: [
            CircularProgressIndicator(color: kPrimaryColor),
            20.verticalSpace,
            FText(
              text: "Verifying payment...",
              fontSize: 16,
              color: kTextColorDark,
            ),
          ],
        ),
      ),
    );

    // Verify payment
    context.read<PaystackPaymentBloc>().add(
      VerifyPaystackPaymentEvent(reference: reference, orderId: orderId),
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

  Widget _buildPaymentDetails() {
    if (selectedMethod == "Paystack" || selectedMethod == "Flutterwave") {
      return Column(
        children: [
          FText(
            text:
                selectedMethod == "Paystack"
                    ? "Secure card payment with Paystack"
                    : "Payment with Flutterwave (Coming Soon)",
            fontSize: 14,
            color: kTextColorDark,
            textAlign: TextAlign.center,
          ),
          40.verticalSpace,
          SizedBox(
            width: 1.sw,
            child: FButton(
              onPressed: selectedMethod == "Paystack" ? _processPayment : null,
              buttonText:
                  selectedMethod == "Paystack"
                      ? "Proceed to Pay"
                      : "Coming Soon",
            ),
          ),
        ],
      );
    }
    return Container();
  }
}
