import 'package:e2_explorer/src/features/common_widgets/clickable_container.dart';
import 'package:e2_explorer/src/features/common_widgets/clickable_style_helper.dart';
import 'package:e2_explorer/src/features/common_widgets/shape_utils.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:flutter/material.dart';

class DropdownLabelItem extends StatelessWidget {
  const DropdownLabelItem({
    super.key,
    required this.label,
    this.onAdd,
    this.height = 40,
  }) : _canAddElement = onAdd != null;

  final String label;
  final VoidCallback? onAdd;
  final bool _canAddElement;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              label,
              style: const TextStyle(color: ColorStyles.lightGrey),
              overflow: TextOverflow.ellipsis,
            ),
            if (_canAddElement)
              ClickableContainer(
                onTap: onAdd,
                style: const ClickableStyleHelper(
                  defaultColor: Color(0xff2b2b2b),
                  hoverColor: ColorStyles.blue,
                  defaultBorderColor: Color(0xff828282),
                  hoverBorderColor: ColorStyles.selectedHoverButtonBlue,
                ),
                height: 24,
                width: 24,
                borderRadius: 4,
                shapeCorners: ShapeUtilsCorners.all,
                childBuilder: (bool isHovered) {
                  return Icon(
                    Icons.add,
                    color: isHovered
                        ? ColorStyles.light100
                        : const Color(0xff828282),
                    size: 16,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
