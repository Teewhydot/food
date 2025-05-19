import 'package:flutter/material.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:food/food/features/tracking/presentation/widgets/draggable_bottomsheet.dart';

class TrackingOrder extends StatefulWidget {
  const TrackingOrder({super.key});

  @override
  State<TrackingOrder> createState() => _TrackingOrderState();
}

class _TrackingOrderState extends State<TrackingOrder> {
    double _calculateChildSize(double height, double maxHeight) {
    // Calculate what fraction of the screen height the given pixel height represents
    return height / maxHeight;
  }
    final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
          Positioned.fill(
            child: FoodContainer(
              color: kGreyColor,
              child: const Center(
                child: Text(
                  'Main Content',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return DraggableScrollableSheet(
                  controller: _sheetController,
                  initialChildSize: 0.3,
                  minChildSize: 0.3,
                  maxChildSize: 0.8, // 80% of screen height
                  snap: true,
                  snapSizes: const [0.2, 0.5, 0.8],
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Drag handle
                          Container(
                            height: 24,
                            alignment: Alignment.center,
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          
                          // Scrollable content
                          Expanded(
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: 20,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text('Item $index'),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}