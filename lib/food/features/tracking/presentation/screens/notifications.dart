import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../components/scaffold.dart';
import '../../../../components/texts/texts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/widgets/back_widget.dart';
import '../widgets/message_widget.dart';
import '../widgets/notification_widget.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = GetIt.instance<NavigationService>();

    return FScaffold(
      body: Column(
        children: [
          Row(
            children: [
              BackWidget(color: kContainerColor),
              10.horizontalSpace,
              FText(
                text: "Notifications",
                fontWeight: FontWeight.w400,
                fontSize: 17,
              ),
            ],
          ),
          24.verticalSpace,
          Expanded(
            child: ContainedTabBarView(
              tabBarProperties: TabBarProperties(
                labelStyle: GoogleFonts.sen(color: kPrimaryColor),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: kPrimaryColor,
                labelColor: kPrimaryColor,
                unselectedLabelStyle: GoogleFonts.sen(
                  color: kContainerColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              tabs: [Text("Notifications"), Text("Messages")],
              views: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      NotificationWidget(),
                      NotificationWidget(),
                      NotificationWidget(),
                      NotificationWidget(),
                      NotificationWidget(),
                    ],
                  ).paddingOnly(top: 32),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      MessageWidget(),
                      MessageWidget(),
                      MessageWidget(),
                      MessageWidget(),
                      MessageWidget(),
                    ],
                  ).paddingOnly(top: 32),
                ),
              ],
            ),
          ),
        ],
      ).paddingAll(AppConstants.defaultPadding),
    );
  }
}
