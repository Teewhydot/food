import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/helpers/extensions.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:food/food/features/payments/domain/entities/payment_method_entity.dart';
import 'package:food/food/features/payments/presentation/screens/status.dart';
import 'package:food/food/features/payments/presentation/widgets/payment_type_widget.dart';
import 'package:food/generated/assets.dart';
import 'package:get/utils.dart';
import 'package:get_it/get_it.dart';

import '../../../../components/texts.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../manager/cart/cart_cubit.dart';
import '../manager/order_bloc/order_bloc.dart';
import '../manager/order_bloc/order_state.dart';
import '../manager/payment_bloc/payment_bloc.dart';
import '../manager/payment_bloc/payment_event.dart';
import '../manager/payment_bloc/payment_state.dart';

class PaymentMethod extends StatefulWidget {
  const PaymentMethod({super.key});

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  final nav = GetIt.instance<NavigationService>();

  List<PaymentMethodEntity> methods = [
    PaymentMethodEntity(
      id: '1',
      name: 'Cash',
      type: 'cash',
      iconUrl: Assets.svgsCash,
    ),
    PaymentMethodEntity(
      id: '2',
      name: 'Visa',
      type: 'card',
      iconUrl: Assets.svgsVisa,
    ),
    PaymentMethodEntity(
      id: '3',
      name: 'Mastercard',
      type: 'card',
      iconUrl: Assets.svgsMastercard,
    ),
    PaymentMethodEntity(
      id: '4',
      name: 'Paypal',
      type: 'paypal',
      iconUrl: Assets.svgsPaypal,
    ),
  ];
  List<CardEntity> cards = [
    // CardEntity(
    //   paymentMethodEntity: PaymentMethodEntity(
    //     id: '2',
    //     name: 'Visa',
    //     type: 'card',
    //     iconUrl: Assets.svgsVisa,
    //   ),
    //   pan: 1234567812345678,
    //   cvv: 123,
    //   mExp: 12,
    //   yExp: 25,
    // ),
    // Add more cards if needed
    CardEntity(
      paymentMethodEntity: PaymentMethodEntity(
        id: '3',
        name: 'Mastercard',
        type: 'card',
        iconUrl: Assets.svgsMastercard,
      ),
      pan: 8765432187654321,
      cvv: 456,
      mExp: 11,
      yExp: 24,
    ),
    CardEntity(
      paymentMethodEntity: PaymentMethodEntity(
        id: '3',
        name: 'Mastercard',
        type: 'card',
        iconUrl: Assets.svgsMastercard,
      ),
      pan: 8777228377654321,
      cvv: 436,
      mExp: 11,
      yExp: 24,
    ),
  ];
  String selectedMethod = "Cash";

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
      ).paddingOnly(left: AppConstants.defaultPadding),
    );
  }

  void _processPayment(CardEntity? card) {
    // Get cart state
    final cartState = context.read<CartCubit>().state;
    if (cartState is! CartLoaded) {
      DFoodUtils.showSnackBar(
        "Cart is empty. Please add items to your cart before proceeding.",
        kErrorColor,
      );
      return;
    }

    // Show loading dialog
    DFoodUtils.showDialogContainer(
      context: context,
      child: BlocListener<OrderBloc, OrderState>(
        listener: (context, orderState) {
          if (orderState is OrderCreated) {
            // Process payment after order is created
            context.read<PaymentBloc>().add(
              ProcessPaymentEvent(
                amount: cartState.totalPrice,
                paymentMethodId: selectedMethod,
                currency: "NGN",
                metadata: {},
              ),
            );
          } else if (orderState is OrderError) {
            nav.goBack();
            DFoodUtils.showSnackBar(orderState.message, kSuccessColor);
          }
        },
        child: BlocListener<PaymentBloc, PaymentState>(
          listener: (context, paymentState) {
            if (paymentState is PaymentProcessed) {
              nav.goBack();
              // Clear cart
              // context.read<CartCubit>().clearCart();
              // Navigate to success screen
              nav.navigateAndReplace(
                Routes.statusScreen,
                arguments: PaymentStatusEnum.success,
              );
            } else if (paymentState is PaymentError) {
              nav.goBack();
              DFoodUtils.showSnackBar(paymentState.message, kErrorColor);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: kPrimaryColor),
              20.verticalSpace,
              FText(
                text: "Processing payment...",
                fontSize: 16,
                color: kTextColorDark,
              ),
            ],
          ),
        ),
      ),
    );

    // Create order
    final orderItems =
        cartState.items
            .map(
              (item) => OrderItem(
                foodId: item.id,
                foodName: item.name,
                quantity: item.quantity,
                price: item.price,
                total: item.price * item.quantity,
              ),
            )
            .toList();

    // context.read<OrderBloc>().add(
    //   CreateOrderEvent(
    //     OrderEntity(
    //       id: Uuid().v4(),
    //       userId:
    //     )
    //   ),
    // );
  }

  Widget _buildPaymentDetails() {
    // Filter cards based on selectedMethod
    List<CardEntity> filteredCards =
        cards
            .where((card) => card.paymentMethodEntity.name == selectedMethod)
            .toList();

    if (selectedMethod == "Cash" || selectedMethod == "Paypal") {
      return Column(
        children: [
          Center(
            child: FText(
              text: "Selected: $selectedMethod",
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          40.verticalSpace,
          SizedBox(
            width: 1.sw - (AppConstants.defaultPadding * 2),
            child: ElevatedButton(
              onPressed: () => _processPayment(null),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: FText(
                text: "Proceed with $selectedMethod",
                color: kWhiteColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    } else if (filteredCards.isEmpty) {
      return Column(
        children: [
          FoodContainer(
            height: 257,
            width: 1.sw,
            color: kGreyColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FImage(
                  assetPath: Assets.svgsEmptyCard,
                  width: 100,
                  height: 100,
                  assetType: FoodAssetType.svg,
                ),
                20.verticalSpace,
                FText(
                  text: "No Cards Added for $selectedMethod",
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                10.verticalSpace,
                FText(
                  text: "Add your card to make payments",
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ).paddingOnly(right: AppConstants.defaultPadding),
        ],
      );
    } else {
      return Column(
        children: [
          ...filteredCards.map(
            (card) => PaymentCardWidget(
              card: card,
              onTap: () => _processPayment(card),
            ).paddingOnly(right: AppConstants.defaultPadding, bottom: 20.h),
          ),
          20.verticalSpace,
        ],
      );
    }
  }
}

class PaymentCardWidget extends StatelessWidget {
  final CardEntity card;
  final Function onTap;
  const PaymentCardWidget({super.key, required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FoodContainer(
      height: 82,
      width: 1.sw,
      color: kGreyColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FText(
                text: card.paymentMethodEntity.name,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              5.verticalSpace,
              Row(
                children: [
                  FImage(
                    assetPath:
                        card.paymentMethodEntity.name == "Mastercard"
                            ? Assets.svgsMastercard
                            : Assets.svgsVisa,
                    width: 28,
                    height: 17,
                    assetType: FoodAssetType.svg,
                  ),
                  10.horizontalSpace,
                  FText(
                    text:
                        "**** ${card.pan.toString().substring(card.pan.toString().length - 4)}",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: kBlackColor,
                  ),
                ],
              ),
            ],
          ),
          FImage(
            assetPath: Assets.svgsArrowDown,
            width: 10,
            height: 10,
            assetType: FoodAssetType.svg,
          ),
        ],
      ).paddingAll(10),
    ).onTap(() {
      onTap();
    });
  }
}
