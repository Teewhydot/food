import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons/buttons.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/textfields.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/features/home/presentation/widgets/circle_widget.dart';
import 'package:food/generated/assets.dart';
import 'package:get/get.dart';

import '../../../../components/texts/texts.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/widgets/back_widget.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  @override
  Widget build(BuildContext context) {
    return FScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                BackWidget(color: kGreyColor),
                20.horizontalSpace,
                FText(
                  text: "Edit profile",
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w400,
                  color: kBlackColor,
                ),
              ],
            ),
            20.verticalSpace,
            Stack(
              children: [
                CircleWidget(radius: 70, color: kPrimaryColor),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleWidget(
                    radius: 20,
                    color: kBlackColor,
                    child: FImage(
                      assetPath: Assets.svgsPencil,
                      assetType: FoodAssetType.svg,
                      width: 16,
                      height: 16,
                      svgAssetColor: kWhiteColor,
                    ),
                  ),
                ),
              ],
            ),
            30.verticalSpace,
            FTextField(
              hintText: "First Name",
              action: TextInputAction.next,
              label: "First Name",
            ),
            24.verticalSpace,
            FTextField(
              hintText: "Last Name",
              action: TextInputAction.next,
              label: "Last Name",
            ),
            24.verticalSpace,
            FTextField(
              hintText: "Email",
              action: TextInputAction.next,
              label: "Email",
              keyboardType: TextInputType.emailAddress,
            ),
            24.verticalSpace,
            FTextField(
              hintText: "Phone",
              action: TextInputAction.next,
              label: "Phone",
              keyboardType: TextInputType.phone,
            ),
            24.verticalSpace,
            FTextField(
              hintText: "",
              action: TextInputAction.next,
              label: "Bio",
              height: 103,
            ),
            32.verticalSpace,
            FButton(buttonText: "Save", width: 1.sw),
            32.verticalSpace,
          ],
        ).paddingSymmetric(horizontal: AppConstants.defaultPadding),
      ),
    );
  }
}
