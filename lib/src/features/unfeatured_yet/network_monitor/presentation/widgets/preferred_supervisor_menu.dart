import 'package:carbon_icons/carbon_icons.dart';
import 'package:e2_explorer/src/features/common_widgets/clickable_container.dart';
import 'package:e2_explorer/src/features/common_widgets/clickable_style_helper.dart';
import 'package:e2_explorer/src/features/common_widgets/hf_dropdown/overlay_utils.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:flutter/material.dart';

class PreferredSupervisorMenu extends StatefulWidget {
  const PreferredSupervisorMenu({
    super.key,
    this.height = 200,
    this.width = 250,
    required this.overlayController,
    required this.supervisors,
    required this.selectedSupervisor,
  });

  final double height;
  final double width;
  final OverlayController overlayController;
  final List<String> supervisors;
  final String selectedSupervisor;

  @override
  State<PreferredSupervisorMenu> createState() =>
      _PreferredSupervisorMenuState();
}

class _PreferredSupervisorMenuState extends State<PreferredSupervisorMenu> {
  bool isConnected = E2Client().isConnected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: ColorStyles.dark700,
          border:
              Border.all(color: ColorStyles.selectedHoverButtonBlue, width: 2),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        height: widget.height,
        width: widget.width,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListView.separated(
              itemBuilder: (context, index) {
                return ClickableContainer(
                  onTap: () {
                    widget.overlayController
                        .closeWithResult(widget.supervisors[index]);
                  },
                  height: 35,
                  style: const ClickableStyleHelper(
                    defaultColor: ColorStyles.dark700,
                    hoverColor: ColorStyles.dark600,
                  ),
                  childBuilder: (isHovered) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            widget.selectedSupervisor ==
                                    widget.supervisors[index]
                                ? CarbonIcons.checkbox_checked_filled
                                : CarbonIcons.checkbox,
                            color: widget.selectedSupervisor ==
                                    widget.supervisors[index]
                                ? Colors.blue
                                : Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.supervisors[index],
                            style: TextStyles.small(),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: 2);
              },
              itemCount: widget.supervisors.length),
        ),
      ),
    );
  }
}
