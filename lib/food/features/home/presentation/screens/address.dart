import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/helpers/extensions.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/features/home/domain/entities/address.dart';
import 'package:food/food/features/home/manager/address/address_cubit.dart';
import 'package:food/food/features/home/presentation/widgets/circle_widget.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:food/generated/assets.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../components/buttons.dart';
import '../../../../components/texts.dart';
import '../../../../core/bloc/managers/bloc_manager.dart';
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
    addressCubit.loadAddresses();
  }

  @override
  Widget build(BuildContext context) {
    final nav = GetIt.instance<NavigationService>();
    return BlocManager<AddressCubit, BaseState<dynamic>>(
      bloc: context.read<AddressCubit>(),
      showLoadingIndicator: true,
      builder: (context, state) {
        if (state is LoadedState) {
          final addresses = state.data as List? ?? [];
          return FScaffold(
            customScroll: false,
            appBarWidget: Row(
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
            body: Stack(
              fit: StackFit.expand,
              children: [
                SingleChildScrollView(
                  child: Column(
                    children:
                        addresses.map((address) {
                          return AddressWidget(
                            addressType:
                                address.type == 'home'
                                    ? AddressType.home
                                    : AddressType.work,
                            address: address,
                            onTapDelete: () {
                              context.read<AddressCubit>().deleteAddress(
                                address,
                              );
                            },
                            onTapEdit: () {
                              nav.navigateTo(
                                Routes.addAddress,
                                arguments: address,
                              );
                            },
                          );
                        }).toList(),
                  ).paddingSymmetric(horizontal: AppConstants.defaultPadding),
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: FButton(
                    buttonText: "Add new address",
                    width: 1.sw,
                    onPressed: () {
                      nav.navigateTo(
                        Routes.addAddress,
                        arguments: AddressEntity(
                          id: '',
                          street: '',
                          city: '',
                          state: '',
                          zipCode: '',
                          type: 'home',
                          address: '',
                          apartment: '',
                        ),
                      );
                    },
                  ).paddingSymmetric(horizontal: AppConstants.defaultPadding),
                ),
              ],
            ),
          );
        }
        if (state is EmptyState) {
          return FScaffold(
            customScroll: false,
            appBarWidget: Row(
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
            body: Stack(
              children: [
                Center(
                  child: FText(
                    text: "No addresses found.",
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: kGreyColor,
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
        }
        if (state is LoadingState) {
          return FScaffold(
            customScroll: false,
            appBarWidget: Row(
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
            body: Stack(
              children: [
                Center(
                  child: FText(
                    text: "Loading addresses...",
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: kGreyColor,
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
        }
        return const SizedBox.shrink();
      },
      child: const SizedBox.shrink(),
    );
  }
}

class AddressWidget extends StatelessWidget {
  final AddressType addressType;
  final AddressEntity address;
  final Function() onTapEdit, onTapDelete;

  const AddressWidget({
    super.key,
    required this.addressType,
    required this.address,
    required this.onTapDelete,
    required this.onTapEdit,
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
                        ).onTap(() {
                          onTapEdit();
                        }),
                        20.horizontalSpace,
                        FImage(
                          assetPath: Assets.svgsDeleteAddress,
                          width: 20,
                          height: 20,
                          assetType: FoodAssetType.svg,
                        ).onTap(() {
                          onTapDelete();
                        }),
                      ],
                    ),
                  ],
                ),
                10.verticalSpace,
                FWrapText(
                  text:
                      '${address.street}, ${address.apartment}, ${address.city}, ${address.state}, ${address.zipCode}',
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
