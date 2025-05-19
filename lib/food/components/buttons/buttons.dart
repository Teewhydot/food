import 'package:flutter/cupertino.dart';

import '../../core/theme/colors.dart';

class FButton extends StatefulWidget {
  final String buttonText;
  final double fontSize;
  final Color color;
  final Color textColor;
  final FontWeight fontWeight;
  final MainAxisAlignment alignment;
  final Widget? icon;
  final Function()? onPressed;
  final double height;
  final double width;
  final double borderRadius;
  final double iconSize;
  final Color borderColor;

  const FButton({
    super.key,
    required this.buttonText,
    this.fontSize = 14.0,
    this.color = kPrimaryColor,
    this.textColor = kWhiteColor,
    this.fontWeight = FontWeight.w700,
    this.alignment = MainAxisAlignment.center,
    this.icon,
    this.onPressed,
    this.height = 50.0,
    this.width = 300,
    this.borderRadius = 12.0,
    this.iconSize = 24.0,
    this.borderColor = kPrimaryColor,
  });

  @override
  State<FButton> createState() => _FButtonState();
}

class _FButtonState extends State<FButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: widget.borderColor),
      ),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Row(
          mainAxisAlignment: widget.alignment,
          children: [
            Text(
              widget.buttonText.toUpperCase(),
              style: TextStyle(
                fontSize: widget.fontSize,
                color: widget.textColor,
                fontWeight: widget.fontWeight,
              ),
            ),
            if (widget.icon != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: widget.icon!,
              ),
          ],
        ),
      ),
    );
  }
}
