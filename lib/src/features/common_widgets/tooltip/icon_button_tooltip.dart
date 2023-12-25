import 'package:e2_explorer/src/features/common_widgets/tooltip/simple_tooltip.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class IconButtonWithTooltip extends StatefulWidget {
  const IconButtonWithTooltip({
    super.key,
    required this.onTap,
    required this.icon,
    required this.tooltipMessage,
    this.foregroundColor = const Color(0xffBDBDBD),
    this.foregroundColorHover = Colors.white,
    this.iconSize,
  });

  final void Function()? onTap;
  final IconData icon;
  final String tooltipMessage;
  final Color foregroundColor;
  final Color foregroundColorHover;
  final double? iconSize;

  @override
  State<StatefulWidget> createState() => _IconButtonWithTooltipState();
}

class _IconButtonWithTooltipState extends State<IconButtonWithTooltip>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Color?> animation;

  bool isHover = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    animation = ColorTween(
      begin: widget.foregroundColor,
      end: widget.foregroundColorHover,
    ).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (PointerEnterEvent event) => controller.forward(),
      onExit: (PointerExitEvent event) => controller.reverse(),
      child: InkWell(
        onTap: widget.onTap,
        child: SimpleTooltip(
          message: widget.tooltipMessage,
          child: Icon(
            widget.icon,
            size: widget.iconSize,
            color: animation.value,
          ),
        ),
      ),
    );
  }
}
