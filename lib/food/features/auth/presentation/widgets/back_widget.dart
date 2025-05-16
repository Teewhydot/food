import 'package:flutter/material.dart';
import 'package:food/food/core/theme/colors.dart';

class BackWidget extends StatelessWidget {
  final Color color;
  const BackWidget({super.key, this.color = kWhiteColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(45),
      ),
      child: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: kBlackColor,
          size: 15,
        ),
      ),
    );
  }
}
