import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/texts.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/bloc/managers/bloc_manager.dart';
import 'package:food/food/core/helpers/user_extensions.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/home/domain/entities/address.dart';
import 'package:food/food/features/home/manager/address/address_cubit.dart';
import 'package:food/food/features/home/manager/selected_address/selected_address_cubit.dart';
import 'package:ionicons/ionicons.dart';

class AddressSelectionBottomSheet extends StatelessWidget {
  final Function(AddressEntity)? onAddressSelected;

  const AddressSelectionBottomSheet({super.key, this.onAddressSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 12.h, bottom: 20.h),
            decoration: BoxDecoration(
              color: kGreyColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FText(
                  text: "Select Delivery Address",
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: kTextColorDark,
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Ionicons.close, size: 24.sp, color: kGreyColor),
                ),
              ],
            ),
          ),

          20.verticalSpace,

          // Address List
          Flexible(
            child: BlocManager<AddressCubit, BaseState<dynamic>>(
              bloc:
                  context.read<AddressCubit>()
                    ..loadAddresses(context.readCurrentUserId ?? ""),
              showLoadingIndicator: false,
              builder: (context, state) {
                if (state is LoadingState) {
                  return SizedBox(
                    height: 200.h,
                    child: Center(
                      child: CircularProgressIndicator(color: kPrimaryColor),
                    ),
                  );
                } else if (state is LoadedState<List<AddressEntity>>) {
                  final addresses = state.data ?? [];

                  if (addresses.isEmpty) {
                    return SizedBox(
                      height: 200.h,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Ionicons.location_outline,
                            size: 48.sp,
                            color: kGreyColor,
                          ),
                          16.verticalSpace,
                          FText(
                            text: "No addresses found",
                            fontSize: 16,
                            color: kGreyColor,
                          ),
                          8.verticalSpace,
                          FText(
                            text: "Add your first delivery address",
                            fontSize: 14,
                            color: kGreyColor,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      final address = addresses[index];
                      return _AddressListItem(
                        address: address,
                        onTap: () {
                          // Update selected address cubit
                          context.read<SelectedAddressCubit>().selectAddress(
                            address,
                          );

                          // Call callback if provided
                          onAddressSelected?.call(address);

                          // Close bottom sheet
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                } else if (state is ErrorState) {
                  return SizedBox(
                    height: 200.h,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Ionicons.alert_circle_outline,
                          size: 48.sp,
                          color: Colors.red,
                        ),
                        16.verticalSpace,
                        FText(
                          text: "Error loading addresses",
                          fontSize: 16,
                          color: Colors.red,
                        ),
                        8.verticalSpace,
                        FText(
                          text: state.errorMessage,
                          fontSize: 14,
                          color: kGreyColor,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return SizedBox(height: 200.h);
              },
              child: const SizedBox.shrink(),
            ),
          ),

          20.verticalSpace,

          // Add New Address Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                // Navigate to add address screen
                // You can add navigation logic here
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: kPrimaryColor, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Ionicons.add, size: 20.sp, color: kPrimaryColor),
                    8.horizontalSpace,
                    FText(
                      text: "Add New Address",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: kPrimaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressListItem extends StatelessWidget {
  final AddressEntity address;
  final VoidCallback onTap;

  const _AddressListItem({required this.address, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectedAddressCubit, BaseState<AddressEntity?>>(
      builder: (context, state) {
        final isSelected = state.hasData && state.data?.id == address.id;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? kPrimaryColor.withValues(alpha: 0.1)
                      : kWhiteColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color:
                    isSelected
                        ? kPrimaryColor
                        : kGreyColor.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Address Type Icon
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: _getAddressTypeColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    _getAddressTypeIcon(),
                    size: 20.sp,
                    color: _getAddressTypeColor(),
                  ),
                ),

                12.horizontalSpace,

                // Address Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          FText(
                            text: address.title ?? _getAddressTypeTitle(),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: kTextColorDark,
                          ),
                          if (address.isDefault) ...[
                            8.horizontalSpace,
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: FText(
                                text: "Default",
                                fontSize: 10,
                                color: kWhiteColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                      4.verticalSpace,
                      FText(
                        text: address.fullAddress,
                        fontSize: 14,
                        color: kGreyColor,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                8.horizontalSpace,

                // Selection Indicator
                Container(
                  width: 20.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? kPrimaryColor : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? kPrimaryColor : kGreyColor,
                      width: 2,
                    ),
                  ),
                  child:
                      isSelected
                          ? Icon(
                            Ionicons.checkmark,
                            size: 12.sp,
                            color: kWhiteColor,
                          )
                          : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getAddressTypeIcon() {
    switch (address.type.toLowerCase()) {
      case 'home':
        return Ionicons.home;
      case 'work':
        return Ionicons.business;
      default:
        return Ionicons.location;
    }
  }

  Color _getAddressTypeColor() {
    switch (address.type.toLowerCase()) {
      case 'home':
        return Colors.blue;
      case 'work':
        return Colors.orange;
      default:
        return kPrimaryColor;
    }
  }

  String _getAddressTypeTitle() {
    switch (address.type.toLowerCase()) {
      case 'home':
        return 'Home';
      case 'work':
        return 'Work';
      default:
        return 'Custom';
    }
  }
}
