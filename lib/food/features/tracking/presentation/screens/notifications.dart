import 'dart:async';

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/helpers/user_extensions.dart';
import 'package:food/food/features/tracking/presentation/manager/notification_bloc/notification_cubit.dart';
import 'package:get/get.dart';

import '../../../../components/buttons.dart';
import '../../../../components/texts.dart';
import '../../../../core/bloc/managers/bloc_manager.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/colors.dart';
import '../../../../domain/failures/failures.dart';
import '../../../auth/presentation/widgets/back_widget.dart';
import '../../domain/entities/notification_entity.dart';
import '../widgets/notification_widget.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications>
    with AutomaticKeepAliveClientMixin {
  bool isLoading = false;
  late Stream<Either<Failure, List<NotificationEntity>>> _notificationsStream;
  bool _streamInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_streamInitialized) {
      _initializeStream();
      _streamInitialized = true;
    }
  }

  void _initializeStream() {
    try {
      final userId = context.readCurrentUserId;
      if (userId != null && userId.isNotEmpty) {
        _notificationsStream =
            context
                .read<NotificationCubit>()
                .watchNotifications(userId)
                .distinct();
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_streamInitialized) {
          _initializeStream();
          _streamInitialized = true;
        }
      });
    }
  }

  void _retryStreamInitialization() {
    _streamInitialized = false;
    _initializeStream();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    if (!_streamInitialized) {
      return FScaffold(
        appBarWidget: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: kPrimaryColor),
              16.verticalSpace,
              FText(
                text: "Loading notifications...",
                fontSize: 14,
                color: kContainerColor,
              ),
            ],
          ),
        ),
      );
    }

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

  Widget _buildNotificationsScaffold(
    Either<Failure, List<NotificationEntity>> notifs,
  ) {
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
        children:
            notifications
                .map(
                  (notification) =>
                      NotificationWidget(notificationEntity: notification),
                )
                .toList(),
      ),
    ).paddingSymmetric(horizontal: AppConstants.defaultPadding);
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

  Widget _buildErrorScaffold(String message) {
    return FScaffold(
      appBarWidget: _buildAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FText(
              text: message,
              color: kErrorColor,
              fontSize: 14,
              textAlign: TextAlign.center,
            ),
            16.verticalSpace,
            FButton(
              buttonText: "Retry",
              width: 120,
              height: 40,
              onPressed: _retryStreamInitialization,
            ),
          ],
        ),
      ),
    );
  }
}
