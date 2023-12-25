// ignore_for_file: prefer_const_constructors

import 'package:e2_explorer/src/features/common_widgets/clickable_container.dart';
import 'package:e2_explorer/src/features/common_widgets/clickable_style_helper.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class E2BoxItem extends StatelessWidget {
  const E2BoxItem(
      {super.key,
      required this.boxName,
      this.isSelected = false,
      required this.messageCount,
      this.onTap});

  final String boxName;
  final VoidCallback? onTap;

  final bool isSelected;

  final int messageCount;

  @override
  Widget build(BuildContext context) {
    return ClickableContainer(
      height: 40,
      style: ClickableStyleHelper(
        defaultColor: !isSelected ? ColorStyles.dark800 : Color(0xff2A3A6F),
        hoverColor: !isSelected ? ColorStyles.dark700 : Color(0xff344A9B),
      ),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              CupertinoIcons.circle_filled,
              size: 8,
              color: Colors.green,
            ),
            SizedBox(
              width: 4,
            ),
            Expanded(
              child: Text(
                boxName,
                style: TextStyle(
                  color: Color(0xff8A8A8A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: Color.fromRGBO(35, 35, 35, 1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Center(
                  child: Text(
                    '$messageCount',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
