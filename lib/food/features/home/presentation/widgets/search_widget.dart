import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/textfields.dart';
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
    ).paddingOnly(right: AppConstants.defaultPadding.w);
  }
}
