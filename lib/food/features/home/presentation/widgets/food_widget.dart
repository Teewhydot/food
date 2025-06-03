import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/helpers/extensions.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/home/presentation/widgets/circle_widget.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:get/get.dart';

class FoodWidget extends StatefulWidget {
  final String image, name, price, rating;
  final Function onTap, onAddTapped;
  const FoodWidget({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    required this.rating,
    required this.onTap,
    required this.onAddTapped,
  });

  @override
  State<FoodWidget> createState() => _FoodWidgetState();
}

class _FoodWidgetState extends State<FoodWidget> {
  bool tapped = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130.w,
      height: 250.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              FoodContainer(width: 153, height: 130),
              FText(
                text: widget.name,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                alignment: MainAxisAlignment.start,
              ),
              5.verticalSpace,
              FText(
                text: widget.rating,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                alignment: MainAxisAlignment.start,
                color: kGreyColor,
              ),
              5.verticalSpace,
            ],
          ).onTap(() {
            widget.onTap();
          }),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FText(
                text: widget.price,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                alignment: MainAxisAlignment.start,
                color: kTextColorDark,
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child:
                    !tapped
                        ? CircleWidget(
                          radius: 20,
                          color: kPrimaryColor,
                          onTap: () async {
                            widget.onAddTapped();
                            setState(() {
                              tapped = true;
                            });
                            await Future.delayed(const Duration(seconds: 1));
                            setState(() {
                              tapped = false;
                            });
                          },
                          child: Icon(Icons.add, color: kWhiteColor),
                        )
                        : CircleWidget(
                          radius: 20,
                          color: kSuccessColor,
                          child: Icon(Icons.check, color: kWhiteColor),
                        ),
              ),
            ],
          ),
        ],
      ),
    ).paddingSymmetric(horizontal: 10);
  }
}
