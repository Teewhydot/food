import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/core/utils/validators.dart';
import 'package:google_fonts/google_fonts.dart';

class FTextField extends StatefulWidget {
  final String? label;
  final String hintText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final AutovalidateMode validationMode;
  final ValueChanged<String?>? onSaved;
  final double? opacity;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final FormFieldValidator? validate;
  final TextInputAction action;
  final FocusNode? node;
  final bool isPassword;
  final VoidCallback? passwordVisibilityPressed;
  final bool? isPasswordVisible;
  final Widget? isDropDown;
  final bool obscureText;
  final bool autoFocus;
  final String? errorText;
  final bool? isReadOnly;
  final bool? showCursor;
  final double labelSize;
  final FontWeight fontWeight;
  final int maxLine;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  final Color enabledColor;
  final Color focusedColor;
  final Color fillColor;
  final Color borderColor;
  final VoidCallback? dropDownPressed;
  final bool hasLabel;
  final double height;
  final Widget? prefix, suffix;
  final TextCapitalization textCapitalization;
  const FTextField({
    super.key,
    this.label,
    required this.hintText,
    this.opacity,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType,
    this.onChanged,
    this.onSaved,
    this.controller,
    this.validate,
    required this.action,
    this.node,
    this.autoFocus = false,
    this.obscureText = false,
    this.onTap,
    this.isPassword = false,
    this.passwordVisibilityPressed,
    this.isPasswordVisible,
    this.errorText,
    this.isReadOnly,
    this.showCursor,
    this.validationMode = AutovalidateMode.disabled,
    this.labelSize = 16,
    this.fontWeight = FontWeight.w500,
    this.focusedColor = kPrimaryColor,
    this.enabledColor = Colors.grey,
    this.fillColor = kContainerColor,
    this.borderColor = kContainerColor,
    this.isDropDown,
    this.maxLine = 1,
    this.maxLength,
    this.inputFormatters,
    this.dropDownPressed,
    this.hasLabel = true,
    this.height = 62,
    this.prefix,
    this.suffix,
  });

  @override
  State<FTextField> createState() => _FTextFieldState();
}

class _FTextFieldState extends State<FTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // So error aligns left
      children: [
        widget.hasLabel
            ? FText(
              text: widget.label?.toUpperCase() ?? "",
              fontSize: 13,
              alignment: MainAxisAlignment.start,
              fontWeight: FontWeight.w400,
            )
            : const SizedBox.shrink(),
        widget.hasLabel ? 8.verticalSpace : const SizedBox.shrink(),
        Container(
          height: widget.height.h,
          decoration: BoxDecoration(
            color: kTextFieldColor,
            borderRadius: BorderRadius.circular(12).r,
            border: Border.all(color: widget.borderColor, width: 1.5),
          ),
          child: Center(
            child: TextFormField(
              textCapitalization: widget.textCapitalization,
              autofocus: widget.autoFocus,
              autovalidateMode: widget.validationMode,
              readOnly: widget.isReadOnly ?? false,
              showCursor: widget.showCursor,
              textInputAction: widget.action,
              obscureText: !widget.isPassword ? false : true,
              cursorWidth: 1.2.sp,
              cursorColor: kPrimaryColor,
              onChanged: widget.onChanged,
              focusNode: widget.node,
              onSaved: widget.onSaved,
              onTap: widget.onTap,
              maxLines: widget.maxLine,
              maxLength: widget.maxLength,
              onTapOutside: (event) {
                FocusScope.of(context).unfocus();
              },
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              style: GoogleFonts.sen(
                fontSize: widget.labelSize.sp,
                fontWeight: widget.fontWeight,
                color: kTextColorDark,
              ),
              decoration: InputDecoration(
                prefixIcon: widget.prefix,
                hintText: widget.hintText,
                hintStyle: GoogleFonts.sen(
                  fontSize: widget.labelSize.sp,
                  fontWeight: FontWeight.w200,
                  color: kAddressColor,
                ),
                suffixIcon:
                    widget.isPassword
                        ? GestureDetector(
                          onTap: () {},
                          child: Icon(
                            Icons.visibility_outlined,
                            color: kTextColorDark,
                            size: 20.sp,
                          ),
                        )
                        : Padding(
                          padding: const EdgeInsetsDirectional.only(end: 16),
                          child: widget.suffix,
                        ),

                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 10,
                ),
                // Remove error borders from InputDecoration
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
