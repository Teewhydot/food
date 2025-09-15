import 'package:flutter/material.dart';
import '../../../domain/entities/widget_response.dart';
import 'base_chat_widget.dart';

/// Chat widget for displaying a list of available rooms
class RoomListChatWidget extends BaseChatWidget {
  const RoomListChatWidget({
    super.key,
    required super.widgetResponse,
    super.onInteraction,
  });

  RoomListWidgetData get roomData => widgetResponse.data as RoomListWidgetData;

  @override
  bool shouldShowHeader() => true;

  @override
  String getHeaderTitle() => roomData.title ?? 'Available Rooms';

  @override
  IconData getHeaderIcon() => Icons.hotel;

  @override
  Color getHeaderColor() => Colors.blue;

  @override
  Widget buildContent(BuildContext context) {
    final rooms = roomData.rooms;

    if (rooms.isEmpty) {
      return buildEmptyState(
        message: 'No rooms available for the selected dates',
        icon: Icons.hotel_outlined,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search criteria summary
        _buildSearchSummary(),
        
        // Room list
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rooms.length,
          separatorBuilder: (context, index) => const Divider(
            color: Colors.grey,
            height: 1,
          ),
          itemBuilder: (context, index) => _buildRoomCard(context, rooms[index]),
        ),
        
        // Instructions banner
        _buildInstructionsBanner(),
      ],
    );
  }

  /// Builds the search criteria summary
  Widget _buildSearchSummary() {
    final checkInDate = DateTime.tryParse(roomData.checkIn);
    final checkOutDate = DateTime.tryParse(roomData.checkOut);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.blue.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.blue[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search Results',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDate(checkInDate)} - ${_formatDate(checkOutDate)} • ${roomData.guests} guest${roomData.guests != 1 ? 's' : ''} • ${roomData.roomsRequested} room${roomData.roomsRequested != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds individual room card
  Widget _buildRoomCard(BuildContext context, RoomWidgetData room) {
    return InkWell(
      onTap: () {
        onInteraction?.call('select_room', {
          'room_id': room.id,
          'room_name': room.name,
          'room_category': room.category,
          'room_price': room.price,
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey[300],
                child: room.imageUrl != null
                    ? Image.network(
                        room.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.hotel, size: 40),
                      )
                    : const Icon(Icons.hotel, size: 40),
              ),
            ),
            const SizedBox(width: 12),
            
            // Room details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room name and category
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              room.category,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₦${room.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                          const Text(
                            'per night',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Rating and guests
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: Colors.amber[600],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        room.rating.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.people,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Max ${room.maxGuests}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Amenities
                  if (room.amenities.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: room.amenities.take(3).map((amenity) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            amenity,
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds instructions banner
  Widget _buildInstructionsBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.touch_app,
            size: 16,
            color: Colors.green[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tap any room to select it for booking',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Invalid Date';
    return '${date.day}/${date.month}/${date.year}';
  }
}