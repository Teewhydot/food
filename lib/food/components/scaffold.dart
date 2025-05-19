import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FScaffold extends StatelessWidget {
  final Widget body, bottomWidget;
  final double padding;
  final bool showNavBar, resizeToAvoidBottomInset;

  const FScaffold({
    super.key,
    required this.body,
    this.padding = 0.0,
    this.showNavBar = false,
    this.resizeToAvoidBottomInset = true,
    this.bottomWidget = const SizedBox(),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Padding(padding: EdgeInsets.all(padding).r, child: body),
      bottomNavigationBar: bottomWidget,
    );
  }
}

// class HavenNavBar extends StatelessWidget {
//   const HavenNavBar({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 44.h,
//       width: 1.sw,
//       decoration: BoxDecoration(
//         color: kScaffoldBgColorLight,
//         borderRadius: BorderRadius.circular(90),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           SvgPicture.asset(Assets.svgsCards, height: 22, width: 22),
//           SvgPicture.asset(Assets.svgsHearts, height: 22, width: 22),
//           SvgPicture.asset(Assets.svgsChatIcon1, height: 22, width: 22),
//           SvgPicture.asset(
//             Assets.svgsProfile,
//             color: kPrimaryColor500,
//             height: 22,
//             width: 22,
//           ),
//         ],
//       ),
//     );
//   }
// }
