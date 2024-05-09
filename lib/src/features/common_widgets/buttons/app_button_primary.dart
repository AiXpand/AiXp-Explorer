import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../utils/dimens.dart';

enum AppButtonStatus { normal, selected, disabled }

class AppButtonPrimary extends StatelessWidget {
  const AppButtonPrimary({
    super.key,
    required this.text,
    this.svgIconPath,
    this.pngIconPath,
    this.icon,
    this.onPressed,
    this.padding,
    this.appButtonStatus = AppButtonStatus.normal,
    this.iconColor,
    this.iconHeight = 18,
    this.iconWidth,
    this.height = 40,
    this.minWidth,
    this.loading = false,
    this.isEnabled = true,
  });

  final String text;
  final String? svgIconPath;
  final String? pngIconPath;
  final Widget? icon;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final AppButtonStatus appButtonStatus;
  final double? iconHeight;
  final double? iconWidth;
  final Color? iconColor;
  final double height;
  final double? minWidth;
  final bool loading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: appButtonStatus == AppButtonStatus.disabled
          ? SystemMouseCursors.zoomIn
          : SystemMouseCursors.click,
      child: Container(
        height: height,
        constraints: BoxConstraints(
          minHeight: height,
          minWidth: minWidth ?? 0,
        ),
        child: iconWidget != null
            ? ElevatedButton.icon(
                style: buttonStyle,
                onPressed: appButtonStatus == AppButtonStatus.disabled
                    ? null
                    : (loading ? () {} : onPressed ?? () {}),
                icon: iconWidget!,
                label: textWidget,
              )
            : ElevatedButton(
                style: buttonStyle,
                onPressed: appButtonStatus == AppButtonStatus.disabled
                    ? null
                    : (loading ? () {} : onPressed ?? () {}),
                child: textWidget,
              ),
      ),
    );
  }

  Widget get textWidget => Stack(
        alignment: Alignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: loading ? Colors.transparent : textColor,
            ),
          ),
          if (loading) ...[
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ],
        ],
      );

  ButtonStyle get buttonStyle => ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            Dimens.btnPrimaryBorderRadius,
          ),
        ),
      );

  Color get bgColor {
    switch (appButtonStatus) {
      case AppButtonStatus.selected:
        return AppColors.buttonPrimaryBgColor;

      case AppButtonStatus.disabled:
        return AppColors.buttonPrimaryBgColor;

      default:
        return AppColors.buttonPrimaryBgColor;
    }
  }

  Color get textColor {
    switch (appButtonStatus) {
      case AppButtonStatus.selected:
        return AppColors.buttonPrimaryTextColor;

      case AppButtonStatus.disabled:
        return AppColors.buttonPrimaryTextColor;

      default:
        return AppColors.buttonPrimaryTextColor;
    }
  }

  Widget? get iconWidget {
    if (icon != null) {
      return icon;
    } else if (svgIconPath != null) {
      return SvgPicture.asset(
        svgIconPath!,
        color: iconColor ?? AppColors.buttonPrimaryIconColor,
        height: iconHeight,
        width: iconWidth,
      );
    } else if (pngIconPath != null) {
      return Image.asset(
        pngIconPath!,
        color: iconColor ?? AppColors.buttonPrimaryIconColor,
        height: iconHeight,
        width: iconWidth,
      );
    }
    return null;
  }
}
