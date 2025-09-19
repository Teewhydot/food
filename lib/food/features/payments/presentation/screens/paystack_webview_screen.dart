import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../../components/scaffold.dart';
import '../../../../components/texts.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/app_utils.dart';

class PaystackWebviewScreen extends StatefulWidget {
  final String authorizationUrl;
  final String reference;
  final VoidCallback? onPaymentCompleted;
  final VoidCallback? onPaymentCancelled;

  const PaystackWebviewScreen({
    super.key,
    required this.authorizationUrl,
    required this.reference,
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

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      appBarWidget: AppBar(
        title: const FText(text: "Complete Payment"),
        backgroundColor: kWhiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: kBlackColor),
          onPressed: () {
            _showCancelConfirmation();
          },
        ),
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

              // Check if payment was completed or cancelled
              _checkPaymentStatus(url.toString());
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

  void _checkPaymentStatus(String currentUrl) {
    // Check if the URL indicates payment completion
    if (currentUrl.contains('success') ||
        currentUrl.contains('completed') ||
        currentUrl.contains('close')) {

      // Payment completed successfully
      Navigator.of(context).pop();
      widget.onPaymentCompleted?.call();

    } else if (currentUrl.contains('cancel') ||
               currentUrl.contains('failed') ||
               currentUrl.contains('error')) {

      // Payment was cancelled or failed
      Navigator.of(context).pop();
      widget.onPaymentCancelled?.call();
    }
  }

  void _showCancelConfirmation() {
    DFoodUtils.showDialogContainer(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FText(
            text: "Cancel Payment",
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 16),
          const FText(
            text: "Are you sure you want to cancel this payment?",
            textAlign: TextAlign.center,
            color: kGreyColor,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: const FText(
                    text: "Continue Payment",
                    color: kPrimaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Close webview
                    widget.onPaymentCancelled?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kErrorColor,
                  ),
                  child: const FText(
                    text: "Cancel",
                    color: kWhiteColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}