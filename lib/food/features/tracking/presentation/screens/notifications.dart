import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/helpers/user_extensions.dart';
import 'package:food/food/features/tracking/presentation/manager/notification_bloc/notification_cubit.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../components/texts.dart';
import '../../../../core/bloc/managers/bloc_manager.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/widgets/back_widget.dart';
import '../widgets/notification_widget.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    // context.read<ChatsCubit>().loadChats();
  }

  @override
  Widget build(BuildContext context) {
    final nav = GetIt.instance<NavigationService>();

    return BlocManager<NotificationCubit, BaseState<dynamic>>(
      bloc: context.read<NotificationCubit>(),
      showLoadingIndicator: true,
      child: StreamBuilder(
        stream: context.read<NotificationCubit>().watchNotifications(
          context.readCurrentUserId!,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return FScaffold(
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
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            final notifs = snapshot.data;
            return FScaffold(
              customScroll:
                  notifs?.fold(
                    (failure) =>
                        true, // Left case (error) - enable custom scroll
                    (notifications) =>
                        notifications
                            .isEmpty, // Right case - check if list is empty
                  ) ??
                  true,
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
              // body: BlocManager<NotificationCubit, BaseState<dynamic>>(
              //   bloc: context.read<NotificationCubit>(),
              //   showLoadingIndicator: true,
              //   builder: (context, state) {
              //     if (state.hasData) {
              //       final notifications = state.data as List? ?? [];
              //       return SingleChildScrollView(
              //         child: Column(
              //           children:
              //               notifications
              //                   .map(
              //                     (notification) => NotificationWidget(
              //                       notificationEntity: notification,
              //                     ),
              //                   )
              //                   .toList(),
              //         ).paddingOnly(top: 32),
              //       );
              //     } else if (state is NotificationError) {
              //       return Center(
              //         child: FText(
              //           text: "Error loading notifications",
              //           color: kErrorColor,
              //           fontSize: 12.sp,
              //           fontWeight: FontWeight.normal,
              //         ),
              //       );
              //     }
              //     return Center(
              //       child: FText(
              //         text: "No notifications available",
              //         color: kPrimaryColor,
              //         fontSize: 12.sp,
              //         fontWeight: FontWeight.normal,
              //       ),
              //     );
              //   },
              //   child: Column(children: [const SizedBox.shrink()]),
              // ).paddingSymmetric(horizontal: AppConstants.defaultPadding),
              body: notifs!.fold(
                (failure) => Center(
                  child: FText(
                    text: "Error loading notifications",
                    color: kErrorColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                (notifications) =>
                    notifications.isNotEmpty
                        ? SingleChildScrollView(
                          child: Column(
                            children:
                                notifications
                                    .map(
                                      (notification) => NotificationWidget(
                                        notificationEntity: notification,
                                      ),
                                    )
                                    .toList(),
                          ).paddingOnly(top: 32),
                        ).paddingSymmetric(
                          horizontal: AppConstants.defaultPadding,
                        )
                        : Center(
                          child: FText(
                            text: "No notifications available",
                            color: kPrimaryColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
              ),
            );
          }
          if (snapshot.hasError) {
            return FScaffold(
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
              body: Center(
                child: FText(
                  text: "Error loading notifications ${snapshot.error}",
                  color: kErrorColor,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            );
          }
          return const Center(
            child: FText(
              text: 'No notifications found.',
              fontSize: 16,
              color: kGreyColor,
            ),
          );
        },
      ),
    );
  }
}
