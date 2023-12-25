import 'package:carbon_icons/carbon_icons.dart';
import 'package:e2_explorer/src/features/common_widgets/clickable_container.dart';
import 'package:e2_explorer/src/features/common_widgets/clickable_style_helper.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FilterTreeItem extends StatelessWidget {
  const FilterTreeItem({
    super.key,
    this.depth = 0,
    required this.onTap,
    required this.onCheckboxPressed,
    required this.title,
    required this.isChecked,
    required this.isExpanded,
    required this.hasChildren,
  });

  final int depth;
  final VoidCallback onTap;
  final VoidCallback onCheckboxPressed;
  final bool isExpanded;

  /// ToDO -> make this functionality disable isExpanded if no children are present
  final bool hasChildren;

  /// isChecked is a tri-state element. See the treeController definition
  /// null -> has at least 1 child, but not all children selected
  /// false -> has 0 children selected, if they exist
  /// true -> has all children selected, if they exist
  final bool? isChecked;

  final String title;

  @override
  Widget build(BuildContext context) {
    return ClickableContainer(
      height: 40,
      style: ClickableStyleHelper(
        defaultColor: isChecked == false
            ? ColorStyles.dark800
            : isChecked == true
                ? Color(0xff2A3A6F)
                : ColorStyles.dark600,
        hoverColor: isChecked == false
            ? ColorStyles.grey
            : isChecked == true
                ? Color(0xff344A9B)
                : ColorStyles.dark700,
      ),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Padding(
          padding: EdgeInsets.only(left: depth * 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (hasChildren)
                Icon(
                  isExpanded
                      ? CupertinoIcons.chevron_down
                      : CupertinoIcons.chevron_right,
                  size: 12,
                  color: Colors.white38,
                )
              else
                const SizedBox(width: 12),
              const SizedBox(
                width: 8,
              ),
              InkWell(
                onTap: onCheckboxPressed,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Icon(
                    isChecked == null
                        ? CarbonIcons.checkbox_indeterminate_filled
                        : isChecked == true
                            ? CarbonIcons.checkbox_checked_filled
                            : CarbonIcons.checkbox,
                    color: isChecked != false ? Colors.blue : Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xff8A8A8A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
