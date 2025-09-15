import 'package:flutter/material.dart';
import '../../../domain/entities/widget_response.dart';

/// Callback type for widget interactions
typedef WidgetInteractionCallback = void Function(String action, Map<String, dynamic> parameters);

/// Base class for all chat widgets
abstract class BaseChatWidget extends StatelessWidget {
  final ChatWidgetResponse widgetResponse;
  final WidgetInteractionCallback? onInteraction;

  const BaseChatWidget({
    super.key,
    required this.widgetResponse,
    this.onInteraction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (shouldShowHeader()) _buildHeader(context),
            buildContent(context),
            if (widgetResponse.actions.isNotEmpty) _buildActions(context),
          ],
        ),
      ),
    );
  }

  /// Builds the main content of the widget
  Widget buildContent(BuildContext context);

  /// Whether to show the header with widget type indicator
  bool shouldShowHeader() => false;

  /// Gets the header title for this widget type
  String getHeaderTitle() => '';

  /// Gets the header icon for this widget type  
  IconData getHeaderIcon() => Icons.widgets;

  /// Gets the header color for this widget type
  Color getHeaderColor() => Colors.blue;

  /// Builds the header section
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: getHeaderColor().withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: getHeaderColor().withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            getHeaderIcon(),
            size: 16,
            color: getHeaderColor(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              getHeaderTitle(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: getHeaderColor(),
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the actions section
  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widgetResponse.actions.map((action) {
          return _buildActionButton(action);
        }).toList(),
      ),
    );
  }

  Widget _buildActionButton(ChatWidgetAction action) {
    final isPrimary = action.isPrimary;
    
    return ElevatedButton.icon(
      onPressed: () {
        onInteraction?.call(action.action, action.parameters);
      },
      icon: action.icon != null 
          ? Icon(
              _getIconFromName(action.icon!),
              size: 16,
            )
          : const SizedBox.shrink(),
      label: Text(action.label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.blue : Colors.grey[100],
        foregroundColor: isPrimary ? Colors.white : Colors.black87,
        elevation: isPrimary ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'hotel':
        return Icons.hotel;
      case 'payment':
        return Icons.payment;
      case 'phone':
        return Icons.phone;
      case 'email':
        return Icons.email;
      case 'info':
        return Icons.info;
      default:
        return Icons.touch_app;
    }
  }

  /// Helper method to build empty state
  Widget buildEmptyState({
    required String message,
    IconData icon = Icons.info_outline,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}