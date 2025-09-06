import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/texts.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/helpers/extensions.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/payments/presentation/manager/cart/cart_cubit.dart';
import 'package:food/food/features/tracking/presentation/widgets/cart_widget.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../components/buttons.dart';
import '../../../../components/textfields.dart';
import '../../../../core/bloc/managers/bloc_manager.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service/nav_config.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  bool editMode = false;

  @override
  Widget build(BuildContext context) {
    final nav = GetIt.instance<NavigationService>();
    return BlocManager<CartCubit, BaseState<dynamic>>(
      bloc: context.read<CartCubit>(),
      showLoadingIndicator: true,
      builder: (context, state) {
        if (state.hasData) {
          final cartData = state.data;
          if (cartData.items.isEmpty) {
            return FScaffold(
              customScroll: true,
              appBarColor: kScaffoldColorDark,
              backgroundColor: kScaffoldColorDark,
              appBarWidget: Row(
                children: [
                  BackWidget(),
                  20.horizontalSpace,
                  FText(text: "Cart", color: kWhiteColor),
                  Spacer(),
                ],
              ),
              body: Column(
                children: [
                  200.verticalSpace,
                  FText(
                    text: "Your cart is empty",
                    color: kWhiteColor,
                    fontSize: 18,
                  ),
                ],
              ),
            );
          }
          return FScaffold(
            customScroll: true,
            appBarColor: kScaffoldColorDark,
            appBarWidget: Row(
              children: [
                BackWidget(),
                18.horizontalSpace,
                FText(text: "Cart", color: kWhiteColor),
                Spacer(),
                FText(
                  text:
                      editMode
                          ? "Save".toUpperCase()
                          : "Edit cart".toUpperCase(),
                  color: kPrimaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.underline,
                  onTap: () {
                    setState(() {
                      editMode = !editMode;
                    });
                  },
                ),
              ],
            ).paddingOnly(right: AppConstants.defaultPadding),
            backgroundColor: kScaffoldColorDark,
            bottomWidget: IntrinsicHeight(
              child: Container(
                width: 1.sw,
                decoration: BoxDecoration(
                  color: kWhiteColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FText(
                          text: "Delivery address".toUpperCase(),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        FText(
                          text: "Edit".toUpperCase(),
                          fontSize: 14,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                        ),
                      ],
                    ),
                    10.verticalSpace,
                    FTextField(
                      hintText: "Address",
                      action: TextInputAction.next,
                    ),
                    30.verticalSpace,
                    Row(
                      children: [
                        FText(
                          text: "Total:".toUpperCase(),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        10.horizontalSpace,
                        FText(
                          text:
                              "\$${cartData.totalPrice.toStringAsFixed(0).toUpperCase()}",
                          fontSize: 30,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                    ),
                    30.verticalSpace,
                    FButton(
                      buttonText: "Place order",
                      width: 1.sw,
                      onPressed: () {
                        nav.navigateTo(Routes.paymentMethod);
                      },
                    ),
                  ],
                ).paddingAll(AppConstants.defaultPadding),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  30.verticalSpace,
                  ...cartData.items.map((cartItem) {
                    return DFoodCartWidget(
                      foodEntity: cartItem,
                      size: cartItem.quantity,
                      editMode: editMode,
                    );
                  }),
                  400.verticalSpace,
                ],
              ).paddingSymmetric(horizontal: AppConstants.defaultPadding),
            ),
          );
        } else if (state is LoadingState) {
          return FScaffold(
            customScroll: true,
            backgroundColor: kScaffoldColorDark,
            body: Center(
              child: FText(
                text: "Your cart is empty",
                color: kWhiteColor,
                fontSize: 18,
              ),
            ),
          ).skeletonize();
        }
        return SizedBox();
      },
      child: const SizedBox.shrink(),
    );
  }
}
