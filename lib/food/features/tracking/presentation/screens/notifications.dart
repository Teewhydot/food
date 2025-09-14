import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/features/tracking/presentation/manager/notification_bloc/notification_cubit.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../components/texts.dart';
import '../../../../core/bloc/managers/bloc_manager.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/widgets/back_widget.dart';
import '../../domain/entities/notification_entity.dart';
import '../widgets/notification_widget.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  bool isLoading = false;
  List<NotificationEntity> notifs = [];
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().loadNotifications();
    // context.read<ChatsCubit>().loadChats();
  }

  @override
  Widget build(BuildContext context) {
    final nav = GetIt.instance<NavigationService>();

    return BlocManager<NotificationCubit, BaseState<dynamic>>(
      bloc: context.read<NotificationCubit>(),
      showLoadingIndicator: true,
      listener: (context, state) {
        if (state is LoadedState) {
          notifs = state.data as List<NotificationEntity>? ?? [];
        }
      },
      child: FScaffold(
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
        body: SingleChildScrollView(
          child: Column(
            children:
                notifs
                    .map(
                      (notification) =>
                          NotificationWidget(notificationEntity: notification),
                    )
                    .toList(),
          ).paddingOnly(top: 32),
        ).paddingSymmetric(horizontal: AppConstants.defaultPadding),
      ),
    );
  }
}
