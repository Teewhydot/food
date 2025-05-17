import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/textfields.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  @override
  Widget build(BuildContext context) {
    return FTextField(
      height: 63,
      hasLabel: false,
      hintText: "Search dishes, restaurants",
      action: TextInputAction.search,
      prefix: Icon(Icons.search),
      suffix: GestureDetector(
        onTap: () {},
        child: CircleAvatar(
          radius: 1,
          backgroundColor: kGreyColor,
          child: Icon(Icons.close_outlined, color: kWhiteColor),
        ),
      ),
      keyboardType: TextInputType.text,
    ).paddingOnly(right: AppConstants.defaultPadding.w);
  }
}
