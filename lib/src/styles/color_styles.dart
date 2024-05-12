import 'package:flutter/material.dart';

class AppColors {
  /// Todo: load proper colors based on theme after implementing light theme colors
  static void initialize() => _loadDarkTheme();
  static late Color scaffoldBackgroundColor;
  static late Color containerBgColor;

  // Text colors
  static late Color textPrimaryColor;
  static late Color textSecondaryColor;
  static late Color textTertiaryColor;

  // Side nav colors
  static late Color sideNavBgColor;
  static late Color sideNavUnselectedTileBgColor;
  static late Color sideNavSelectedTileBgColor;
  static late Color sideNavSelectedTileIndicatorColor;
  static late Color sideNavTileHoverBgColor;
  static late Color sideNavUnselectedTileTextColor;
  static late Color sideNavSelectedTileTextColor;
  static late Color sideNavUnselectedTileIconColor;
  static late Color sideNavSelectedTileIconColor;
  static late Color sideNavDividerColor;

  // Input fields
  static late Color dropdownFieldFillColor;
  static late Color dropdownFieldIconColor;
  static late Color inputFieldFillColor;
  static late Color inputFieldHintTextColor;
  static late Color inputFieldSuffixButtonBgColor;
  static late Color inputFieldSuffixButtonTextColor;
  static late Color inputFieldUnfocusedBorderColor;
  static late Color inputFieldFocusedBorderColor;
  static late Color inputFieldErrorBorderColor;
  static late Color inputFieldErrorTextColor;

  // checkbox colors
  static late Color checkboxUncheckedFillColor;
  static late Color checkboxCheckedFillColor;
  static late Color checkboxCheckColor;

  // Button colors
  static late Color buttonPrimaryBgColor;
  static late Color softButtonPrimaryBgColor;
  static late Color buttonPrimaryTextColor;
  static late Color buttonPrimaryIconColor;
  static late Color buttonPrimaryBorderColor;
  static late Color buttonSecondaryBgColor;
  static late Color buttonSecondaryTextColor;
  static late Color buttonSecondaryIconColor;
  static late Color buttonSecondaryBorderColor;
  static late Color buttonSecondaryDisabledBgColor;

  // Dialog colors
  static late Color alertDialogBgColor;
  static late Color alertDialogDividerColor;

  // Scroll bar colors
  static late Color scrollbarTrackColor;
  static late Color scrollbarThumbColor;

  // Wallet info container
  static late Color walletInfoContainerBgColor;
  static late Color walletInfoContainerDividerColor;

  // Table colors
  static late Color tableHeaderBgColor;
  static late Color tableHeaderTextColor;
  static late Color tableHeaderInactiveIconColor;
  static late Color tableHeaderActiveIconColor;
  static late Color tableBodyTextColor;
  static late Color tableRowOddIndexBgColor;
  static late Color tableRowEvenIndexBgColor;
  static late Color tableStatusSuccessBtnBgColor;
  static late Color tableStatusSuccessBtnTextColor;
  static late Color tableStatusErrorBtnBgColor;
  static late Color tableStatusErrorBtnTextColor;
  static late Color tableStatusWarningBtnBgColor;
  static late Color tableStatusWarningBtnTextColor;
  static late Color tableBorderColor;
  static late Color tableHeaderSortIconInactiveColor;
  static late Color tableHeaderSortIconActiveColor;

  /// Line chart colors
  static late Color lineChartGreenBorderColor;
  static late Color lineChartMagentaBorderColor;
  static late Color lineChartPinkBorderColor;
  static late Color lineChartBlueBorderColor;

  /// Gradients
  static late LinearGradient tabBarIndicatorGradient;
  static late LinearGradient lineChartGreenGradient;
  static late LinearGradient lineChartMagentaGradient;
  static late LinearGradient lineChartPinkGradient;
  static late LinearGradient lineChartBlueGradient;

  /// Loads the colors for dark theme
  static void _loadDarkTheme() {
    scaffoldBackgroundColor = const Color(0xFF0A0930);
    containerBgColor = const Color(0xFF1E1D47);

    // Text colors
    textPrimaryColor = const Color(0xFFFFFFFF);
    textSecondaryColor = const Color(0xFF92A3D6);
    textTertiaryColor = const Color(0xFF8A8FB5);

    // Side nav colors
    sideNavBgColor = const Color(0xFF1E1D47);
    sideNavUnselectedTileBgColor = Colors.transparent;
    sideNavSelectedTileBgColor = const Color(0xFF2E2C6A);
    sideNavSelectedTileIndicatorColor = const Color(0xFF4E4BDE);
    sideNavTileHoverBgColor = Colors.transparent;
    sideNavUnselectedTileTextColor = const Color(0xFFDFDFDF);
    sideNavSelectedTileTextColor = const Color(0xFFF0F1F5);
    sideNavUnselectedTileIconColor = const Color(0xFFDFDFDF);
    sideNavSelectedTileIconColor = const Color(0xFFF0F1F5);
    sideNavDividerColor = const Color(0xFF0C0B2F);

    // Input fields
    dropdownFieldFillColor = const Color(0xFF282760);
    dropdownFieldIconColor = const Color(0xFFFFFFFF);
    inputFieldFillColor = const Color(0xFF282760);
    inputFieldHintTextColor = const Color(0xFF92A3D6);
    inputFieldSuffixButtonBgColor = const Color(0xFF1B1A49);
    inputFieldSuffixButtonTextColor = const Color(0xFFFFFFFF);
    inputFieldUnfocusedBorderColor = Colors.transparent;
    inputFieldFocusedBorderColor = const Color(0xFF4E4BDE);
    inputFieldErrorBorderColor = const Color(0xFFFF384E);
    inputFieldErrorTextColor = const Color(0xFFFF384E);

    // checkbox colors
    checkboxUncheckedFillColor = const Color(0xFFFFFFFF);
    checkboxCheckedFillColor = const Color(0xFF4E4BDE);
    checkboxCheckColor = const Color(0xFFFFFFFF);

    // Button colors
    buttonPrimaryBgColor = const Color(0xFF4E4BDE);
    softButtonPrimaryBgColor = const Color(0xff9392D0).withOpacity(0.5);
    buttonPrimaryTextColor = const Color(0xFFFFFFFF);
    buttonPrimaryIconColor = const Color(0xFFFFFFFF);
    buttonPrimaryBorderColor = buttonPrimaryBgColor;
    buttonSecondaryBgColor = const Color(0xFF2E2C6A);
    buttonSecondaryTextColor = const Color(0xFFFFFFFF);
    buttonSecondaryIconColor = const Color(0xFFFFFFFF);
    buttonSecondaryBorderColor = const Color(0xFF5553DA);
    buttonSecondaryDisabledBgColor = const Color(0xFF9392D0).withOpacity(0.5);

    // Dialog colors
    alertDialogBgColor = const Color(0xFF1E1D47);
    alertDialogDividerColor = const Color(0xFF0C0B2F);

    // Scroll bar colors
    scrollbarTrackColor = const Color(0xFF535561);
    scrollbarThumbColor = const Color(0xFFFFFFFF);

    // Wallet info container
    walletInfoContainerBgColor = const Color(0xFF0C0B2F);
    walletInfoContainerDividerColor = const Color(0xFF2C2E40);

    // Table colors
    tableHeaderBgColor = const Color(0xFF11113A);
    tableHeaderTextColor = const Color(0xFFF0F1F5);
    tableHeaderInactiveIconColor = const Color(0xFFBEC0C9);
    tableHeaderActiveIconColor = const Color(0xFFFFFFFF);
    tableBodyTextColor = const Color(0xFFFFFFFF);
    tableRowOddIndexBgColor = const Color(0xFF1E1D47);
    tableRowEvenIndexBgColor = const Color(0xFF171744);
    tableStatusSuccessBtnBgColor = const Color(0xFF0BE27B).withOpacity(0.2);
    tableStatusSuccessBtnTextColor = const Color(0xFF0BE27B);
    tableStatusErrorBtnBgColor = const Color(0xFFF65F70).withOpacity(0.2);
    tableStatusErrorBtnTextColor = const Color(0xFFF65F70);
    tableStatusWarningBtnBgColor = const Color(0xFFFFD600).withOpacity(0.2);
    tableStatusWarningBtnTextColor = const Color(0xFFFFD600);
    tableBorderColor = const Color(0xFF0C0B2F);
    tableHeaderSortIconInactiveColor = const Color(0xFF8A8FB5);
    tableHeaderSortIconActiveColor = const Color(0xFFFFFFFF);

    /// Line chart colors
    lineChartGreenBorderColor = const Color(0xFF0BE27B);
    lineChartMagentaBorderColor = const Color(0xFF9B29AF);
    lineChartPinkBorderColor = const Color(0xFFE61E62);
    lineChartBlueBorderColor = const Color(0xFF2E2BBA);

    /// Gradients
    tabBarIndicatorGradient = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: [0, 0.45, 0.83],
      colors: [
        Color(0xFFC92063),
        Color(0xFFA63CC8),
        Color(0xFF4E4BDE),
      ],
    );
    lineChartGreenGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        lineChartGreenBorderColor,
        const Color(0xFF1E1D47).withOpacity(0),
      ],
    );
    lineChartMagentaGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        lineChartMagentaBorderColor,
        const Color(0xFF9A29AE).withOpacity(0),
      ],
    );
    lineChartPinkGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        lineChartPinkBorderColor,
        const Color(0xFFEA1E63).withOpacity(0),
      ],
    );
    lineChartBlueGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        lineChartBlueBorderColor,
        const Color(0xFF1E1D47).withOpacity(0),
      ],
    );
  }
}

class ColorStyles {
  ColorStyles._();

  static const Color dark800 = Color(0xff1F1F1F);
  static const Color dark700 = Color(0xff282828);

  static const Color dark950 = Color(0xff0D0D0D);
  static const Color dark900 = Color(0xff161616);
  static const Color dark850 = Color(0xff181818);
  static const Color dark750 = Color(0xff262626);
  static const Color dark650 = Color(0xff2D2D2D);
  static const Color dark630 = Color(0xff424242);
  static const Color dark600 = Color(0xff454545);
  static const Color grey = Color(0xff5E5E5E);
  static const Color darkGrey = Color(0xff575757);
  static const Color disabledGrey = Color(0xff4F4F4F);
  static const Color spaceGrey = Color(0xff2D2D2D);
  static const Color lightGrey = Color(0xffBDBDBD);
  static const Color light100 = Color(0xffF7F7F7);
  static const Color light200 = Color(0xffB3B3B3);
  static const Color light900 = Color(0xff8A8A8A);
  static const Color red = Color(0xffF24646);
  static const Color warningRed = Color(0xffDF1E1E);
  static const Color green = Color(0xff46F26C);
  static const Color viridianGreen = Color(0xff417B5A);
  static const Color seaGreen = Color(0xff008148);
  static const Color magenta = Color(0xffF246B8);
  static const Color darkGold = Color(0xffB5860D);
  static const Color blue = Color(0xff466CF2);
  static const Color yellow = Color(0xffF2C246);
  static const Color purple = Color(0xff3F1179);
  static const Color lightBlue = Color(0xff6C8FF3);

  static const Color darkButtonHover = Color(0xff262626);
  static const Color greyButtonHover = Color(0xff383838);
  static const Color selectedButtonBlue = Color(0xff2A3A6F);
  static const Color selectedTabBlue = Color(0xff0073E6);
  static const Color selectedButtonBorder = Color(0xff466CF2);
  static const Color selectedHoverButtonBlue = Color(0xff344A9B);
  static const Color hoverBlue = Color(0xff193047);
  static const Color darkBlue = Color(0xff1c2733);

  // start of new color
  static const Color primaryColor = Color(0xff0A0930);
  static const Color secondaryColor = Color(0xff1E1D47);
  static const Color softBlueColor = Color(0xff9392D0);
}
