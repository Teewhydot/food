import 'package:flutter/material.dart';
import 'package:food/food/components/textfields.dart';
import 'package:get/get.dart';

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
    ).paddingOnly(right: 24);
  }
}
