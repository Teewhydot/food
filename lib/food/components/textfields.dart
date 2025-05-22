import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class FTextField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        hasLabel
            ? FText(
              text: label ?? "",
              fontSize: 13,
              alignment: MainAxisAlignment.start,
              fontWeight: FontWeight.w400,
            )
            : const SizedBox.shrink(),
        hasLabel ? 8.verticalSpace : const SizedBox.shrink(),
        Container(
          height: height.h,
          decoration: BoxDecoration(
            color: kTextFieldColor,
            borderRadius: BorderRadius.circular(12).r,
          ),
          child: Center(
            child: TextFormField(
              textCapitalization: textCapitalization,
              autofocus: autoFocus,
              autovalidateMode: validationMode,
              readOnly: isReadOnly ?? false,
              showCursor: showCursor,
              textInputAction: action,
              obscureText: !isPassword ? false : true,
              cursorWidth: 1.2.sp,
              cursorColor: kPrimaryColor,
              onChanged: onChanged,
              focusNode: node,
              onSaved: onSaved,
              onTap: onTap,
              validator: validate,
              maxLines: maxLine,
              maxLength: maxLength,
              onTapOutside: (event) {
                FocusScope.of(context).unfocus();
              },
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              style: GoogleFonts.sen(
                fontSize: labelSize.sp,
                fontWeight: fontWeight,
                color: kTextColorDark,
              ),
              decoration: InputDecoration(
                prefixIcon: prefix,
                hintText: hintText,
                hintStyle: GoogleFonts.sen(
                  fontSize: labelSize.sp,
                  fontWeight: FontWeight.w200,
                  color: kAddressColor,
                ),
                suffixIcon:
                    isPassword
                        ? GestureDetector(
                          onTap: () {},
                          child: Icon(
                            Icons.visibility_outlined,
                            color: kTextColorDark,
                            size: 20.sp,
                          ),
                        )
                        : Padding(
                          padding: const EdgeInsetsDirectional.only(
                            end: 16,
                            // top: 21,
                            // bottom: 21,
                          ),
                          child: suffix,
                        ),
                errorStyle: TextStyle(
                  height: 1.2.sp,
                  color: Colors.red,
                  fontSize: 12.sp,
                ),
                errorText: errorText,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 10,
                ),
                // focusedBorder: OutlineInputBorder(
                //   borderRadius: BorderRadius.circular(8.sp),
                //   borderSide: BorderSide(color: focusedColor),
                // ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.sp),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                border: InputBorder.none,
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.sp),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
