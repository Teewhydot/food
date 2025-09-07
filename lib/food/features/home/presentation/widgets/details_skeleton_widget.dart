import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DetailsSkeletonWidget extends StatefulWidget {
  final bool hasBottomWidget, hasIndicator, isRestaurant;
  final IconData icon;
  final Widget bottomWidget, bodyWidget;
  final String imageUrl;
  const DetailsSkeletonWidget({
    super.key,
    this.hasBottomWidget = true,
    this.hasIndicator = true,
    this.isRestaurant = true,
    this.icon = Ionicons.heart,
    this.imageUrl = '',
    this.bottomWidget = const SizedBox(),
    this.bodyWidget = const SizedBox(),
  });

  @override
  State<DetailsSkeletonWidget> createState() => _DetailsSkeletonWidgetState();
}

class _DetailsSkeletonWidgetState extends State<DetailsSkeletonWidget> {
  final PageController controller = PageController(keepPage: true);
  final CarouselSliderController carouselController =
      CarouselSliderController();
  int currentPage = 0;
  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar:
          widget.hasBottomWidget ? widget.bottomWidget : SizedBox.shrink(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                345.verticalSpace,
                widget.bodyWidget.paddingOnly(
                  left: AppConstants.defaultPadding,
                  right: AppConstants.defaultPadding,
                ),
              ],
            ),
          ),
          Container(
            width: 1.sw,
            height: 301,
            decoration: BoxDecoration(color: kContainerColor),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10.r),
                bottomRight: Radius.circular(10.r),
              ),
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(top: 50, left: 24, child: BackWidget()),
          if (widget.hasIndicator)
            Positioned(
              top: 260.h,
              left: (1.sw - 100) / 2,
              right: 0,
              child: SizedBox(
                width: 100,
                height: 20,
                child: SmoothPageIndicator(
                  controller: PageController(initialPage: currentPage),
                  count: 6,
                  onDotClicked: (index) {
                    carouselController.animateToPage(index);
                  },
                  effect: CustomizableEffect(
                    dotDecoration: DotDecoration(
                      width: 10,
                      height: 10,
                      borderRadius: BorderRadius.circular(20),
                      color: kGreyColor,
                    ),
                    activeDotDecoration: DotDecoration(
                      width: 20,
                      height: 20,
                      borderRadius: BorderRadius.circular(20),
                      dotBorder: DotBorder(color: kWhiteColor, width: 2),
                      color: kGreyColor,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 50,
            right: 24,
            child: FoodContainer(
              width: 45,
              height: 45,
              borderRadius: 45,
              color: kWhiteColor,
              child: Icon(widget.icon),
            ),
          ),
        ],
      ),
    );
  }
}
