import 'package:e2_explorer/src/features/common_widgets/shape_utils.dart';
import 'package:e2_explorer/src/features/common_widgets/tree_list/widgets/tree_clickable_wrapper.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:carbon_icons/carbon_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TreeParentElement extends StatefulWidget {
  const TreeParentElement({
    super.key,
    this.height = 48,
    required this.text,
    this.children = const <Widget>[],
    this.onTap,
    this.isSelected = false,
    this.isChildSelected = false,
    this.rightAlignedText,
  });

  final double height;
  final String text;
  final List<Widget> children;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isChildSelected;
  final String? rightAlignedText;

  @override
  State<StatefulWidget> createState() => _TreeParentElementState();
}

class _TreeParentElementState extends State<TreeParentElement> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // final bool isCategorySelected = widget.plugins.any((PluginReference element) {
    //   return element.uuid == widget.selectedPluginUuid;
    // });
    // print(widget.children);

    return Column(
      children: <Widget>[
        TreeClickableWrapper(
          ///TODO Change this to be able to define a style for the parent
          isParent: widget.isChildSelected,
          isSelected: widget.isSelected,
          // isCategorySelected: isCategorySelected,
          shapeCorners:
              isExpanded ? ShapeUtilsCorners.top : ShapeUtilsCorners.all,
          height: widget.height,
          onTap: () {
            widget.onTap?.call();
            if (widget.isSelected) {
              setState(() {
                if (widget.children.isNotEmpty) {
                  isExpanded = !isExpanded;
                }
              });
            }
          },
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8),
                child: isExpanded
                    ? InkWell(
                        onTap: () {
                          setState(() {
                            if (widget.children.isNotEmpty) {
                              isExpanded = !isExpanded;
                            }
                          });
                        },
                        child: const Icon(
                          CarbonIcons.chevron_down,
                          color: ColorStyles.lightGrey,
                          size: 16,
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          setState(() {
                            if (widget.children.isNotEmpty) {
                              isExpanded = !isExpanded;
                            }
                          });
                        },
                        child: const Icon(
                          CarbonIcons.chevron_right,
                          color: ColorStyles.lightGrey,
                          size: 16,
                        ),
                      ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(
                  CarbonIcons.model_builder,
                  color: ColorStyles.lightGrey,
                  size: 20,
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    const TextStyle style =
                        TextStyle(color: ColorStyles.lightGrey, fontSize: 14);
                    final TextPainter textPainter = TextPainter(
                      text: TextSpan(text: widget.text, style: style),
                      maxLines: 1,
                      textDirection: TextDirection.ltr,
                    )..layout(maxWidth: constraints.maxWidth);
                    final bool hasOverflow = textPainter.didExceedMaxLines;
                    if (!hasOverflow) {
                      return Text(
                        widget.text,
                        style: style,
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
                          style: style,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }
                  },
                ),
              ),
              if (widget.rightAlignedText != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      widget.rightAlignedText!,
                      style: const TextStyle(
                        color: ColorStyles.lightGrey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.decelerate,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (Widget child, Animation<double> animation) =>
              SizeTransition(
            sizeFactor: animation,
            axisAlignment: 1,
            child: child,
          ),
          child: isExpanded
              ? Column(
                  children: widget.children,
                )
              : null,
        ),
      ],
    );
  }
}
