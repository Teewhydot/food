import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

extension NigerianPhoneNumber on String {
  String formatNigerianPhoneNumber() {
    if (startsWith('0')) {
      return '+234${substring(1)}';
    } else if (startsWith('+234')) {
      return this;
    } else {
      return '+234$this';
    }
  }
}

extension HavenMediaQuery on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;

  double get screenHeight => MediaQuery.of(this).size.height;

  double get screenPaddingTop => MediaQuery.of(this).padding.top;

  double get screenPaddingBottom => MediaQuery.of(this).padding.bottom;

  double get screenPaddingLeft => MediaQuery.of(this).padding.left;

  double get screenPaddingRight => MediaQuery.of(this).padding.right;

  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;

  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;

  bool get isSmallScreen => screenWidth < 600;

  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 1200;

  bool get isLargeScreen => screenWidth >= 1200;

  bool get isDarkMode =>
      MediaQuery.of(this).platformBrightness == Brightness.dark;
}

extension WidgetStyling on Widget {
  Widget withPadding(EdgeInsetsGeometry padding) {
    return Padding(padding: padding, child: this);
  }

  Widget withMargin(EdgeInsetsGeometry margin) {
    return Container(margin: margin, child: this);
  }
}

extension Tappable on Widget {
  Widget onTap(VoidCallback? onTap, {Key? key}) {
    return GestureDetector(key: key, onTap: onTap, child: this);
  }

  Widget onLongPress(VoidCallback? onLongPress, {Key? key}) {
    return GestureDetector(key: key, onLongPress: onLongPress, child: this);
  }
}

// skeletonizer extension for widgets
extension Skeletonizer on Widget {
  Widget skeletonize() {
    return Skeleton.leaf(child: this);
  }
}

extension StringExtensions on String {
  String toSentenceCase() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ')
        .map(
          (word) =>
              word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                  : '',
        )
        .join(' ');
  }
}
