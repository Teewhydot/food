import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons.dart';
import 'package:food/food/components/permission_dialog.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/texts.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/custom_overlay.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../../generated/assets.dart';
import '../../../../components/image.dart';
import '../../../../core/bloc/bloc_manager.dart';
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
  void initState() {
    super.initState();
    // Check if location permission is already granted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationBloc>().add(LocationPermissionCheckEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocManager<LocationBloc, LocationState>(
      bloc: context.read<LocationBloc>(),
      listener: (context, state) {
        if (state is LocationPermissionRequired) {
          _showPermissionDialog(context);
        } else if (state is LocationPermissionGranted) {
          // Permission is already granted, proceed with location request
          context.read<LocationBloc>().add(LocationRequestedEvent());
        }
      },
      isError: (state) => state is LocationError,
      getErrorMessage: (state) => (state as LocationError).errorMessage,
      isSuccess: (state) => state is LocationSuccess,
      onSuccess: (context, state) {
        // Handle any additional success logic if needed
        DFoodUtils.showSnackBar("Location access granted", kSuccessColor);
        nav.navigateAndReplaceAll(Routes.home);
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

  void _showPermissionDialog(BuildContext context) {
    PermissionDialog.show(
      context: context,
      title: "Location Access",
      description:
          "DFood needs access to your location to deliver food to your address.",
      icon:
          Assets
              .svgsLocationIcon, // This path might need adjustment if it's not compatible with Image.asset
      permission: Permission.location,
      isMandatory: true, // Making it mandatory
      onGranted: () {
        // When permission is granted, request the location
        context.read<LocationBloc>().add(LocationRequestedEvent());
      },
      onDenied: () {
        // Show a message that location is required
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission is required to use this app'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }
}
