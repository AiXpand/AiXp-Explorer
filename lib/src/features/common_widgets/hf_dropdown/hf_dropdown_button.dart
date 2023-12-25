import 'package:carbon_icons/carbon_icons.dart';
import 'package:e2_explorer/src/features/common_widgets/clickable_container.dart';
import 'package:e2_explorer/src/features/common_widgets/clickable_style_helper.dart';
import 'package:e2_explorer/src/features/common_widgets/shape_utils.dart';
import 'package:e2_explorer/src/features/common_widgets/tooltip/icon_button_tooltip.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:flutter/material.dart';

class HFDropdownButton extends StatefulWidget {
  const HFDropdownButton({
    super.key,
    this.height = 40,
    this.width,
    this.displayValue = '',
    this.onTap,
    this.isExpanded = false,
  });

  final double? height;
  final double? width;
  final String displayValue;
  final VoidCallback? onTap;
  final bool isExpanded;

  @override
  State<StatefulWidget> createState() => _HFDropdownButtonState();
}

class _HFDropdownButtonState extends State<HFDropdownButton> {
  final ClickableStyleHelper _collapsedStyle = const ClickableStyleHelper(
    defaultColor: Color(0xff2b2b2b),
    hoverColor: Color(0xff262626),
    defaultBorderColor: Color(0xff454545),
    hoverBorderColor: Color(0xff8a8a8a),
  );

  final ClickableStyleHelper _expandedStyle = const ClickableStyleHelper(
    defaultColor: Color(0xff212020),
    hoverColor: Color(0xff3b3b3b),
    defaultBorderColor: ColorStyles.blue,
    hoverBorderColor: ColorStyles.blue,
  );

  final Color _hoveredColor = const Color(0xff8a8a8a);
  final Color _defaultColor = const Color(0xff454545);

  bool isHovered = false;
  // bool isExpanded = false;

  void _onDropdownTap() {
    // setState(() {
    //   isExpanded = !isExpanded;
    // });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final IconData rightIcon =
        widget.isExpanded ? CarbonIcons.chevron_up : CarbonIcons.chevron_down;

    return ClickableContainer(
      // width: double.infinity,
      onTap: _onDropdownTap,
      height: widget.height,
      width: widget.width,
      style: widget.isExpanded ? _expandedStyle : _collapsedStyle,
      onHover: (bool isHovered) {
        setState(() {
          this.isHovered = isHovered;
        });
      },
      shapeCorners: ShapeUtilsCorners.all,
      borderRadius: 8,
      childBuilder: (bool isHover) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: <Widget>[
              Text(
                widget.displayValue,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.small(
                  color: isHover ? const Color(0xffbdbdbd) : _hoveredColor,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: !isHover
                    ? Icon(
                        rightIcon,
                        color: _defaultColor,
                      )
                    : IconButtonWithTooltip(
                        onTap: _onDropdownTap,
                        icon: rightIcon,
                        tooltipMessage:
                            widget.isExpanded ? 'Hide options' : 'Show options',
                        foregroundColor: _hoveredColor,
                        foregroundColorHover: const Color(0xffbdbdbd),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
