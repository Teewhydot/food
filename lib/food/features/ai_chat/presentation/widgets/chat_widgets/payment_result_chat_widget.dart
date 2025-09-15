import 'package:flutter/material.dart';
import '../../../domain/entities/widget_response.dart';
import 'base_chat_widget.dart';

/// Widget for displaying payment results and receipts
class PaymentResultChatWidget extends BaseChatWidget {
  const PaymentResultChatWidget({
    super.key,
    required super.widgetResponse,
    super.onInteraction,
  });

  PaymentResultWidgetData get paymentData =>
      widgetResponse.data as PaymentResultWidgetData;

  @override
  bool shouldShowHeader() => true;

  @override
  String getHeaderTitle() => paymentData.title;

  @override
  IconData getHeaderIcon() => Icons.payment;

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status indicator
        _buildStatusIndicator(),
        
        const SizedBox(height: 16),

        // Payment details
        _buildPaymentDetails(),

        // Message
        if (paymentData.message?.isNotEmpty == true) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              paymentData.message!,
              style: TextStyle(
                color: _getStatusColor(),
              ),
            ),
          ),
        ],

        // Receipt section
        if (paymentData.status == 'successful' && paymentData.receiptUrl != null) ...[
          const SizedBox(height: 16),
          _buildReceiptSection(),
        ],

        // Note: Actions are handled by the base widget, not here
      ],
    );
  }

  Widget _buildStatusIndicator() {
    final color = _getStatusColor();
    final icon = _getStatusIcon();
    final statusText = _getStatusText();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Booking ID: ${paymentData.bookingId}',
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Details',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildDetailRow('Amount', '₦${paymentData.amount.toStringAsFixed(0)}'),
          
          if (paymentData.transactionId != null)
            _buildDetailRow('Transaction ID', paymentData.transactionId!),
          
          _buildDetailRow('Status', _getStatusText()),
          
          _buildDetailRow('Payment Method', 'Paystack'),
          
          _buildDetailRow('Date', _formatDateTime(DateTime.now())),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.receipt,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Receipt Available',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Your payment receipt is ready for download',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              onInteraction?.call('download_receipt', {
                'receipt_url': paymentData.receiptUrl!,
                'booking_id': paymentData.bookingId,
              });
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (paymentData.status.toLowerCase()) {
      case 'successful':
      case 'completed':
        return Colors.green;
      case 'failed':
      case 'error':
        return Colors.red;
      case 'pending':
      case 'processing':
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon() {
    switch (paymentData.status.toLowerCase()) {
      case 'successful':
      case 'completed':
        return Icons.check_circle;
      case 'failed':
      case 'error':
        return Icons.error;
      case 'pending':
      case 'processing':
      default:
        return Icons.access_time;
    }
  }

  String _getStatusText() {
    switch (paymentData.status.toLowerCase()) {
      case 'successful':
        return 'Payment Successful';
      case 'completed':
        return 'Payment Completed';
      case 'failed':
        return 'Payment Failed';
      case 'error':
        return 'Payment Error';
      case 'pending':
        return 'Payment Pending';
      case 'processing':
        return 'Processing Payment';
      default:
        return 'Payment ${paymentData.status}';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}