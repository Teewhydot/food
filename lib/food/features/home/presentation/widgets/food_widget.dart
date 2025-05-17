import 'package:flutter/material.dart';
import 'package:food/food/features/home/presentation/widgets/trapezoid_container.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';

class PopularFastFood extends StatelessWidget {
  final String image, name, restaurantName, price;
  const PopularFastFood({
    super.key,
    required this.image,
    required this.name,
    required this.restaurantName,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(painter: RPSCustomPainter(), size: Size(150, 123)),
        FoodContainer(width: 153, height: 130),
      ],
    );
  }
}
