import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/textfields.dart';
import 'package:food/food/components/texts.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/helpers/extensions.dart';
import 'package:food/food/core/services/floor_db_service/user_profile/user_profile_database_service.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/auth/presentation/widgets/custom_overlay.dart';
import 'package:food/food/features/home/domain/entities/address.dart';
import 'package:food/food/features/home/manager/address/address_cubit.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/bloc/managers/bloc_manager.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/utils/app_utils.dart';

class AddAddress extends StatefulWidget {
  final AddressEntity addressEntity;

  const AddAddress({super.key, required this.addressEntity});
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
  final addressController = TextEditingController();
  final db = UserProfileDatabaseService();
  String? selectedLabel;
  List<String> labels = ["home", "work", "other"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final address = widget.addressEntity;
      streetController.text = address.street;
      cityController.text = address.city;
      stateController.text = address.state;
      postCodeController.text = address.zipCode;
      apartmentController.text = address.apartment;
      selectedLabel = address.type;
      addressController.text = address.address;
    });
  }

  @override
  void dispose() {
    super.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    postCodeController.dispose();
    apartmentController.dispose();
    addressController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocManager<AddressCubit, BaseState<dynamic>>(
      bloc: context.read<AddressCubit>(),
      showLoadingIndicator: true,
      onSuccess: (context, state) {
        nav.goBack();
        DFoodUtils.showSnackBar("Address saved successfully", kSuccessColor);
      },
      builder: (context, state) {
        return CustomOverlay(
          isLoading: state is LoadingState,
          child: FScaffold(
            customScroll: false,
            resizeToAvoidBottomInset: false,
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
                    FTextField(
                      hintText: "Address",
                      action: TextInputAction.next,
                      controller: addressController,
                    ),
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
                    Row(
                      spacing: 15,
                      children: [
                        Expanded(
                          child: FTextField(
                            hintText: "City",
                            action: TextInputAction.next,
                            controller: cityController,
                          ),
                        ),
                        Expanded(
                          child: FTextField(
                            hintText: "State",
                            action: TextInputAction.next,
                            controller: stateController,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (String label in labels)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedLabel = label;
                              });
                            },
                            child: Container(
                              width: 95.w,
                              height: 45.h,
                              decoration: BoxDecoration(
                                color:
                                    selectedLabel == label
                                        ? kPrimaryColor
                                        : kGreyColor,
                                borderRadius: BorderRadius.circular(22.r),
                              ),
                              alignment: Alignment.center,
                              child: FText(
                                text: label.toSentenceCase(),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color:
                                    selectedLabel == label
                                        ? Colors.white
                                        : Colors.black,
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
                    if (widget.addressEntity.address.isNotEmpty) {
                      final address = AddressEntity(
                        id: widget.addressEntity.id,
                        apartment: apartmentController.text,
                        address: addressController.text,
                        street: streetController.text,
                        city: cityController.text,
                        state: stateController.text,
                        zipCode: postCodeController.text,
                        type: selectedLabel!,
                      );
                      context.read<AddressCubit>().updateAddress(address);
                    } else {
                      final address = AddressEntity(
                        id: Uuid().v4(),
                        apartment: apartmentController.text,
                        address: addressController.text,
                        street: streetController.text,
                        city: cityController.text,
                        state: stateController.text,
                        zipCode: postCodeController.text,
                        type: selectedLabel!,
                      );
                      context.read<AddressCubit>().addAddress(address);
                    }
                  },
                ),
              ],
            ).paddingOnly(
              left: AppConstants.defaultPadding,
              right: AppConstants.defaultPadding,
              bottom: AppConstants.defaultPadding,
            ),
          ),
        );
      },
      child: const SizedBox.shrink(),
    );
  }
}
