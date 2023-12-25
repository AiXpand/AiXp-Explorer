import 'package:e2_explorer/src/features/common_widgets/clickable_style_helper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'shape_utils.dart';

class ClickableContainer extends StatefulWidget {
  const ClickableContainer({
    super.key,
    this.height,
    this.width,
    this.onTap,
    this.onHover,
    this.child,
    this.childBuilder,
    this.shapeCorners = ShapeUtilsCorners.none,
    this.shapeBorder = ShapeUtilsBorder.all,
    required this.style,
    this.borderRadius = 2.0,
  });

  final double? height;
  final double? width;
  final void Function()? onTap;
  final void Function(bool isHovered)? onHover;
  final Widget? child;
  final Widget Function(bool isHovered)? childBuilder;
  final ShapeUtilsCorners shapeCorners;
  final ShapeUtilsBorder shapeBorder;
  final ClickableStyleHelper style;
  final double borderRadius;

  @override
  State<StatefulWidget> createState() => _ClickableContainerState();
}

class _ClickableContainerState extends State<ClickableContainer> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    final Widget child = AnimatedContainer(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: isHover ? widget.style.hoverColor : widget.style.defaultColor,
        border: widget.style.hasBorder
            ? ShapeUtils.getBorder(
                widget.shapeBorder,
                isHover && widget.style.hoverBorderColor != null
                    ? widget.style.hoverBorderColor!
                    : widget.style.defaultBorderColor!,
              )
            : null,
        borderRadius: widget.shapeCorners != ShapeUtilsCorners.none
            ? ShapeUtils.getBorderRadius(
                widget.shapeCorners, widget.borderRadius)
            : null,
      ),
      duration: const Duration(milliseconds: 100),
      child: widget.childBuilder != null
          ? widget.childBuilder!.call(isHover)
          : widget.child,
    );

    if (widget.onTap != null) {
      return InkWell(
        onTap: widget.onTap,
        onHover: (bool isHover) {
          setState(() {
            this.isHover = isHover;
          });
          widget.onHover?.call(isHover);
        },
        child: child,
      );
    } else {
      return MouseRegion(
        onEnter: (PointerEnterEvent event) {
          setState(() {
            isHover = true;
          });
          widget.onHover?.call(isHover);
        },
        onExit: (PointerExitEvent event) {
          setState(() {
            isHover = false;
          });
          widget.onHover?.call(isHover);
        },
        child: child,
      );
    }
  }
}
