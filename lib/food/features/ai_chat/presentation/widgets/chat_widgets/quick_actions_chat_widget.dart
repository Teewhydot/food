import 'package:flutter/material.dart';
import '../../../domain/entities/widget_response.dart';
import 'base_chat_widget.dart';

/// Widget for displaying quick action buttons
class QuickActionsChatWidget extends BaseChatWidget {
  const QuickActionsChatWidget({
    super.key,
    required super.widgetResponse,
    super.onInteraction,
  });

  QuickActionsWidgetData get actionsData =>
      widgetResponse.data as QuickActionsWidgetData;

  @override
  bool shouldShowHeader() => true;

  @override
  String getHeaderTitle() => actionsData.title;

  @override
  IconData getHeaderIcon() => Icons.touch_app;

  @override
  Widget buildContent(BuildContext context) {
    final actions = actionsData.actions;

    if (actions.isEmpty) {
      return buildEmptyState(
        message: 'No quick actions available',
        icon: Icons.touch_app_outlined,
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            actionsData.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          
          // Grid of quick actions
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              return _buildActionCard(actions[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(QuickAction action) {
    return InkWell(
      onTap: () {
        onInteraction?.call(action.action, action.parameters);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconFromName(action.icon),
              size: 24,
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'hotel':
        return Icons.hotel;
      case 'room_service':
        return Icons.room_service;
      case 'restaurant':
        return Icons.restaurant;
      case 'help':
        return Icons.help;
      case 'info':
        return Icons.info;
      case 'phone':
        return Icons.phone;
      case 'email':
        return Icons.email;
      case 'search':
        return Icons.search;
      case 'book':
        return Icons.bookmark;
      case 'calendar':
        return Icons.calendar_today;
      case 'payment':
        return Icons.payment;
      case 'support':
        return Icons.support_agent;
      case 'fitness':
        return Icons.fitness_center;
      case 'pool':
        return Icons.pool;
      case 'laundry':
        return Icons.local_laundry_service;
      case 'concierge':
        return Icons.support_agent;
      default:
        return Icons.touch_app;
    }
  }
}