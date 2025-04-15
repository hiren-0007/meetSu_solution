import 'package:flutter/material.dart';

class AppTheme {
  // Main Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryLightColor = Color(0xFF00B0FF);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white;
  static const Color blackColor = Colors.black;
  static const Color cardColorRed = Colors.red;
  static const Color textPrimaryColor = Color(0xFF333333);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color white = Colors.white;
  static const Color white30 = Colors.white30;
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color boxDecorationColor = Color.fromRGBO(0, 0, 0, 0.05);

  // Transparent Colors
  static const Color transparent = Colors.transparent;

  // Avatar Colors
  static Color aptitudeCardColor = Colors.blue.shade50;
  static Color aptitudeBorderColor = Colors.blue.shade200;
  static Color aptitudeTitleColor = Colors.blue.shade800;
  static Color categoryCardBorderColor = Colors.grey.shade300;
  static Color questionCardColor = Colors.grey.shade100;
  static Color correctAnswerBgColor = Colors.green.shade100;
  static Color correctAnswerTextColor = Colors.green.shade800;
  static Color wrongAnswerBgColor = Colors.red.shade100;
  static Color wrongAnswerTextColor = Colors.red.shade800;
  static Color correctAnswerLightBgColor = Colors.green.shade50;

  // Icon Colors
  static const Color iconColorPrimary = Colors.white;
  static const Color iconColorSecondary = primaryColor;

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

  static BoxShadow cardShadow = BoxShadow(
    color: const Color.fromRGBO(0, 0, 0, 0.05),
    offset: const Offset(0, 2),
    blurRadius: 4,
  );

  // Border Radius
  static const double largeBorderRadius = 40.0;
  static const double mediumBorderRadius = 25.0;
  static const double smallBorderRadius = 12.0;
  static const double extraSmallBorderRadius = 8.0;
  static const double miniRadius = 6.0;

  // Border Width
  static const double thinBorderWidth = 1.0;
  static const double mediumBorderWidth = 1.5;

  // Paddings
  static const double screenPadding = 25.0;
  static const double cardPadding = 30.0;
  static const double contentSpacing = 20.0;
  static const double largeSpacing = 40.0;
  static const double mediumSpacing = 16.0;
  static const double smallSpacing = 10.0;
  static const double extraSmallSpacing = 8.0;
  static const double miniSpacing = 5.0;
  static const double microSpacing = 4.0;
  static const double iconPadding = 8.0;
  static const double textFieldPadding = 16.0;
  static const double inputVerticalPadding = 12.0;

  // Sizes
  static const double navIconSize = 24.0;
  static const double largeIconSize = 30.0;
  static const double mediumIconSize = 24.0;
  static const double smallIconSize = 18.0;
  static const double extraSmallIconSize = 14.0;
  static const double avatarSizeLarge = 80.0;
  static const double avatarSizeMedium = 60.0;
  static const double avatarSizeSmall = 40.0;
  static const double categoryCardWidth = 120.0;
  static const double categoryCardHeight = 120.0;
  static const double optionCircleSize = 24.0;
  static const double buttonHeight = 50.0;
  static const double buttonHeightLarge = 55.0;
  static const double appBarBackButtonMargin = 40.0;
  static const double tabBarHeight = 120.0;

  // Text Sizes
  static const double textSizeLarge = 26.0;
  static const double textSizeMediumLarge = 24.0;
  static const double textSizeMedium = 20.0;
  static const double textSizeRegular = 16.0;
  static const double textSizeSmall = 15.0;
  static const double textSizeExtraSmall = 14.0;
  static const double textSizeMini = 13.0;
  static const double textSizeMicro = 12.0;
  static const double titleSize = 18.0;
  static const double subtitleSize = 15.0;

  // Text Styles
  static const TextStyle headerStyle = TextStyle(
    fontSize: textSizeLarge,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle subHeaderStyle = TextStyle(
    fontSize: textSizeRegular,
    color: textSecondaryColor,
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: titleSize,
    fontWeight: FontWeight.bold,
    color: white,
  );

  static const TextStyle sectionTitleStyle = TextStyle(
    fontSize: textSizeMediumLarge,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle sectionSubtitleStyle = TextStyle(
    fontSize: textSizeMini,
    color: textSecondaryColor,
  );

  static const TextStyle categoryTitleStyle = TextStyle(
    fontSize: subtitleSize,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle tabTitleStyle = TextStyle(
    fontSize: textSizeMini,
    fontWeight: FontWeight.w500,
    color: textPrimaryColor,
  );

  static const TextStyle errorStyle = TextStyle(
    fontSize: titleSize,
    fontWeight: FontWeight.bold,
    color: white,
  );

  static const TextStyle errorMessageStyle = TextStyle(
    color: white,
  );

  static const TextStyle appNameStyle = TextStyle(
    color: white,
    fontSize: textSizeMedium,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: textSizeRegular,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
    color: white,
  );

  static TextStyle inputLabelStyle = TextStyle(
    color: textSecondaryColor,
    fontSize: textSizeRegular,
  );

  static const TextStyle inputTextStyle = TextStyle(
    fontSize: textSizeRegular,
    color: textPrimaryColor,
  );

  static TextStyle smallTextStyle = TextStyle(
    color: textSecondaryColor,
    fontSize: textSizeExtraSmall,
  );

  static const TextStyle linkTextStyle = TextStyle(
    color: primaryColor,
    fontSize: textSizeExtraSmall,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle infoFieldLabelStyle = TextStyle(
    fontSize: textSizeExtraSmall,
    color: textSecondaryColor,
  );

  static const TextStyle infoFieldValueStyle = TextStyle(
    fontSize: textSizeRegular,
    color: textPrimaryColor,
  );

  static const TextStyle emptyStateStyle = TextStyle(
    color: textSecondaryColor,
  );

  static const TextStyle questionStyle = TextStyle(
    fontSize: textSizeSmall,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle questionCategoryStyle = TextStyle(
    fontSize: textSizeMicro,
    color: textSecondaryColor,
  );

  static const TextStyle optionLetterStyle = TextStyle(
    fontSize: textSizeExtraSmall,
    fontWeight: FontWeight.bold,
    color: textSecondaryColor,
  );

  static const TextStyle categoryScoreStyle = TextStyle(
    fontSize: textSizeSmall,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle categoryPercentStyle = TextStyle(
    fontSize: textSizeMini,
    color: textSecondaryColor,
  );

  static TextStyle aptitudeTitleStyle = TextStyle(
    fontSize: textSizeRegular,
    fontWeight: FontWeight.bold,
    color: aptitudeTitleColor,
  );

  static const TextStyle aptitudeLabelStyle = TextStyle(
    fontSize: textSizeMicro,
    color: textSecondaryColor,
  );

  static const TextStyle aptitudeValueStyle = TextStyle(
    fontSize: textSizeMini,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle educationDegreeStyle = TextStyle(
    fontSize: textSizeRegular,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle educationInstitutionStyle = TextStyle(
    fontSize: textSizeExtraSmall,
  );

  static const TextStyle educationDateStyle = TextStyle(
    fontSize: textSizeExtraSmall,
    color: textSecondaryColor,
  );

  static const TextStyle experienceItemStyle = TextStyle(
    fontSize: textSizeSmall,
    fontWeight: FontWeight.w500,
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
        size: mediumIconSize,
      ),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(smallBorderRadius),
        borderSide: BorderSide(
          color: Colors.grey[300]!,
          width: thinBorderWidth,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(smallBorderRadius),
        borderSide: const BorderSide(
          color: primaryColor,
          width: mediumBorderWidth,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: textFieldPadding,
        horizontal: textFieldPadding,
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
    minimumSize: const Size(double.infinity, buttonHeightLarge),
  );

  static ButtonStyle retryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: white,
    foregroundColor: primaryColor,
  );

  // Card Decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(mediumBorderRadius),
    boxShadow: [lightShadow],
  );

  static BoxDecoration educationCardDecoration = BoxDecoration(
    border: Border.all(color: categoryCardBorderColor),
    borderRadius: BorderRadius.circular(smallBorderRadius),
  );

  static BoxDecoration experienceCardDecoration = BoxDecoration(
    border: Border.all(color: categoryCardBorderColor),
    borderRadius: BorderRadius.circular(smallBorderRadius),
  );

  static BoxDecoration categoryCardDecoration = BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(extraSmallBorderRadius),
    border: Border.all(color: categoryCardBorderColor),
  );

  static BoxDecoration questionCardDecoration = BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(smallBorderRadius),
    border: Border.all(color: categoryCardBorderColor),
    boxShadow: [cardShadow],
  );

  // Button Decoration
  static BoxDecoration backButtonDecoration = const BoxDecoration(
    color: white30,
    shape: BoxShape.circle,
  );

  // App Icon Decoration
  static BoxDecoration appIconDecoration = BoxDecoration(
    color: white,
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

  // Profile Content Container
  static const BoxDecoration profileContentDecoration = BoxDecoration(
    color: white,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(largeBorderRadius),
      topRight: Radius.circular(largeBorderRadius),
    ),
  );

  // Aptitude Card Decoration
  static BoxDecoration aptitudeCardDecoration = BoxDecoration(
    color: aptitudeCardColor,
    borderRadius: BorderRadius.circular(smallBorderRadius),
    border: Border.all(color: aptitudeBorderColor),
  );

  // Info Field Decoration
  static BoxDecoration infoFieldDecoration = BoxDecoration(
    border: Border(
      bottom: BorderSide(
        color: categoryCardBorderColor,
        width: thinBorderWidth,
      ),
    ),
  );

  // Avatar with Photo Decoration
  static BoxDecoration avatarWithPhotoDecoration(String photoUrl) {
    return BoxDecoration(
      color: white,
      shape: BoxShape.circle,
      image: DecorationImage(
        image: NetworkImage(photoUrl),
        fit: BoxFit.cover,
      ),
    );
  }

  // Avatar without Photo Decoration
  static const BoxDecoration avatarWithoutPhotoDecoration = BoxDecoration(
    color: white,
    shape: BoxShape.circle,
  );

  // Option Circle Decoration
  static BoxDecoration optionCircleDecoration(bool isSelected, Color borderColor) {
    return BoxDecoration(
      color: white,
      shape: BoxShape.circle,
      border: Border.all(
        color: borderColor,
      ),
    );
  }
}