import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/home/presentation/widgets/circle_widget.dart';
import 'package:food/generated/assets.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../../../../core/routes/routes.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../components/texts.dart';

enum PaymentStatusEnum { success, failure, pending }

class PaymentStatus extends StatefulWidget {
  final PaymentStatusEnum? status;
  final String? orderId;
  final String? reference;
  final String? paymentMethod;

  const PaymentStatus({
    super.key,
    this.status,
    this.orderId,
    this.reference,
    this.paymentMethod,
  });

  @override
  State<PaymentStatus> createState() => _PaymentStatusState();
}

class _PaymentStatusState extends State<PaymentStatus> {
  StreamSubscription<DocumentSnapshot>? _orderStatusSubscription;
  PaymentStatusEnum _currentStatus = PaymentStatusEnum.pending;
  bool _isMonitoring = false;
  String _statusMessage = 'Checking payment status...';
  final nav = GetIt.instance<NavigationService>();

  @override
  void initState() {
    super.initState();
    _initializeStatus();
  }

  @override
  void dispose() {
    _orderStatusSubscription?.cancel();
    super.dispose();
  }

  void _initializeStatus() {
    if (widget.status != null) {
      // Legacy mode - static status
      _currentStatus = widget.status!;
      _statusMessage = _getStatusMessage(_currentStatus);
    } else if (widget.orderId != null) {
      // New mode - real-time monitoring
      _isMonitoring = true;
      _startRealTimeMonitoring();
    }
  }

  void _startRealTimeMonitoring() {
    if (widget.orderId == null) return;

    _orderStatusSubscription = FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId!)
        .snapshots()
        .listen((docSnapshot) {
      if (!mounted) return;

      setState(() {
        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          if (data != null) {
            final status = data['status'] as String?;
            final paymentStatus = data['paymentStatus'] as String?;

            // Determine current payment status based on Firebase data
            if (paymentStatus == 'success' || paymentStatus == 'completed') {
              _currentStatus = PaymentStatusEnum.success;
              _statusMessage = 'Payment successful!';
            } else if (paymentStatus == 'failed' || paymentStatus == 'cancelled') {
              _currentStatus = PaymentStatusEnum.failure;
              _statusMessage = 'Payment failed. Please try again.';
            } else if (status == 'confirmed' || status == 'preparing') {
              _currentStatus = PaymentStatusEnum.success;
              _statusMessage = 'Payment confirmed! Order is being prepared.';
            } else {
              // Still pending - show appropriate message based on payment method
              _currentStatus = PaymentStatusEnum.pending;
              if (widget.paymentMethod == 'paystack') {
                _statusMessage = 'Processing Paystack payment...\\nNote: Webhook may be experiencing delays.';
              } else if (widget.paymentMethod == 'flutterwave') {
                _statusMessage = 'Processing Flutterwave payment...';
              } else {
                _statusMessage = 'Processing payment...';
              }
            }
          }
        } else {
          _currentStatus = PaymentStatusEnum.pending;
          _statusMessage = 'Order not found. Please check your payment.';
        }
      });
    });
  }

  String _getStatusMessage(PaymentStatusEnum status) {
    switch (status) {
      case PaymentStatusEnum.success:
        return 'Thank you for your purchase!';
      case PaymentStatusEnum.failure:
        return 'Something went wrong, please try again.';
      case PaymentStatusEnum.pending:
        return 'Processing your payment...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      appBarWidget: _isMonitoring
          ? AppBar(
              title: FText(
                text: 'Payment Status',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: kWhiteColor,
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: [
                TextButton(
                  onPressed: () => nav.navigateAndOffAll(Routes.home, Routes.statusScreen),
                  child: const FText(
                    text: 'Home',
                    color: kPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : Container(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              _isMonitoring ? 100.verticalSpace : 238.verticalSpace,

              // Status icon/animation
              if (_currentStatus == PaymentStatusEnum.success)
                FImage(
                  assetPath: Assets.svgsSuccessful,
                  width: 260,
                  height: 181,
                  assetType: FoodAssetType.svg,
                )
              else if (_currentStatus == PaymentStatusEnum.failure)
                CircleWidget(
                  color: kErrorColor,
                  radius: 60,
                  child: const Icon(Icons.close, size: 90, color: kWhiteColor),
                )
              else
                // Pending status - show loading
                Column(
                  children: [
                    const CircularProgressIndicator(
                      color: kPrimaryColor,
                      strokeWidth: 3,
                    ),
                    16.verticalSpace,
                    const FText(
                      text: 'Processing...',
                      fontSize: 16,
                      color: kGreyColor,
                    ),
                  ],
                ),

              32.verticalSpace,

              // Status title
              FText(
                text: _getStatusTitle(_currentStatus),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),

              16.verticalSpace,

              // Status message
              FText(
                text: _statusMessage,
                fontSize: 16,
                color: kGreyColor,
                textAlign: TextAlign.center,
              ),

              // Real-time monitoring indicator
              if (_isMonitoring && _currentStatus == PaymentStatusEnum.pending) ...[
                24.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: kPrimaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    8.horizontalSpace,
                    const FText(
                      text: 'Monitoring payment status...',
                      fontSize: 12,
                      color: kPrimaryColor,
                    ),
                  ],
                ),
              ],
            ],
          ),

          const Spacer(),

          // Action buttons
          Column(
            children: [
              FButton(
                buttonText: _getButtonText(_currentStatus),
                width: 1.sw,
                color: _currentStatus == PaymentStatusEnum.failure
                    ? kErrorColor
                    : kPrimaryColor,
                onPressed: () => _handleButtonPress(),
              ),

              // Additional "Go Home" button if monitoring and not failed
              if (_isMonitoring && _currentStatus != PaymentStatusEnum.failure) ...[
                12.verticalSpace,
                FButton(
                  buttonText: "Go to Home",
                  width: 1.sw,
                  color: kGreyColor,
                  onPressed: () => nav.navigateAndOffAll(Routes.home, Routes.statusScreen),
                ),
              ],
            ],
          ),
        ],
      ).paddingAll(AppConstants.defaultPadding),
    );
  }

  String _getStatusTitle(PaymentStatusEnum status) {
    switch (status) {
      case PaymentStatusEnum.success:
        return 'Payment Successful!';
      case PaymentStatusEnum.failure:
        return 'Payment Failed';
      case PaymentStatusEnum.pending:
        return 'Processing Payment';
    }
  }

  String _getButtonText(PaymentStatusEnum status) {
    switch (status) {
      case PaymentStatusEnum.success:
        return _isMonitoring ? "Track Order" : "Track Order";
      case PaymentStatusEnum.failure:
        return "Retry Payment";
      case PaymentStatusEnum.pending:
        return "Continue Monitoring";
    }
  }

  void _handleButtonPress() {
    switch (_currentStatus) {
      case PaymentStatusEnum.success:
        nav.navigateAndOffAll(Routes.tracking, Routes.home);
        break;
      case PaymentStatusEnum.failure:
        nav.goBack();
        break;
      case PaymentStatusEnum.pending:
        // For pending, just keep monitoring - maybe refresh the stream
        _startRealTimeMonitoring();
        break;
    }
  }
}
