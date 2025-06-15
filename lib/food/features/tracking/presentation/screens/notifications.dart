import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/features/tracking/presentation/manager/chats_bloc/chats_cubit.dart';
import 'package:food/food/features/tracking/presentation/manager/chats_bloc/chats_state.dart';
import 'package:food/food/features/tracking/presentation/manager/notification_bloc/notification_cubit.dart';
import 'package:food/food/features/tracking/presentation/manager/notification_bloc/notification_state.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../components/texts/texts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/widgets/back_widget.dart';
import '../widgets/message_widget.dart';
import '../widgets/notification_widget.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().loadNotifications();
    context.read<ChatsCubit>().loadChats();
  }

  @override
  Widget build(BuildContext context) {
    final nav = GetIt.instance<NavigationService>();

    return FScaffold(
      customScroll: false,
      appBarWidget: Row(
        children: [
          BackWidget(color: kGreyColor),
          20.horizontalSpace,
          FText(
            text: "Notifications",
            fontSize: 17.sp,
            fontWeight: FontWeight.w400,
            color: kBlackColor,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ContainedTabBarView(
              tabBarProperties: TabBarProperties(
                isScrollable: false,
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
              tabBarViewProperties: TabBarViewProperties(
                physics: BouncingScrollPhysics(),
              ),
              views: [
                BlocBuilder<NotificationCubit, NotificationState>(
                  builder: (context, state) {
                    if (state is NotificationLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else if (state is NotificationLoaded) {
                      if (state.notifications.isEmpty) {
                        return Center(
                          child: FText(
                            text: "No notifications available",
                            color: kPrimaryColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.normal,
                          ),
                        );
                      }
                      return SingleChildScrollView(
                        child: Column(
                          children:
                              state.notifications
                                  .map(
                                    (notification) => NotificationWidget(
                                      notificationEntity: notification,
                                    ),
                                  )
                                  .toList(),
                        ).paddingOnly(top: 32),
                      );
                    } else if (state is NotificationError) {
                      return Center(
                        child: FText(
                          text: "Error loading notifications",
                          color: kErrorColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.normal,
                        ),
                      );
                    }
                    return Center(
                      child: FText(
                        text: "No notifications available",
                        color: kPrimaryColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.normal,
                      ),
                    );
                  },
                ),
                BlocBuilder<ChatsCubit, ChatsState>(
                  builder: (context, state) {
                    if (state is ChatsLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else if (state is ChatsLoaded) {
                      if (state.chats.isEmpty) {
                        return Center(
                          child: FText(
                            text: "No messages available",
                            color: kPrimaryColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.normal,
                          ),
                        );
                      }
                      return SingleChildScrollView(
                        child: Column(
                          children:
                              state.chats
                                  .map(
                                    (notification) => MessageWidget(
                                      onTap: () {
                                        nav.navigateTo(Routes.chatScreen);
                                      },
                                    ),
                                  )
                                  .toList(),
                        ).paddingOnly(top: 32),
                      );
                    } else if (state is ChatsError) {
                      return Center(
                        child: FText(
                          text: "Error loading messages",
                          color: kErrorColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.normal,
                        ),
                      );
                    }
                    return Center(
                      child: FText(
                        text: "No messages available",
                        color: kPrimaryColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.normal,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: AppConstants.defaultPadding),
    );
  }
}
