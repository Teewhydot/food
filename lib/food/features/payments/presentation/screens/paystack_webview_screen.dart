import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../../../components/scaffold.dart';
import '../../../../components/texts.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/routes/routes.dart';

class PaystackWebviewScreen extends StatefulWidget {
  final String authorizationUrl;
  final String reference;
  final String orderId;
  final VoidCallback? onPaymentCompleted;
  final VoidCallback? onPaymentCancelled;

  const PaystackWebviewScreen({
    super.key,
    required this.authorizationUrl,
    required this.reference,
    required this.orderId,
    this.onPaymentCompleted,
    this.onPaymentCancelled,
  });

  @override
  State<PaystackWebviewScreen> createState() => _PaystackWebviewScreenState();
}

class _PaystackWebviewScreenState extends State<PaystackWebviewScreen> {
  late InAppWebViewController webViewController;
  bool isLoading = true;
  double loadingProgress = 0;
  bool hasProcessedPayment = false;
  final nav = GetIt.instance<NavigationService>();
  StreamSubscription<DocumentSnapshot>? _orderStatusSubscription;

  @override
  void initState() {
    super.initState();
    _startOrderStatusListener();
  }

  @override
  void dispose() {
    _orderStatusSubscription?.cancel();
    super.dispose();
  }

  void _startOrderStatusListener() {
    _orderStatusSubscription = FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .snapshots()
        .listen((docSnapshot) {
      if (!mounted || hasProcessedPayment) return;

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null) {
          final status = data['status'] as String?;
          final paymentStatus = data['paymentStatus'] as String?;

          // Check if payment was successful
          if (paymentStatus == 'success' || paymentStatus == 'completed') {
            hasProcessedPayment = true;
            nav.goBack();
            widget.onPaymentCompleted?.call();
          }
          // Check if payment failed
          else if (paymentStatus == 'failed' || paymentStatus == 'cancelled') {
            hasProcessedPayment = true;
            nav.goBack();
            widget.onPaymentCancelled?.call();
          }
          // Check if order status indicates payment success
          else if (status == 'confirmed' || status == 'preparing') {
            hasProcessedPayment = true;
            nav.goBack();
            widget.onPaymentCompleted?.call();
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      appBarWidget: AppBar(
        title: const FText(text: "Complete Payment"),
        backgroundColor: kWhiteColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: kBlackColor),
            onPressed: () {
              nav.navigateTo(Routes.statusScreen, arguments: {
                'orderId': widget.orderId,
                'reference': widget.reference,
                'paymentMethod': 'paystack',
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(widget.authorizationUrl),
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() {
                isLoading = true;
              });
            },
            onLoadStop: (controller, url) {
              setState(() {
                isLoading = false;
              });
            },
            onProgressChanged: (controller, progress) {
              setState(() {
                loadingProgress = progress / 100;
              });
            },
            onReceivedError: (controller, request, error) {
              DFoodUtils.showSnackBar(
                "Failed to load payment page. Please try again.",
                kErrorColor,
              );
            },
            initialSettings: InAppWebViewSettings(
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
              iframeAllow: "camera; microphone",
              iframeAllowFullscreen: true,
            ),
          ),

          // Loading indicator
          if (isLoading)
            Container(
              color: kWhiteColor,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: kPrimaryColor),
                    SizedBox(height: 16),
                    FText(
                      text: "Loading payment page...",
                      color: kGreyColor,
                    ),
                  ],
                ),
              ),
            ),

          // Progress bar
          if (loadingProgress < 1.0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: loadingProgress,
                backgroundColor: kGreyColor.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
              ),
            ),
        ],
      ),
    );
  }


}