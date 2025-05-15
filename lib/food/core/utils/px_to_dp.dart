import 'package:flutter/cupertino.dart';

double convertPxToDp(double px, BuildContext context) {
  return px / MediaQuery.of(context).devicePixelRatio;
}
