import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/colors.dart';

enum TextVariant {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
}

enum TextArrangement { left, right, center, justify, start, end }

enum TextWrap { noWrap, wrap, ellipsis, fade, clip, visible }

class FText extends StatelessWidget {
  const FText({
    super.key,
    required this.text,
    this.variant = TextVariant.bodyMedium,
    this.color = Colors.black,
    this.decorationColor = kPrimaryColor,
    this.textAlign,
    this.arrangement,
    this.wrap = TextWrap.ellipsis,
    this.maxLines,
    this.overflow,
    this.fontWeight = FontWeight.bold,
    this.fontSize = 16.0,
    this.height,
    this.letterSpacing,
    this.wordSpacing,
    this.decoration,
    this.decorationStyle,
    this.decorationThickness,
    this.fontStyle,
    this.textBaseline,
    this.textDirection,
    this.softWrap,
    this.textScaler,
    this.onTap,
    this.selectable = false,
    this.width,
    this.padding,
    this.margin,
    // Legacy parameters for backward compatibility
    this.alignment = MainAxisAlignment.center,
    this.decorations = const [],
    this.textOverflow = TextOverflow.ellipsis,
  });

  // Legacy constructor for backward compatibility
  const FText.legacy({
    super.key,
    required this.text,
    this.fontSize = 16.0,
    this.color = Colors.black,
    this.decorationColor = kPrimaryColor,
    this.fontWeight = FontWeight.bold,
    this.alignment = MainAxisAlignment.center,
    this.decorations = const [],
    this.textOverflow = TextOverflow.ellipsis,
  }) : variant = TextVariant.bodyMedium,
       textAlign = null,
       arrangement = null,
       wrap = TextWrap.ellipsis,
       maxLines = null,
       overflow = null,
       height = null,
       letterSpacing = null,
       wordSpacing = null,
       decoration = null,
       decorationStyle = null,
       decorationThickness = null,
       fontStyle = null,
       textBaseline = null,
       textDirection = null,
       softWrap = null,
       textScaler = null,
       onTap = null,
       selectable = false,
       width = null,
       padding = null,
       margin = null;

  // Factory constructors following AppText pattern
  factory FText.displayLarge(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    TextArrangement? arrangement,
    TextWrap wrap = TextWrap.wrap,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    VoidCallback? onTap,
    double? width,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return FText(
      text: text,
      key: key,
      variant: TextVariant.displayLarge,
      color: color ?? Colors.black,
      textAlign: textAlign,
      arrangement: arrangement,
      wrap: wrap,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight ?? FontWeight.bold,
      height: height,
      letterSpacing: letterSpacing,
      onTap: onTap,
      width: width,
      padding: padding,
      margin: margin,
    );
  }

  factory FText.headlineLarge(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    TextArrangement? arrangement,
    TextWrap wrap = TextWrap.wrap,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    VoidCallback? onTap,
    double? width,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return FText(
      text: text,
      key: key,
      variant: TextVariant.headlineLarge,
      color: color ?? Colors.black,
      textAlign: textAlign,
      arrangement: arrangement,
      wrap: wrap,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight ?? FontWeight.bold,
      height: height,
      letterSpacing: letterSpacing,
      onTap: onTap,
      width: width,
      padding: padding,
      margin: margin,
    );
  }

  factory FText.titleLarge(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    TextArrangement? arrangement,
    TextWrap wrap = TextWrap.wrap,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    VoidCallback? onTap,
    double? width,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return FText(
      text: text,
      key: key,
      variant: TextVariant.titleLarge,
      color: color ?? Colors.black,
      textAlign: textAlign,
      arrangement: arrangement,
      wrap: wrap,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight ?? FontWeight.bold,
      height: height,
      letterSpacing: letterSpacing,
      onTap: onTap,
      width: width,
      padding: padding,
      margin: margin,
    );
  }

  factory FText.titleMedium(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    TextArrangement? arrangement,
    TextWrap wrap = TextWrap.wrap,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    VoidCallback? onTap,
    double? width,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return FText(
      text: text,
      key: key,
      variant: TextVariant.titleMedium,
      color: color ?? Colors.black,
      textAlign: textAlign,
      arrangement: arrangement,
      wrap: wrap,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight ?? FontWeight.bold,
      height: height,
      letterSpacing: letterSpacing,
      onTap: onTap,
      width: width,
      padding: padding,
      margin: margin,
    );
  }

  factory FText.headlineSmall(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    TextArrangement? arrangement,
    TextWrap wrap = TextWrap.wrap,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    VoidCallback? onTap,
    double? width,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return FText(
      text: text,
      key: key,
      variant: TextVariant.headlineSmall,
      color: color ?? Colors.black,
      textAlign: textAlign,
      arrangement: arrangement,
      wrap: wrap,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight ?? FontWeight.bold,
      height: height,
      letterSpacing: letterSpacing,
      onTap: onTap,
      width: width,
      padding: padding,
      margin: margin,
    );
  }

  factory FText.bodyLarge(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    TextArrangement? arrangement,
    TextWrap wrap = TextWrap.wrap,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    VoidCallback? onTap,
    double? width,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return FText(
      text: text,
      key: key,
      variant: TextVariant.bodyLarge,
      color: color ?? Colors.black,
      textAlign: textAlign,
      arrangement: arrangement,
      wrap: wrap,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight ?? FontWeight.bold,
      height: height,
      letterSpacing: letterSpacing,
      onTap: onTap,
      width: width,
      padding: padding,
      margin: margin,
    );
  }

  factory FText.bodyMedium(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    TextArrangement? arrangement,
    TextWrap wrap = TextWrap.wrap,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    VoidCallback? onTap,
    double? width,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return FText(
      text: text,
      key: key,
      variant: TextVariant.bodyMedium,
      color: color ?? Colors.black,
      textAlign: textAlign,
      arrangement: arrangement,
      wrap: wrap,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight ?? FontWeight.bold,
      height: height,
      letterSpacing: letterSpacing,
      onTap: onTap,
      width: width,
      padding: padding,
      margin: margin,
    );
  }

  factory FText.labelMedium(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    TextArrangement? arrangement,
    TextWrap wrap = TextWrap.wrap,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    VoidCallback? onTap,
    double? width,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return FText(
      text: text,
      key: key,
      variant: TextVariant.labelMedium,
      color: color ?? Colors.black,
      textAlign: textAlign,
      arrangement: arrangement,
      wrap: wrap,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight ?? FontWeight.bold,
      height: height,
      letterSpacing: letterSpacing,
      onTap: onTap,
      width: width,
      padding: padding,
      margin: margin,
    );
  }

  factory FText.labelSmall(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    TextArrangement? arrangement,
    TextWrap wrap = TextWrap.wrap,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    VoidCallback? onTap,
    double? width,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return FText(
      text: text,
      key: key,
      variant: TextVariant.labelSmall,
      color: color ?? Colors.black,
      textAlign: textAlign,
      arrangement: arrangement,
      wrap: wrap,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight ?? FontWeight.bold,
      height: height,
      letterSpacing: letterSpacing,
      onTap: onTap,
      width: width,
      padding: padding,
      margin: margin,
    );
  }

  factory FText.centered(
    String text, {
    Key? key,
    TextVariant variant = TextVariant.bodyMedium,
    Color? color,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
    double? fontSize,
    double? height,
    double? letterSpacing,
    VoidCallback? onTap,
    double? width,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return FText(
      text: text,
      key: key,
      variant: variant,
      color: color ?? Colors.black,
      arrangement: TextArrangement.center,
      textAlign: TextAlign.center,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight ?? FontWeight.bold,
      fontSize: fontSize ?? 16.0,
      height: height,
      letterSpacing: letterSpacing,
      onTap: onTap,
      width: width,
      padding: padding,
      margin: margin,
    );
  }

  factory FText.bodySmall(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    TextArrangement? arrangement,
    TextWrap wrap = TextWrap.wrap,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    VoidCallback? onTap,
    double? width,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return FText(
      text: text,
      key: key,
      variant: TextVariant.bodySmall,
      color: color ?? Colors.black,
      textAlign: textAlign,
      arrangement: arrangement,
      wrap: wrap,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight ?? FontWeight.bold,
      height: height,
      letterSpacing: letterSpacing,
      onTap: onTap,
      width: width,
      padding: padding,
      margin: margin,
    );
  }

  factory FText.labelLarge(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    TextArrangement? arrangement,
    TextWrap wrap = TextWrap.wrap,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    VoidCallback? onTap,
    double? width,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return FText(
      text: text,
      key: key,
      variant: TextVariant.labelLarge,
      color: color ?? Colors.black,
      textAlign: textAlign,
      arrangement: arrangement,
      wrap: wrap,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight ?? FontWeight.bold,
      height: height,
      letterSpacing: letterSpacing,
      onTap: onTap,
      width: width,
      padding: padding,
      margin: margin,
    );
  }

  factory FText.headlineMedium(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    TextArrangement? arrangement,
    TextWrap wrap = TextWrap.wrap,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    VoidCallback? onTap,
    double? width,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return FText(
      text: text,
      key: key,
      variant: TextVariant.headlineMedium,
      color: color ?? Colors.black,
      textAlign: textAlign,
      arrangement: arrangement,
      wrap: wrap,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight ?? FontWeight.bold,
      height: height,
      letterSpacing: letterSpacing,
      onTap: onTap,
      width: width,
      padding: padding,
      margin: margin,
    );
  }

  factory FText.displayMedium(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    TextArrangement? arrangement,
    TextWrap wrap = TextWrap.wrap,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    VoidCallback? onTap,
    double? width,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return FText(
      text: text,
      key: key,
      variant: TextVariant.displayMedium,
      color: color ?? Colors.black,
      textAlign: textAlign,
      arrangement: arrangement,
      wrap: wrap,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight ?? FontWeight.bold,
      height: height,
      letterSpacing: letterSpacing,
      onTap: onTap,
      width: width,
      padding: padding,
      margin: margin,
    );
  }

  factory FText.displaySmall(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    TextArrangement? arrangement,
    TextWrap wrap = TextWrap.wrap,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    VoidCallback? onTap,
    double? width,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return FText(
      text: text,
      key: key,
      variant: TextVariant.displaySmall,
      color: color ?? Colors.black,
      textAlign: textAlign,
      arrangement: arrangement,
      wrap: wrap,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight ?? FontWeight.bold,
      height: height,
      letterSpacing: letterSpacing,
      onTap: onTap,
      width: width,
      padding: padding,
      margin: margin,
    );
  }

  factory FText.titleSmall(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    TextArrangement? arrangement,
    TextWrap wrap = TextWrap.wrap,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    VoidCallback? onTap,
    double? width,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return FText(
      text: text,
      key: key,
      variant: TextVariant.titleSmall,
      color: color ?? Colors.black,
      textAlign: textAlign,
      arrangement: arrangement,
      wrap: wrap,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight ?? FontWeight.bold,
      height: height,
      letterSpacing: letterSpacing,
      onTap: onTap,
      width: width,
      padding: padding,
      margin: margin,
    );
  }

  final String text;
  final TextVariant variant;
  final Color color, decorationColor;
  final TextAlign? textAlign;
  final TextArrangement? arrangement;
  final TextWrap wrap;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight fontWeight;
  final double fontSize;
  final double? height;
  final double? letterSpacing;
  final double? wordSpacing;
  final TextDecoration? decoration;
  final TextDecorationStyle? decorationStyle;
  final double? decorationThickness;
  final FontStyle? fontStyle;
  final TextBaseline? textBaseline;
  final TextDirection? textDirection;
  final bool? softWrap;
  final TextScaler? textScaler;
  final VoidCallback? onTap;
  final bool selectable;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  // Legacy parameters for backward compatibility
  final MainAxisAlignment alignment;
  final List<TextDecoration> decorations;
  final TextOverflow textOverflow;

  @override
  Widget build(BuildContext context) {
    final textStyle = _getTextStyle(context).copyWith(
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize.sp,
      height: height,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      decoration: decoration ?? TextDecoration.combine([...decorations]),
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontStyle: fontStyle,
      textBaseline: textBaseline,
    );

    // Determine text alignment
    final effectiveTextAlign = textAlign ?? _getTextAlignFromArrangement();

    // Determine overflow behavior - prioritize new wrap system over legacy
    final effectiveOverflow =
        overflow ?? _getOverflowFromWrap() ?? textOverflow;

    // Determine soft wrap
    final effectiveSoftWrap = softWrap ?? _getSoftWrapFromWrap();

    Widget textWidget;

    if (selectable) {
      textWidget = SelectableText(
        text,
        style: textStyle,
        textAlign: effectiveTextAlign,
        maxLines: maxLines,
        textDirection: textDirection,
        textScaler: textScaler,
      );
    } else {
      textWidget = Text(
        text,
        style: textStyle,
        textAlign: effectiveTextAlign,
        maxLines: maxLines,
        overflow: effectiveOverflow,
        softWrap: effectiveSoftWrap,
        textDirection: textDirection,
        textScaler: textScaler,
      );
    }

    // Apply width constraint if specified
    if (width != null) {
      textWidget = SizedBox(width: width, child: textWidget);
    }

    // Apply padding if specified
    if (padding != null) {
      textWidget = Padding(padding: padding!, child: textWidget);
    }

    // Apply margin if specified
    if (margin != null) {
      textWidget = Container(margin: margin, child: textWidget);
    }

    // Apply tap handler
    if (onTap != null) {
      textWidget = GestureDetector(onTap: onTap, child: textWidget);
    }

    // Apply arrangement-specific wrapping or legacy alignment
    if (arrangement == TextArrangement.center) {
      textWidget = Center(child: textWidget);
    } else if (arrangement == TextArrangement.right ||
        arrangement == TextArrangement.end) {
      textWidget = Align(alignment: Alignment.centerRight, child: textWidget);
    } else if (arrangement == TextArrangement.left ||
        arrangement == TextArrangement.start) {
      textWidget = Align(alignment: Alignment.centerLeft, child: textWidget);
    } else {
      // Legacy alignment behavior for backward compatibility
      textWidget = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: alignment,
        children: [Flexible(child: textWidget)],
      );
    }

    return textWidget;
  }

  TextAlign? _getTextAlignFromArrangement() {
    if (arrangement == null) return null;
    switch (arrangement!) {
      case TextArrangement.left:
        return TextAlign.left;
      case TextArrangement.right:
        return TextAlign.right;
      case TextArrangement.center:
        return TextAlign.center;
      case TextArrangement.justify:
        return TextAlign.justify;
      case TextArrangement.start:
        return TextAlign.start;
      case TextArrangement.end:
        return TextAlign.end;
    }
  }

  TextOverflow? _getOverflowFromWrap() {
    switch (wrap) {
      case TextWrap.noWrap:
        return TextOverflow.clip;
      case TextWrap.wrap:
        return null;
      case TextWrap.ellipsis:
        return TextOverflow.ellipsis;
      case TextWrap.fade:
        return TextOverflow.fade;
      case TextWrap.clip:
        return TextOverflow.clip;
      case TextWrap.visible:
        return TextOverflow.visible;
    }
  }

  bool _getSoftWrapFromWrap() {
    switch (wrap) {
      case TextWrap.noWrap:
        return false;
      case TextWrap.wrap:
        return true;
      case TextWrap.ellipsis:
      case TextWrap.fade:
      case TextWrap.clip:
      case TextWrap.visible:
        return false;
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    switch (variant) {
      case TextVariant.displayLarge:
        return GoogleFonts.sen(
          fontSize: 57.sp,
          fontWeight: FontWeight.w400,
          color: kBlackColor,
        );
      case TextVariant.displayMedium:
        return GoogleFonts.sen(
          fontSize: 45.sp,
          fontWeight: FontWeight.w400,
          color: kBlackColor,
        );
      case TextVariant.displaySmall:
        return GoogleFonts.sen(
          fontSize: 36.sp,
          fontWeight: FontWeight.w400,
          color: kBlackColor,
        );
      case TextVariant.headlineLarge:
        return GoogleFonts.sen(
          fontSize: 32.sp,
          fontWeight: FontWeight.w600,
          color: kBlackColor,
        );
      case TextVariant.headlineMedium:
        return GoogleFonts.sen(
          fontSize: 28.sp,
          fontWeight: FontWeight.w600,
          color: kBlackColor,
        );
      case TextVariant.headlineSmall:
        return GoogleFonts.sen(
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
          color: kBlackColor,
        );
      case TextVariant.titleLarge:
        return GoogleFonts.sen(
          fontSize: 22.sp,
          fontWeight: FontWeight.w700,
          color: kBlackColor,
        );
      case TextVariant.titleMedium:
        return GoogleFonts.sen(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: kBlackColor,
        );
      case TextVariant.titleSmall:
        return GoogleFonts.sen(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: kBlackColor,
        );
      case TextVariant.bodyLarge:
        return GoogleFonts.sen(
          fontSize: 18.sp,
          fontWeight: FontWeight.w400,
          color: kBlackColor,
        );
      case TextVariant.bodyMedium:
        return GoogleFonts.sen(
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: kBlackColor,
        );
      case TextVariant.bodySmall:
        return GoogleFonts.sen(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: kBlackColor,
        );
      case TextVariant.labelLarge:
        return GoogleFonts.sen(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: kBlackColor,
        );
      case TextVariant.labelMedium:
        return GoogleFonts.sen(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: kBlackColor,
        );
      case TextVariant.labelSmall:
        return GoogleFonts.sen(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: kBlackColor,
        );
    }
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
