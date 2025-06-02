import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/textfields.dart';
import 'package:food/food/core/helpers/extensions.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import 'circle_widget.dart';

class SearchWidget<T> extends StatefulWidget {
  void Function(String) onchanged;
  SearchWidget({super.key, required this.onchanged});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState<T> extends State<SearchWidget> {
  List<T> filteredResult = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FTextField(
      height: 63,
      hasLabel: false,
      hintText: "Search dishes, restaurants",
      onChanged: widget.onchanged,
      action: TextInputAction.search,
      prefix: Icon(Icons.search),
      suffix: GestureDetector(
        onTap: () {},
        child: CircleWidget(
          radius: 1,
          color: kGreyColor,
          child: Icon(Icons.close_outlined, color: kWhiteColor),
        ),
      ),
      keyboardType: TextInputType.text,
    ).paddingOnly(right: AppConstants.defaultPadding.w).onTap(() {});
  }
}
