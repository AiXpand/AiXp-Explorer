import 'dart:convert';

import 'package:carbon_icons/carbon_icons.dart';
import 'package:e2_explorer/src/features/common_widgets/tooltip/icon_button_tooltip.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PayloadImageViwer extends StatefulWidget {
  const PayloadImageViwer(
      {super.key, required this.base64Images, required this.hasImages});
  final List<String> base64Images;
  final bool hasImages;

  @override
  State<PayloadImageViwer> createState() => _PayloadImageViwerState();
}

class _PayloadImageViwerState extends State<PayloadImageViwer> {
  late PageController _pageController;

  int currentPage = 1;

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.containerBgColor,
      child: !widget.hasImages
          ? const Center(
              child: Text(
                'No images available',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: InteractiveViewer(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: widget.base64Images
                          .map((imageString) =>
                              Image.memory(base64Decode(imageString)))
                          .toList(),
                    ),
                  ),
                ),
                if (widget.base64Images.length > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButtonWithTooltip(
                        onTap: () async {
                          await _pageController.previousPage(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeIn,
                          );
                          setState(() {
                            if (currentPage > 1) {
                              currentPage -= 1;
                            }
                          });
                        },
                        icon: CarbonIcons.chevron_left,
                        tooltipMessage: 'Previous image',
                      ),
                      Text(
                        '${currentPage.toString()} / ${widget.base64Images.length.toString()}',
                        style: TextStyles.body(),
                      ),
                      IconButtonWithTooltip(
                        onTap: () async {
                          await _pageController.nextPage(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeIn,
                          );
                          setState(() {
                            if (currentPage < widget.base64Images.length) {
                              currentPage += 1;
                            }
                          });
                        },
                        icon: CarbonIcons.chevron_right,
                        tooltipMessage: 'Next image',
                      ),
                    ],
                  ),
              ],
            ),
    );
  }
}
