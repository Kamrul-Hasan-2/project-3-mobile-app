import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

const Color bluishClr = Color(0xff4e5ae8);
const Color yellowClr = Color(0xFFFFB746);
const Color pinkClr = Color(0xFFff4667);
const Color white = Colors.white;
const primaryClr = bluishClr;
const Color darkGreyClr = Color(0xFF121212);
Color darkHeaderClr = Color(0xFF525050);
// Custom color variable (can be updated dynamically)
Color customColor = Colors.teal; // Default custom color

class Themes {
  static final light = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    useMaterial3: true,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryClr, // Sets AppBar background color
      foregroundColor: Colors.black, // Sets AppBar text/icon color
      // Sets AppBar text/icon color
    ),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
        backgroundColor:
            darkGreyClr, // Sets AppBar background color for dark theme
        foregroundColor:
            Colors.white // Sets AppBar text/icon color for dark theme
        ),
  );
}

TextStyle get subHeadingStyle {
  return GoogleFonts.lato(
      textStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Get.isDarkMode ? Colors.grey[400] : Colors.grey));
}

TextStyle get headingStyle {
  return GoogleFonts.lato(
      textStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Get.isDarkMode ? Colors.white : Colors.black));
}

TextStyle get titleStyle {
  return GoogleFonts.lato(
      textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Get.isDarkMode ? Colors.white : Colors.black));
}

TextStyle get subTitleStyle {
  return GoogleFonts.lato(
      textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          // color: Get.isDarkMode? Colors.grey[100]:Colors.grey[600]
          color: Get.isDarkMode ? Colors.grey[100] : Colors.black));
}

TextStyle get subTitleStyle2 {
  return GoogleFonts.lato(
      textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          // color: Get.isDarkMode? Colors.grey[100]:Colors.grey[600]
          color: Get.isDarkMode ? Colors.grey[100] : Colors.black));
}
