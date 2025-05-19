import 'package:flutter/material.dart';

class DFoodDraggableBottomSheet extends StatelessWidget {
  const DFoodDraggableBottomSheet({super.key});

  void _showDraggableScrollableBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // This is important for full screen height
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5, // Initial height of the sheet
          minChildSize: 0.25, // Minimum height when dragged down
          maxChildSize: 0.9, // Maximum height when dragged up
          expand: false, // Set to true if you want the sheet to take full height initially
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              color: Colors.blue[100], // Background color of the sheet
              child: ListView.builder(
                controller: scrollController,
                itemCount: 50, // Example list items
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text('Item $index'),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bottom Sheet Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showDraggableScrollableBottomSheet(context),
          child: const Text('Show Draggable Bottom Sheet'),
        ),
      ),
    );
  }
}
