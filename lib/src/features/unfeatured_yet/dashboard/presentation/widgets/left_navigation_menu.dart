import 'package:carbon_icons/carbon_icons.dart';
import 'package:e2_explorer/src/features/common_widgets/hf_dropdown/overlay_utils.dart';
import 'package:e2_explorer/src/features/common_widgets/tooltip/icon_button_tooltip.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/dashboard/presentation/widgets/navigation/settings_menu.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/dashboard/presentation/widgets/navigation_button.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/dashboard/presentation/widgets/navigation_item.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:flutter/material.dart';

/// ToDO: Add controller to this nav menu
class LeftNavigationMenu extends StatefulWidget {
  const LeftNavigationMenu({
    super.key,
    this.navigationItems = const [],
    this.navigationIndexChanged,
  });

  final void Function(int index)? navigationIndexChanged;

  /// Might change to list<String> titles
  final List<NavigationItem> navigationItems;

  @override
  State<LeftNavigationMenu> createState() => _LeftNavigationMenuState();
}

class _LeftNavigationMenuState extends State<LeftNavigationMenu> {
  int _currentIndex = 0;
  final OverlayController _settingsOverlayController =
      OverlayController('Settings Menu');
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isExpanded ? 100 : 50,
      height: double.infinity,
      color: ColorStyles.dark750,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return NavigationButton(
                    title: widget.navigationItems[index].title,
                    isSelected: index == _currentIndex,
                    icon: widget.navigationItems[index].icon,
                    onTap: () {
                      setState(() {
                        _currentIndex = index;
                        widget.navigationIndexChanged?.call(index);
                      });
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 4);
                },
                itemCount: widget.navigationItems.length,
              ),
            ),
            SizedBox(
              height: 80,
              child: Center(
                child: OverlayTarget(
                  targetKey: _settingsOverlayController.targetKey,
                  layerLink: _settingsOverlayController.layerLink,
                  groupID: _settingsOverlayController.tapRegionGroupID,
                  child: IconButtonWithTooltip(
                    onTap: () async {
                      if (!_settingsOverlayController.canOpen) {
                        _settingsOverlayController.closeWithResult(null);
                        return;
                      }
                      const Alignment targetAnchor = Alignment.bottomRight;
                      const Alignment followerAnchor = Alignment.bottomLeft;

                      final dynamic returnedValue =
                          await _settingsOverlayController.showOverlay(
                        context: context,
                        isModal: false,
                        targetAnchor: targetAnchor,
                        followerAnchor: followerAnchor,
                        contentOffset: Offset(15, 0),
                        width: 300,
                        maxHeight: 350,

                        // maxWidth: widget.maxContentWidth,
                        // maxHeight: widget.maxContentHeight,
                        shellBuilder: (context, content) => content,
                        contentBuilder: (context, controller) {
                          return SettingsMenu(
                            overlayController: _settingsOverlayController,
                          );
                        },
                        // onTapOutside: widget.onTapOutside,
                      );
                    },
                    icon: CarbonIcons.settings,
                    tooltipMessage: 'Open Settings menu',
                    iconSize: 30,
                    foregroundColor: ColorStyles.grey,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: IconButtonWithTooltip(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                icon: isExpanded
                    ? CarbonIcons.chevron_left
                    : CarbonIcons.chevron_right,
                foregroundColor: ColorStyles.grey,
                tooltipMessage: '',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<dynamic> showOverlayOnRight({
  required BuildContext context,
  required Widget Function(BuildContext, OverlayController overlay) builder,
  OverlayController? controller,
  required GlobalKey targetKey,
  double offset = 0.0,
  double width = 200.0,
}) async {
  final LayerLink layerLink = LayerLink();
  const Alignment targetAnchor = Alignment.centerRight;
  const Alignment followerAnchor = Alignment.centerLeft;

  return showLinkedOverlay(
    context: context,
    layerLink: layerLink,
    targetAnchor: targetAnchor,
    followerAnchor: followerAnchor,
    controller: controller,
    targetKey: targetKey,
    contentOffset: Offset(offset, 0),
    width: width,
    shellBuilder: (context, content) => content,
    contentBuilder: builder,
  );
}
