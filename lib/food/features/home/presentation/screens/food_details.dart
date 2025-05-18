import 'package:flutter/material.dart';
import 'package:food/food/features/home/presentation/widgets/details_skeleton_widget.dart';

class FoodDetails extends StatelessWidget {
  const FoodDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return DetailsSkeletonWidget(
      hasBottomWidget: true,
      hasIndicator: true,
      isRestaurant: true,
      icon: Icons.favorite,
      bodyWidget: Column(
        children: [
          // Add your body widget here
          Container(height: 200, color: Colors.blue),
          // Add more widgets as needed
        ],
      ),
    );
  }
}
