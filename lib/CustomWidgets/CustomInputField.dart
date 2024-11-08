import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../untils/utils.dart';

class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText; // Initially passed as true for password
  final String? svgIconPath; // Path to SVG icon
  final Color? iconColor; // Color for the SVG icon
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final String? hintText;

  CustomInputField({
    required this.controller,
    required this.label,
    this.obscureText = false, // Default to false unless used for password
    this.svgIconPath,
    this.iconColor, // Color for the SVG icon
    this.keyboardType = TextInputType.text,
    this.validator,
    this.hintText,
  });

  @override
  _CustomInputFieldState createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _obscureText = true; // Default value for hiding the text

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText; // Set the initial state from the parent
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscureText, // Toggles based on eye icon
        keyboardType: widget.keyboardType,
        obscuringCharacter: '*',
        style: AppColors.descriptionStyle.copyWith(
          color: AppColors.bottomColor,
        ),
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.never,
          fillColor: AppColors.inputBtnColor,
          filled: true,
          labelText: widget.label,
          hintText: widget.hintText,
          hintStyle: AppColors.descriptionStyle.copyWith(
            color: AppColors.bottomColor,
          ),
          labelStyle: AppColors.headingStyle.copyWith(
            color: AppColors.bottomColor,
            fontSize: 14.65.sp,
          ),
          prefixIcon: widget.svgIconPath != null
              ? Padding(
            padding: EdgeInsets.all(8.0), // Add padding around the icon
            child: SvgPicture.asset(
              widget.svgIconPath!,
              fit: BoxFit.scaleDown,
              width: 24.0,
              height: 24.0,
              color: widget.iconColor ?? AppColors.bottomColor, // Apply color
            ),
          )
              : null,
          suffixIcon: widget.obscureText
              ? IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: AppColors.bottomColor,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText; // Toggle the obscure text
              });
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(color: AppColors.borderColor, width: 3.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.borderColor, width: 3.0),
            borderRadius: BorderRadius.circular(20.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.borderColor, width: 3.0),
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        validator: widget.validator,
      ),
    );
  }
}
