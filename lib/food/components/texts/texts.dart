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
  final TextOverflow textOverflow;

  const FText({
    super.key,
    required this.text,
    this.fontSize = 16.0,
    this.color = Colors.black,
    this.decorationColor = kPrimaryColor,
    this.fontWeight = FontWeight.bold,
    this.alignment = MainAxisAlignment.center,
    this.decorations = const [],
    this.textOverflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        Text(
          text,
          overflow: textOverflow,
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
  final Alignment alignment;
  final TextOverflow? textOverflow;
  const FWrapText({
    super.key,
    required this.text,
    this.fontSize = 16.0,
    this.color = kBlackColor,
    this.fontWeight = FontWeight.bold,
    this.textAlign = TextAlign.center,
    this.alignment = Alignment.center,
    this.textOverflow,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment, // Adjust alignment as needed
      child: Wrap(
        alignment: WrapAlignment.center, // Aligns the text within the Wrap
        children: [
          Text(
            text,
            textAlign: textAlign,
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

class FConstrainedText extends StatelessWidget {
  final double maxWidth, minWidth;
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;

  const FConstrainedText({
    super.key,
    required this.text,
    this.maxWidth = double.infinity,
    this.minWidth = 0.0,
    this.fontSize = 16.0,
    this.color = kBlackColor,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth, minWidth: minWidth),
      child: Text(
        text,
        style: GoogleFonts.sen(
          fontSize: fontSize.sp,
          color: color,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
