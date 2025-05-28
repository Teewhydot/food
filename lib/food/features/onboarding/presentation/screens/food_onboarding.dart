import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons/buttons.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/services/navigation_service/nav_config.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/onboarding/presentation/widgets/onboarding_widget.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/constants/app_constants.dart';

class FoodOnboarding1 extends StatefulWidget {
  const FoodOnboarding1({super.key});

  @override
  State<FoodOnboarding1> createState() => _FoodOnboardingState1();
}

class _FoodOnboardingState1 extends State<FoodOnboarding1> {
  final PageController controller = PageController(keepPage: true);
  int currentPage = 0;
  bool isLastPage = false;
  @override
  Widget build(BuildContext context) {
    final nav = GetIt.instance<NavigationService>();
    return FScaffold(
      body: Column(
        children: [
          SizedBox(
            height: 0.65.sh,
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
          ).paddingOnly(
            left: AppConstants.defaultPadding,
            right: AppConstants.defaultPadding,
          ),
          if (!isLastPage)
            TextButton(
              onPressed: () {},
              child: FText(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: kGreyColor,
                text: 'Skip',
              ),
            ).paddingOnly(
              left: AppConstants.defaultPadding,
              right: AppConstants.defaultPadding,
            ),
        ],
      ),
    );
  }
}

class FoodOnboarding extends StatefulWidget {
  const FoodOnboarding({super.key});

  @override
  _FoodOnboardingState createState() => _FoodOnboardingState();
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
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Expanded(
                  child: PageView(
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
                    onPageChanged: (newPage) {
                      setState(() {
                        currentPage = newPage;
                        isLastPage = false;
                        if (currentPage == 2) {
                          isLastPage = true;
                        }
                      });
                    },
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
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FButton(
                  buttonText: isLastPage ? "Get Started" : "Next",
                  width: 1.sw,
                  borderRadius: 12,
                ).paddingOnly(
                  left: AppConstants.defaultPadding,
                  right: AppConstants.defaultPadding,
                ),
                TextButton(
                  onPressed: () {},
                  child: FText(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: kGreyColor,
                    text: (isLastPage ? "" : "Skip"),
                  ),
                ).paddingOnly(
                  left: AppConstants.defaultPadding,
                  right: AppConstants.defaultPadding,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
