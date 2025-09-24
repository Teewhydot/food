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
import 'dart:async';
import 'package:dartz/dartz.dart' hide State;

import '../../../../core/routes/routes.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../components/texts.dart';
import '../../domain/entities/order_entity.dart';
import '../manager/order_bloc/order_bloc.dart';
import '../../../../domain/failures/failures.dart';
import '../../../auth/data/remote/data_sources/user_data_source.dart';

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
  late OrderBloc _orderBloc;
  StreamSubscription<Either<Failure, List<OrderEntity>>>? _orderStreamSubscription;
  PaymentStatusEnum _currentStatus = PaymentStatusEnum.pending;
  bool _isMonitoring = false;
  String _statusMessage = 'Checking payment status...';
  final nav = GetIt.instance<NavigationService>();
  final userDataSource = GetIt.instance<UserDataSource>();

  @override
  void initState() {
    super.initState();
    _orderBloc = OrderBloc();
    _initializeStatus();
  }

  @override
  void dispose() {
    _orderStreamSubscription?.cancel();
    _orderBloc.close();
    super.dispose();
  }

  void _initializeStatus() {
    if (widget.status != null) {
      // Legacy mode - static status
      _currentStatus = widget.status!;
      _statusMessage = _getStatusMessage(_currentStatus);
    } else if (widget.orderId != null) {
      // New mode - real-time monitoring using BLoC pattern
      _isMonitoring = true;
      _startRealTimeMonitoring();
    }
  }

  void _startRealTimeMonitoring() async {
    if (widget.orderId == null) return;


    // Get current user through proper DI pattern
    try {
      final currentUser = await userDataSource.getCurrentUser();

      // Ensure user ID is not null
      if (currentUser.id == null) {
        throw Exception('User ID is null');
      }

      // Use BLoC pattern to stream user orders
      _orderStreamSubscription = _orderBloc.streamUserOrders(currentUser.id!).listen((result) {
        if (!mounted) return;

        result.fold(
          (failure) {
            // Handle failure
            setState(() {
              _currentStatus = PaymentStatusEnum.pending;
              _statusMessage = 'Connection error. Retrying...\\nOrder ID: ${widget.orderId}';
            });
          },
          (orders) {
            // Handle success - find the specific order
            final targetOrder = orders.firstWhere(
              (order) => order.id == widget.orderId,
              orElse: () => OrderEntity(
                id: '',
                userId: '',
                restaurantId: '',
                restaurantName: '',
                items: [],
                subtotal: 0,
                deliveryFee: 0,
                tax: 0,
                total: 0,
                deliveryAddress: '',
                paymentMethod: '',
                status: OrderStatus.pending,
                createdAt: DateTime.now(),
              ),
            );

            if (targetOrder.id.isNotEmpty) {
              // Found the order - update UI
              _processOrderEntity(targetOrder);
            } else {
              // Order not found in user's orders - show searching message
              setState(() {
                _currentStatus = PaymentStatusEnum.pending;
                _statusMessage = 'Creating order record...\\nOrder ID: ${widget.orderId}\\nThis may take a few seconds.';
              });
            }
          },
        );
      });
    } catch (e) {
      // Handle authentication error
      setState(() {
        _currentStatus = PaymentStatusEnum.failure;
        _statusMessage = 'User not authenticated. Please login again.';
      });
    }
  }

  void _processOrderEntity(OrderEntity order) {
    setState(() {
      // Map OrderStatus to PaymentStatusEnum
      switch (order.status) {
        case OrderStatus.confirmed:
        case OrderStatus.preparing:
        case OrderStatus.onTheWay:
        case OrderStatus.delivered:
          _currentStatus = PaymentStatusEnum.success;
          _statusMessage = 'Payment successful! Order is ${_getOrderStatusText(order.status)}.';
          break;
        case OrderStatus.cancelled:
          _currentStatus = PaymentStatusEnum.failure;
          _statusMessage = 'Order was cancelled. Please contact support if payment was deducted.';
          break;
        case OrderStatus.pending:
          _currentStatus = PaymentStatusEnum.pending;
          if (widget.paymentMethod == 'paystack') {
            _statusMessage = 'Processing Paystack payment...\\nOrder ID: ${widget.orderId}\\nNote: Webhook may be experiencing delays.';
          } else if (widget.paymentMethod == 'flutterwave') {
            _statusMessage = 'Processing Flutterwave payment...\\nOrder ID: ${widget.orderId}';
          } else {
            _statusMessage = 'Processing payment...\\nOrder ID: ${widget.orderId}';
          }
          break;
      }
    });
  }

  String _getOrderStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'pending confirmation';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.preparing:
        return 'being prepared';
      case OrderStatus.onTheWay:
        return 'on the way';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
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
