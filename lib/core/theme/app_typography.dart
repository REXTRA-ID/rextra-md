import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTypography {
  static const Color _darkText = Color(0xFF102542);
  static const Color _greyText = Color(0xFF6B7280);

  // HEADING
  static TextStyle get h1 => TextStyle(
    fontSize: 48.sp,
    fontWeight: FontWeight.w700,
    color: _darkText,
    height: 1.2,
  );

  static TextStyle get h2 => TextStyle(
    fontSize: 40.sp,
    fontWeight: FontWeight.w700,
    color: _darkText,
    height: 1.2,
  );

  static TextStyle get h3 => TextStyle(
    fontSize: 32.sp,
    fontWeight: FontWeight.w700,
    color: _darkText,
    height: 1.2,
  );

  static TextStyle get h4 => TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    color: _darkText,
  );

  static TextStyle get h5 => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    color: _darkText,
  );

  static TextStyle get h6 => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    color: _darkText,
  );

  // BODY
  static TextStyle get bodyLarge => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18.sp,
    fontWeight: FontWeight.w400,
    color: _darkText,
    height: 1.5,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: _darkText,
    height: 1.5,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: _darkText,
    height: 1.5,
  );

  static TextStyle get bodyXSmall => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: _greyText,
    height: 1.4,
  );

  // BUTTON
  static TextStyle get buttonLarge => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get buttonSmall => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}