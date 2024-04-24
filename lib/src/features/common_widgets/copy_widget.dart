import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:e2_explorer/src/utils/asset_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CopyTextWidget extends StatelessWidget {
  const CopyTextWidget({
    super.key,
    required this.text,
    this.allowCopy = true,
  });
  final String text;
  final bool allowCopy;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (allowCopy) {
          Clipboard.setData(ClipboardData(text: text)).then((value) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Copied to Clipboard")),
            );
          });
        }
      },
      child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.copy_outlined,
              color: AppColors.sideNavSelectedTileIndicatorColor,
            ),
            const SizedBox(width: 7),
            Text(
              "Copy",
              style: TextStyles.bodyStrong(),
            )
          ]),
    );
  }
}

class ShowHideWidget extends StatelessWidget {
  const ShowHideWidget({
    super.key,
    required this.isVisible,
    required this.onToggle,
  });
  final bool isVisible;
  final Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onToggle(!isVisible);
      },
      child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AssetUtils.getSvgIconPath(
                isVisible ? "eye-off" : "eye",
              ),
              color: AppColors.sideNavSelectedTileIndicatorColor,
              height: 20,
              fit: BoxFit.fill,
            ),
            const SizedBox(width: 7),
            Text(
              isVisible ? "Hide" : "Show",
              style: TextStyles.bodyStrong(),
            )
          ]),
    );
  }
}
