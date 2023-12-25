import 'package:carbon_icons/carbon_icons.dart';
import 'package:e2_explorer/src/features/common_widgets/clickable_container.dart';
import 'package:e2_explorer/src/features/common_widgets/clickable_style_helper.dart';
import 'package:e2_explorer/src/features/common_widgets/options_menu/options_menu.dart';
import 'package:e2_explorer/src/features/common_widgets/shape_utils.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/connection/domain/models/mqtt_server.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:flutter/material.dart';

class ServerDropdownItem extends StatefulWidget {
  const ServerDropdownItem({
    super.key,
    this.height = 45,
    this.selected = false,
    required this.server,
    this.onTap,
    this.onMenuOpen,
    this.onMenuClose,
    this.menuItems = const <BaseMenuItem>[],
  });

  final double height;
  final bool selected;
  final MqttServer server;
  final ValueChanged<bool>? onTap;
  final VoidCallback? onMenuOpen;
  final VoidCallback? onMenuClose;
  final List<BaseMenuItem> menuItems;

  @override
  State<ServerDropdownItem> createState() => _ServerDropdownItemState();
}

class _ServerDropdownItemState extends State<ServerDropdownItem> {
  bool _isHovered = false;
  bool _popupMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final bool shouldShowCheckmark =
        !((_isHovered && widget.menuItems.isNotEmpty) || _popupMenuOpen);

    return ClickableContainer(
      onTap: () {
        widget.onTap?.call(widget.selected);
      },
      onHover: (bool isHovered) {
        setState(() {
          _isHovered = isHovered;
        });
      },
      style: /* !widget.selected
          ? const ClickableStyleHelper(
              defaultColor: Color(0xff2b2b2b),
              hoverColor: Color(0xff262626),
            )
          : */
          const ClickableStyleHelper(
        defaultColor: Color(0xff262626),
        hoverColor: Color(0xff363636),
      ),
      height: widget.height,
      shapeBorder: ShapeUtilsBorder.none,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.server.name,
                    style: TextStyles.small(color: ColorStyles.lightGrey),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${widget.server.host}:${widget.server.port}',
                    style: TextStyles.caption(color: ColorStyles.lightGrey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Visibility(
              visible: widget.menuItems.isNotEmpty &&
                  (_isHovered == true || _popupMenuOpen == true),
              child: OptionsMenuButton(
                onOpenOptionBox: () {
                  debugPrint('onOpenOptionBox');
                  widget.onMenuOpen?.call();
                  _popupMenuOpen = true;
                },
                onCloseOptionBox: () {
                  debugPrint('onCloseOptionBox');
                  widget.onMenuClose?.call();

                  _popupMenuOpen = false;
                },
                borderRadius: BorderRadius.circular(8),
                items: widget.menuItems,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    CarbonIcons.overflow_menu_horizontal,
                    color: ColorStyles.light100,
                    size: 18,
                  ),
                ),
              ),
              /*PopupMenu(
                onButtonClick: () {
                  widget.onPopupOpen?.call();
                  _popupMenuOpen = true;
                },
                onClose: () {
                  widget.onPopupClose?.call();
                  _popupMenuOpen = false;
                },
              ),*/
            ),
            Visibility(
              visible: widget.selected && shouldShowCheckmark,
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  CarbonIcons.checkmark,
                  color: ColorStyles.light100,
                  size: 16,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
