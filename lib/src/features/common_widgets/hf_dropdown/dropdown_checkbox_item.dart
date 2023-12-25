import 'package:carbon_icons/carbon_icons.dart';
import 'package:e2_explorer/src/features/common_widgets/clickable_container.dart';
import 'package:e2_explorer/src/features/common_widgets/clickable_style_helper.dart';
import 'package:e2_explorer/src/features/common_widgets/shape_utils.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:flutter/material.dart';

class DropdownCheckboxItem extends StatelessWidget {
  const DropdownCheckboxItem({
    super.key,
    this.height = 40,
    this.checked = false,
    required this.displayValue,
    this.onTap,
  });

  final double height;
  final bool checked;
  final String displayValue;
  final ValueChanged<bool>? onTap;

  @override
  Widget build(BuildContext context) {
    return ClickableContainer(
      onTap: () {
        onTap?.call(!checked);
      },
      style: !checked
          ? const ClickableStyleHelper(
              defaultColor: Color(0xff2b2b2b),
              hoverColor: Color(0xff262626),
            )
          : const ClickableStyleHelper(
              defaultColor: Color(0xff262626),
              hoverColor: Color(0xff363636),
            ),
      height: height,
      shapeBorder: ShapeUtilsBorder.none,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        child: Row(
          children: <Widget>[
            Icon(
              checked
                  ? CarbonIcons.checkbox_checked_filled
                  : CarbonIcons.checkbox,
              color: checked ? ColorStyles.blue : ColorStyles.lightGrey,
            ),
            const SizedBox(
              width: 4,
            ),
            Flexible(
              child: Text(
                displayValue,
                style: const TextStyle(color: ColorStyles.lightGrey),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
