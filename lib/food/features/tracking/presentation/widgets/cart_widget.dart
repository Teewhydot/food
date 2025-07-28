import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:food/food/features/payments/presentation/manager/cart/cart_cubit.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/bloc/bloc_manager.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../home/domain/entities/food.dart';
import '../../../home/presentation/widgets/circle_widget.dart';

class DFoodCartWidget extends StatelessWidget {
  final FoodEntity foodEntity;
  final int size;
  final bool editMode;

  const DFoodCartWidget({
    super.key,
    required this.foodEntity,
    required this.size,
    this.editMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocManager<CartCubit, CartState>(
      bloc: context.read<CartCubit>(),
      child: Container(),
      isError: (state) => state is CartError,
      getErrorMessage: (state) =>
          state is CartError
              ? state.errorMessage
              : AppConstants.defaultErrorMessage,
      builder: (context, state) {
        return Row(
          children: [
            FoodContainer(
              width: 140,
              height: 120,
              color: kContainerColor,
              child: Container(),
            ),
            20.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FWrapText(
                    text: foodEntity.name,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: kWhiteColor,
                    alignment: Alignment.centerLeft,
                  ),
                  10.verticalSpace,
                  FText(
                    text: "\$${foodEntity.price}",
                    alignment: MainAxisAlignment.start,
                    color: kGreyColor,
                  ),
                  FWrapText(
                    text: "Total: \$${foodEntity.price * foodEntity.quantity}",
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: kWhiteColor,
                    alignment: Alignment.centerLeft,
                  ),
                  17.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FText(
                        text: "$size``",
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: kWhiteColor,
                      ),
                      if (editMode)
                        Row(
                          children: [
                            CircleWidget(
                              radius: 12,
                              color: kGreyColor,
                              child: Icon(Ionicons.remove),
                              onTap: () {
                                context.read<CartCubit>().removeFood(
                                  foodEntity,
                                );
                              },
                            ),
                            17.horizontalSpace,
                            FText(
                              text: foodEntity.quantity.toString(),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: kWhiteColor,
                            ),
                            17.horizontalSpace,
                            CircleWidget(
                              radius: 12,
                              color: kGreyColor,
                              child: Icon(Ionicons.add),
                              onTap: () {
                                context.read<CartCubit>().addFood(foodEntity);
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ).paddingOnly(bottom: 20);
      },
    );
  }
}
