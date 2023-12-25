import 'dart:convert';

import 'package:carbon_icons/carbon_icons.dart';
import 'package:e2_explorer/src/features/common_widgets/buttons/clickable_button.dart';
import 'package:e2_explorer/src/features/common_widgets/tooltip/icon_button_tooltip.dart';
import 'package:e2_explorer/src/features/e2_status/application/client_messages/payload_message.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/live_image_view/presentation/live_image_view_dialog.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:flutter/material.dart';

class PayloadImagePreview extends StatefulWidget {
  const PayloadImagePreview({
    super.key,
    required this.base64Images,
    required this.message,
  });

  final List<String> base64Images;
  final PayloadMessage message;

  @override
  State<PayloadImagePreview> createState() => _PayloadImagePreviewState();
}

class _PayloadImagePreviewState extends State<PayloadImagePreview> {
  late PageController _pageController;
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  void didUpdateWidget(PayloadImagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.base64Images != oldWidget.base64Images) {
      if (widget.base64Images.isNotEmpty) {
        print('yes');
        _pageController.dispose();
        _pageController = PageController();
        currentPage = 1;
        _pageController.addListener(() {
          setState(() {});
        });
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.base64Images.isEmpty) {
      return const Center(
        child: Text(
          'No images available',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    }
    return Column(
      children: [
        ClickableButton(
          onTap: () async {
            final result = await showDialog(
              context: context,
              builder: (_) => LiveImageViewDialog(
                originalMessage: widget.message,
              ),
            );
          },
          text: 'To live view',
        ),
        Expanded(
          child: InteractiveViewer(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: widget.base64Images
                  .map((imageString) => Image.memory(base64Decode(imageString)))
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
    );
  }
}
