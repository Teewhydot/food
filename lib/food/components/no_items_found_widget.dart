import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/texts.dart';
import 'package:food/food/core/theme/colors.dart';

enum NoItemsType {
  food,
  restaurant,
  search,
  address,
  order,
  notification,
  chat,
  generic,
}

class NoItemsFoundWidget extends StatelessWidget {
  final NoItemsType type;
  final String? customMessage;
  final double? height;
  final IconData? customIcon;

  const NoItemsFoundWidget({
    super.key,
    required this.type,
    this.customMessage,
    this.height,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 250.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              customIcon ?? _getIconForType(type),
              size: 48,
              color: kGreyColor,
            ),
            16.verticalSpace,
            FText(
              text: customMessage ?? _getMessageForType(type),
              fontSize: 16,
              color: kGreyColor,
              alignment: MainAxisAlignment.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(NoItemsType type) {
    switch (type) {
      case NoItemsType.food:
        return Icons.fastfood;
      case NoItemsType.restaurant:
        return Icons.restaurant;
      case NoItemsType.search:
        return Icons.search_off;
      case NoItemsType.address:
        return Icons.location_off;
      case NoItemsType.order:
        return Icons.receipt_long;
      case NoItemsType.notification:
        return Icons.notifications_off;
      case NoItemsType.chat:
        return Icons.chat_bubble_outline;
      case NoItemsType.generic:
        return Icons.inbox;
    }
  }

  String _getMessageForType(NoItemsType type) {
    switch (type) {
      case NoItemsType.food:
        return 'No food available';
      case NoItemsType.restaurant:
        return 'No restaurants found';
      case NoItemsType.search:
        return 'No results found';
      case NoItemsType.address:
        return 'No addresses found';
      case NoItemsType.order:
        return 'No orders found';
      case NoItemsType.notification:
        return 'No notifications';
      case NoItemsType.chat:
        return 'No messages';
      case NoItemsType.generic:
        return 'No items found';
    }
  }
}