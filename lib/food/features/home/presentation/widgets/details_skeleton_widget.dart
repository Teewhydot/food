import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:ionicons/ionicons.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DetailsSkeletonWidget extends StatefulWidget {
  final bool hasBottomWidget, hasIndicator, isRestaurant;
  final IconData icon;
  final Widget bottomWidget, bodyWidget;
  const DetailsSkeletonWidget({
    super.key,
    this.hasBottomWidget = true,
    this.hasIndicator = true,
    this.isRestaurant = true,
    this.icon = Ionicons.heart,
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
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(children: [345.verticalSpace, widget.bodyWidget]),
        ),
        widget.isRestaurant
            ? CarouselSlider(
              items: [
                FoodContainer(
                  height: 321,
                  width: 1.sw,
                  borderRadius: 30,
                  color: kContainerColor,
                ),
                FoodContainer(
                  height: 321,
                  width: 1.sw,
                  borderRadius: 30,
                  color: kContainerColor,
                ),
                FoodContainer(
                  height: 321,
                  width: 1.sw,
                  borderRadius: 30,
                  color: kContainerColor,
                ),
                FoodContainer(
                  height: 321,
                  width: 1.sw,
                  borderRadius: 30,
                  color: kContainerColor,
                ),
                FoodContainer(
                  height: 321,
                  width: 1.sw,
                  borderRadius: 30,
                  color: kContainerColor,
                ),
                FoodContainer(
                  height: 321,
                  width: 1.sw,
                  borderRadius: 30,
                  color: kContainerColor,
                ),
              ],
              carouselController: carouselController,
              options: CarouselOptions(
                height: 321,
                initialPage: 0,
                enableInfiniteScroll: false,
                reverse: false,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    currentPage = index;
                  });
                },
                scrollDirection: Axis.horizontal,
                viewportFraction: 1.0,
              ),
            )
            : FoodContainer(width: 1.sw, height: 321, borderRadius: 30),
        Positioned(
          bottom: 0,
          child: FoodContainer(
            height: 184,
            width: 1.sw,
            borderRadius: 30,
            color: kSecondaryColor,
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
                effect: ScrollingDotsEffect(
                  activeDotColor: kPrimaryColor,
                  dotColor: kGreyColor,
                  dotHeight: 10,
                  dotWidth: 10,
                  spacing: 10,
                  strokeWidth: 2,
                  paintStyle: PaintingStyle.stroke,
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
    );
  }
}
