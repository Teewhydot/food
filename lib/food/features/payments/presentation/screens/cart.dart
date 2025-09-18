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
import 'package:food/food/features/home/manager/selected_address/selected_address_cubit.dart';
import 'package:food/food/features/home/presentation/widgets/address_selection_bottom_sheet.dart';
import 'package:food/food/features/payments/presentation/manager/cart/cart_cubit.dart';
import 'package:food/food/features/tracking/presentation/widgets/cart_widget.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../components/buttons.dart';
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

  void _showAddressSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: const AddressSelectionBottomSheet(),
          ),
    );
  }

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
                        GestureDetector(
                          onTap: () {
                            _showAddressSelectionBottomSheet(context);
                          },
                          child: FText(
                            text: "Change".toUpperCase(),
                            fontSize: 14,
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                    10.verticalSpace,
                    _AddressSelectionWidget(),
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
                              "\$${cartData.totalPrice.toStringAsFixed(1).toUpperCase()}",
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
        } else if (state is EmptyState) {
          return FScaffold(
            customScroll: false,
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

class _AddressSelectionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocManager<SelectedAddressCubit, BaseState<dynamic>>(
      bloc: context.read<SelectedAddressCubit>(),
      showLoadingIndicator: false,
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder:
                  (context) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: const AddressSelectionBottomSheet(),
                  ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: kContainerColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: kGreyColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Ionicons.location_outline, size: 20.sp, color: kGreyColor),
                12.horizontalSpace,
                Expanded(child: _buildAddressText(state)),
                8.horizontalSpace,
                Icon(Ionicons.chevron_down, size: 16.sp, color: kGreyColor),
              ],
            ),
          ),
        );
      },
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildAddressText(BaseState state) {
    if (state is LoadingState) {
      return FText(text: "Loading address...", fontSize: 14, color: kGreyColor);
    } else if (state is LoadedState && state.data != null) {
      final selectedAddress = state.data;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedAddress.title != null) ...[
            FText(
              text: selectedAddress.title!,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: kTextColorDark,
            ),
            2.verticalSpace,
          ],
          FText(
            text: selectedAddress.fullAddress,
            fontSize: 13,
            color: kGreyColor,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    } else {
      return FText(
        text: "Select delivery address",
        fontSize: 14,
        color: kGreyColor,
      );
    }
  }
}
