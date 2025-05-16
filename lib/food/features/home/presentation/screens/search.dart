import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/home/presentation/widgets/cart_widget.dart';
import 'package:food/food/features/home/presentation/widgets/search_widget.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return FScaffold(
      body: Column(
        children: [
          50.verticalSpace,
          Row(
            children: [
              Row(
                children: [
                  BackWidget(color: kBackWidgetColor),
                  20.horizontalSpace,
                  FText(
                    text: "Search",
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: kTextColorDark,
                  ),
                ],
              ),
              Spacer(),
              CartWidget().paddingOnly(right: AppConstants.defaultPadding.w),
            ],
          ),
          25.verticalSpace,
          SearchWidget(),
        ],
      ).paddingOnly(left: AppConstants.defaultPadding.w),
    );
  }
}
