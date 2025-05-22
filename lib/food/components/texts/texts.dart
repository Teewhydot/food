import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/colors.dart';

class FText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color, decorationColor;
  final FontWeight fontWeight;
  final MainAxisAlignment alignment;
  final List<TextDecoration> decorations;

  const FText({
    super.key,
    required this.text,
    this.fontSize = 16.0,
    this.color = Colors.black,
    this.decorationColor = kPrimaryColor,
    this.fontWeight = FontWeight.bold,
    this.alignment = MainAxisAlignment.center,
    this.decorations = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        Text(
          text,
          style: GoogleFonts.sen(
            fontSize: fontSize.sp,
            color: color,
            fontWeight: fontWeight,
            decoration: TextDecoration.combine([...decorations]),
            decorationColor: decorationColor,
          ),
        ),
      ],
    );
  }
}

class FRichText extends StatelessWidget {
  final String text, text2;
  final double fontSize;
  final Color color, text2Color;
  final FontWeight fontWeight;
  final MainAxisAlignment alignment;

  const FRichText({
    super.key,
    required this.text,
    required this.text2,
    this.fontSize = 16.0,
    this.color = kBlackColor,
    this.text2Color = kPrimaryColor,
    this.fontWeight = FontWeight.bold,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        Text(
          text,
          style: GoogleFonts.sen(
            fontSize: fontSize.sp,
            color: color,
            fontWeight: fontWeight,
          ),
        ),
        Text(
          text2,
          style: GoogleFonts.abel(
            fontSize: fontSize.sp,
            color: text2Color,
            fontWeight: fontWeight,
          ),
        ),
      ],
    );
  }
}

class FWrapText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final TextOverflow? textOverflow;
  const FWrapText({
    super.key,
    required this.text,
    this.fontSize = 16.0,
    this.color = kBlackColor,
    this.fontWeight = FontWeight.bold,
    this.textAlign = TextAlign.center,
    this.textOverflow,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center, // Adjust alignment as needed
      child: Wrap(
        alignment: WrapAlignment.center, // Aligns the text within the Wrap
        children: [
          Text(
            text,
            textAlign: textAlign, // Ensures text is centered
            overflow: textOverflow,
            style: GoogleFonts.sen(
              fontSize: fontSize.sp,
              color: color,
              fontWeight: fontWeight,
            ),
          ),
        ],
      ),
    );
  }
}
