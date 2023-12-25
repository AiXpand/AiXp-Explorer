import 'dart:async';

import 'package:flutter/material.dart';

import 'hf_dropdown.dart';

export 'overlay_utils.dart';

typedef DropdownButtonOnTap = void Function({bool isModal});
typedef DropdownButtonBuilder = Widget Function(
    BuildContext context, DropdownButtonOnTap onButtonTap);
typedef DropdownContentBuilder = Widget Function(
    BuildContext context, OverlayController overlay);
typedef DropdownContentShellBuilder = Widget Function(
    BuildContext context, Widget content);
typedef DropdownItemChanged<ItemType> = void Function(
    ItemType item, bool checked);
typedef DropdownItemSelected<ItemType> = void Function(ItemType item);
typedef DropdownOnClose = void Function(dynamic result);

class HFDropdown extends StatefulWidget {
  const HFDropdown({
    super.key,
    required this.buttonBuilder,
    required this.contentShellBuilder,
    required this.contentBuilder,
    this.onClose,
    this.onTapOutside,
    this.contentWidth,
    this.maxButtonWidth,
    this.maxButtonHeight,
    this.maxContentWidth,
    this.maxContentHeight,
    this.contentOffset,
    this.overlayController,
    this.targetAnchor,
    this.followerAnchor,
  });

  final double? contentWidth;
  final double? maxButtonHeight;
  final double? maxButtonWidth;
  final double? maxContentWidth;
  final double? maxContentHeight;
  final Offset? contentOffset;
  final DropdownButtonBuilder buttonBuilder;
  final DropdownContentBuilder contentBuilder;
  final DropdownContentShellBuilder contentShellBuilder;
  final DropdownOnClose? onClose;
  final OverlayController? overlayController;
  final OverlayOnTapOutside? onTapOutside;
  final Alignment? targetAnchor;
  final Alignment? followerAnchor;

  @override
  State<HFDropdown> createState() => _HFDropdownState();
}

class _HFDropdownState extends State<HFDropdown> {
  late OverlayController _overlayController;
  @override
  void initState() {
    super.initState();
    _overlayController =
        widget.overlayController ?? OverlayController('Unnamed Dropdown');
  }

  @override
  Widget build(BuildContext context) {
    return OverlayTarget(
      targetKey: _overlayController.targetKey,
      layerLink: _overlayController.layerLink,
      groupID: _overlayController.tapRegionGroupID,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: widget.maxButtonHeight ?? double.infinity,
          maxWidth: widget.maxButtonWidth ?? double.infinity,
        ),
        child: widget.buttonBuilder(
          context,
          onButtonTap,
        ),
      ),
    );
  }

  Future<void> onButtonTap({bool isModal = false}) async {
    if (!_overlayController.canOpen) {
      _overlayController.closeWithResult(null);
      return;
    }
    final dynamic returnedValue = await _overlayController.showOverlay(
      context: context,
      isModal: isModal,
      targetAnchor: widget.targetAnchor,
      followerAnchor: widget.followerAnchor,
      contentOffset: widget.contentOffset,
      width: widget.contentWidth,
      maxWidth: widget.maxContentWidth,
      maxHeight: widget.maxContentHeight,
      shellBuilder: widget.contentShellBuilder,
      contentBuilder: widget.contentBuilder,
      onTapOutside: widget.onTapOutside,
    );
    widget.onClose?.call(returnedValue);
  }
}
