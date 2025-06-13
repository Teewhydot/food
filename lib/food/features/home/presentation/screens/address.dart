import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/features/home/manager/address/address_cubit.dart';
import 'package:food/food/features/home/manager/user_profile/user_profile_cubit.dart';
import 'package:food/food/features/home/presentation/widgets/circle_widget.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:food/generated/assets.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../components/buttons/buttons.dart';
import '../../../../components/texts/texts.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/widgets/back_widget.dart';

enum AddressType { home, work }

class Address extends StatefulWidget {
  const Address({super.key});

  @override
  State<Address> createState() => _AddressState();
}

class _AddressState extends State<Address> {
  @override
  void initState() {
    super.initState();
    final addressCubit = AddressCubit();
    final user = UserProfileCubit();
    print(user.userId);
    addressCubit.loadAddresses();
  }

  @override
  Widget build(BuildContext context) {
    final nav = GetIt.instance<NavigationService>();
    return BlocBuilder<AddressCubit, AddressState>(
      bloc: context.read<AddressCubit>(),
      builder: (context, state) {
        if (state is AddressLoaded) {
          if (state.addresses.isEmpty) {
            return Scaffold(
              extendBody: true,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(56.h),
                child: AppBar(
                  backgroundColor: kWhiteColor,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  title: Row(
                    children: [
                      BackWidget(color: kGreyColor),
                      20.horizontalSpace,
                      FText(
                        text: "Address",
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w400,
                        color: kBlackColor,
                      ),
                    ],
                  ),
                ),
              ),
              body: Center(
                child: FText(
                  text: "No addresses found",
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: kGreyColor,
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: FButton(
                buttonText: "Add new address",
                width: 1.sw,
                onPressed: () {
                  nav.navigateTo(Routes.addAddress);
                },
              ).paddingSymmetric(horizontal: AppConstants.defaultPadding),
            );
          }
          return Scaffold(
            extendBody: true,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(56.h),
              child: AppBar(
                backgroundColor: kWhiteColor,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    BackWidget(color: kGreyColor),
                    20.horizontalSpace,
                    FText(
                      text: "Address",
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w400,
                      color: kBlackColor,
                    ),
                  ],
                ),
              ),
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children:
                            state.addresses.map((address) {
                              return AddressWidget(
                                addressType:
                                    address.type == 'home'
                                        ? AddressType.home
                                        : AddressType.work,
                                address: address.city,
                              );
                            }).toList(),
                      ).paddingSymmetric(
                        horizontal: AppConstants.defaultPadding,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: FButton(
                    buttonText: "Add new address",
                    width: 1.sw,
                    onPressed: () {
                      nav.navigateTo(Routes.addAddress);
                    },
                  ).paddingSymmetric(horizontal: AppConstants.defaultPadding),
                ),
              ],
            ),
          );
        } else if (state is AddressError) {
          return Scaffold(
            extendBody: true,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(56.h),
              child: AppBar(
                backgroundColor: kWhiteColor,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    BackWidget(color: kGreyColor),
                    20.horizontalSpace,
                    FText(
                      text: "Address",
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w400,
                      color: kBlackColor,
                    ),
                  ],
                ),
              ),
            ),
            body: Center(
              child: FWrapText(
                text: state.errorMessage,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: kErrorColor,
              ),
            ),
          );
        }
        return Center(
          child: FText(
            text: "Loading addresses...",
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: kErrorColor,
          ),
        );
      },
    );
  }
}

class AddressWidget extends StatelessWidget {
  final AddressType addressType;
  final String address;

  const AddressWidget({
    super.key,
    required this.addressType,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return FoodContainer(
      width: 1.sw,
      height: 101,
      color: kTextFieldColor,
      borderRadius: 16,
      child: Row(
        children: [
          CircleWidget(
            radius: 24,
            color: kWhiteColor,
            child: FImage(
              width: 20,
              height: 20,
              assetType: FoodAssetType.svg,
              assetPath:
                  addressType == AddressType.home
                      ? Assets.svgsHomeAddress
                      : Assets.svgsWorkAddress,
            ),
          ),
          14.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FText(
                      text: addressType == AddressType.home ? "Home" : "Work",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    Row(
                      children: [
                        FImage(
                          assetPath: Assets.svgsEditAddress,
                          width: 20,
                          height: 20,
                          assetType: FoodAssetType.svg,
                        ),
                        20.horizontalSpace,
                        FImage(
                          assetPath: Assets.svgsDeleteAddress,
                          width: 20,
                          height: 20,
                          assetType: FoodAssetType.svg,
                        ),
                      ],
                    ),
                  ],
                ),
                10.verticalSpace,
                FWrapText(
                  text: address,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  textAlign: TextAlign.start,
                  textOverflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ).paddingAll(16),
    ).paddingOnly(bottom: 20);
  }
}
