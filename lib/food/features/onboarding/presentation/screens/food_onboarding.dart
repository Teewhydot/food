import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons/buttons.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/onboarding/presentation/widgets/onboarding_widget.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class FoodOnboarding extends StatefulWidget {
  const FoodOnboarding({super.key});

  @override
  State<FoodOnboarding> createState() => _FoodOnboardingState();
}

class _FoodOnboardingState extends State<FoodOnboarding> {
  final PageController controller = PageController(keepPage: true);
  int currentPage = 0;
  bool isLastPage = false;
  @override
  Widget build(BuildContext context) {
    return FScaffold(
      body: Column(
        children: [
          SizedBox(
            height: 0.75.sh,
            child: PageView(
              onPageChanged: (newPage) {
                setState(() {
                  currentPage = newPage;
                  isLastPage = false;
                  if (currentPage == 2) {
                    isLastPage = true;
                  }
                });
              },
              controller: controller,
              pageSnapping: true,
              children: [
                OnboardingWidget(
                  title: "All your favorites",
                  description:
                      "Get all your loved foods in one place,just place the order and we do the rest",
                  imagePath: "imagePath",
                  controller: controller,
                ),
                OnboardingWidget(
                  title: "Order from choosen chef",
                  description:
                      "Get all your loved foods in one place,just place the order and we do the rest",
                  imagePath: "imagePath",
                  controller: controller,
                ),
                OnboardingWidget(
                  title: "Free delivery offers",
                  description:
                      " Free delivery offers for all orders above 10000",
                  imagePath: "imagePath",
                  controller: controller,
                ),
              ],
            ),
          ),
          SmoothPageIndicator(
            controller: controller,
            count: 3,
            onDotClicked: (index) {
              controller.animateToPage(
                index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
              );
            },
            effect: ExpandingDotsEffect(
              activeDotColor: kPrimaryColor,
              dotColor: kSecondaryColor,
            ),
          ),
          70.verticalSpace,
          FButton(
            buttonText: isLastPage ? "Get Started" : "Next",
            width: 1.sw,
            borderRadius: 12,
          ).paddingOnly(left: 24, right: 24),
          if (!isLastPage)
            TextButton(
              onPressed: () {},
              child: FText(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: kGreyColor,
                text: 'Skip',
              ),
            ).paddingOnly(left: 24, right: 24),
        ],
      ),
    );
  }
}
