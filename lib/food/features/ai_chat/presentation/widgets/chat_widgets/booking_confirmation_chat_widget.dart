import 'package:flutter/material.dart';
import '../../../domain/entities/widget_response.dart';
import 'base_chat_widget.dart';

/// Widget for displaying booking confirmation details
class BookingConfirmationChatWidget extends BaseChatWidget {
  const BookingConfirmationChatWidget({
    super.key,
    required super.widgetResponse,
    super.onInteraction,
  });

  BookingConfirmationWidgetData get bookingData =>
      widgetResponse.data as BookingConfirmationWidgetData;

  @override
  bool shouldShowHeader() => true;

  @override
  String getHeaderTitle() => 'Booking Confirmation';

  @override
  IconData getHeaderIcon() => Icons.confirmation_number;

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Booking summary
        _buildBookingSummary(),
        
        // Room details
        if (bookingData.roomsCount > 1 && bookingData.selectedRooms != null)
          _buildMultipleRoomsSection()
        else
          _buildSingleRoomSection(),
        
        // Guest information
        _buildGuestInformation(),
        
        // Pricing breakdown
        _buildPricingBreakdown(),
        
        // Terms and conditions
        _buildTermsAndConditions(),
      ],
    );
  }

  Widget _buildBookingSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStatusIcon(),
                color: _getStatusColor(),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Booking ${bookingData.status.value.toUpperCase()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Booking ID: ${bookingData.bookingId}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleRoomSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Room Details',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildRoomDetailRow('Room', bookingData.roomName),
          _buildRoomDetailRow('Room Number', bookingData.roomNumber),
          _buildRoomDetailRow('Check-in', _formatDate(bookingData.checkIn)),
          _buildRoomDetailRow('Check-out', _formatDate(bookingData.checkOut)),
          _buildRoomDetailRow('Guests', '${bookingData.guests} guest${bookingData.guests != 1 ? 's' : ''}'),
          _buildRoomDetailRow('Duration', '${_calculateNights()} night${_calculateNights() != 1 ? 's' : ''}'),
        ],
      ),
    );
  }

  Widget _buildMultipleRoomsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rooms (${bookingData.roomsCount})',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          
          ...bookingData.selectedRooms!.map((room) => 
            _buildMultiRoomCard(room)
          ),
          
          const SizedBox(height: 12),
          _buildRoomDetailRow('Check-in', _formatDate(bookingData.checkIn)),
          _buildRoomDetailRow('Check-out', _formatDate(bookingData.checkOut)),
          _buildRoomDetailRow('Total Guests', '${bookingData.guests} guest${bookingData.guests != 1 ? 's' : ''}'),
          _buildRoomDetailRow('Duration', '${_calculateNights()} night${_calculateNights() != 1 ? 's' : ''}'),
        ],
      ),
    );
  }

  Widget _buildMultiRoomCard(BookingRoomData room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            room.roomName,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Room ${room.roomNumber} • ${room.category}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                '₦${room.totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestInformation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Guest Information',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildRoomDetailRow('Primary Guest', bookingData.guestName),
          if (bookingData.guestEmail != null)
            _buildRoomDetailRow('Email', bookingData.guestEmail!),
        ],
      ),
    );
  }

  Widget _buildPricingBreakdown() {
    final nights = _calculateNights();
    final pricePerNight = bookingData.totalPrice / nights;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pricing',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildPriceRow(
            '${bookingData.roomsCount} room${bookingData.roomsCount != 1 ? 's' : ''} × $nights night${nights != 1 ? 's' : ''}',
            '₦${(pricePerNight * nights).toStringAsFixed(0)}',
          ),
          
          const Divider(),
          
          _buildPriceRow(
            'Total',
            '₦${bookingData.totalPrice.toStringAsFixed(0)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey[600],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Terms & Conditions',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Check-in: 2:00 PM\n• Check-out: 12:00 PM\n• Cancellation: 24-hour advance notice required\n• Payment: Secure payment processing',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (bookingData.status) {
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.pending:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon() {
    switch (bookingData.status) {
      case BookingStatus.confirmed:
        return Icons.check_circle;
      case BookingStatus.cancelled:
        return Icons.cancel;
      case BookingStatus.pending:
        return Icons.pending;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  int _calculateNights() {
    try {
      final checkIn = DateTime.parse(bookingData.checkIn);
      final checkOut = DateTime.parse(bookingData.checkOut);
      return checkOut.difference(checkIn).inDays;
    } catch (e) {
      return 1;
    }
  }
}