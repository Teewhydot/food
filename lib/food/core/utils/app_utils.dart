import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/core/theme/colors.dart';

class DFoodUtils {
  static showDialogContainer({
    required BuildContext context,
    required Widget child,
    double? height,
    double width = 382,
    bool isDismissible = true,
    EdgeInsets? insetPadding,
    EdgeInsets? contentPadding,
    bool pop = false,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: isDismissible,
      barrierColor: kPrimaryColor.withOpacity(0.7),
      builder: (context) {
        return PopScope(
          canPop: pop,
          onPopInvoked: (didPop) {},
          child: Dialog(
            clipBehavior: Clip.none,
            insetPadding: insetPadding,
            backgroundColor: kWhiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(35).r,
            ),
            child: Container(
              width: width.w,
              height: height,
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.circular(35).r,
              ),
              padding:
                  contentPadding ??
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 10).r,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class DialogWithStackExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dialog with Stack Example")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  insetPadding: EdgeInsets.all(20),
                  child: Material(
                    clipBehavior: Clip.none, // Allow overflow
                    child: Stack(
                      clipBehavior: Clip.none, // Ensure Stack allows overflow
                      children: [
                        Container(
                          height: 200,
                          width: 300,
                          color: Colors.white,
                          child: Center(child: Text("Dialog Content")),
                        ),
                        Positioned(
                          top: -20,
                          right: -20,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.red,
                            child: Icon(Icons.close, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: Text("Show Dialog"),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: DialogWithStackExample()));
}
