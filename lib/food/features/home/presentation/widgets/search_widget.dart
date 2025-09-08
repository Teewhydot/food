import 'package:flutter/material.dart';
import 'package:food/food/components/textfields.dart';
import 'package:food/food/core/helpers/extensions.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:get/get.dart';

import 'circle_widget.dart';

class SearchWidget extends StatefulWidget {
  void Function(String) onValueChanged;
  void Function() onSuffixTap;
  final TextEditingController controller;
  final VoidCallback? onEditingComplete;

  SearchWidget({
    super.key,
    required this.onValueChanged,
    required this.onSuffixTap,
    required this.controller,
    required this.onEditingComplete,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState<T> extends State<SearchWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FTextField(
      height: 63,
      hasLabel: false,
      onEditingComplete: widget.onEditingComplete,
      controller: widget.controller,
      hintText: "Search dishes, restaurants",
      onChanged: widget.onValueChanged,
      action: TextInputAction.search,
      prefix: Icon(Icons.search),
      suffix: CircleWidget(
        radius: 1,
        color: kGreyColor,
        onTap: () {
          widget.onSuffixTap();
        },
        child: Icon(Icons.close_outlined, color: kWhiteColor),
      ),
      keyboardType: TextInputType.text,
    ).paddingZero.onTap(() {});
  }
}
