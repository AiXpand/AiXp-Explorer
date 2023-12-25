import 'package:e2_explorer/src/features/common_widgets/shape_utils.dart';
import 'package:e2_explorer/src/features/common_widgets/tree_list/widgets/tree_clickable_wrapper.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:carbon_icons/carbon_icons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TreeChildElement extends StatefulWidget {
  const TreeChildElement({
    super.key,
    this.height = 48,
    required this.text,
    // required this.plugin,
    required this.onTap,
    // this.onPluginDelete,
    this.isSelected = false,
    // this.isCategorySelected = false,
    this.isLast = false,
  });

  final String text;
  final double height;

  // final PluginReference plugin;
  final VoidCallback onTap;

  // final void Function(String)? onPluginDelete;
  final bool isSelected;

  // final bool isCategorySelected;
  final bool isLast;

  @override
  State<StatefulWidget> createState() => _SubTreeElementState();
}

class _SubTreeElementState extends State<TreeChildElement> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (PointerHoverEvent event) {
        setState(() => isHovered = true);
      },
      onExit: (PointerExitEvent event) {
        setState(() => isHovered = false);
      },
      child: TreeClickableWrapper(
        shapeCorners: widget.isSelected
            ? ShapeUtilsCorners.all
            : widget.isLast
                ? ShapeUtilsCorners.bottom
                : ShapeUtilsCorners.none,
        isSelected: widget.isSelected,
        isParent: false,
        onTap: () {
          widget.onTap.call();
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  CarbonIcons.container_software,
                  color: widget.isSelected
                      ? ColorStyles.light100
                      : ColorStyles.lightGrey,
                  size: 20,
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final TextStyle style = GoogleFonts.inter(
                        color: widget.isSelected
                            ? ColorStyles.light100
                            : ColorStyles.lightGrey,
                        fontSize: 14);
                    final TextPainter textPainter = TextPainter(
                      text: TextSpan(text: widget.text, style: style),
                      maxLines: 1,
                      textDirection: TextDirection.ltr,
                    )..layout(maxWidth: constraints.maxWidth);
                    final bool hasOverflow = textPainter.didExceedMaxLines;
                    if (!hasOverflow) {
                      return Text(
                        widget.text,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: widget.isSelected
                              ? ColorStyles.light100
                              : ColorStyles.lightGrey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      );
                    } else {
                      return Tooltip(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 1, vertical: 1),
                        textStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          color: const Color(0xffBDBDBD),
                          fontSize: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xff1F1F1F),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4)),
                          border: Border.all(
                            color: const Color(0xffBDBDBD),
                          ),
                        ),
                        message: widget.text,
                        child: Text(
                          widget.text,
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.isSelected
                                ? ColorStyles.light100
                                : ColorStyles.lightGrey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }
                  },
                ),
              ),
              // if (isHovered)
              //   DeleteElement(
              //     onTap: () {
              //       if (widget.onPluginDelete != null) {
              //         widget.onPluginDelete!.call(widget.plugin.uuid);
              //       }
              //     },
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
