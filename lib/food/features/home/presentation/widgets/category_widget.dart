import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/texts/texts.dart';
import '../../../../core/theme/colors.dart';

class CategoryWidget extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryWidget({
    super.key,
    required this.text,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: IntrinsicWidth(
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryColor : kWhiteColor,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: kGreyColor.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: kGreyColor,
                child: Container(),
              ).paddingAll(8),
              FText(
                text: text,
                color: isSelected ? kWhiteColor : kTextColorDark,
              ).paddingOnly(right: 5),
            ],
          ),
        ).paddingAll(5),
      ),
    );
  }
}
