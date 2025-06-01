import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons/buttons.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/custom_overlay.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../../generated/assets.dart';
import '../../../../components/image.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/utils/app_utils.dart';
import '../manager/location_bloc/location_bloc.dart';

class Location extends StatefulWidget {
  const Location({super.key});

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  final nav = GetIt.instance<NavigationService>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationBloc, LocationState>(
      listener: (context, state) {
        if (state is LocationSuccess) {
          DFoodUtils.showSnackBar("Location access granted", kSuccessColor);
          nav.navigateAndReplaceAll(Routes.home);
        } else if (state is LocationFailure) {
          DFoodUtils.showSnackBar(state.error, kErrorColor);
        }
      },
      child: CustomOverlay(
        isLoading: context.watch<LocationBloc>().state is LocationLoading,
        child: FScaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FoodContainer(
                  height: 250,
                  width: 206,
                  borderRadius: 90,
                  hasBorder: true,
                  child: Container(),
                ),
                94.verticalSpace,
                FButton(
                  buttonText: "ACCESS LOCATION",
                  icon: FImage(
                    assetType: FoodAssetType.svg,
                    assetPath: Assets.svgsLocationIcon,
                    width: 32,
                    height: 32,
                  ),
                  onPressed: () {
                    context.read<LocationBloc>().add(LocationRequestedEvent());
                  },
                ),
                37.verticalSpace,
                FWrapText(
                  text:
                      "DFOOD WILL ACCESS YOUR LOCATION ONLY WHILE USING THE APP",
                  color: kTextColorDark,
                ).paddingOnly(
                  left: AppConstants.defaultPadding.w,
                  right: AppConstants.defaultPadding.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
