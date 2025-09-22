import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/helpers/user_extensions.dart';
import 'package:food/food/features/tracking/presentation/manager/notification_bloc/notification_cubit.dart';
import 'package:get/get.dart';
import 'package:dartz/dartz.dart' hide State;

import '../../../../components/texts.dart';
import '../../../../core/bloc/managers/bloc_manager.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/widgets/back_widget.dart';
import '../widgets/notification_widget.dart';
import '../../../../domain/failures/failures.dart';
import '../../domain/entities/notification_entity.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  bool isLoading = false;
  late Stream<Either<Failure, List<NotificationEntity>>> _notificationsStream;

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  void _initializeStream() {
    _notificationsStream = context
        .read<NotificationCubit>()
        .watchNotifications(context.readCurrentUserId!)
        .distinct();
  }

  @override
  Widget build(BuildContext context) {
    return BlocManager<NotificationCubit, BaseState<dynamic>>(
      bloc: context.read<NotificationCubit>(),
      showLoadingIndicator: true,
      child: StreamBuilder<Either<Failure, List<NotificationEntity>>>(
        stream: _notificationsStream,
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
            return _buildNotificationsScaffold(snapshot.data!);
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

  Widget _buildNotificationsScaffold(Either<Failure, List<NotificationEntity>> notifs) {
    return FScaffold(
      customScroll: notifs.fold(
        (failure) => true,
        (notifications) => notifications.isEmpty,
      ),
      appBarWidget: _buildAppBar(),
      body: notifs.fold(
        (failure) => _buildErrorBody("Error loading notifications"),
        (notifications) => _buildNotificationsList(notifications),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
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
    );
  }

  Widget _buildNotificationsList(List<NotificationEntity> notifications) {
    if (notifications.isEmpty) {
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
        children: notifications
            .map((notification) => NotificationWidget(
                  notificationEntity: notification,
                ))
            .toList(),
      ).paddingOnly(top: 32),
    ).paddingSymmetric(
      horizontal: AppConstants.defaultPadding,
    );
  }

  Widget _buildErrorBody(String message) {
    return Center(
      child: FText(
        text: message,
        color: kErrorColor,
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
      ),
    );
  }
}
