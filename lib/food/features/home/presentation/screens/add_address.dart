import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons/buttons.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/textfields.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/services/floor_db_service/user_profile/user_profile_database_service.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/auth/presentation/widgets/custom_overlay.dart';
import 'package:food/food/features/home/domain/entities/address.dart';
import 'package:food/food/features/home/manager/address/address_cubit.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/services/navigation_service/nav_config.dart';

class AddAddress extends StatefulWidget {
  const AddAddress({super.key});

  @override
  State<AddAddress> createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  final nav = GetIt.instance<NavigationService>();

  // controllers
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final postCodeController = TextEditingController();
  final apartmentController = TextEditingController();
  final db = UserProfileDatabaseService();
  String userId = "";

  @override
  void initState() async {
    super.initState();
    // Fetch user ID from the database
    final user = await (await db.database).userProfileDao.getUserProfile();
    if (user != null) {
      userId = user.id.toString();
    }
  }

  @override
  void dispose() {
    super.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    postCodeController.dispose();
    apartmentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddressCubit, AddressState>(
      listener: (context, state) {},
      child: CustomOverlay(
        isLoading: context.read<AddressCubit>().state is AddressLoading,
        child: FScaffold(
          appBarWidget: Row(
            children: [
              BackWidget(color: kGreyColor),
              10.horizontalSpace,
              FText(
                text: "Add new address",
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  30.verticalSpace,
                  FTextField(hintText: "Address", action: TextInputAction.next),
                  10.verticalSpace,
                  Row(
                    spacing: 15,
                    children: [
                      Expanded(
                        child: FTextField(
                          hintText: "Street",
                          action: TextInputAction.next,
                          controller: streetController,
                        ),
                      ),
                      Expanded(
                        child: FTextField(
                          hintText: "Post code",
                          action: TextInputAction.next,
                          controller: postCodeController,
                        ),
                      ),
                    ],
                  ),
                  10.verticalSpace,
                  FTextField(
                    hintText: "Apartment",
                    action: TextInputAction.next,
                    controller: apartmentController,
                  ),
                  30.verticalSpace,
                  FText(
                    text: "Label as".toUpperCase(),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    alignment: MainAxisAlignment.start,
                  ),
                  10.verticalSpace,
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: FoodContainer(
                          width: 95,
                          height: 45,
                          color: kGreyColor,
                          borderRadius: 22,
                          child: FText(
                            text: "Home",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            alignment: MainAxisAlignment.center,
                          ),
                        ),
                      ),
                      Expanded(
                        child: FoodContainer(
                          width: 95,
                          height: 45,
                          color: kGreyColor,
                          borderRadius: 22,
                          child: FText(
                            text: "Work",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            alignment: MainAxisAlignment.center,
                          ),
                        ),
                      ),
                      Expanded(
                        child: FoodContainer(
                          width: 95,
                          height: 45,
                          color: kGreyColor,
                          borderRadius: 22,
                          child: FText(
                            text: "Other",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            alignment: MainAxisAlignment.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              FButton(
                buttonText: "Save Address",
                width: 1.sw,
                onPressed: () {
                  final address = AddressEntity(
                    street: streetController.text,
                    city: cityController.text,
                    state: stateController.text,
                    userId: userId,
                    zipCode: postCodeController.text,
                  );
                  context.read<AddressCubit>().addAddress(address);
                  nav.goBack();
                },
              ),
            ],
          ).paddingOnly(
            left: AppConstants.defaultPadding,
            right: AppConstants.defaultPadding,
            bottom: AppConstants.defaultPadding,
          ),
        ),
      ),
    );
  }
}
