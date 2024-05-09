import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import '../../../utils/dimens.dart';
import 'app_button_primary.dart';

class AppButtonSecondary extends StatefulWidget {
  const AppButtonSecondary({
    super.key,
    required this.text,
    this.svgIconPath,
    this.pngIconPath,
    this.icon,
    this.onPressed,
    this.padding,
    this.appButtonStatus = AppButtonStatus.normal,
    this.iconColor,
    this.iconHeight,
    this.iconWidth,
    this.height = 36,
    this.minWidth,
    this.borderColor,
    this.loading = false,
    this.tootlTipText,
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
  final Color? borderColor;
  final bool loading;
  final String? tootlTipText;

  @override
  State<AppButtonSecondary> createState() => _AppButtonSecondaryState();
}

class _AppButtonSecondaryState extends State<AppButtonSecondary> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    if (widget.tootlTipText != null) {
      return JustTheTooltip(
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.tootlTipText!),
          ),
          child: buildButton());
    } else {
      return buildButton();
    }
  }

  Container buildButton() {
    return Container(
      height: widget.height,
      constraints: BoxConstraints(
        minHeight: widget.height,
        minWidth: widget.minWidth ?? 0,
      ),
      child: iconWidget != null
          ? ElevatedButton.icon(
              onHover: (bool hoveredState) {
                setState(() {
                  hovered = hoveredState;
                });
              },
              style: buttonStyle,
              onPressed: widget.appButtonStatus == AppButtonStatus.disabled
                  ? null
                  : widget.loading
                      ? () {}
                      : widget.onPressed ?? () {},
              icon: iconWidget!,
              label: textWidget,
            )
          : ElevatedButton(
              style: buttonStyle,
              onPressed: widget.loading ? () {} : widget.onPressed ?? () {},
              child: textWidget,
            ),
    );
  }

  Widget get textWidget => Stack(
        alignment: Alignment.center,
        children: [
          Text(
            widget.text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.loading ? Colors.transparent : textColor,
            ),
          ),
          if (widget.loading) ...[
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
        disabledBackgroundColor: AppColors.buttonSecondaryDisabledBgColor,
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            Dimens.btnSecondaryBorderRadius,
          ),
          side: BorderSide(
              color: widget.appButtonStatus == AppButtonStatus.disabled
                  ? Colors.transparent
                  : widget.borderColor ?? AppColors.buttonSecondaryBorderColor),
        ),
      );

  Color get bgColor {
    switch (widget.appButtonStatus) {
      case AppButtonStatus.selected:
        return AppColors.buttonSecondaryBgColor;

      case AppButtonStatus.disabled:
        return AppColors.buttonSecondaryDisabledBgColor;

      case AppButtonStatus.normal:
        return AppColors.buttonSecondaryBgColor;

      default:
        return AppColors.buttonSecondaryBgColor;
    }
  }

  Color get textColor {
    switch (widget.appButtonStatus) {
      default:
        return AppColors.buttonSecondaryTextColor;
    }
  }

  Widget? get iconWidget {
    if (widget.icon != null) {
      return widget.icon;
    } else if (widget.svgIconPath != null) {
      return SvgPicture.asset(
        widget.svgIconPath!,
        color: widget.iconColor ?? AppColors.buttonSecondaryIconColor,
        height: widget.iconHeight,
        width: widget.iconWidth,
      );
    } else if (widget.pngIconPath != null) {
      return Image.asset(
        widget.pngIconPath!,
        color: widget.iconColor ?? AppColors.buttonSecondaryIconColor,
        height: widget.iconHeight,
        width: widget.iconWidth,
      );
    }
    return null;
  }
}
