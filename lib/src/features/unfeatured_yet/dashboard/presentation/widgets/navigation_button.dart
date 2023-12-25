import 'package:e2_explorer/src/features/common_widgets/clickable_container.dart';
import 'package:e2_explorer/src/features/common_widgets/clickable_style_helper.dart';
import 'package:e2_explorer/src/features/common_widgets/shape_utils.dart';
import 'package:e2_explorer/src/features/common_widgets/tooltip/simple_tooltip.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:flutter/material.dart';

/// A widget that creates each button in the navigation menu, based on a Navigation item
/// and a isSelected property
/// The selection is going to be made by comparing the selected index to the Navigation Item index
class NavigationButton extends StatelessWidget {
  const NavigationButton({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  /// The displayed text inside the button -> TBD
  final String title;

  /// Whether the functionality is selected or not
  final bool isSelected;

  /// Callback onTap event
  final VoidCallback onTap;

  /// Optional icon instead of title. If icon is present, we will also have a tooltip with the title.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    bool expandedMode = false;
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 60) {
          expandedMode = true;
        }
        return ClickableContainer(
          onTap: onTap,
          shapeCorners: ShapeUtilsCorners.all,
          borderRadius: 8,
          style: ClickableStyleHelper(
            defaultColor: isSelected
                ? ColorStyles.selectedButtonBlue
                : ColorStyles.spaceGrey,
            hoverColor: isSelected
                ? ColorStyles.selectedHoverButtonBlue
                : ColorStyles.dark630,
          ),
          childBuilder: (isHovered) {
            /// ToDO: Treat this case separately
            if (icon == null) {
              return Center(
                child: Text(
                  title,
                  style: TextStyles.small14(),
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              if (expandedMode) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: isHovered
                            ? ColorStyles.light100
                            : ColorStyles.light200,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        title,
                        style: TextStyles.small14(
                          color: isHovered
                              ? ColorStyles.light100
                              : ColorStyles.light200,
                        ),
                        // overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              } else {
                return Center(
                  child: SimpleTooltip(
                    message: title,
                    child: Icon(
                      icon,
                      color: isHovered
                          ? ColorStyles.light100
                          : ColorStyles.light200,
                    ),
                  ),
                );
              }
            }
          },
        );
      }),
    );
  }
}
