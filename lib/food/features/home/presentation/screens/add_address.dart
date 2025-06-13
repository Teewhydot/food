import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons/buttons.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/textfields.dart';
import 'package:food/food/components/texts/texts.dart';
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

import '../../../../core/services/navigation_service/nav_config.dart';

class AddAddress extends StatefulWidget {
  final AddressEntity? addressEntity;

  const AddAddress({super.key, this.addressEntity});
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
  int userId = 0;
  String? selectedLabel;
  List<String> labels = ["home", "work", "other"];

  @override
  void initState() {
    super.initState();
    if (widget.addressEntity != null) {
      final address = widget.addressEntity!;
      streetController.text = address.street;
      cityController.text = address.city;
      stateController.text = address.state;
      postCodeController.text = address.zipCode;
      apartmentController.text = address.street.split(',').first;
      addressController.text = address.street.split(',').last;
      selectedLabel = address.type;
    } else {
      selectedLabel = labels.first; // Default to the first label
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
    addressController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddressCubit, AddressState>(
      listener: (context, state) {},
      child: CustomOverlay(
        isLoading: context.read<AddressCubit>().state is AddressLoading,
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
                  final address = AddressEntity(
                    id: Uuid().v4(),
                    street:
                        "${apartmentController.text}, ${addressController.text}",
                    city: cityController.text,
                    state: stateController.text,
                    zipCode: postCodeController.text,
                    type: selectedLabel!,
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
