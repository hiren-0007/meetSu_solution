import 'package:flutter/material.dart';

class AppTheme {
  // Main Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryLightColor = Color(0xFF00B0FF);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white;
  static const Color cardColorRed = Colors.red;
  static const Color textPrimaryColor = Color(0xFF333333);
  static const Color textSecondaryColor = Color(0xFF757575);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      primaryColor,
      primaryLightColor,
    ],
  );

  // Shadows
  static BoxShadow primaryShadow = BoxShadow(
    color: const Color.fromRGBO(0, 0, 0, 0.1),
    blurRadius: 10,
    spreadRadius: 5,
  );

  static BoxShadow lightShadow = BoxShadow(
    color: const Color.fromRGBO(0, 0, 0, 0.05),
    blurRadius: 15,
    spreadRadius: 1,
  );

  static BoxShadow iconShadow = BoxShadow(
    color: const Color.fromRGBO(0, 0, 0, 0.1),
    blurRadius: 10,
    spreadRadius: 1,
  );

  // Border Radius
  static const double largeBorderRadius = 40.0;
  static const double mediumBorderRadius = 25.0;
  static const double smallBorderRadius = 12.0;

  // Paddings
  static const double screenPadding = 25.0;
  static const double cardPadding = 30.0;
  static const double contentSpacing = 20.0;
  static const double largeSpacing = 40.0;
  static const double smallSpacing = 10.0;

  // Text Styles
  static const TextStyle headerStyle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle subHeaderStyle = TextStyle(
    fontSize: 16,
    color: textSecondaryColor,
  );

  static const TextStyle appNameStyle = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
    color: Colors.white,
  );

  static TextStyle inputLabelStyle = TextStyle(
    color: textSecondaryColor,
    fontSize: 16,
  );

  static const TextStyle inputTextStyle = TextStyle(
    fontSize: 16,
    color: textPrimaryColor,
  );

  static TextStyle smallTextStyle = TextStyle(
    color: textSecondaryColor,
    fontSize: 14,
  );

  static const TextStyle linkTextStyle = TextStyle(
    color: primaryColor,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  // Input Decoration
  static InputDecoration getInputDecoration({
    required String labelText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: inputLabelStyle,
      prefixIcon: Icon(
        prefixIcon,
        color: primaryColor,
        size: 22,
      ),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(smallBorderRadius),
        borderSide: BorderSide(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(smallBorderRadius),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 16,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    );
  }

  // Button Style
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(smallBorderRadius),
    ),
    elevation: 0,
    minimumSize: const Size(double.infinity, 55),
  );

  // Card Decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(mediumBorderRadius),
    boxShadow: [lightShadow],
  );

  // App Icon Decoration
  static BoxDecoration appIconDecoration = BoxDecoration(
    color: Colors.white,
    shape: BoxShape.circle,
    boxShadow: [iconShadow],
  );

  // Header Container Decoration
  static BoxDecoration headerContainerDecoration = BoxDecoration(
    gradient: primaryGradient,
    borderRadius: const BorderRadius.only(
      bottomLeft: Radius.circular(largeBorderRadius),
      bottomRight: Radius.circular(largeBorderRadius),
    ),
    boxShadow: [primaryShadow],
  );
}